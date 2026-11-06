import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/api/api_client.dart';
import 'package:gestion_hsse/cores/services/offline_storage_service.dart';
import 'package:gestion_hsse/cores/services/sync_service.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/views/home/inspection/equipment/equipment_list_view.dart';

class EquipmentCategoryItem {
  final String key;
  final String label;
  const EquipmentCategoryItem(this.key, this.label);
}

class SiteItem {
  final int? id;
  final String name;
  final String? locality;
  final String? province;
  final double? latitude;
  final double? longitude;

  const SiteItem({
    this.id,
    required this.name,
    this.locality,
    this.province,
    this.latitude,
    this.longitude,
  });

  factory SiteItem.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] as Map<String, dynamic>?;
    return SiteItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? 'Station Galana',
      locality: json['locality']?.toString() ?? loc?['locality']?.toString(),
      province: json['province']?.toString() ?? loc?['province']?.toString(),
      latitude: json['latitude'] is num
          ? (json['latitude'] as num).toDouble()
          : (loc?['latitude'] is num ? (loc!['latitude'] as num).toDouble() : null),
      longitude: json['longitude'] is num
          ? (json['longitude'] as num).toDouble()
          : (loc?['longitude'] is num ? (loc!['longitude'] as num).toDouble() : null),
    );
  }
}

