import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gestion_hsse/cores/api/api_client.dart';
import 'package:gestion_hsse/cores/services/offline_storage_service.dart';
import 'package:gestion_hsse/cores/services/sync_service.dart';
import 'package:gestion_hsse/views/home/inspection/equipment/equipment_list_view.dart';

class EquipmentService {
  static const List<EquipmentMonitoringData> _defaultMonitorings = [
    EquipmentMonitoringData(
      id: 1,
      reference: "#EQ-1",
      siteName: "Station Majunga",
      date: "15 Oct 2026",
      status: "En cours",
      rawStatus: "IN_PROGRESS",
      inspector: "Jules Rakoto",
      conformityRate: 75.0,
      initialConformityRate: 75.0,
      observations: "Inspection périodique terrain en cours.",
      items: [
        EquipmentItemData(
          id: 101,
          monitoringId: 1,
          tagNumber: "EXT-P50-01",
          designation: "Extincteur 50kg Poudre sur roues",
          type: "Extincteur P50",
          site: "Station Majunga",
          location: "Îlot B - Pompes Gasoil",
          lastControlDate: "15 Oct 2026",
          nextDueDate: "15 Nov 2026",
          status: "Conforme",
          pressureStatus: "Normal (14 bars)",
          conformity: true,
          comment: "Pression conforme, goupille scellée",
        ),
        EquipmentItemData(
          id: 102,
          monitoringId: 1,
          tagNumber: "EXT-P9-02",
          designation: "Extincteur Portatif 9kg ABC",
          type: "Extincteur P9",
          site: "Station Majunga",
          location: "Boutique & Caisse",
          lastControlDate: "15 Oct 2026",
          nextDueDate: "15 Nov 2026",
          status: "Conforme",
          pressureStatus: "Normal (12 bars)",
          conformity: true,
          comment: "Accès dégagé, signalétique en place",
        ),
        EquipmentItemData(
          id: 103,
          monitoringId: 1,
          tagNumber: "EXT-CO2-01",
          designation: "Extincteur CO2 5kg",
          type: "Extincteur CO2",
          site: "Station Majunga",
          location: "Local Technique TGBT",
          lastControlDate: "15 Oct 2026",
          nextDueDate: "15 Nov 2026",
          status: "Non-conforme",
          pressureStatus: "Contrôle requis",
          conformity: false,
          comment: "Goupille plastique endommagée à remplacer",
        ),
        EquipmentItemData(
          id: 104,
          monitoringId: 1,
          tagNumber: "BAC-RET-01",
          designation: "Bac de Rétention Hydrocarbures",
          type: "Cuves & Bacs",
          site: "Station Majunga",
          location: "Zone Dépotage Camions",
          lastControlDate: "15 Oct 2026",
          nextDueDate: "15 Nov 2026",
          status: "Conforme",
          pressureStatus: "Étanche",
          conformity: true,
          comment: "Propre et sec, vanne fermée",
        ),
      ],
    ),
    EquipmentMonitoringData(
      id: 2,
      reference: "#EQ-2",
      siteName: "Terminal Toamasina",
      date: "12 Oct 2026",
      status: "Clôturée",
      rawStatus: "COMPLETED",
      inspector: "Marie Razafi",
      conformityRate: 100.0,
      initialConformityRate: 100.0,
      observations: "Inspection de conformité complète effectuée avec succès.",
      items: [
        EquipmentItemData(
          id: 201,
          monitoringId: 2,
          tagNumber: "EXT-P50-02",
          designation: "Extincteur 50kg Poudre sur roues",
          type: "Extincteur P50",
          site: "Terminal Toamasina",
          location: "Poste Chargement Sud",
          lastControlDate: "12 Oct 2026",
          nextDueDate: "12 Nov 2026",
          status: "Conforme",
          pressureStatus: "Normal (14 bars)",
          conformity: true,
        ),
        EquipmentItemData(
          id: 202,
          monitoringId: 2,
          tagNumber: "RIA-01",
          designation: "Robinet d'Incendie Armé DN 25",
          type: "RIA",
          site: "Terminal Toamasina",
          location: "Hall d'accueil",
          lastControlDate: "12 Oct 2026",
          nextDueDate: "12 Nov 2026",
          status: "Conforme",
          pressureStatus: "Normal (7 bars)",
          conformity: true,
        ),
        EquipmentItemData(
          id: 203,
          monitoringId: 2,
          tagNumber: "BAC-RET-02",
          designation: "Bac de Rétention 1200L",
          type: "Cuves & Bacs",
          site: "Terminal Toamasina",
          location: "Parc à fûts",
          lastControlDate: "12 Oct 2026",
          nextDueDate: "12 Nov 2026",
          status: "Conforme",
          pressureStatus: "Étanche",
          conformity: true,
        ),
      ],
    ),
    EquipmentMonitoringData(
      id: 3,
      reference: "#EQ-3",
      siteName: "Dépôt Ivato",
      date: "16 Oct 2026",
      status: "Planifiée",
      rawStatus: "DRAFT",
      inspector: "ARIMANANA Jules",
      conformityRate: 100.0,
      initialConformityRate: 100.0,
      observations: "Session planifiée - Les matériels seront contrôlés sur le terrain.",
      items: [],
    ),
    EquipmentMonitoringData(
      id: 4,
      reference: "#EQ-4",
      siteName: "Dépôt Antsirabe",
      date: "05 Oct 2026",
      status: "Clôturée",
      rawStatus: "COMPLETED",
      inspector: "Jules Rakoto",
      conformityRate: 80.0,
      initialConformityRate: 80.0,
      observations: "Contrôle mensuel régulier.",
      items: [
        EquipmentItemData(
          id: 401,
          monitoringId: 4,
          tagNumber: "EXT-P9-10",
          designation: "Extincteur Portatif 9kg Poudre",
          type: "Extincteur P9",
          site: "Dépôt Antsirabe",
          location: "Atelier Mécanique",
          lastControlDate: "05 Oct 2026",
          nextDueDate: "20 Oct 2026",
          status: "Conforme",
          pressureStatus: "Normal",
          conformity: true,
        ),
        EquipmentItemData(
          id: 402,
          monitoringId: 4,
          tagNumber: "EXT-P6-01",
          designation: "Extincteur 6kg Eau Pulvérisée",
          type: "Extincteur P6",
          site: "Dépôt Antsirabe",
          location: "Bureaux Administratifs",
          lastControlDate: "05 Oct 2026",
          nextDueDate: "20 Oct 2026",
          status: "Conforme",
          pressureStatus: "Normal",
          conformity: true,
        ),
        EquipmentItemData(
          id: 403,
          monitoringId: 4,
          tagNumber: "RIA-02",
          designation: "Robinet d'Incendie Armé",
          type: "RIA",
          site: "Dépôt Antsirabe",
          location: "Zone Stockage",
          lastControlDate: "05 Oct 2026",
          nextDueDate: "20 Oct 2026",
          status: "Non-conforme",
          pressureStatus: "Fuite joint",
          conformity: false,
          comment: "Joint à remplacer sur lance",
        ),
        EquipmentItemData(
          id: 404,
          monitoringId: 4,
          tagNumber: "POUB-120",
          designation: "Poubelle tri sélectif 120L",
          type: "Déchets & Poubelles",
          site: "Dépôt Antsirabe",
          location: "Zone atelier",
          lastControlDate: "05 Oct 2026",
          nextDueDate: "20 Oct 2026",
          status: "Conforme",
          pressureStatus: "Bon état",
          conformity: true,
        ),
        EquipmentItemData(
          id: 405,
          monitoringId: 4,
          tagNumber: "SIG-EXT-01",
          designation: "Panneau Signalétique Extincteur",
          type: "Signalétique",
          site: "Dépôt Antsirabe",
          location: "Poste Garde",
          lastControlDate: "05 Oct 2026",
          nextDueDate: "20 Oct 2026",
          status: "Conforme",
          pressureStatus: "Visible",
          conformity: true,
        ),
      ],
    ),
  ];

