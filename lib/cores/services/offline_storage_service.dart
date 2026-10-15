import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gestion_hsse/cores/models/report_model.dart';
import 'package:gestion_hsse/views/home/inspection/checklist/checklist_list_view.dart';
import 'package:gestion_hsse/views/home/inspection/equipment/equipment_list_view.dart';
import 'package:gestion_hsse/views/home/inspection/vmc/vmc_list_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service de persistance locale des données d'inspections pour le mode hors-ligne
class OfflineStorageService {
  static const String _keyVmcs = 'offline_cached_vmcs';
  static const String _keyChecklists = 'offline_cached_checklists';
  static const String _keyEquipments = 'offline_cached_equipments';
  static const String _keyReports = 'offline_cached_reports';
  static const String _keyVmcDetailPrefix = 'offline_cached_vmc_detail_';


  // ==========================================
  // VMC (Visite Managériale Comportementale)
  // ==========================================

  /// Sauvegarde la liste des VMC en local
  static Future<void> cacheVmcs(List<VmcItemData> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = items.map((item) => {
        'id': item.id,
        'reference': item.reference,
        'title': item.title,
        'site': item.site,
        'type': item.type,
        'code': item.code,
        'category': item.category,
        'inspector': item.inspector,
        'date': item.date,
        'status': item.status,
        'positivePoints': item.positivePoints,
        'deviations': item.deviations,
        'complianceRate': item.complianceRate,
        'participantsCount': item.participantsCount,
        'theme': item.theme,
      }).toList();
      await prefs.setString(_keyVmcs, jsonEncode(list));
    } catch (e) {
      debugPrint('[OfflineStorage] Erreur cache VMCs: $e');
    }
  }

  /// Récupère la liste des VMC en local
  static Future<List<VmcItemData>> getCachedVmcs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyVmcs);
      if (raw != null && raw.isNotEmpty) {
        final List list = jsonDecode(raw);
        return list.map((json) => VmcItemData.fromJson(Map<String, dynamic>.from(json))).toList();
      }
    } catch (e) {
      debugPrint('[OfflineStorage] Erreur lecture VMCs en cache: $e');
    }
    return [];
  }

  /// Met à jour une VMC spécifique en local (ex: clôture hors-ligne)
  static Future<void> updateCachedVmcStatus(int id, String newStatus) async {
    try {
      final items = await getCachedVmcs();
      final index = items.indexWhere((item) => item.id == id);
      if (index != -1) {
        final old = items[index];
        items[index] = VmcItemData(
          id: old.id,
          reference: old.reference,
          title: old.title,
          site: old.site,
          type: old.type,
          code: old.code,
          category: old.category,
          inspector: old.inspector,
          date: old.date,
          status: newStatus,
          positivePoints: old.positivePoints,
          deviations: old.deviations,
          complianceRate: old.complianceRate,
          participantsCount: old.participantsCount,
          theme: old.theme,
          rawData: old.rawData,
        );
        await cacheVmcs(items);
      }
    } catch (_) {}
  }


  /// Sauvegarde les détails complets d'une VMC
  static Future<void> cacheVmcDetail(int id, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_keyVmcDetailPrefix$id', jsonEncode(data));
    } catch (_) {}
  }

  /// Récupère les détails complets d'une VMC en local
  static Future<Map<String, dynamic>?> getCachedVmcDetail(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_keyVmcDetailPrefix$id');
      if (raw != null && raw.isNotEmpty) {
        return jsonDecode(raw) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  // ==========================================
  // CHECKLISTS
  // ==========================================

  /// Sauvegarde la liste des checklists en local
  static Future<void> cacheChecklists(List<ChecklistItemData> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = items.map((item) => {
        'title': item.title,
        'site': item.site,
        'inspector': item.inspector,
        'date': item.date,
        'progress': item.progress,
        'status': item.status,
      }).toList();
      await prefs.setString(_keyChecklists, jsonEncode(list));
    } catch (e) {
      debugPrint('[OfflineStorage] Erreur cache Checklists: $e');
    }
  }

  /// Récupère la liste des checklists en local
  static Future<List<ChecklistItemData>> getCachedChecklists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyChecklists);
      if (raw != null && raw.isNotEmpty) {
        final List list = jsonDecode(raw);
        return list.map((json) => ChecklistItemData(
          title: json['title'] ?? '',
          site: json['site'] ?? '',
          inspector: json['inspector'] ?? '',
          date: json['date'] ?? '',
          progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
          status: json['status'] ?? 'En cours',
        )).toList();
      }
    } catch (e) {
      debugPrint('[OfflineStorage] Erreur lecture Checklists en cache: $e');
    }
    return [];
  }

  /// Met à jour une checklist en local après réalisation du contrôle
  static Future<void> updateCachedChecklist(ChecklistItemData updated) async {
    try {
      final items = await getCachedChecklists();
      final index = items.indexWhere((item) => item.title == updated.title && item.site == updated.site);
      if (index != -1) {
        items[index] = updated;
      } else {
        items.insert(0, updated);
      }
      await cacheChecklists(items);
    } catch (_) {}
  }

  // ==========================================
  // SUIVI MATÉRIEL (EQUIPMENT MONITORING)
  // ==========================================

  /// Sauvegarde la liste des équipements en local
  static Future<void> cacheEquipments(List<EquipmentItemData> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = items.map((item) => {
        'tagNumber': item.tagNumber,
        'designation': item.designation,
        'type': item.type,
        'site': item.site,
        'location': item.location,
        'lastControlDate': item.lastControlDate,
        'nextDueDate': item.nextDueDate,
        'status': item.status,
        'pressureStatus': item.pressureStatus,
      }).toList();
      await prefs.setString(_keyEquipments, jsonEncode(list));
    } catch (e) {
      debugPrint('[OfflineStorage] Erreur cache Équipements: $e');
    }
  }

  /// Récupère la liste des équipements en local
  static Future<List<EquipmentItemData>> getCachedEquipments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyEquipments);
      if (raw != null && raw.isNotEmpty) {
        final List list = jsonDecode(raw);
        return list.map((json) => EquipmentItemData(
          tagNumber: json['tagNumber'] ?? '',
          designation: json['designation'] ?? '',
          type: json['type'] ?? '',
          site: json['site'] ?? '',
          location: json['location'] ?? '',
          lastControlDate: json['lastControlDate'] ?? '',
          nextDueDate: json['nextDueDate'] ?? '',
          status: json['status'] ?? 'Conforme',
          pressureStatus: json['pressureStatus'] ?? '',
        )).toList();
      }
    } catch (e) {
      debugPrint('[OfflineStorage] Erreur lecture Équipements en cache: $e');
    }
    return [];
  }

  /// Met à jour un équipement en local après contrôle terrain
  static Future<void> updateCachedEquipment(EquipmentItemData updated) async {
    try {
      final items = await getCachedEquipments();
      final index = items.indexWhere((item) => item.tagNumber == updated.tagNumber);
      if (index != -1) {
        items[index] = updated;
      } else {
        items.add(updated);
      }
      await cacheEquipments(items);
    } catch (_) {}
  }

  // ==========================================
  // RAPPORTS HSSE (Inspections & Audits)
  // ==========================================

  /// Sauvegarde la liste des rapports en local
  static Future<void> cacheReports(List<ReportModel> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = items.map((r) => r.toJson()).toList();
      await prefs.setString(_keyReports, jsonEncode(list));
    } catch (e) {
      debugPrint('[OfflineStorage] Erreur cache Rapports: $e');
    }
  }

  /// Récupère la liste des rapports en local
  static Future<List<ReportModel>> getCachedReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyReports);
      if (raw != null && raw.isNotEmpty) {
        final List list = jsonDecode(raw);
        return list
            .map((json) => ReportModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }
    } catch (e) {
      debugPrint('[OfflineStorage] Erreur lecture Rapports en cache: $e');
    }
    return [];
  }
}
