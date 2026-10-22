import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gestion_hsse/cores/models/emergency_contact_model.dart';
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
  static const String _keyEquipmentMonitorings = 'offline_cached_equipment_monitorings';
  static const String _keyReports = 'offline_cached_reports';
  static const String _keyEmergencyContacts = 'offline_cached_emergency_contacts';
  static const String _keyEmergencySites = 'offline_cached_emergency_sites';
  static const String _keyVmcDetailPrefix = 'offline_cached_vmc_detail_';
  static const String _keyChecklistDetailPrefix = 'offline_cached_checklist_detail_';


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

  /// Sauvegarde les détails complets d'une Checklist en local
  static Future<void> cacheChecklistDetail(dynamic id, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_keyChecklistDetailPrefix$id', jsonEncode(data));
    } catch (_) {}
  }

  /// Récupère les détails complets d'une Checklist en local
  static Future<Map<String, dynamic>?> getCachedChecklistDetail(dynamic id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_keyChecklistDetailPrefix$id');
      if (raw != null && raw.isNotEmpty) {
        return jsonDecode(raw) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  // ==========================================
  // SUIVI MATÉRIEL (EQUIPMENT MONITORING)
  // ==========================================

  /// Sauvegarde la liste des équipements en local
  static Future<void> cacheEquipments(List<EquipmentItemData> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = items.map((item) => item.toJson()).toList();
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
        return list.map((json) => EquipmentItemData.fromJson(Map<String, dynamic>.from(json))).toList();
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
      final index = items.indexWhere((item) {
        if (updated.id != null && item.id != null) return item.id == updated.id;
        return item.tagNumber == updated.tagNumber;
      });
      if (index != -1) {
        items[index] = updated;
      } else {
        items.insert(0, updated);
      }
      await cacheEquipments(items);
    } catch (_) {}
  }

  /// Ajoute un nouvel équipement en local
  static Future<void> addCachedEquipment(EquipmentItemData item) async {
    try {
      final items = await getCachedEquipments();
      items.insert(0, item);
      await cacheEquipments(items);
    } catch (_) {}
  }

  /// Supprime un équipement du cache local
  static Future<void> deleteCachedEquipment(int? id, String tagNumber) async {
    try {
      final items = await getCachedEquipments();
      items.removeWhere((item) {
        if (id != null && item.id != null) return item.id == id;
        return item.tagNumber == tagNumber;
      });
      await cacheEquipments(items);
    } catch (_) {}
  }

  // ==========================================
  // SUIVIS MATÉRIELS (EQUIPMENT MONITORINGS)
  // ==========================================

  /// Sauvegarde la liste des sessions de suivi matériel en local
  static Future<void> cacheEquipmentMonitorings(List<EquipmentMonitoringData> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = items.map((m) => m.toJson()).toList();
      await prefs.setString(_keyEquipmentMonitorings, jsonEncode(list));
    } catch (e) {
      debugPrint('[OfflineStorage] Erreur cache Suivis Matériels: $e');
    }
  }

  /// Récupère la liste des sessions de suivi matériel en local
  static Future<List<EquipmentMonitoringData>> getCachedEquipmentMonitorings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyEquipmentMonitorings);
      if (raw != null && raw.isNotEmpty) {
        final List list = jsonDecode(raw);
        return list.map((json) => EquipmentMonitoringData.fromJson(Map<String, dynamic>.from(json))).toList();
      }
    } catch (e) {
      debugPrint('[OfflineStorage] Erreur lecture Suivis Matériels en cache: $e');
    }
    return [];
  }

  /// Ajoute une nouvelle session de suivi matériel en local
  static Future<void> addCachedEquipmentMonitoring(EquipmentMonitoringData item) async {
    try {
      final items = await getCachedEquipmentMonitorings();
      items.insert(0, item);
      await cacheEquipmentMonitorings(items);
    } catch (_) {}
  }

  /// Met à jour une session de suivi matériel en local
  static Future<void> updateCachedEquipmentMonitoring(EquipmentMonitoringData updated) async {
    try {
      final items = await getCachedEquipmentMonitorings();
      final index = items.indexWhere((m) {
        if (updated.id != null && m.id != null) return m.id.toString() == updated.id.toString();
        return m.reference == updated.reference;
      });
      if (index != -1) {
        items[index] = updated;
      } else {
        items.insert(0, updated);
      }
      await cacheEquipmentMonitorings(items);
    } catch (_) {}
  }

  /// Supprime une session de suivi matériel du cache local
  static Future<void> deleteCachedEquipmentMonitoring(dynamic id) async {
    try {
      final items = await getCachedEquipmentMonitorings();
      items.removeWhere((m) => m.id?.toString() == id?.toString() || m.reference == id?.toString());
      await cacheEquipmentMonitorings(items);
    } catch (_) {}
  }

  /// Ajoute un matériel dans une session de suivi spécifique en local
  static Future<void> addItemToMonitoringInCache(dynamic monitoringId, EquipmentItemData item) async {
    try {
      final monitorings = await getCachedEquipmentMonitorings();
      final idx = monitorings.indexWhere((m) =>
          m.id?.toString() == monitoringId?.toString() || m.reference == monitoringId?.toString());
      if (idx != -1) {
        final current = monitorings[idx];
        final updatedItems = List<EquipmentItemData>.from(current.items);
        updatedItems.insert(0, item);
        final total = updatedItems.length;
        final confCount = updatedItems.where((i) => i.conformity).length;
        final rate = total > 0 ? (confCount / total) * 100.0 : 100.0;
        String newStatus = current.status;
        String newRawStatus = current.rawStatus;
        if (current.status.toLowerCase().contains('planifi') || current.rawStatus.toUpperCase() == 'DRAFT') {
          newStatus = 'En cours';
          newRawStatus = 'IN_PROGRESS';
        }

        monitorings[idx] = current.copyWith(
          items: updatedItems,
          conformityRate: rate,
          status: newStatus,
          rawStatus: newRawStatus,
        );
        await cacheEquipmentMonitorings(monitorings);
      }
      await addCachedEquipment(item);
    } catch (_) {}
  }

  /// Met à jour un matériel dans une session de suivi en local
  static Future<void> updateItemInMonitoringInCache(dynamic monitoringId, EquipmentItemData item) async {
    try {
      final monitorings = await getCachedEquipmentMonitorings();
      final idx = monitorings.indexWhere((m) =>
          m.id?.toString() == monitoringId?.toString() || m.reference == monitoringId?.toString());
      if (idx != -1) {
        final current = monitorings[idx];
        final updatedItems = List<EquipmentItemData>.from(current.items);
        final itemIdx = updatedItems.indexWhere((i) =>
            (item.id != null && i.id != null && i.id == item.id) || i.tagNumber == item.tagNumber);
        if (itemIdx != -1) {
          updatedItems[itemIdx] = item;
        } else {
          updatedItems.insert(0, item);
        }
        final total = updatedItems.length;
        final confCount = updatedItems.where((i) => i.conformity).length;
        final rate = total > 0 ? (confCount / total) * 100.0 : 100.0;
        monitorings[idx] = current.copyWith(
          items: updatedItems,
          conformityRate: rate,
        );
        await cacheEquipmentMonitorings(monitorings);
      }
      await updateCachedEquipment(item);
    } catch (_) {}
  }

  /// Supprime un matériel d'une session de suivi en local
  static Future<void> deleteItemFromMonitoringInCache(dynamic monitoringId, int? itemId, String tagNumber) async {
    try {
      final monitorings = await getCachedEquipmentMonitorings();
      final idx = monitorings.indexWhere((m) =>
          m.id?.toString() == monitoringId?.toString() || m.reference == monitoringId?.toString());
      if (idx != -1) {
        final current = monitorings[idx];
        final updatedItems = List<EquipmentItemData>.from(current.items);
        updatedItems.removeWhere((i) {
          if (itemId != null && i.id != null) return i.id == itemId;
          return i.tagNumber == tagNumber;
        });
        final total = updatedItems.length;
        final confCount = updatedItems.where((i) => i.conformity).length;
        final rate = total > 0 ? (confCount / total) * 100.0 : 100.0;
        monitorings[idx] = current.copyWith(
          items: updatedItems,
          conformityRate: rate,
        );
        await cacheEquipmentMonitorings(monitorings);
      }
      await deleteCachedEquipment(itemId, tagNumber);
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

  // ==========================================
  // CONTACTS D'URGENCE & SECOURS (HSSE)
  // ==========================================

  /// Sauvegarde les contacts d'urgence en local
  static Future<void> cacheEmergencyContacts(List<EmergencyContactModel> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = items.map((c) => c.toJson()).toList();
      await prefs.setString(_keyEmergencyContacts, jsonEncode(list));
    } catch (e) {
      debugPrint('[OfflineStorage] Erreur cache Contacts d urgence: $e');
    }
  }

  /// Récupère les contacts d'urgence en local
  static Future<List<EmergencyContactModel>> getCachedEmergencyContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyEmergencyContacts);
      if (raw != null && raw.isNotEmpty) {
        final List list = jsonDecode(raw);
        return list
            .map((json) => EmergencyContactModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }
    } catch (e) {
      debugPrint('[OfflineStorage] Erreur lecture Contacts d urgence en cache: $e');
    }
    return [];
  }

  /// Sauvegarde les stations Galana pour le module d'urgence
  static Future<void> cacheEmergencySites(List<EmergencySiteModel> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = items.map((s) => s.toJson()).toList();
      await prefs.setString(_keyEmergencySites, jsonEncode(list));
    } catch (e) {
      debugPrint('[OfflineStorage] Erreur cache Stations Galana: $e');
    }
  }

  /// Récupère les stations Galana en local
  static Future<List<EmergencySiteModel>> getCachedEmergencySites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyEmergencySites);
      if (raw != null && raw.isNotEmpty) {
        final List list = jsonDecode(raw);
        return list
            .map((json) => EmergencySiteModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }
    } catch (e) {
      debugPrint('[OfflineStorage] Erreur lecture Stations Galana en cache: $e');
    }
    return [];
  }
}
