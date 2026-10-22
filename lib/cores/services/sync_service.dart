import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gestion_hsse/cores/api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Modèle représentant une opération d'inspection en attente de synchronisation
class SyncAction {
  final String id;
  final String type; // 'VMC_STATUS', 'VMC_UPDATE', 'CHECKLIST_UPDATE', 'EQUIPMENT_UPDATE'
  final String title;
  final String endpoint;
  final String method; // 'POST', 'PUT', 'PATCH'
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

    // Surveillance périodique toutes les 7 secondes
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 7), (_) {
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

  /// Test de connectivité vers l'API backend
  Future<bool> checkConnectivity() async {
    bool wasOnline = _isOnline;
    try {
      // On teste un endpoint léger avec un timeout très court (3s)
      final testDio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
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
  Future<void> syncAll() async {
    if (_isSyncing || _queue.isEmpty) return;

    _isSyncing = true;
    notifyListeners();

    // S'assurer de l'authentification
    await ApiClient.ensureAuthenticated();
    if (!ApiClient.isAuthenticated) {
      _isSyncing = false;
      notifyListeners();
      return;
    }

    // Re-vérifier l'état de la connexion
    final online = await checkConnectivity();
    if (!online) {
      _isSyncing = false;
      notifyListeners();
      return;
    }

    debugPrint('[SyncService] Démarrage de la synchronisation de ${_queue.length} action(s)...');

    // On copie la liste pour itérer proprement
    final List<SyncAction> toProcess = List.from(_queue);

    for (final action in toProcess) {
      try {
        action.status = 'syncing';
        notifyListeners();

        Response response;
        final options = Options(method: action.method);

        if (action.method.toUpperCase() == 'GET') {
          response = await ApiClient.dio.get(action.endpoint, options: options);
        } else if (action.method.toUpperCase() == 'PATCH') {
          response = await ApiClient.dio.patch(action.endpoint, data: action.payload, options: options);
        } else if (action.method.toUpperCase() == 'PUT') {
          response = await ApiClient.dio.put(action.endpoint, data: action.payload, options: options);
        } else if (action.method.toUpperCase() == 'DELETE') {
          response = await ApiClient.dio.delete(action.endpoint, data: action.payload, options: options);
        } else {
          response = await ApiClient.dio.post(action.endpoint, data: action.payload, options: options);
        }

        if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
          debugPrint('[SyncService] Synchronisé avec succès : ${action.title}');
          _queue.removeWhere((item) => item.id == action.id);
          await _saveQueueToStorage();
        } else {
          debugPrint('[SyncService] Réponse inattendue (${response.statusCode}) pour ${action.title}');
          action.retryCount++;
          action.status = 'failed';
          action.errorMessage = 'Erreur HTTP ${response.statusCode}';
        }
      } on DioException catch (dioErr) {
        debugPrint('[SyncService] Échec réseau pour ${action.title} : ${dioErr.type}');
        // Si c'est une déconnexion ou timeout, on interrompt le cycle et attend la reconnexion
        if (dioErr.type == DioExceptionType.connectionError ||
            dioErr.type == DioExceptionType.connectionTimeout ||
            dioErr.type == DioExceptionType.sendTimeout ||
            dioErr.type == DioExceptionType.receiveTimeout) {
          _isOnline = false;
          action.status = 'pending';
          break; // Sortir de la boucle, le prochain battement reprendra
        } else if (dioErr.response?.statusCode == 404 || dioErr.response?.statusCode == 422) {
          // Erreur de validation ou ressource déjà traitée : on évite le blocage infini
          action.retryCount++;
          if (action.retryCount >= 3) {
            _queue.removeWhere((item) => item.id == action.id);
            await _saveQueueToStorage();
          }
        }
      } catch (err) {
        debugPrint('[SyncService] Erreur inconnue : $err');
        action.retryCount++;
        action.status = 'failed';
      }
    }

    _isSyncing = false;
    _lastSyncTime = DateTime.now();
    await _saveQueueToStorage();
    notifyListeners();

    debugPrint('[SyncService] Fin du cycle de synchronisation. Actions restantes: ${_queue.length}');
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