class EquipmentService {
  static const List<EquipmentCategoryItem> standardCategories = [
    EquipmentCategoryItem('extincteur', 'Extincteur'),
    EquipmentCategoryItem('bac', 'Bac de rétention'),
    EquipmentCategoryItem('materiel', 'Matériel et outils'),
    EquipmentCategoryItem('poubelle', 'Poubelles'),
    EquipmentCategoryItem('signalisation', 'Signalétique et pictogramme'),
    EquipmentCategoryItem('securite', 'Sécurité incendie'),
    EquipmentCategoryItem('conformite', 'Document & affichage'),
    EquipmentCategoryItem('divers', 'Autre / Divers'),
  ];
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
          type: "Extincteur",
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
          type: "Extincteur",
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
          type: "Extincteur",
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
          type: "Bac de rétention",
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
          type: "Extincteur",
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
          type: "Extincteur",
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
          type: "Bac de rétention",
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
          type: "Extincteur",
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
          type: "Extincteur",
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
          type: "Extincteur",
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
          type: "Poubelles",
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
          type: "Signalétique et pictogramme",
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
      type: "Extincteur",
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
      type: "Extincteur",
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
      type: "Extincteur",
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
            final cached = await OfflineStorageService.getCachedEquipmentMonitorings();
            return _filterMonitorings(cached.isNotEmpty ? cached : parsed, search, status);
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
    String newStatus, {
    List<EquipmentItemData>? currentItems,
  }) async {
    final cached = await OfflineStorageService.getCachedEquipmentMonitorings();
    final idx = cached.indexWhere((m) =>
        m.id?.toString() == monitoringId?.toString() || m.reference == monitoringId?.toString());

    String raw = 'IN_PROGRESS';
    if (newStatus == 'Clôturée') raw = 'COMPLETED';
    if (newStatus == 'Planifiée') raw = 'DRAFT';
    if (newStatus == 'Annulée') raw = 'CANCELLED';

    final base = idx != -1 ? cached[idx] : null;
    final items = OfflineStorageService.deduplicateItems(currentItems ?? base?.items ?? []);
    final total = items.length;
    final confCount = items.where((i) => i.conformity).length;
    final rate = total > 0 ? (confCount / total) * 100.0 : 100.0;

    final updated = (base ?? EquipmentMonitoringData(
      id: monitoringId,
      reference: '#EQ-$monitoringId',
      siteName: '',
      date: '',
      status: newStatus,
      inspector: 'Inspecteur HSSE',
    )).copyWith(
      status: newStatus,
      rawStatus: raw,
      items: items,
      conformityRate: rate,
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
    Map<String, dynamic>? action,
  }) async {
    final now = DateTime.now();
    final tempTag = "EQ-${now.millisecondsSinceEpoch.toString().substring(7)}";
    final dateStr = "${now.day} Oct ${now.year}";
    final String formattedType = formatEquipmentType(type);
    final String categoryKey = getCategoryKey(type);

    EquipmentItemData newItem = EquipmentItemData(
      monitoringId: monitoringId,
      tagNumber: tempTag,
      designation: name,
      type: formattedType,
      site: '',
      location: (location != null && location.trim().isNotEmpty) ? location : "Piste distribution",
      lastControlDate: dateStr,
      nextDueDate: "${now.day} Nov ${now.year}",
      status: isConforme ? "Conforme" : "Non-conforme",
      pressureStatus: isConforme ? "Normal (14 bars)" : "Contrôle requis",
      conformity: isConforme,
      attachments: photoPaths ?? const [],
      comment: comment,
      action: action,
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
          'type': categoryKey,
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
      final syncAction = SyncAction(
        id: 'equipment_item_add_${DateTime.now().millisecondsSinceEpoch}',
        type: 'EQUIPMENT_ITEM_ADD',
        title: 'Ajout matériel $name',
        endpoint: '/home/equipments-monitoring/equipments/$monitoringId/items',
        method: 'POST',
        payload: {
          'name': name,
          'type': categoryKey,
          'conformity': isConforme,
          'location': location,
          'comment': comment,
        },
        createdAt: now,
      );
      await SyncService.instance.queueAction(syncAction);
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
    Map<String, dynamic>? action,
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
      action: newConformity ? null : (action ?? item.action),
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
        final syncAction = SyncAction(
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
        await SyncService.instance.queueAction(syncAction);
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
    if (rawType == null || rawType.isEmpty) return 'Autre / Divers';
    final t = rawType.toLowerCase().trim();
    if (t == 'extincteur' || t.contains('extincteur') || t.contains('p50') || t.contains('p9') || t.contains('p6') || t.contains('co2') || t.contains('ria')) {
      return 'Extincteur';
    }
    if (t == 'bac' || t.contains('bac') || t.contains('cuve') || t.contains('retention')) {
      return 'Bac de rétention';
    }
    if (t == 'materiel' || t.contains('materiel') || t.contains('outil')) {
      return 'Matériel et outils';
    }
    if (t == 'poubelle' || t.contains('poubelle') || t.contains('dechet')) {
      return 'Poubelles';
    }
    if (t == 'signalisation' || t.contains('signal') || t.contains('picto') || t.contains('panneau')) {
      return 'Signalétique et pictogramme';
    }
    if (t == 'securite' || t.contains('securite') || t.contains('incendie') || t.contains('caf') || t.contains('caisse')) {
      return 'Sécurité incendie';
    }
    if (t == 'conformite' || t.contains('conformite') || t.contains('document') || t.contains('affichage')) {
      return 'Document & affichage';
    }
    if (t == 'divers' || t.contains('divers') || t.contains('autre')) {
      return 'Autre / Divers';
    }
    return rawType;
  }

  static String getCategoryKey(String? labelOrKey) {
    if (labelOrKey == null || labelOrKey.isEmpty) return 'divers';
    final t = labelOrKey.toLowerCase().trim();
    if (t == 'extincteur' || t.contains('extincteur') || t.contains('p50') || t.contains('p9') || t.contains('p6') || t.contains('co2') || t.contains('ria')) return 'extincteur';
    if (t == 'bac' || t.contains('bac') || t.contains('cuve') || t.contains('retention')) return 'bac';
    if (t == 'materiel' || t.contains('materiel') || t.contains('outil')) return 'materiel';
    if (t == 'poubelle' || t.contains('poubelle') || t.contains('dechet')) return 'poubelle';
    if (t == 'signalisation' || t.contains('signal') || t.contains('picto') || t.contains('panneau')) return 'signalisation';
    if (t == 'securite' || t.contains('securite') || t.contains('incendie')) return 'securite';
    if (t == 'conformite' || t.contains('conformite') || t.contains('document') || t.contains('affichage')) return 'conformite';
    return 'divers';
  }

  /// Récupère la liste des noms de sites / stations
  static Future<List<String>> getSiteNames() async {
    final sites = await getDetailedSites();
    return sites.map((s) => s.name).toList();
  }

  /// Récupère la liste détaillée des sites / stations Galana avec leur localisation
  static Future<List<SiteItem>> getDetailedSites() async {
    try {
      await ApiClient.ensureAuthenticated();
      final response = await ApiClient.dio.get('/home/equipments-monitoring/site-names');
      if (response.statusCode == 200 && response.data != null) {
        final List raw = response.data is List ? response.data : (response.data['data'] ?? []);
        final list = raw
            .whereType<Map>()
            .map((e) => SiteItem.fromJson(Map<String, dynamic>.from(e)))
            .where((s) => s.name.isNotEmpty)
            .toList();
        if (list.isNotEmpty) return list;
      }
    } catch (_) {}

    return const [
      SiteItem(name: "Terminal Toamasina", locality: "Toamasina", province: "Atsinanana"),
      SiteItem(name: "Dépôt Antsirabe", locality: "Antsirabe", province: "Vakinankaratra"),
      SiteItem(name: "Station Majunga", locality: "Mahajanga", province: "Boeny"),
      SiteItem(name: "Dépôt Ivato", locality: "Ivato", province: "Analamanga"),
      SiteItem(name: "Station Tana Ankorondrano", locality: "Ankorondrano", province: "Analamanga"),
      SiteItem(name: "Station Tamatave Port", locality: "Port", province: "Atsinanana"),
      SiteItem(name: "Station Fianarantsoa", locality: "Fianarantsoa", province: "Haute Matsiatra"),
      SiteItem(name: "Station Tuléar Centre", locality: "Toliara", province: "Atsimo-Andrefana"),
    ];
  }

  /// Sélecteur de station Galana convivial avec recherche instantanée, localités et saisie personnalisée
  static Future<SiteItem?> showSitePicker(
    BuildContext context, {
    String? currentSite,
  }) async {
    final allSites = await getDetailedSites();
    if (!context.mounted) return null;

    return showModalBottomSheet<SiteItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (ctx, setPickerState) {
            final filtered = allSites.where((s) {
              if (searchQuery.trim().isEmpty) return true;
              final q = searchQuery.toLowerCase().trim();
              return s.name.toLowerCase().contains(q) ||
                  (s.locality?.toLowerCase().contains(q) ?? false) ||
                  (s.province?.toLowerCase().contains(q) ?? false);
            }).toList();

            return Container(
              height: MediaQuery.of(ctx).size.height * 0.80,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barre de tirage
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.local_gas_station_rounded,
                                  color: Color(0xFF1D4ED8), size: 22),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Sélectionner une station",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  "${filtered.length} station(s) disponible(s)",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20, color: Color(0xFF64748B)),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),

                  // Barre de recherche
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: TextField(
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: "Rechercher station, ville, province...",
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                        prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  setPickerState(() => searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        setPickerState(() => searchQuery = val);
                      },
                    ),
                  ),

                  const SizedBox(height: 8),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),

                  // Liste des stations filtrées
                  Expanded(
                    child: filtered.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade300),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Aucune station trouvée pour « $searchQuery »",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF475569),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  if (searchQuery.trim().isNotEmpty)
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.pop(
                                          ctx,
                                          SiteItem(name: searchQuery.trim()),
                                        );
                                      },
                                      icon: const Icon(Icons.add, size: 18),
                                      label: Text("Utiliser « ${searchQuery.trim()} »"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 4),
                            itemBuilder: (ctx, idx) {
                              final site = filtered[idx];
                              final isSelected = currentSite != null &&
                                  site.name.toLowerCase().trim() == currentSite.toLowerCase().trim();

                              return InkWell(
                                onTap: () => Navigator.pop(ctx, site),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isSelected
                                        ? Border.all(color: const Color(0xFF93C5FD))
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFFDBEAFE)
                                              : const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.local_gas_station_rounded,
                                          size: 18,
                                          color: isSelected
                                              ? const Color(0xFF1D4ED8)
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              site.name,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                                color: isSelected
                                                    ? const Color(0xFF1D4ED8)
                                                    : const Color(0xFF0F172A),
                                              ),
                                            ),
                                            if (site.locality != null || site.province != null) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                [
                                                  if (site.locality != null && site.locality!.isNotEmpty)
                                                    site.locality,
                                                  if (site.province != null && site.province!.isNotEmpty)
                                                    site.province,
                                                ].join(" • "),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF64748B),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          color: Color(0xFF1D4ED8),
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
