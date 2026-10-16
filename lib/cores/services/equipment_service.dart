import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gestion_hsse/cores/api/api_client.dart';
import 'package:gestion_hsse/cores/services/offline_storage_service.dart';
import 'package:gestion_hsse/cores/services/sync_service.dart';
import 'package:gestion_hsse/views/home/inspection/equipment/equipment_list_view.dart';

class EquipmentService {
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
    EquipmentItemData(
      id: 4,
      tagNumber: "EXT-P50-04",
      designation: "Extincteur 50kg Poudre sur roues",
      type: "Extincteur P50",
      site: "Station Majunga",
      location: "Îlot B - Pompes Gasoil",
      lastControlDate: "15 Sep 2026",
      nextDueDate: "15 Oct 2026",
      status: "Non-conforme",
      pressureStatus: "Basse (Goupille manquante)",
      conformity: false,
      value: 1,
      valueType: "number",
    ),
    EquipmentItemData(
      id: 5,
      tagNumber: "BAC-RET-02",
      designation: "Bac de Rétention Hydrocarbures 1200L",
      type: "Cuves & Bacs",
      site: "Dépôt Ivato",
      location: "Zone Stockage Fûts & Huiles",
      lastControlDate: "01 Oct 2026",
      nextDueDate: "01 Nov 2026",
      status: "Conforme",
      pressureStatus: "Étanche",
      conformity: true,
      value: 3,
      valueType: "number",
    ),
  ];

  /// Récupère la liste des équipements (API en ligne avec fallback stockage hors-ligne)
  static Future<List<EquipmentItemData>> getEquipments({
    String? search,
    String? category,
  }) async {
    // 1. Tentative en ligne via l'API
    try {
      await ApiClient.ensureAuthenticated();
      final response = await ApiClient.dio.get('/home/equipments-monitoring/equipments');

      if (response.statusCode == 200 && response.data != null) {
        final rawData = response.data['data'] ?? response.data;
        if (rawData is List && rawData.isNotEmpty) {
          final List<EquipmentItemData> parsedItems = [];

          for (final record in rawData) {
            final m = Map<String, dynamic>.from(record);
            final siteName = m['site_name']?.toString() ?? 'Station Galana';
            final controlDate = m['date']?.toString() ?? '16 Oct 2026';

            // Modèle 3-tiers : Si le monitoring possède des EquipmentItem
            if (m['items'] is List && (m['items'] as List).isNotEmpty) {
              for (final it in (m['items'] as List)) {
                final itemMap = Map<String, dynamic>.from(it);
                final itemId = itemMap['id'] is int
                    ? itemMap['id']
                    : int.tryParse(itemMap['id']?.toString() ?? '');
                final bool isConforme =
                    itemMap['conformity'] == true || itemMap['conformity'] == 1;

                // Extraction des photos / attachments
                List<String> photoUrls = [];
                if (itemMap['attachments'] is List) {
                  photoUrls = (itemMap['attachments'] as List).map<String>((att) {
                    final attMap = Map<String, dynamic>.from(att);
                    final path = attMap['file_path']?.toString() ?? '';
                    if (path.startsWith('http')) return path;
                    return '${ApiClient.baseUrl.replaceAll('/api', '')}$path';
                  }).toList();
                }

                parsedItems.add(EquipmentItemData(
                  id: itemId,
                  tagNumber: 'EQ-${itemId ?? itemMap['name']}',
                  designation: itemMap['name']?.toString() ?? 'Équipement',
                  type: _formatEquipmentType(itemMap['type']?.toString()),
                  site: siteName,
                  location: itemMap['location']?.toString() ?? 'Piste distribution',
                  lastControlDate: controlDate,
                  nextDueDate: '16 Nov 2026',
                  status: isConforme ? 'Conforme' : 'Non-conforme',
                  pressureStatus: isConforme ? 'Normal (14 bars)' : 'Contrôle requis',
                  conformity: isConforme,
                  value: itemMap['value'],
                  valueType: itemMap['value_type']?.toString() ?? 'number',
                  attachments: photoUrls,
                  comment: itemMap['comment']?.toString(),
                ));
              }
            } else {
              // Fallback si fiche sans sous-items
              final id = int.tryParse(m['id']?.toString() ?? '');
              final bool isConforme = (m['conformity_rate'] as num? ?? 100) >= 90;
              parsedItems.add(EquipmentItemData(
                id: id,
                tagNumber: "EQ-${m['id'] ?? 'SS'}",
                designation: "Parc matériel $siteName",
                type: "Extincteurs & Bacs",
                site: siteName,
                location: "Station complète",
                lastControlDate: controlDate,
                nextDueDate: "16 Nov 2026",
                status: isConforme ? 'Conforme' : 'Non-conforme',
                pressureStatus: isConforme ? "Normal" : "Anomalie",
                conformity: isConforme,
                value: 1,
                valueType: "number",
                attachments: const [],
              ));
            }
          }

          if (parsedItems.isNotEmpty) {
            await OfflineStorageService.cacheEquipments(parsedItems);
            return _filterList(parsedItems, search, category);
          }
        }
      }
    } catch (e) {
      debugPrint('[EquipmentService] Erreur lecture API: $e');
    }

    // 2. Repli hors-ligne depuis le cache local
    final cached = await OfflineStorageService.getCachedEquipments();
    if (cached.isNotEmpty) {
      return _filterList(cached, search, category);
    }

    // 3. Premier démarrage : initialisation des données par défaut
    await OfflineStorageService.cacheEquipments(_defaultEquipments);
    return _filterList(_defaultEquipments, search, category);
  }

  static String _formatEquipmentType(String? rawType) {
    if (rawType == null) return 'Extincteur P50';
    final t = rawType.toLowerCase();
    if (t.contains('p50')) return 'Extincteur P50';
    if (t.contains('p9')) return 'Extincteur P9';
    if (t.contains('ria')) return 'RIA';
    if (t.contains('bac')) return 'Cuves & Bacs';
    if (t.contains('extincteur')) return 'Extincteur P50';
    return rawType;
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

  /// Réalisation d'un contrôle équipement avec persistance hors-ligne et auto-synchro en ligne
  static Future<EquipmentItemData> performControl(
    EquipmentItemData equipment, {
    required bool isConforme,
    String? pressureStatus,
    String? observation,
    List<String>? newPhotoPaths,
  }) async {
    final updatedPhotos = List<String>.from(equipment.attachments);
    if (newPhotoPaths != null) {
      updatedPhotos.addAll(newPhotoPaths);
    }

    final updated = equipment.copyWith(
      lastControlDate: "Aujourd'hui (${DateTime.now().day} Oct ${DateTime.now().year})",
      status: isConforme ? "Conforme" : "Non-conforme",
      conformity: isConforme,
      pressureStatus: pressureStatus ?? (isConforme ? "Normal (14 bars)" : "Pression anormale"),
      attachments: updatedPhotos,
      comment: observation ?? equipment.comment,
    );

    // 1. Sauvegarde locale hors-ligne immédiate
    await OfflineStorageService.updateCachedEquipment(updated);

    // 2. Synchronisation en ligne si itemId disponible
    if (equipment.id != null) {
      try {
        await ApiClient.ensureAuthenticated();
        await ApiClient.dio.put(
          '/home/equipments-monitoring/equipments/items/${equipment.id}',
          data: {
            'conformity': isConforme,
            'comment': observation,
          },
        );

        // Upload des nouvelles photos s'il y en a
        if (newPhotoPaths != null && newPhotoPaths.isNotEmpty) {
          for (final photoPath in newPhotoPaths) {
            final file = File(photoPath);
            if (await file.exists()) {
              final remoteUrl = await uploadItemPhoto(equipment.id!, file);
              if (remoteUrl != null) {
                // Remplace le chemin local par l'URL distante
                final idx = updatedPhotos.indexOf(photoPath);
                if (idx != -1) {
                  updatedPhotos[idx] = remoteUrl;
                }
              }
            }
          }
          await OfflineStorageService.updateCachedEquipment(
            updated.copyWith(attachments: updatedPhotos),
          );
        }
      } catch (err) {
        // Enfilement offline sync
        final action = SyncAction(
          id: 'equipment_control_${equipment.id}_${DateTime.now().millisecondsSinceEpoch}',
          type: 'EQUIPMENT_UPDATE',
          title: 'Contrôle ${equipment.designation} (${isConforme ? 'Conforme' : 'Non-conforme'})',
          endpoint: '/home/equipments-monitoring/equipments/items/${equipment.id}',
          method: 'PUT',
          payload: {
            'conformity': isConforme,
            'comment': observation,
          },
          createdAt: DateTime.now(),
        );
        await SyncService.instance.queueAction(action);
      }
    }

    return updated;
  }
}