  static const List<EquipmentItemData> _defaultEquipments = [
    EquipmentItemData(
      id: 1,
      tagNumber: "EXT-P50-01",
      designation: "Extincteur 50kg Poudre sur roues",
      type: "Extincteur P50",
      site: "Terminal Toamasina",
      location: "Zone Cuves Sud - Poste Chargement",
      lastControlDate: "12 Oct 2026",
      nextDueDate: "12 Nov 2026",
      status: "Conforme",
      pressureStatus: "Normal (14 bars)",
      conformity: true,
      value: 2,
      valueType: "number",
    ),
    EquipmentItemData(
      id: 2,
      tagNumber: "EXT-P9-14",
      designation: "Extincteur Portatif 9kg Poudre ABC",
      type: "Extincteur P9",
      site: "Dépôt Antsirabe",
      location: "Atelier Mécanique & Maintenance",
      lastControlDate: "05 Oct 2026",
      nextDueDate: "20 Oct 2026",
      status: "Contrôle requis",
      pressureStatus: "Vérifier manomètre",
      conformity: false,
      value: 4,
      valueType: "number",
    ),
    EquipmentItemData(
      id: 3,
      tagNumber: "RIA-03",
      designation: "Robinet d'Incendie Armé DN 25/30m",
      type: "RIA",
      site: "Terminal Toamasina",
      location: "Bâtiment Administratif & Hall",
      lastControlDate: "10 Oct 2026",
      nextDueDate: "10 Nov 2026",
      status: "Conforme",
      pressureStatus: "Normal (7.5 bars)",
      conformity: true,
      value: 1,
      valueType: "number",
    ),
  ];

