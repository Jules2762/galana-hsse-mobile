import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gestion_hsse/cores/api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Modèle représentant une opération d'inspection en attente de synchronisation
class SyncAction {
  final String id;
  final String type; // 'CHECKLIST_UPDATE', 'VMC_UPDATE', 'EQUIPMENT_UPDATE', 'ACTION_CREATE', etc.
  final String title;
  final String endpoint;
  final String method; // 'POST', 'PUT', 'PATCH', 'DELETE'
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  int retryCount;
  String status; // 'pending', 'syncing', 'failed'
  String? errorMessage;

  SyncAction({
    required this.id,
    required this.type,
    required this.title,
    required this.endpoint,
    required this.method,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.status = 'pending',
    this.errorMessage,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'endpoint': endpoint,
        'method': method,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
        'retryCount': retryCount,
        'status': status,
        'errorMessage': errorMessage,
      };

  factory SyncAction.fromJson(Map<String, dynamic> json) => SyncAction(
        id: json['id'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        endpoint: json['endpoint'] as String,
        method: json['method'] as String,
        payload: Map<String, dynamic>.from(json['payload'] as Map),
        createdAt: DateTime.parse(json['createdAt'] as String),
        retryCount: json['retryCount'] as int? ?? 0,
        status: json['status'] as String? ?? 'pending',
        errorMessage: json['errorMessage'] as String?,
      );
}

/// Moteur de synchronisation hors-ligne & auto-sync en ligne
class SyncService extends ChangeNotifier {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  static SyncService get instance => _instance;

  static const String _storageKey = 'offline_sync_queue';

  bool _isOnline = true;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  List<SyncAction> _queue = [];
  Timer? _heartbeatTimer;

  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  List<SyncAction> get queue => List.unmodifiable(_queue);
  int get pendingCount => _queue.length;

  /// Nettoie et normalise l'endpoint pour éviter les conflits avec le baseUrl de Dio
  static String cleanEndpoint(String endpoint) {
    var ep = endpoint.trim();
    if (ep.startsWith('http://') || ep.startsWith('https://')) {
      return ep;
    }
    if (ep.startsWith('/api/')) {
      ep = ep.substring(4);
    } else if (ep.startsWith('api/')) {
      ep = ep.substring(3);
    }
    if (!ep.startsWith('/')) {
      ep = '/$ep';
    }
    return ep;
  }

  /// Vérifie si une inspection spécifique a une synchronisation en attente
  bool hasPendingSyncFor(String targetId) {
    return _queue.any((action) =>
        action.endpoint.contains('/$targetId') ||
        (action.payload['id'] != null && action.payload['id'].toString() == targetId) ||
        (action.payload['tagNumber'] != null && action.payload['tagNumber'].toString() == targetId));
  }

  /// Initialisation du service (chargement file + démarrage timer)
  Future<void> init() async {
    await _loadQueueFromStorage();
    await checkConnectivity();

    // Surveillance périodique toutes les 10 secondes
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      checkConnectivity();
    });
  }

