import 'package:gestion_hsse/cores/api/api_client.dart';
import 'package:gestion_hsse/cores/services/offline_storage_service.dart';
import 'package:gestion_hsse/cores/services/sync_service.dart';
import 'package:gestion_hsse/views/home/inspection/checklist/checklist_list_view.dart';

class ChecklistService {
  static const List<ChecklistItemData> _defaultChecklists = [
    ChecklistItemData(
      id: 1,
      title: "Inspection Sécurité Incendie",
      site: "Dépôt Antsirabe",
      inspector: "Jules Rakoto",
      date: "14 Oct 2026",
      progress: 0.65,
      status: "En cours",
    ),
    ChecklistItemData(
      id: 2,
      title: "Audit EPI & Protections Terrain",
      site: "Terminal Toamasina",
      inspector: "Marie Razafi",
      date: "12 Oct 2026",
      progress: 1.0,
      status: "Terminée",
    ),
    ChecklistItemData(
      id: 3,
      title: "Contrôle Stockage Carburant & Bacs",
      site: "Station Majunga",
      inspector: "Jules Rakoto",
      date: "10 Oct 2026",
      progress: 0.12,
      status: "En cours",
    ),
    ChecklistItemData(
      id: 4,
      title: "Inspection Environnementale & Déchets",
      site: "Dépôt Ivato",
      inspector: "Alain Rajaona",
      date: "05 Oct 2026",
      progress: 0.0,
      status: "Planifiée",
    ),
  ];

  /// Récupère la liste des checklists (API en ligne ou stockage hors-ligne)
  static Future<List<ChecklistItemData>> getChecklists({
    String? search,
    String? status,
  }) async {
    // 1. Tentative en ligne via l'API
    try {
      await ApiClient.ensureAuthenticated();
      final response = await ApiClient.dio.get('/home/checklists/checklists');

      if (response.statusCode == 200 && response.data != null) {
        final rawData = response.data['data'] ?? response.data;
        if (rawData is List && rawData.isNotEmpty) {
          final items = rawData.map<ChecklistItemData>((json) {
            final m = Map<String, dynamic>.from(json);
            final id = m['id'];
            final title = m['title']?.toString() ?? 'Inspection';
            final site = m['site']?.toString() ?? 'Galana Site';
            final inspectorObj = m['inspector'];
            final inspector = inspectorObj is Map
                ? "${inspectorObj['first_name'] ?? ''} ${inspectorObj['last_name'] ?? ''}".trim()
                : (m['inspector']?.toString() ?? 'Inspecteur Galana');
            final date = m['date']?.toString() ?? '14 Oct 2026';
            final statusStr = m['status']?.toString() ?? 'En cours';
            double progress = 0.5;
            if (statusStr.toLowerCase().contains('termin') || statusStr == 'COMPLETED') {
              progress = 1.0;
            } else if (statusStr.toLowerCase().contains('planif')) {
              progress = 0.0;
            }

            return ChecklistItemData(
              id: id,
              title: title,
              site: site,
              inspector: inspector.isNotEmpty ? inspector : 'Inspecteur HSSE',
              date: date,
              progress: progress,
              status: statusStr == 'COMPLETED' ? 'Terminée' : statusStr,
            );
          }).toList();

          await OfflineStorageService.cacheChecklists(items);
          return _filterList(items, search, status);
        }
      }
    } catch (_) {}

    // 2. Repli hors-ligne depuis le cache local
    final cached = await OfflineStorageService.getCachedChecklists();
    if (cached.isNotEmpty) {
      return _filterList(cached, search, status);
    }

    // 3. Premier démarrage hors-ligne : initialisation avec données de référence
    await OfflineStorageService.cacheChecklists(_defaultChecklists);
    return _filterList(_defaultChecklists, search, status);
  }

  static List<ChecklistItemData> _filterList(
    List<ChecklistItemData> list,
    String? search,
    String? status,
  ) {
    return list.where((item) {
      if (search != null && search.trim().isNotEmpty) {
        final q = search.toLowerCase();
        final match = item.title.toLowerCase().contains(q) ||
            item.site.toLowerCase().contains(q) ||
            item.inspector.toLowerCase().contains(q);
        if (!match) return false;
      }
      if (status != null && status.isNotEmpty && !status.toLowerCase().contains('tous')) {
        return item.status.toLowerCase() == status.toLowerCase();
      }
      return true;
    }).toList();
  }