  /// Récupère la liste des sessions de suivi matériel (API en ligne avec fallback local)
  static Future<List<EquipmentMonitoringData>> getMonitorings({
    String? search,
    String? status,
  }) async {
    // 1. Tentative en ligne
    try {
      await ApiClient.ensureAuthenticated();
      final response = await ApiClient.dio.get('/home/equipments-monitoring/equipments');

      if (response.statusCode == 200 && response.data != null) {
        final rawData = response.data['data'] ?? response.data;
        if (rawData is List && rawData.isNotEmpty) {
          final List<EquipmentMonitoringData> parsed = [];
          for (final record in rawData) {
            final m = Map<String, dynamic>.from(record);
            parsed.add(EquipmentMonitoringData.fromJson(m));
          }

          if (parsed.isNotEmpty) {
            await OfflineStorageService.cacheEquipmentMonitorings(parsed);
            return _filterMonitorings(parsed, search, status);
          }
        }
      }
    } catch (e) {
      debugPrint('[EquipmentService] Erreur lecture API getMonitorings: $e');
    }

    // 2. Repli hors-ligne depuis le cache local
    final cached = await OfflineStorageService.getCachedEquipmentMonitorings();
    if (cached.isNotEmpty) {
      return _filterMonitorings(cached, search, status);
    }

    // 3. Initialisation avec les données par défaut si premier lancement
    await OfflineStorageService.cacheEquipmentMonitorings(_defaultMonitorings);
    return _filterMonitorings(_defaultMonitorings, search, status);
  }

