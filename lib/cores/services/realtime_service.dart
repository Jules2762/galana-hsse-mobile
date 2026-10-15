import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:gestion_hsse/cores/api/api_client.dart';
import 'package:gestion_hsse/cores/services/sync_service.dart';

/// Type d'événement temps réel
enum RealtimeCategory { vmc, checklist, equipment, system, all }

/// Événement reçu en temps réel depuis l'API
class RealtimeEvent {
  final int id;
  final String category; // 'VMC', 'CHECKLIST', 'EQUIPMENT', 'SYSTEM'
  final String type;
  final String title;
  final String description;
  final Map<String, dynamic>? properties;
  final DateTime createdAt;

  RealtimeEvent({
    required this.id,
    required this.category,
    required this.type,
    required this.title,
    required this.description,
    this.properties,
    required this.createdAt,
  });

  factory RealtimeEvent.fromJson(Map<String, dynamic> json) {
    return RealtimeEvent(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      category: json['category']?.toString() ?? 'SYSTEM',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notification',
      description: json['description']?.toString() ?? '',
      properties: json['properties'] is Map ? Map<String, dynamic>.from(json['properties']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Service de synchronisation et d'écoute des événements en Temps Réel
class RealtimeService extends ChangeNotifier {
  static final RealtimeService _instance = RealtimeService._internal();
  factory RealtimeService() => _instance;
  RealtimeService._internal();

  static RealtimeService get instance => _instance;

  Timer? _pollingTimer;
  int _lastEventId = 0;
  bool _isRunning = false;
  bool _isLive = false;
  String? _latestVmcUpdate;
  String? _latestChecklistUpdate;
  String? _latestEquipmentUpdate;
  RealtimeEvent? _latestEvent;

  final StreamController<RealtimeEvent> _eventStream = StreamController<RealtimeEvent>.broadcast();

  bool get isLive => _isLive;
  RealtimeEvent? get latestEvent => _latestEvent;
  String? get latestVmcUpdate => _latestVmcUpdate;
  String? get latestChecklistUpdate => _latestChecklistUpdate;
  String? get latestEquipmentUpdate => _latestEquipmentUpdate;
  Stream<RealtimeEvent> get onEvent => _eventStream.stream;

  /// Flux filtrés par domaine pour réactivité immédiate dans les vues
  Stream<RealtimeEvent> get onVmcEvent =>
      _eventStream.stream.where((e) => e.category == 'VMC');
  Stream<RealtimeEvent> get onChecklistEvent =>
      _eventStream.stream.where((e) => e.category == 'CHECKLIST');
  Stream<RealtimeEvent> get onEquipmentEvent =>
      _eventStream.stream.where((e) => e.category == 'EQUIPMENT');

  /// Démarrage du moteur temps réel
  void start() {
    if (_isRunning) return;
    _isRunning = true;

    // Premier sondage immédiat
    _fetchUpdates();

    // Boucle réactive temps réel toutes les 2.5 secondes
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      _fetchUpdates();
    });
  }

  /// Arrêt du moteur temps réel
  void stop() {
    _pollingTimer?.cancel();
    _isRunning = false;
    _isLive = false;
    notifyListeners();
  }

  /// Déclenche un rafraîchissement temps réel forcé (ex: après une mutation locale)
  void notifyLocalChange(String category, String title, String description) {
    final event = RealtimeEvent(
      id: DateTime.now().millisecondsSinceEpoch,
      category: category.toUpperCase(),
      type: '${category.toUpperCase()}_LOCAL_MUTATION',
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );
    _latestEvent = event;
    _eventStream.add(event);
    notifyListeners();

    // Si on est en ligne, tente immédiatement de synchroniser
    SyncService.instance.syncAll();
  }

  /// Récupération des nouveautés depuis l'API Laravel
  Future<void> _fetchUpdates() async {
    // Si l'appareil est hors-ligne, on ne lance pas d'appel réseau
    if (!SyncService.instance.isOnline) {
      if (_isLive) {
        _isLive = false;
        notifyListeners();
      }
      return;
    }

    try {
      await ApiClient.ensureAuthenticated();

      final response = await ApiClient.dio.get(
        '/home/realtime/updates',
        queryParameters: {
          if (_lastEventId > 0) 'last_id': _lastEventId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        _isLive = true;

        final int newLastId = data['last_id'] is int ? data['last_id'] : 0;
        final List rawEvents = data['events'] is List ? data['events'] : [];

        // Horodatages de modifications
        if (data['latest_updates'] is Map) {
          final updates = data['latest_updates'];
          _latestVmcUpdate = updates['vmc']?.toString();
          _latestChecklistUpdate = updates['checklist']?.toString();
          _latestEquipmentUpdate = updates['equipment']?.toString();
        }

        // Si nous avons de nouveaux événements depuis le dernier ID
        if (_lastEventId > 0 && rawEvents.isNotEmpty) {
          for (final raw in rawEvents) {
            final event = RealtimeEvent.fromJson(Map<String, dynamic>.from(raw));
            _latestEvent = event;
            _eventStream.add(event);
            debugPrint('[Realtime] Événement reçu : [${event.category}] ${event.title}');
          }
        }

        if (newLastId > _lastEventId) {
          _lastEventId = newLastId;
        }

        notifyListeners();
      } else {
        _isLive = false;
        notifyListeners();
      }
    } catch (_) {
      _isLive = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _eventStream.close();
    super.dispose();
  }
}
