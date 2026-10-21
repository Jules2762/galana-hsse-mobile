import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    return 'ARIMANANA Jules';
  }

  /// Vérifie si une inspection (par nom d'inspecteur ou ID) est attribuée à l'utilisateur connecté
  static bool isAssignedToCurrentUser(String? inspectorName, [dynamic inspectorId]) {
    // 1. Comparaison par ID si disponible
    if (inspectorId != null && _currentUser != null && _currentUser!['id'] != null) {
      if (inspectorId.toString() == _currentUser!['id'].toString()) return true;
    }

    final String targetName = inspectorName?.trim() ?? '';
    if (targetName.isEmpty) return false;
    final lowerTarget = targetName.toLowerCase();

    // 2. Utilisateur connecté disponible
    if (_currentUser != null) {
      final first = _currentUser!['first_name']?.toString().toLowerCase().trim() ?? '';
      final last = _currentUser!['last_name']?.toString().toLowerCase().trim() ?? '';
      final email = _currentUser!['email']?.toString().toLowerCase().trim() ?? '';

      if (first.isNotEmpty && last.isNotEmpty) {
        final full1 = '$first $last';
        final full2 = '$last $first';
        if (lowerTarget == full1 || lowerTarget == full2) return true;
        if (lowerTarget.contains(first) && lowerTarget.contains(last)) return true;
        if (full1.contains(lowerTarget) || full2.contains(lowerTarget)) return true;
      }
      if (first.isNotEmpty && lowerTarget.contains(first)) return true;
      if (last.isNotEmpty && lowerTarget.contains(last)) return true;

      if (email.isNotEmpty) {
        final prefix = email.split('@').first.replaceAll('_ext', '').replaceAll('.', ' ').trim();
        if (prefix.isNotEmpty && (lowerTarget.contains(prefix) || prefix.contains(lowerTarget))) return true;
      }
    }

    // 3. Fallback compte standard Galana (Jules Rakoto / Jules Arimanana)
    if (lowerTarget.contains('jules') || lowerTarget.contains('rakoto') || lowerTarget.contains('arimanana')) {
      return true;
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

    // Ajout d'intercepteur pour injecter automatiquement le token
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
          if (error.response?.statusCode == 401) {
            // Token expiré
            _token = null;
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Connexion utilisateur avec sauvegarde du token et des données utilisateur
  static Future<bool> login(String email, String password) async {
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

        if (_token != null) {
          dio.options.headers['Authorization'] = 'Bearer $_token';
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('auth_token', _token!);
            if (_currentUser != null) {
              await prefs.setString('current_user_data', jsonEncode(_currentUser));
            }
          } catch (_) {}
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
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

  /// Assure qu'une session valide est ouverte pour tester immédiatement
  static Future<void> ensureAuthenticated() async {
    if (isAuthenticated) return;
    await init();
    if (isAuthenticated) return;

    // Tentative de connexion par défaut automatique pour un dev fluide
    await login('julesari_ext@galana.mg', 'galana@admin*');
  }
}