  /// Récupère les détails complets d'une session de suivi par son ID
  static Future<EquipmentMonitoringData?> getMonitoringById(dynamic id) async {
    try {
      await ApiClient.ensureAuthenticated();
      final response = await ApiClient.dio.get('/home/equipments-monitoring/equipments/$id');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] ?? response.data;
        final monitoring = EquipmentMonitoringData.fromJson(Map<String, dynamic>.from(data));
        await OfflineStorageService.updateCachedEquipmentMonitoring(monitoring);
        return monitoring;
      }
    } catch (_) {}

    final cached = await OfflineStorageService.getCachedEquipmentMonitorings();
    final match = cached.where((m) => m.id?.toString() == id?.toString() || m.reference == id?.toString());
    if (match.isNotEmpty) return match.first;
    return null;
  }

  /// Création / Planification d'une nouvelle session de suivi matériel (0 équipement à la création)
  static Future<EquipmentMonitoringData> createMonitoring({
    required String siteName,
    required String date,
    required String status,
    String? inspector,
    String? observations,
  }) async {
    final tempId = DateTime.now().millisecondsSinceEpoch;
    final now = DateTime.now();
    final defaultInspector = inspector ?? ApiClient.currentUser?['name']?.toString() ?? 'Inspecteur HSSE';

    EquipmentMonitoringData newMonitoring = EquipmentMonitoringData(
      id: tempId,
      reference: '#EQ-$tempId',
      siteName: siteName,
      date: date,
      status: status,
      rawStatus: status == 'Planifiée' ? 'DRAFT' : 'IN_PROGRESS',
      inspector: defaultInspector,
      conformityRate: 100.0,
      initialConformityRate: 100.0,
      observations: observations,
      items: const [],
      isPendingSync: true,
    );

    // 1. Sauvegarde locale immédiate (mode hors-ligne garanti)
    await OfflineStorageService.addCachedEquipmentMonitoring(newMonitoring);

    // 2. Synchronisation en ligne
    try {
      await ApiClient.ensureAuthenticated();
      final response = await ApiClient.dio.post(
        '/home/equipments-monitoring/equipments',
        data: {
          'site_name': siteName,
          'date': date,
          'status': status == 'Planifiée' ? 'DRAFT' : 'IN_PROGRESS',
          'observations': observations,
          'items': [],
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final serverData = response.data['data'] ?? response.data;
        final serverId = serverData['id'] ?? response.data['id'];
        if (serverId != null) {
          newMonitoring = newMonitoring.copyWith(
            id: serverId,
            reference: '#EQ-$serverId',
            isPendingSync: false,
          );
          await OfflineStorageService.updateCachedEquipmentMonitoring(newMonitoring);
        }
      }
    } catch (e) {
      debugPrint('[EquipmentService] Enregistrement suivi en ligne échoué, mise en file sync: $e');
      final action = SyncAction(
        id: 'monitoring_create_$tempId',
        type: 'EQUIPMENT_MONITORING_CREATE',
        title: 'Création suivi matériel ($siteName)',
        endpoint: '/home/equipments-monitoring/equipments',
        method: 'POST',
        payload: {
          'site_name': siteName,
          'date': date,
          'status': status == 'Planifiée' ? 'DRAFT' : 'IN_PROGRESS',
          'observations': observations,
          'items': [],
        },
        createdAt: now,
      );
      await SyncService.instance.queueAction(action);
    }

    return newMonitoring;
  }

  /// Mise à jour du statut d'une session de suivi matériel
  static Future<EquipmentMonitoringData?> updateMonitoringStatus(
    dynamic monitoringId,
    String newStatus,
  ) async {
    final cached = await OfflineStorageService.getCachedEquipmentMonitorings();
    final idx = cached.indexWhere((m) =>
        m.id?.toString() == monitoringId?.toString() || m.reference == monitoringId?.toString());
    if (idx == -1) return null;

    String raw = 'IN_PROGRESS';
    if (newStatus == 'Clôturée') raw = 'COMPLETED';
    if (newStatus == 'Planifiée') raw = 'DRAFT';
    if (newStatus == 'Annulée') raw = 'CANCELLED';

    final updated = cached[idx].copyWith(
      status: newStatus,
      rawStatus: raw,
    );
    await OfflineStorageService.updateCachedEquipmentMonitoring(updated);

    try {
      await ApiClient.ensureAuthenticated();
      await ApiClient.dio.put(
        '/home/equipments-monitoring/equipments/$monitoringId',
        data: {'status': raw},
      );
    } catch (e) {
      final action = SyncAction(
        id: 'monitoring_status_${monitoringId}_${DateTime.now().millisecondsSinceEpoch}',
        type: 'EQUIPMENT_MONITORING_UPDATE',
        title: 'Mise à jour statut suivi ${updated.reference} ($newStatus)',
        endpoint: '/home/equipments-monitoring/equipments/$monitoringId',
        method: 'PUT',
        payload: {'status': raw},
        createdAt: DateTime.now(),
      );
      await SyncService.instance.queueAction(action);
    }

    return updated;
  }

  /// Ajout d'un matériel sur site pendant l'inspection (contrôle unitaire, sans saisie de quantité)
  static Future<EquipmentItemData> addItemToMonitoring(
    dynamic monitoringId, {
    required String name,
    required String type,
    required bool isConforme,
    String? location,
    String? comment,
    List<String>? photoPaths,
  }) async {
    final now = DateTime.now();
    final tempTag = "EQ-${now.millisecondsSinceEpoch.toString().substring(7)}";
    final dateStr = "${now.day} Oct ${now.year}";

    EquipmentItemData newItem = EquipmentItemData(
      monitoringId: monitoringId,
      tagNumber: tempTag,
      designation: name,
      type: formatEquipmentType(type),
      site: '',
      location: (location != null && location.trim().isNotEmpty) ? location : "Piste distribution",
      lastControlDate: dateStr,
      nextDueDate: "${now.day} Nov ${now.year}",
      status: isConforme ? "Conforme" : "Non-conforme",
      pressureStatus: isConforme ? "Normal (14 bars)" : "Contrôle requis",
      conformity: isConforme,
      attachments: photoPaths ?? const [],
      comment: comment,
    );

    // 1. Sauvegarde locale immédiate
    await OfflineStorageService.addItemToMonitoringInCache(monitoringId, newItem);

    // 2. Synchronisation en ligne
    try {
      await ApiClient.ensureAuthenticated();
      final response = await ApiClient.dio.post(
        '/home/equipments-monitoring/equipments/$monitoringId/items',
        data: {
          'name': name,
          'type': type,
          'conformity': isConforme,
          'location': location,
          'comment': comment,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final serverItem = response.data['item'];
        final serverId = serverItem?['id'] is int
            ? serverItem['id']
            : int.tryParse(serverItem?['id']?.toString() ?? '');

        if (serverId != null) {
          newItem = newItem.copyWith(id: serverId, tagNumber: "EQ-$serverId");

          if (photoPaths != null && photoPaths.isNotEmpty) {
            final List<String> remoteUrls = [];
            for (final p in photoPaths) {
              final file = File(p);
              if (await file.exists()) {
                final url = await uploadItemPhoto(serverId, file);
                if (url != null) remoteUrls.add(url);
              }
            }
            if (remoteUrls.isNotEmpty) {
              newItem = newItem.copyWith(attachments: remoteUrls);
            }
          }
          await OfflineStorageService.updateItemInMonitoringInCache(monitoringId, newItem);
        }
      }
    } catch (e) {
      debugPrint('[EquipmentService] Ajout item en ligne échoué, mise en file sync: $e');
      final action = SyncAction(
        id: 'equipment_item_add_${DateTime.now().millisecondsSinceEpoch}',
        type: 'EQUIPMENT_ITEM_ADD',
        title: 'Ajout matériel $name',
        endpoint: '/home/equipments-monitoring/equipments/$monitoringId/items',
        method: 'POST',
        payload: {
          'name': name,
          'type': type,
          'conformity': isConforme,
          'location': location,
          'comment': comment,
        },
        createdAt: DateTime.now(),
      );
      await SyncService.instance.queueAction(action);
    }

    return newItem;
  }

  /// Mise à jour de la conformité d'un matériel (toggle en direct sur le terrain)
  static Future<EquipmentItemData> updateItemConformity(
    dynamic monitoringId,
    EquipmentItemData item,
    bool newConformity, {
    String? comment,
    List<String>? newPhotoPaths,
  }) async {
    final updatedPhotos = List<String>.from(item.attachments);
    if (newPhotoPaths != null) {
      updatedPhotos.addAll(newPhotoPaths);
    }

    final updated = item.copyWith(
      lastControlDate: "Aujourd'hui (${DateTime.now().day} Oct ${DateTime.now().year})",
      status: newConformity ? "Conforme" : "Non-conforme",
      conformity: newConformity,
      pressureStatus: newConformity ? "Normal (14 bars)" : "Pression anormale",
      attachments: updatedPhotos,
      comment: comment ?? item.comment,
    );

    // 1. Sauvegarde locale
    await OfflineStorageService.updateItemInMonitoringInCache(monitoringId, updated);

    // 2. Synchronisation en ligne si itemId disponible
    if (item.id != null) {
      try {
        await ApiClient.ensureAuthenticated();
        await ApiClient.dio.put(
          '/home/equipments-monitoring/equipments/items/${item.id}',
          data: {
            'conformity': newConformity,
            'comment': comment ?? item.comment,
          },
        );

        if (newPhotoPaths != null && newPhotoPaths.isNotEmpty) {
          for (final photoPath in newPhotoPaths) {
            final file = File(photoPath);
            if (await file.exists()) {
              final remoteUrl = await uploadItemPhoto(item.id!, file);
              if (remoteUrl != null) {
                final idx = updatedPhotos.indexOf(photoPath);
                if (idx != -1) {
                  updatedPhotos[idx] = remoteUrl;
                }
              }
            }
          }
          await OfflineStorageService.updateItemInMonitoringInCache(
            monitoringId,
            updated.copyWith(attachments: updatedPhotos),
          );
        }
      } catch (err) {
        final action = SyncAction(
          id: 'equipment_item_update_${item.id}_${DateTime.now().millisecondsSinceEpoch}',
          type: 'EQUIPMENT_ITEM_UPDATE',
          title: 'Contrôle ${item.designation} (${newConformity ? 'Conforme' : 'Non-conforme'})',
          endpoint: '/home/equipments-monitoring/equipments/items/${item.id}',
          method: 'PUT',
          payload: {
            'conformity': newConformity,
            'comment': comment ?? item.comment,
          },
          createdAt: DateTime.now(),
        );
        await SyncService.instance.queueAction(action);
      }
    }

    return updated;
  }

  /// Supprime un matériel d'une session de suivi
  static Future<bool> deleteItemFromMonitoring(dynamic monitoringId, EquipmentItemData item) async {
    await OfflineStorageService.deleteItemFromMonitoringInCache(monitoringId, item.id, item.tagNumber);

    if (item.id != null) {
      try {
        await ApiClient.ensureAuthenticated();
        await ApiClient.dio.delete('/home/equipments-monitoring/equipments/items/${item.id}');
        return true;
      } catch (e) {
        debugPrint('[EquipmentService] Erreur suppression en ligne: $e');
        final action = SyncAction(
          id: 'equipment_delete_${item.id}_${DateTime.now().millisecondsSinceEpoch}',
          type: 'EQUIPMENT_ITEM_DELETE',
          title: 'Suppression matériel ${item.designation}',
          endpoint: '/home/equipments-monitoring/equipments/items/${item.id}',
          method: 'DELETE',
          payload: const {},
          createdAt: DateTime.now(),
        );
        await SyncService.instance.queueAction(action);
      }
    }
    return true;
  }

  /// Récupère la liste des équipements (pour compatibilité avec Dashboard)
  static Future<List<EquipmentItemData>> getEquipments({
    String? search,
    String? category,
  }) async {
    final monitorings = await getMonitorings();
    final List<EquipmentItemData> allItems = [];
    for (final m in monitorings) {
      for (final it in m.items) {
        allItems.add(it.copyWith(site: m.siteName));
      }
    }
    if (allItems.isNotEmpty) {
      return _filterList(allItems, search, category);
    }

    final cached = await OfflineStorageService.getCachedEquipments();
    if (cached.isNotEmpty) {
      return _filterList(cached, search, category);
    }

    await OfflineStorageService.cacheEquipments(_defaultEquipments);
    return _filterList(_defaultEquipments, search, category);
  }

  static String formatEquipmentType(String? rawType) {
    if (rawType == null) return 'Extincteur P50';
    final t = rawType.toLowerCase();
    if (t.contains('p50')) return 'Extincteur P50';
    if (t.contains('p9')) return 'Extincteur P9';
    if (t.contains('p6')) return 'Extincteur P6';
    if (t.contains('co2')) return 'Extincteur CO2';
    if (t.contains('ria')) return 'RIA';
    if (t.contains('bac')) return 'Cuves & Bacs';
    if (t.contains('poubelle')) return 'Déchets & Poubelles';
    if (t.contains('caf') || t.contains('caisse')) return 'Sécurité Incendie';
    if (t.contains('picto') || t.contains('panneau') || t.contains('signal')) return 'Signalétique';
    if (t.contains('extincteur')) return 'Extincteur P50';
    return rawType;
  }

  /// Récupère la liste des noms de sites / stations
  static Future<List<String>> getSiteNames() async {
    try {
      await ApiClient.ensureAuthenticated();
      final response = await ApiClient.dio.get('/home/equipments-monitoring/site-names');
      if (response.statusCode == 200 && response.data != null) {
        final List raw = response.data is List ? response.data : (response.data['data'] ?? []);
        final names = raw.map<String>((e) => e['name']?.toString() ?? '').where((s) => s.isNotEmpty).toList();
        if (names.isNotEmpty) return names;
      }
    } catch (_) {}
    return const [
      "Terminal Toamasina",
      "Dépôt Antsirabe",
      "Station Majunga",
      "Dépôt Ivato",
      "Station Tana Ankorondrano",
      "Station Tamatave Port",
      "Station Fianarantsoa",
      "Station Tuléar Centre",
    ];
  }

  /// Upload d'une photo d'équipement vers l'API
  static Future<String?> uploadItemPhoto(int itemId, File photoFile) async {
    try {
      await ApiClient.ensureAuthenticated();
      final fileName = photoFile.path.split('/').last.split('\\').last;
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          photoFile.path,
          filename: fileName,
        ),
      });

      final response = await ApiClient.dio.post(
        '/home/equipments-monitoring/equipments/items/$itemId/photo',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final filePath = response.data['attachment']?['file_path']?.toString();
        if (filePath != null) {
          if (filePath.startsWith('http')) return filePath;
          return '${ApiClient.baseUrl.replaceAll('/api', '')}$filePath';
        }
      }
    } catch (e) {
      debugPrint('[EquipmentService] Erreur uploadItemPhoto: $e');
    }
    return null;
  }

  static List<EquipmentMonitoringData> _filterMonitorings(
    List<EquipmentMonitoringData> list,
    String? search,
    String? status,
  ) {
    return list.where((item) {
      if (search != null && search.trim().isNotEmpty) {
        final q = search.toLowerCase();
        final match = item.reference.toLowerCase().contains(q) ||
            item.siteName.toLowerCase().contains(q) ||
            item.inspector.toLowerCase().contains(q) ||
            (item.observations?.toLowerCase().contains(q) ?? false);
        if (!match) return false;
      }
      if (status != null && status.isNotEmpty && !status.toLowerCase().contains('tous')) {
        return item.status.toLowerCase() == status.toLowerCase();
      }
      return true;
    }).toList();
  }

  static List<EquipmentItemData> _filterList(
    List<EquipmentItemData> list,
    String? search,
    String? category,
  ) {
    return list.where((item) {
      if (search != null && search.trim().isNotEmpty) {
        final q = search.toLowerCase();
        final match = item.tagNumber.toLowerCase().contains(q) ||
            item.designation.toLowerCase().contains(q) ||
            item.site.toLowerCase().contains(q) ||
            item.location.toLowerCase().contains(q);
        if (!match) return false;
      }
      if (category != null && category.isNotEmpty && !category.toLowerCase().contains('tous')) {
        return item.type.toLowerCase().contains(category.toLowerCase()) ||
            category.toLowerCase().contains(item.type.toLowerCase());
      }
      return true;
    }).toList();
  }
}
