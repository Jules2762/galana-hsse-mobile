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

  /// Initialise le client et recharge le token sauvegardé
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      final savedUrl = prefs.getString('api_base_url');
      if (savedUrl != null && savedUrl.isNotEmpty) {
        baseUrl = savedUrl;
        dio.options.baseUrl = baseUrl;
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

  /// Connexion utilisateur avec sauvegarde du token
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
