import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginResult {
  final bool success;
  final String? errorMessage;

  const LoginResult({required this.success, this.errorMessage});
}

class ApiClient {
  static const String defaultBaseUrl = 'http://127.0.0.1:8000/api';
  static String baseUrl = defaultBaseUrl;

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  static String? _token;
  static Map<String, dynamic>? _currentUser;
  static bool _isForcingLogout = false;
  static void Function(bool isAccountDisabled)? onSessionExpired;

  static String? get token => _token;
  static Map<String, dynamic>? get currentUser => _currentUser;
  static bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  /// Nom complet de l'utilisateur connecté pour l'affichage et les visas
  static String get currentUserName {
    if (_currentUser != null) {
      final first = _currentUser!['first_name']?.toString() ?? '';
      final last = _currentUser!['last_name']?.toString() ?? '';
      final fullName = '$first $last'.trim();
      if (fullName.isNotEmpty) return fullName;
      final name = _currentUser!['name']?.toString();
      if (name != null && name.isNotEmpty) return name;
    }
    return 'Utilisateur';
  }

  /// Vérifie si une inspection ou ressource (par nom, objet inspecteur ou ID) est attribuée à l'utilisateur connecté
  static bool isAssignedToCurrentUser(dynamic inspector, [dynamic inspectorId]) {
    if (_currentUser == null) return false;

    // 1. Si inspector est un objet Map (ex: UserResource)
    if (inspector is Map) {
      final targetId = inspector['id'] ?? inspector['user_id'];
      if (targetId != null && _currentUser!['id'] != null) {
        if (targetId.toString() == _currentUser!['id'].toString()) return true;
      }
      final targetEmail = inspector['email']?.toString().toLowerCase().trim();
      final myEmail = _currentUser!['email']?.toString().toLowerCase().trim();
      if (targetEmail != null && myEmail != null && targetEmail.isNotEmpty && targetEmail == myEmail) {
        return true;
      }
      final fn = inspector['first_name']?.toString() ?? '';
      final ln = inspector['last_name']?.toString() ?? '';
      final nameStr = '$fn $ln'.trim();
      inspector = nameStr.isNotEmpty ? nameStr : (inspector['name']?.toString() ?? '');
    }

    // 2. Comparaison directe par ID si fourni
    if (inspectorId != null && _currentUser!['id'] != null) {
      if (inspectorId.toString() == _currentUser!['id'].toString()) return true;
    }

    final String targetName = inspector?.toString().trim() ?? '';
    if (targetName.isEmpty) return false;
    final lowerTarget = targetName.toLowerCase();

    final first = _currentUser!['first_name']?.toString().toLowerCase().trim() ?? '';
    final last = _currentUser!['last_name']?.toString().toLowerCase().trim() ?? '';
    final email = _currentUser!['email']?.toString().toLowerCase().trim() ?? '';
    final name = _currentUser!['name']?.toString().toLowerCase().trim() ?? '';

    // Nom complet combiné
    if (name.isNotEmpty) {
      if (lowerTarget == name || lowerTarget.contains(name) || name.contains(lowerTarget)) return true;
    }

    if (first.isNotEmpty && last.isNotEmpty) {
      final full1 = '$first $last';
      final full2 = '$last $first';
      if (lowerTarget == full1 || lowerTarget == full2) return true;
      if (lowerTarget.contains(first) && lowerTarget.contains(last)) return true;
      if (full1.contains(lowerTarget) || full2.contains(lowerTarget)) return true;
    }
    if (first.isNotEmpty && lowerTarget.contains(first)) return true;
    if (last.isNotEmpty && lowerTarget.contains(last)) return true;

    // Recherche par parties de nom (tokens >= 3 caractères)
    final tokens = [
      ...first.split(RegExp(r'\s+')),
      ...last.split(RegExp(r'\s+')),
      ...name.split(RegExp(r'\s+')),
    ].where((t) => t.length >= 3).toList();

    for (final tok in tokens) {
      if (lowerTarget.contains(tok)) return true;
    }

    // Recherche par email ou préfixe d'email
    if (email.isNotEmpty) {
      if (lowerTarget.contains(email)) return true;
      final prefix = email.split('@').first.replaceAll('_ext', '').replaceAll('.', ' ').trim();
      if (prefix.isNotEmpty && (lowerTarget.contains(prefix) || prefix.contains(lowerTarget))) return true;
    }

    return false;
  }

