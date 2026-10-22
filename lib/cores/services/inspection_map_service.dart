import 'dart:math' as math;
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:gestion_hsse/cores/models/emergency_contact_model.dart';
import 'package:gestion_hsse/cores/models/inspection_map_item.dart';
import 'package:gestion_hsse/cores/services/checklist_service.dart';
import 'package:gestion_hsse/cores/services/emergency_contact_service.dart';
import 'package:gestion_hsse/cores/services/equipment_service.dart';
import 'package:gestion_hsse/cores/services/vmc_service.dart';

class InspectionMapService {
  static const Map<String, LatLng> _regionalCoordinates = {
    'antsirabe': LatLng(-19.8659, 47.0333),
    'toamasina': LatLng(-18.1492, 49.4023),
    'tamatave': LatLng(-18.1492, 49.4023),
    'mahajanga': LatLng(-15.7167, 46.3167),
    'majunga': LatLng(-15.7167, 46.3167),
    'ivato': LatLng(-18.7969, 47.4788),
    'ankorondrano': LatLng(-18.8872, 47.5255),
    'alarobia': LatLng(-18.8742, 47.5312),
    'analakely': LatLng(-18.9056, 47.5244),
    'tanjombato': LatLng(-18.9667, 47.5333),
    'antananarivo': LatLng(-18.8792, 47.5079),
    'tana': LatLng(-18.8792, 47.5079),
    'fianarantsoa': LatLng(-21.4527, 47.0857),
    'toliara': LatLng(-23.3516, 43.6675),
    'tulear': LatLng(-23.3516, 43.6675),
    'antsiranana': LatLng(-12.2833, 49.2833),
    'diego': LatLng(-12.2833, 49.2833),
    'tolagnaro': LatLng(-25.0381, 46.9987),
    'fortdauphin': LatLng(-25.0381, 46.9987),
    'morondava': LatLng(-20.2986, 44.3178),
    'sambava': LatLng(-14.2667, 50.1667),
    'nosybe': LatLng(-13.3167, 48.2667),
  };

  static String _cleanText(String? str) {
    if (str == null) return '';
    return str
        .toLowerCase()
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[^a-z0-9]'), '')
        .trim();
  }

  /// Résout les coordonnées géographiques d'un site avec détection automatique
  static LatLng resolveCoordinates({
    String? siteName,
    String? locality,
    double? latitude,
    double? longitude,
    List<EmergencySiteModel>? knownSites,
    int jitterIndex = 0,
  }) {
    if (latitude != null &&
        longitude != null &&
        latitude != 0 &&
        longitude != 0) {
      return _applyJitter(LatLng(latitude, longitude), jitterIndex);
    }

    final query = _cleanText('$siteName $locality');

    // 1. Recherche parmi les sites référencés
    if (knownSites != null && knownSites.isNotEmpty) {
      for (final s in knownSites) {
        if (s.latitude == null || s.longitude == null) continue;
        final target = _cleanText('${s.name} ${s.locality}');
        if (query.isNotEmpty &&
            (target.contains(query) ||
                query.contains(target) ||
                _cleanText(s.name) == _cleanText(siteName))) {
          return _applyJitter(LatLng(s.latitude!, s.longitude!), jitterIndex);
        }
      }
    }

    // 2. Recherche par alias régional malgache
    for (final entry in _regionalCoordinates.entries) {
      if (query.contains(entry.key)) {
        return _applyJitter(entry.value, jitterIndex);
      }
    }

    // 3. Coordonnées par défaut : Centre Antananarivo
    return _applyJitter(const LatLng(-18.8792, 47.5079), jitterIndex);
  }

  /// Applique un léger décalage pour éviter la superposition exacte de plusieurs marqueurs au même endroit
  static LatLng _applyJitter(LatLng base, int index) {
    if (index == 0) return base;
    final double angle = (index * 72) * (math.pi / 180);
    final double radius = 0.0018 + (index ~/ 5) * 0.0012;
    return LatLng(
      base.latitude + (radius * math.sin(angle)),
      base.longitude + (radius * math.cos(angle)),
    );
  }

