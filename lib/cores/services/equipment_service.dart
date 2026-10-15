import 'package:gestion_hsse/cores/api/api_client.dart';
import 'package:gestion_hsse/cores/services/offline_storage_service.dart';
import 'package:gestion_hsse/cores/services/sync_service.dart';
import 'package:gestion_hsse/views/home/inspection/equipment/equipment_list_view.dart';

class EquipmentService {
  static const List<EquipmentItemData> _defaultEquipments = [
    EquipmentItemData(
      tagNumber: "EXT-P50-01",
      designation: "Extincteur 50kg Poudre sur roues",
      type: "Extincteur P50",
      site: "Terminal Toamasina",
      location: "Zone Cuves Sud - Poste Chargement",
      lastControlDate: "12 Oct 2026",
      nextDueDate: "12 Nov 2026",
      status: "Conforme",
      pressureStatus: "Normal (14 bars)",
    ),
    EquipmentItemData(
      tagNumber: "EXT-P9-14",
      designation: "Extincteur Portatif 9kg Poudre ABC",
      type: "Extincteur P9",
      site: "Dépôt Antsirabe",
      location: "Atelier Mécanique & Maintenance",
      lastControlDate: "05 Oct 2026",
      nextDueDate: "20 Oct 2026",
      status: "Contrôle requis",
      pressureStatus: "Vérifier manomètre",
    ),
    EquipmentItemData(
      tagNumber: "RIA-03",
      designation: "Robinet d'Incendie Armé DN 25/30m",
      type: "RIA",
      site: "Terminal Toamasina",
      location: "Bâtiment Administratif & Hall",
      lastControlDate: "10 Oct 2026",
      nextDueDate: "10 Nov 2026",
      status: "Conforme",
      pressureStatus: "Normal (7.5 bars)",
    ),
    EquipmentItemData(
      tagNumber: "EXT-P50-04",
      designation: "Extincteur 50kg Poudre sur roues",
      type: "Extincteur P50",
      site: "Station Majunga",
      location: "Îlot B - Pompes Gasoil",
      lastControlDate: "15 Sep 2026",
      nextDueDate: "15 Oct 2026",
      status: "Non-conforme",
      pressureStatus: "Basse (Goupille manquante)",
    ),
    EquipmentItemData(
      tagNumber: "BAC-RET-02",
      designation: "Bac de Rétention Hydrocarbures 1200L",
      type: "Cuves & Bacs",
      site: "Dépôt Ivato",
      location: "Zone Stockage Fûts & Huiles",
      lastControlDate: "01 Oct 2026",
      nextDueDate: "01 Nov 2026",
      status: "Conforme",
      pressureStatus: "Étanche",
    ),
  ];

  /// Récupère la liste des équipements (API en ligne ou stockage hors-ligne)
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
          final items = rawData.map<EquipmentItemData>((json) {
            final m = Map<String, dynamic>.from(json);
            return EquipmentItemData(
              tagNumber: m['tag_number']?.toString() ?? 'TAG-${m['id']}',
              designation: m['designation']?.toString() ?? 'Équipement incendie',
              type: m['type']?.toString() ?? 'Extincteur P50',
              site: m['site_name']?['name']?.toString() ?? m['site']?.toString() ?? 'Galana',
              location: m['location']?.toString() ?? 'Zone Dépôt',
              lastControlDate: m['last_control_date']?.toString() ?? '14 Oct 2026',
              nextDueDate: m['next_due_date']?.toString() ?? '14 Nov 2026',
              status: m['status']?.toString() ?? 'Conforme',
              pressureStatus: m['pressure_status']?.toString() ?? 'Normal',
            );
          }).toList();

          await OfflineStorageService.cacheEquipments(items);
          return _filterList(items, search, category);
        }
      }
    } catch (_) {}

    // 2. Repli hors-ligne depuis le cache local
    final cached = await OfflineStorageService.getCachedEquipments();
    if (cached.isNotEmpty) {
      return _filterList(cached, search, category);
    }

    // 3. Premier démarrage : initialisation des données par défaut
    await OfflineStorageService.cacheEquipments(_defaultEquipments);
    return _filterList(_defaultEquipments, search, category);
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
        return item.type.toLowerCase() == category.toLowerCase();
      }
      return true;
    }).toList();
  }

  /// Réalisation d'un contrôle équipement avec persistance hors-ligne et auto-synchro en ligne
  static Future<EquipmentItemData> performControl(
    EquipmentItemData equipment, {
    required bool isConforme,
    String? pressureStatus,
    String? observation,
    int photoCount = 0,
  }) async {
    final updated = EquipmentItemData(
      tagNumber: equipment.tagNumber,
      designation: equipment.designation,
      type: equipment.type,
      site: equipment.site,
      location: equipment.location,
      lastControlDate: "Aujourd'hui (14 Oct 2026)",
      nextDueDate: "14 Nov 2026",
      status: isConforme ? "Conforme" : "Non-conforme",
      pressureStatus: pressureStatus ?? (isConforme ? "Normal (14 bars)" : "Pression anormale"),
    );

    // 1. Sauvegarde immédiate en mode hors-ligne
    await OfflineStorageService.updateCachedEquipment(updated);

    // 2. Enfilement dans la file d'attente de synchronisation automatique
    final action = SyncAction(
      id: 'equipment_control_${equipment.tagNumber}_${DateTime.now().millisecondsSinceEpoch}',
      type: 'EQUIPMENT_UPDATE',
      title: 'Contrôle Matériel ${equipment.tagNumber} (${isConforme ? 'Conforme' : 'Non-conforme'})',
      endpoint: '/home/equipments-monitoring/equipments/1',
      method: 'PUT',
      payload: {
        'tagNumber': equipment.tagNumber,
        'status': isConforme ? 'Conforme' : 'Non-conforme',
        'pressureStatus': updated.pressureStatus,
        'lastControlDate': DateTime.now().toIso8601String(),
        'observation': observation,
        'photos_count': photoCount,
      },
      createdAt: DateTime.now(),
    );

    await SyncService.instance.queueAction(action);
    return updated;
  }
}