  /// Initialise le client et recharge le token et l'utilisateur sauvegardés
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      final savedUrl = prefs.getString('api_base_url');
      if (savedUrl != null && savedUrl.isNotEmpty) {
        baseUrl = savedUrl;
        dio.options.baseUrl = baseUrl;
      }
      final savedUserJson = prefs.getString('current_user_data');
      if (savedUserJson != null && savedUserJson.isNotEmpty) {
        try {
          _currentUser = Map<String, dynamic>.from(jsonDecode(savedUserJson));
        } catch (_) {}
      }
      if (_token != null && _token!.isNotEmpty) {
        dio.options.headers['Authorization'] = 'Bearer $_token';
      }
    } catch (_) {}

    // Ajout d'intercepteur pour injecter automatiquement le token et détecter la déconnexion
    dio.interceptors.clear();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null && _token!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          final path = error.requestOptions.path;
          final isLoginAttempt = path.contains('/auth/login');

          if (!isLoginAttempt) {
            final statusCode = error.response?.statusCode;
            final dynamic resData = error.response?.data;
            final serverMsg = resData is Map ? resData['message']?.toString() : null;
            final serverErr = resData is Map ? resData['error']?.toString() : null;

            final isAccountDisabled = statusCode == 403 &&
                (serverMsg == '403.disabled' || serverErr == 'ACCOUNT_DISABLED');
            final isUnauthorized = statusCode == 401;

            if (isAccountDisabled || isUnauthorized) {
              forceLogout(isAccountDisabled: isAccountDisabled);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Déconnexion forcée automatique (compte désactivé ou token révoqué)
  static Future<void> forceLogout({bool isAccountDisabled = false}) async {
    if (_isForcingLogout) return;
    _isForcingLogout = true;

    _token = null;
    _currentUser = null;
    dio.options.headers.remove('Authorization');

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('current_user_data');
    } catch (_) {}

    try {
      onSessionExpired?.call(isAccountDisabled);
    } catch (_) {}

    _isForcingLogout = false;
  }

  /// Connexion utilisateur avec sauvegarde du token et des données utilisateur
  static Future<LoginResult> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        _token = data['token']?.toString();
        if (data['user'] is Map<String, dynamic>) {
          _currentUser = Map<String, dynamic>.from(data['user']);
        }

        if (_token != null && _token!.isNotEmpty) {
          dio.options.headers['Authorization'] = 'Bearer $_token';
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('auth_token', _token!);
            if (_currentUser != null) {
              await prefs.setString('current_user_data', jsonEncode(_currentUser));
            }
          } catch (_) {}
          return const LoginResult(success: true);
        }
      }
      return const LoginResult(
        success: false,
        errorMessage: 'Identifiants invalides.',
      );
    } on DioException catch (dioError) {
      String? serverMsg;
      if (dioError.response?.data is Map) {
        serverMsg = dioError.response?.data['message']?.toString();
      }

      if (dioError.response?.statusCode == 422) {
        return LoginResult(
          success: false,
          errorMessage: serverMsg ?? 'Email ou mot de passe incorrect.',
        );
      } else if (dioError.response?.statusCode == 403) {
        if (serverMsg == '403.disabled') {
          return const LoginResult(
            success: false,
            errorMessage: 'Ce compte a été désactivé. Veuillez contacter un administrateur.',
          );
        }
        return LoginResult(
          success: false,
          errorMessage: serverMsg ?? 'Accès non autorisé.',
        );
      } else if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout ||
          dioError.type == DioExceptionType.sendTimeout ||
          dioError.type == DioExceptionType.connectionError) {
        return const LoginResult(
          success: false,
          errorMessage: 'Impossible de joindre le serveur. Vérifiez votre connexion.',
        );
      }

      return LoginResult(
        success: false,
        errorMessage: serverMsg ?? 'Erreur lors de la connexion. Veuillez réessayer.',
      );
    } catch (e) {
      return LoginResult(
        success: false,
        errorMessage: 'Une erreur inattendue est survenue.',
      );
    }
  }

  /// Déconnexion
  static Future<void> logout() async {
    try {
      if (isAuthenticated) {
        await dio.post('/auth/logout');
      }
    } catch (_) {}
    _token = null;
    _currentUser = null;
    dio.options.headers.remove('Authorization');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('current_user_data');
    } catch (_) {}
  }

  /// Assure que le token et l'utilisateur sauvegardés sont initialisés
  static Future<void> ensureAuthenticated() async {
    if (isAuthenticated) return;
    await init();
  }
}