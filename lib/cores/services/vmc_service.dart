import 'package:gestion_hsse/cores/api/api_client.dart';
import 'package:gestion_hsse/cores/services/offline_storage_service.dart';
import 'package:gestion_hsse/cores/services/sync_service.dart';
import 'package:gestion_hsse/views/home/inspection/vmc/vmc_list_view.dart';

class VmcService {
  /// Récupère la liste des VMC depuis l'API backend ou le cache hors-ligne
  static Future<List<VmcItemData>> getVmcs({
    String? type,
    String? status,
    String? search,
    int page = 1,
  }) async {
    // Tentative de récupération en ligne
    try {
      await ApiClient.ensureAuthenticated();

      final Map<String, dynamic> queryParams = {
        'page': page,
      };

      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      if (type != null && type.isNotEmpty && !type.toLowerCase().contains('tous')) {
        String apiType = type;
        if (type.contains('Station-Service') || type.contains('SS')) {
          apiType = 'STATION SERVICE';
        } else if (type.contains('Inspection Camion') || type.contains('CC')) {
          apiType = 'INSPECTION CAMION';
        } else if (type.contains('Magasins & Agences')) {
          apiType = 'VISITE MAGASINS & AGENCES';
        } else if (type.contains('Safety Moment')) {
          apiType = 'SAFETY MOMENT';
        } else if (type.contains('Safety Awareness')) {
          apiType = 'SAFETY AWARENESS';
        } else if (type.contains('Fiche de Remontée') || type.contains('Report')) {
          apiType = 'SAFETY REPORT';
        }
        queryParams['type'] = apiType;
      }

      if (status != null && status.isNotEmpty && !status.toLowerCase().contains('tous')) {
        String apiStatus = status;
        if (status.toLowerCase().contains('cours')) {
          apiStatus = 'IN_PROGRESS';
        } else if (status.toLowerCase().contains('clôtur') || status.toLowerCase().contains('clotur')) {
          apiStatus = 'COMPLETED';
        } else if (status.toLowerCase().contains('brouillon')) {
          apiStatus = 'DRAFT';
        }
        queryParams['status'] = apiStatus;
      }

      final response = await ApiClient.dio.get(
        '/home/vmcs',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final rawData = response.data['data'];
        if (rawData is List) {
          final items = rawData
              .map((json) => VmcItemData.fromJson(Map<String, dynamic>.from(json)))
              .toList();

          // Sauvegarde automatique dans le cache local
          if (items.isNotEmpty && (search == null || search.isEmpty) && (type == null || type.contains('tous'))) {
            await OfflineStorageService.cacheVmcs(items);
          }
          return items;
        }
      }
    } catch (_) {
      // En cas de panne ou hors-ligne, on bascule silencieusement sur le cache
    }

    // ==========================================
    // REPLI HORS-LIGNE : Lecture du cache local
    // ==========================================
    final cached = await OfflineStorageService.getCachedVmcs();
    if (cached.isNotEmpty) {
      return cached.where((item) {
        if (search != null && search.trim().isNotEmpty) {
          final q = search.toLowerCase();
          final matches = item.title.toLowerCase().contains(q) ||
              item.site.toLowerCase().contains(q) ||
              item.inspector.toLowerCase().contains(q);
          if (!matches) return false;
        }
        if (status != null && status.isNotEmpty && !status.toLowerCase().contains('tous')) {
          final q = status.toLowerCase();
          if (q.contains('cours') && !item.status.toLowerCase().contains('cours') && item.status != 'IN_PROGRESS') {
            return false;
          }
          if ((q.contains('clôtur') || q.contains('clotur')) &&
              !item.status.toLowerCase().contains('clôtur') &&
              item.status != 'COMPLETED') {
            return false;
          }
        }
        return true;
      }).toList();
    }

    return [];
  }

  /// Récupère le détail complet d'une VMC par son identifiant
  static Future<Map<String, dynamic>?> getVmcDetail(int id) async {
    try {
      await ApiClient.ensureAuthenticated();
      final response = await ApiClient.dio.get('/home/vmcs/$id');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] ?? response.data;
        if (data is Map<String, dynamic>) {
          await OfflineStorageService.cacheVmcDetail(id, data);
          return data;
        }
      }
    } catch (_) {}

    // Repli cache local
    return await OfflineStorageService.getCachedVmcDetail(id);
  }

  /// Met à jour le statut d'une VMC (ex: IN_PROGRESS -> COMPLETED)
  /// Enregistre instantanément en local et enfile l'auto-synchronisation en ligne
  static Future<bool> updateStatus(int id, String status) async {
    String apiStatus = status;
    final lower = status.toLowerCase();
    if (lower.contains('clôtur') || lower.contains('clotur') || lower == 'completed') {
      apiStatus = 'COMPLETED';
    } else if (lower.contains('cours') || lower == 'in_progress') {
      apiStatus = 'IN_PROGRESS';
    } else if (lower.contains('annul') || lower == 'cancelled') {
      apiStatus = 'CANCELLED';
    }

    // 1. Mettre à jour immédiatement le stockage hors-ligne
    await OfflineStorageService.updateCachedVmcStatus(id, apiStatus);

    // 2. Mettre en file d'attente l'action de synchronisation
    final action = SyncAction(
      id: 'vmc_status_${id}_${DateTime.now().millisecondsSinceEpoch}',
      type: 'VMC_STATUS',
      title: 'Clôture VMC #$id ($apiStatus)',
      endpoint: '/home/vmcs/$id/status',
      method: 'PATCH',
      payload: {'status': apiStatus},
      createdAt: DateTime.now(),
    );

    await SyncService.instance.queueAction(action);
    return true;
  }

  /// Sauvegarde des données d'évaluation de la VMC
  /// Enregistre instantanément en local et enfile l'auto-synchronisation en ligne
  static Future<bool> updateVmc(int id, Map<String, dynamic> payload) async {
    // 1. Mettre à jour le détail en cache
    final current = await OfflineStorageService.getCachedVmcDetail(id) ?? {};
    current.addAll(payload);
    await OfflineStorageService.cacheVmcDetail(id, current);

    // 2. Mettre en file d'attente l'action de synchronisation
    final action = SyncAction(
      id: 'vmc_update_${id}_${DateTime.now().millisecondsSinceEpoch}',
      type: 'VMC_UPDATE',
      title: 'Mise à jour données VMC #$id',
      endpoint: '/home/vmcs/$id',
      method: 'PUT',
      payload: payload,
      createdAt: DateTime.now(),
    );

    await SyncService.instance.queueAction(action);
    return true;
  }

  /// Récupère les options de filtres dynamiques depuis l'API
  static Future<Map<String, dynamic>?> getFilters() async {
    try {
      await ApiClient.ensureAuthenticated();
      final response = await ApiClient.dio.get('/home/vmcs/filters');
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
    } catch (_) {}
    return null;
  }
}