  /// Récupère l'ensemble des inspections (Checklists, VMC, Suivi matériel) projetées sur la carte
  static Future<List<InspectionMapItem>> getAllInspectionMapItems() async {
    final List<InspectionMapItem> result = [];

    // Chargement parallèle des 3 sources de données + référentiel des sites
    final results = await Future.wait([
      ChecklistService.getChecklists(),
      VmcService.getVmcs(),
      EquipmentService.getMonitorings(),
      EmergencyContactService.getMapData(),
    ]);

    final checklists = results[0] as List<dynamic>;
    final vmcs = results[1] as List<dynamic>;
    final monitorings = results[2] as List<dynamic>;
    final emergencyData = results[3] as Map<String, dynamic>;
    final sites = (emergencyData['sites'] as List<dynamic>?)
            ?.cast<EmergencySiteModel>() ??
        EmergencyContactService.defaultEmergencySites;

    // Compteur par emplacement pour décaler les marqueurs superposés
    final Map<String, int> siteClusterCount = {};

    // 1. CHECKLISTS
    for (final it in checklists) {
      final siteName = it.site?.toString() ?? 'Station Galana';
      final clusterKey = _cleanText(siteName);
      final count = siteClusterCount[clusterKey] ?? 0;
      siteClusterCount[clusterKey] = count + 1;

      final coords = resolveCoordinates(
        siteName: siteName,
        knownSites: sites,
        jitterIndex: count,
      );

      result.add(
        InspectionMapItem(
          id: it.id ?? 'chk_${DateTime.now().millisecondsSinceEpoch}',
          type: InspectionType.checklist,
          title: it.title?.toString() ?? 'Checklist Inspection',
          reference: '#CHK-${it.id ?? ''}',
          site: siteName,
          locality: siteName,
          province: 'Madagascar',
          latitude: coords.latitude,
          longitude: coords.longitude,
          status: it.status?.toString() ?? 'En cours',
          date: it.date?.toString() ?? '14 Oct 2026',
          inspector: it.inspector?.toString() ?? 'Inspecteur HSSE',
          conformityRate: (it.progress != null) ? (it.progress * 100) : 75.0,
          deviationsCount: null,
          rawData: it,
        ),
      );
    }

    // 2. VMC (Visites Managériales de Conformité)
    for (final vmc in vmcs) {
      final siteName = vmc.site?.toString() ?? 'Site Galana';
      final clusterKey = _cleanText(siteName);
      final count = siteClusterCount[clusterKey] ?? 0;
      siteClusterCount[clusterKey] = count + 1;

      final coords = resolveCoordinates(
        siteName: siteName,
        knownSites: sites,
        jitterIndex: count,
      );

      result.add(
        InspectionMapItem(
          id: vmc.id ?? 'vmc_${DateTime.now().millisecondsSinceEpoch}',
          type: InspectionType.vmc,
          title: vmc.title?.toString() ?? 'VMC Terrain',
          reference: vmc.reference?.toString() ?? '#VMC',
          site: siteName,
          locality: siteName,
          province: 'Madagascar',
          latitude: coords.latitude,
          longitude: coords.longitude,
          status: vmc.status?.toString() ?? 'En cours',
          date: vmc.date?.toString() ?? '15 Oct 2026',
          inspector: vmc.inspector?.toString() ?? 'Responsable HSSE',
          conformityRate: vmc.complianceRate != null
              ? vmc.complianceRate.toDouble()
              : 85.0,
          deviationsCount: vmc.deviations,
          rawData: vmc,
        ),
      );
    }

    // 3. SUIVI DU MATÉRIEL (ÉQUIPEMENTS)
    for (final eq in monitorings) {
      final siteName = eq.siteName?.toString() ?? 'Station Galana';
      final clusterKey = _cleanText(siteName);
      final count = siteClusterCount[clusterKey] ?? 0;
      siteClusterCount[clusterKey] = count + 1;

      final coords = resolveCoordinates(
        siteName: siteName,
        knownSites: sites,
        jitterIndex: count,
      );

      result.add(
        InspectionMapItem(
          id: eq.id ?? 'eq_${DateTime.now().millisecondsSinceEpoch}',
          type: InspectionType.equipment,
          title: 'Contrôle Matériel • ${eq.reference ?? siteName}',
          reference: eq.reference?.toString() ?? '#EQ',
          site: siteName,
          locality: siteName,
          province: 'Madagascar',
          latitude: coords.latitude,
          longitude: coords.longitude,
          status: eq.status?.toString() ?? 'En cours',
          date: eq.date?.toString() ?? '16 Oct 2026',
          inspector: eq.inspector?.toString() ?? 'Technicien HSSE',
          conformityRate: eq.conformityRate != null
              ? eq.conformityRate.toDouble()
              : 90.0,
          deviationsCount: eq.items
              ?.where((item) => item.conformity == false)
              .length,
          rawData: eq,
        ),
      );
    }

    return result;
  }
}