  /// Charge la file d'attente sauvegardée dans le stockage local
  Future<void> _loadQueueFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final List list = jsonDecode(raw);
        _queue = list
            .map((item) => SyncAction.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[SyncService] Erreur chargement queue: $e');
    }
  }

  /// Sauvegarde la file d'attente dans le stockage local
  Future<void> _saveQueueToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(_queue.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, raw);
    } catch (e) {
      debugPrint('[SyncService] Erreur sauvegarde queue: $e');
    }
  }

  /// Test de connectivité vers l'API backend (timeout étendu à 6s)
  Future<bool> checkConnectivity() async {
    bool wasOnline = _isOnline;
    try {
      final testDio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 6),
          receiveTimeout: const Duration(seconds: 6),
        ),
      );

      final url = '${ApiClient.baseUrl}/test';
      final response = await testDio.get(url);

      if (response.statusCode == 200) {
        _isOnline = true;
      } else {
        _isOnline = false;
      }
    } catch (_) {
      _isOnline = false;
    }

    if (wasOnline != _isOnline) {
      notifyListeners();
    }

    // Si on vient de retrouver la connexion et qu'il y a des actions en attente,
    // déclencher automatiquement la synchronisation en arrière-plan !
    if (_isOnline && _queue.isNotEmpty && !_isSyncing) {
      debugPrint('[SyncService] Connexion rétablie ! Lancement de la synchronisation automatique (${_queue.length} actions en attente)...');
      syncAll();
    }

    return _isOnline;
  }

  /// Ajoute une action d'inspection dans la file d'attente
  Future<void> queueAction(SyncAction action) async {
    // Si une action similaire existe déjà pour la même ressource, on la met à jour
    final existingIdx = _queue.indexWhere((a) => a.endpoint == action.endpoint && a.method == action.method);
    if (existingIdx != -1) {
      _queue[existingIdx] = action;
    } else {
      _queue.add(action);
    }

    await _saveQueueToStorage();
    notifyListeners();

    debugPrint('[SyncService] Action enregistrée en local : "${action.title}" (${_queue.length} en attente)');

    // Si on est en ligne, tentative d'envoi immédiat
    if (_isOnline && !_isSyncing) {
      syncAll();
    }
  }

  /// Exécute et synchronise toutes les actions en attente
  /// [manual] permet de forcer la tentative même si checkConnectivity est temporairement négatif
  Future<bool> syncAll({bool manual = false}) async {
    if (_isSyncing) return false;
    if (_queue.isEmpty) return true;

    _isSyncing = true;
    notifyListeners();

    try {
      await ApiClient.ensureAuthenticated();

      if (!manual) {
        final online = await checkConnectivity();
        if (!online) {
          _isSyncing = false;
          notifyListeners();
          return false;
        }
      }

      debugPrint('[SyncService] Démarrage de la synchronisation de ${_queue.length} action(s)...');

      final List<SyncAction> toProcess = List.from(_queue);
      int successCount = 0;

      for (final action in toProcess) {
        final success = await _executeAction(action);
        if (success) {
          successCount++;
        }
      }

      _isSyncing = false;
      _lastSyncTime = DateTime.now();
      await _saveQueueToStorage();
      notifyListeners();

      debugPrint('[SyncService] Fin du cycle de synchronisation ($successCount/${toProcess.length} réussies). Restantes: ${_queue.length}');
      return successCount > 0;
    } catch (err) {
      debugPrint('[SyncService] Erreur inattendue dans syncAll: $err');
      _isSyncing = false;
      notifyListeners();
      return false;
    }
  }

  /// Synchronise manuellement une seule action spécifique de la file d'attente
  Future<bool> syncSingleAction(String actionId) async {
    final idx = _queue.indexWhere((a) => a.id == actionId);
    if (idx == -1) return false;

    await ApiClient.ensureAuthenticated();
    final action = _queue[idx];
    return await _executeAction(action);
  }

  /// Exécute une action unitaire de synchronisation via Dio
  Future<bool> _executeAction(SyncAction action) async {
    try {
      action.status = 'syncing';
      notifyListeners();

      final targetPath = cleanEndpoint(action.endpoint);
      final options = Options(
        method: action.method,
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      );

      Response response;
      final method = action.method.toUpperCase();

      if (method == 'GET') {
        response = await ApiClient.dio.get(targetPath, options: options);
      } else if (method == 'PATCH') {
        response = await ApiClient.dio.patch(targetPath, data: action.payload, options: options);
      } else if (method == 'PUT') {
        response = await ApiClient.dio.put(targetPath, data: action.payload, options: options);
      } else if (method == 'DELETE') {
        response = await ApiClient.dio.delete(targetPath, data: action.payload, options: options);
      } else {
        response = await ApiClient.dio.post(targetPath, data: action.payload, options: options);
      }

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        debugPrint('[SyncService] Synchronisé avec succès : ${action.title}');
        _queue.removeWhere((item) => item.id == action.id);
        _isOnline = true;
        await _saveQueueToStorage();
        notifyListeners();
        return true;
      } else {
        debugPrint('[SyncService] Réponse inattendue (${response.statusCode}) pour ${action.title}');
        action.retryCount++;
        action.status = 'failed';
        action.errorMessage = 'Erreur HTTP ${response.statusCode}';
        await _saveQueueToStorage();
        notifyListeners();
        return false;
      }
    } on DioException catch (dioErr) {
      debugPrint('[SyncService] Échec réseau pour ${action.title} : ${dioErr.type}');
      final dynamic resData = dioErr.response?.data;
      String errorDesc = 'Erreur réseau (${dioErr.type.name})';

      if (resData is Map) {
        errorDesc = resData['message']?.toString() ??
            resData['error']?.toString() ??
            resData['errors']?.toString() ??
            errorDesc;
      } else if (dioErr.response?.statusMessage != null) {
        errorDesc = '${dioErr.response!.statusCode} ${dioErr.response!.statusMessage}';
      }

      action.status = 'failed';
      action.errorMessage = errorDesc;
      action.retryCount++;

      if (dioErr.type == DioExceptionType.connectionError ||
          dioErr.type == DioExceptionType.connectionTimeout ||
          dioErr.type == DioExceptionType.sendTimeout ||
          dioErr.type == DioExceptionType.receiveTimeout) {
        _isOnline = false;
      }

      await _saveQueueToStorage();
      notifyListeners();
      return false;
    } catch (err) {
      debugPrint('[SyncService] Erreur inconnue : $err');
      action.retryCount++;
      action.status = 'failed';
      action.errorMessage = err.toString();
      await _saveQueueToStorage();
      notifyListeners();
      return false;
    }
  }

  /// Supprime manuellement une action de la file
  Future<void> removeAction(String id) async {
    _queue.removeWhere((a) => a.id == id);
    await _saveQueueToStorage();
    notifyListeners();
  }

  /// Vide toute la file d'attente
  Future<void> clearQueue() async {
    _queue.clear();
    await _saveQueueToStorage();
    notifyListeners();
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    super.dispose();
  }
}