  /// Récupère le détail complet d'une Checklist (API ou cache hors-ligne)
  static Future<Map<String, dynamic>?> getChecklistDetail(dynamic id) async {
    try {
      await ApiClient.ensureAuthenticated();
      final response = await ApiClient.dio.get('/home/checklists/checklists/$id');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] ?? response.data;
        if (data is Map<String, dynamic>) {
          await OfflineStorageService.cacheChecklistDetail(id, data);
          return data;
        }
      }
    } catch (_) {}

    // Repli hors-ligne
    return await OfflineStorageService.getCachedChecklistDetail(id);
  }

  /// Met à jour le statut d'une checklist
  static Future<bool> updateStatus(dynamic id, String status) async {
    String apiStatus = status;
    final lower = status.toLowerCase();
    if (lower.contains('clôtur') || lower.contains('clotur') || lower == 'completed' || lower == 'terminée') {
      apiStatus = 'COMPLETED';
    } else if (lower.contains('cours') || lower == 'in_progress') {
      apiStatus = 'IN_PROGRESS';
    } else if (lower.contains('planif') || lower == 'draft') {
      apiStatus = 'DRAFT';
    }

    final checklistId = id?.toString() ?? '1';
    final action = SyncAction(
      id: 'checklist_status_${checklistId}_${DateTime.now().millisecondsSinceEpoch}',
      type: 'CHECKLIST_STATUS',
      title: 'Mise à jour statut Checklist #$checklistId ($apiStatus)',
      endpoint: '/home/checklists/checklists/$checklistId',
      method: 'PUT',
      payload: {'status': apiStatus},
      createdAt: DateTime.now(),
    );

    await SyncService.instance.queueAction(action);
    return true;
  }

  /// Sauvegarde des données d'évaluation de la checklist
  static Future<bool> updateChecklist(dynamic id, Map<String, dynamic> payload) async {
    final current = await OfflineStorageService.getCachedChecklistDetail(id) ?? {};
    current.addAll(payload);
    await OfflineStorageService.cacheChecklistDetail(id, current);

    final checklistId = id?.toString() ?? '1';
    final action = SyncAction(
      id: 'checklist_eval_${checklistId}_${DateTime.now().millisecondsSinceEpoch}',
      type: 'CHECKLIST_UPDATE',
      title: 'Évaluation Checklist #$checklistId',
      endpoint: '/home/checklists/checklists/$checklistId',
      method: 'PUT',
      payload: payload,
      createdAt: DateTime.now(),
    );

    await SyncService.instance.queueAction(action);
    return true;
  }

  /// Clôture d'une checklist avec persistance hors-ligne et auto-synchro en ligne
  static Future<bool> completeChecklist(
    ChecklistItemData item, {
    Map<String, dynamic>? answers,
  }) async {
    final updated = ChecklistItemData(
      id: item.id,
      title: item.title,
      site: item.site,
      inspector: item.inspector,
      date: "Aujourd'hui (14 Oct 2026)",
      progress: 1.0,
      status: "Terminée",
    );

    // 1. Sauvegarde immédiate en mode hors-ligne
    await OfflineStorageService.updateCachedChecklist(updated);

    // 2. Enfilement dans la file de synchronisation automatique avec ID réel
    final checklistId = item.id != null ? item.id.toString() : '1';
    final action = SyncAction(
      id: 'checklist_complete_${checklistId}_${DateTime.now().millisecondsSinceEpoch}',
      type: 'CHECKLIST_UPDATE',
      title: 'Clôture Checklist "${item.title}"',
      endpoint: '/home/checklists/checklists/$checklistId',
      method: 'PUT',
      payload: {
        'title': item.title,
        'site': item.site,
        'status': 'COMPLETED',
        'completed_at': DateTime.now().toIso8601String(),
        'answers': answers ?? {},
      },
      createdAt: DateTime.now(),
    );

    await SyncService.instance.queueAction(action);
    return true;
  }
}
