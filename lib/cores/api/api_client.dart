import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:gestion_hsse/cores/services/onesignal_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginResult {
  final bool success;
  final String? errorMessage;

  const LoginResult({required this.success, this.errorMessage});
}

class ApiClient {
  static const String defaultBaseUrl = 'http://192.168.1.188:8000/api';
  static String baseUrl = defaultBaseUrl;

  /// Modifie dynamiquement l'URL de base de l'API (ex: changement d'adresse IP WiFi)
  static Future<void> setBaseUrl(String newUrl) async {
    var url = newUrl.trim();
    if (url.isEmpty) return;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }
    if (!url.endsWith('/api')) {
      if (url.endsWith('/')) {
        url = '${url}api';
      } else {
        url = '$url/api';
      }
    }
    baseUrl = url;
    dio.options.baseUrl = baseUrl;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_base_url', baseUrl);
    } catch (_) {}
  }

  /// Réinitialise l'URL de base à sa valeur par défaut
  static Future<void> resetBaseUrl() async {
    baseUrl = defaultBaseUrl;
    dio.options.baseUrl = baseUrl;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('api_base_url');
    } catch (_) {}
  }

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
  static String? _refreshToken;
  static Map<String, dynamic>? _currentUser;
  static bool _isForcingLogout = false;
  static bool _isRefreshing = false;
  static void Function(bool isAccountDisabled)? onSessionExpired;

  static String? get token => _token;
  static String? get refreshToken => _refreshToken;
  static Map<String, dynamic>? get currentUser => _currentUser;
  static bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  /// Vérifie si l'utilisateur connecté est Administrateur
  static bool get isAdmin {
    if (_currentUser == null) return false;
    if (_currentUser!['isAdmin'] == true) return true;
    final role = _currentUser!['role']?.toString().toUpperCase();
    if (role == 'ADMIN') return true;
    final roles = _currentUser!['roles'];
    if (roles is List && roles.any((r) => r.toString().toUpperCase() == 'ADMIN')) {
      return true;
    }
    return false;
  }

  /// Liste des permissions de l'utilisateur connecté
  static List<String> get userPermissions {
    if (_currentUser == null) return [];
    final perms = _currentUser!['permissions'];
    if (perms is List) {
      return perms.map((p) => p.toString()).toList();
    }
    return [];
  }

  /// Vérifie si l'utilisateur possède une permission spécifique
  static bool hasPermission(String permission) {
    if (isAdmin) return true;
    return userPermissions.contains(permission);
  }

  /// Vérifie si l'utilisateur possède au moins une des permissions fournies
  static bool hasAnyPermission(List<String> permissions) {
    if (isAdmin) return true;
    final userPerms = userPermissions;
    return permissions.any((p) => userPerms.contains(p));
  }

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
      _refreshToken = prefs.getString('refresh_token');
      final savedUrl = prefs.getString('api_base_url');
      if (savedUrl != null && savedUrl.isNotEmpty) {
        baseUrl = savedUrl;
        dio.options.baseUrl = baseUrl;
      }
      final savedUserJson = prefs.getString('current_user_data');
      if (savedUserJson != null && savedUserJson.isNotEmpty) {
        try {
          _currentUser = Map<String, dynamic>.from(jsonDecode(savedUserJson));
          if (_currentUser != null && _currentUser!['id'] != null) {
            OneSignalService.instance.login(_currentUser!['id']);
          }
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
        onError: (DioException error, handler) async {
          final path = error.requestOptions.path;
          final isAuthEndpoint = path.contains('/auth/login') || path.contains('/auth/refresh');

          if (!isAuthEndpoint) {
            final statusCode = error.response?.statusCode;
            final dynamic resData = error.response?.data;
            final serverMsg = resData is Map ? resData['message']?.toString() : null;
            final serverErr = resData is Map ? resData['error']?.toString() : null;

            final isAccountDisabled = statusCode == 403 &&
                (serverMsg == '403.disabled' || serverErr == 'ACCOUNT_DISABLED');
            final isUnauthorized = statusCode == 401;

            if (isAccountDisabled) {
              forceLogout(isAccountDisabled: true);
              return handler.next(error);
            }

            // Tentative de rafraîchissement transparent du jeton d'accès via le refresh token
            if (isUnauthorized && _refreshToken != null && !_isRefreshing) {
              _isRefreshing = true;
              try {
                final refreshDio = Dio(
                  BaseOptions(
                    baseUrl: baseUrl,
                    connectTimeout: const Duration(seconds: 10),
                    receiveTimeout: const Duration(seconds: 10),
                    headers: {
                      'Accept': 'application/json',
                      'Content-Type': 'application/json',
                    },
                  ),
                );

                final refreshRes = await refreshDio.post(
                  '/auth/refresh',
                  data: {'refresh_token': _refreshToken},
                );

                if (refreshRes.statusCode == 200 && refreshRes.data != null) {
                  final rData = refreshRes.data;
                  final newAccess = rData['access_token']?.toString() ?? rData['token']?.toString();
                  final newRefresh = rData['refresh_token']?.toString();

                  if (newAccess != null && newAccess.isNotEmpty) {
                    _token = newAccess;
                    if (newRefresh != null && newRefresh.isNotEmpty) {
                      _refreshToken = newRefresh;
                    }
                    dio.options.headers['Authorization'] = 'Bearer $_token';

                    try {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('auth_token', _token!);
                      if (_refreshToken != null) {
                        await prefs.setString('refresh_token', _refreshToken!);
                      }
                    } catch (_) {}

                    _isRefreshing = false;

                    // Rejouer la requête initiale avec le nouveau jeton d'accès
                    final retryOptions = error.requestOptions;
                    retryOptions.headers['Authorization'] = 'Bearer $_token';
                    try {
                      final clonedResponse = await dio.fetch(retryOptions);
                      return handler.resolve(clonedResponse);
                    } catch (retryError) {
                      if (retryError is DioException) {
                        return handler.next(retryError);
                      }
                    }
                  }
                }
              } catch (_) {
                // Échec du rafraîchissement
              } finally {
                _isRefreshing = false;
              }

              forceLogout(isAccountDisabled: false);
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
    _refreshToken = null;
    _currentUser = null;
    dio.options.headers.remove('Authorization');

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('refresh_token');
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
        _token = data['access_token']?.toString() ?? data['token']?.toString();
        _refreshToken = data['refresh_token']?.toString();
        if (data['user'] is Map<String, dynamic>) {
          _currentUser = Map<String, dynamic>.from(data['user']);
        }

        if (_token != null && _token!.isNotEmpty) {
          dio.options.headers['Authorization'] = 'Bearer $_token';
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('auth_token', _token!);
            if (_refreshToken != null && _refreshToken!.isNotEmpty) {
              await prefs.setString('refresh_token', _refreshToken!);
            }
            if (_currentUser != null) {
              await prefs.setString('current_user_data', jsonEncode(_currentUser));
              if (_currentUser!['id'] != null) {
                OneSignalService.instance.login(_currentUser!['id']);
              }
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
      await OneSignalService.instance.logout();
    } catch (_) {}
    try {
      if (isAuthenticated) {
        await dio.post('/auth/logout', data: {
          if (_refreshToken != null) 'refresh_token': _refreshToken,
        });
      }
    } catch (_) {}
    _token = null;
    _refreshToken = null;
    _currentUser = null;
    dio.options.headers.remove('Authorization');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('refresh_token');
      await prefs.remove('current_user_data');
    } catch (_) {}
  }

  /// Assure que le token et l'utilisateur sauvegardés sont initialisés
  static Future<void> ensureAuthenticated() async {
    if (isAuthenticated) return;
    await init();
  }

  /// Recharge les informations à jour du profil utilisateur depuis le serveur
  static Future<Map<String, dynamic>?> fetchCurrentUser() async {
    try {
      await ensureAuthenticated();
      final response = await dio.get('/profile');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] ?? response.data;
        if (data is Map<String, dynamic>) {
          _currentUser = data;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('current_user_data', jsonEncode(_currentUser));
          return _currentUser;
        }
      }
    } catch (_) {}
    return _currentUser;
  }

  /// Met à jour localement les données utilisateur
  static Future<void> updateCurrentUser(Map<String, dynamic> data) async {
    _currentUser = {
      ...?_currentUser,
      ...data,
    };
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user_data', jsonEncode(_currentUser));
    } catch (_) {}
  }
}