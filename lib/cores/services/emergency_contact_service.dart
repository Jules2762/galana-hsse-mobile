import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gestion_hsse/cores/api/api_client.dart';
import 'package:gestion_hsse/cores/models/emergency_contact_model.dart';
import 'package:gestion_hsse/cores/services/offline_storage_service.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactService {
  /// Répertoire de secours pré-embarqué par défaut en cas d'absence totale de réseau
  static final List<EmergencyContactModel> defaultEmergencyContacts = [
    const EmergencyContactModel(
      id: 'default_1',
      name: 'C.U.A Tsaralalana (Sapeurs-Pompiers)',
      type: 'POMPIER',
      locality: 'ANTANANARIVO',
      province: 'ANTANANARIVO',
      contact1: '118',
      contact2: '0202222566',
      contact3: '0341400118',
      address: 'Rue Tsaralalana, Antananarivo 101',
      notes: 'Centre d\'incendie et de secours principal pour les dépôts et stations de la capitale.',
      siteNames: ['SS ANKORONDRANO', 'SS ANALAKELY', 'SS TALATAMATY', 'SS ANKADIMBAHOAKA'],
    ),
    const EmergencyContactModel(
      id: 'default_2',
      name: 'CHU Joseph Ravoahangy Andrianavalona (HJRA)',
      type: 'HOPITAL',
      locality: 'ANTANANARIVO',
      province: 'ANTANANARIVO',
      contact1: '0202227979',
      contact2: '0340555555',
      address: 'Ampefiloha, Antananarivo',
      notes: 'Urgences chirurgicales, réanimation et centre des grands brûlés.',
      siteNames: ['SS ANALAKELY', 'SS ANKORONDRANO', 'SS ANKADIMBAHOAKA'],
    ),
    const EmergencyContactModel(
      id: 'default_3',
      name: 'SAMU Urgences Médicales & Ambulances',
      type: 'AMBULANCE',
      locality: 'ANTANANARIVO',
      province: 'ANTANANARIVO',
      contact1: '124',
      contact2: '0340500124',
      address: 'HJRA Ampefiloha',
      notes: 'Intervention médicale d\'urgence et évacuation sanitaire sur site.',
    ),
    const EmergencyContactModel(
      id: 'default_4',
      name: 'Police Nationale Secours (Commissariat Central)',
      type: 'POLICE',
      locality: 'ANTANANARIVO',
      province: 'ANTANANARIVO',
      contact1: '117',
      contact2: '0202222735',
      contact3: '0340599811',
      address: 'Tsaralalana, Antananarivo',
      notes: 'Sécurité publique, barrage routier et protection périmétrique.',
    ),
    const EmergencyContactModel(
      id: 'default_5',
      name: 'Gendarmerie Nationale (Toby Ratsimandrava)',
      type: 'GENDARMERIE',
      locality: 'ANTANANARIVO',
      province: 'ANTANANARIVO',
      contact1: '119',
      contact2: '0340500012',
      address: 'Andrefan\'Ambohijanahary, Antananarivo',
      notes: 'Interventions sur axes nationaux, convois citernes et dépôts hors agglomération.',
    ),
    const EmergencyContactModel(
      id: 'default_6',
      name: 'Centre de Secours & Pompiers Toamasina',
      type: 'POMPIER',
      locality: 'TOAMASINA',
      province: 'TOAMASINA',
      contact1: '118',
      contact2: '0205332555',
      contact3: '0341400218',
      address: 'Boulevard Joffre, Toamasina',
      notes: 'Unité d\'intervention incendie proche du terminal pétrolier de Tamatave.',
      siteNames: ['DEPOT TOAMASINA', 'SS BAZAR KELY', 'SS BOULEVARD DE LA LIBERTE'],
    ),
    const EmergencyContactModel(
      id: 'default_7',
      name: 'CHU Morafeno Toamasina',
      type: 'HOPITAL',
      locality: 'TOAMASINA',
      province: 'TOAMASINA',
      contact1: '0205332100',
      address: 'Morafeno, Toamasina',
      notes: 'Prise en charge des urgences traumatologiques et intoxications hydrocarbures.',
    ),
    const EmergencyContactModel(
      id: 'default_8',
      name: 'Sapeurs-Pompiers d\'Antsirabe',
      type: 'POMPIER',
      locality: 'ANTSIRABE',
      province: 'ANTANANARIVO',
      contact1: '118',
      contact2: '0204448555',
      address: 'Avenue de la Gare, Antsirabe',
      notes: 'Intervention sur les stations du Vakinankaratra et axe RN7.',
      siteNames: ['DEPOT ANTSIRABE', 'SS AS HOTEL ANTSIRABE'],
    ),
    const EmergencyContactModel(
      id: 'default_9',
      name: 'Corps des Sapeurs-Pompiers de Mahajanga',
      type: 'POMPIER',
      locality: 'MAHAJANGA',
      province: 'MAHAJANGA',
      contact1: '118',
      contact2: '0206222222',
      address: 'Mangarivotra, Mahajanga',
      notes: 'Secours incendie littoral et couverture des dépôts pétroliers de Majunga.',
      siteNames: ['DEPOT MAHAJANGA', 'SS MAJ STYLE'],
    ),
    const EmergencyContactModel(
      id: 'default_10',
      name: 'Centre Hospitalier Universitaire d\'Androva',
      type: 'HOPITAL',
      locality: 'MAHAJANGA',
      province: 'MAHAJANGA',
      contact1: '0206222481',
      address: 'Androva, Mahajanga',
      notes: 'Service d\'accueil des urgences et réanimation.',
    ),
  ];

  /// Récupère la liste des contacts d'urgence (En ligne ou Cache local)
  static Future<List<EmergencyContactModel>> getEmergencyContacts({
    String? search,
    String? type,
    String? locality,
    int? stationId,
    String? province,
  }) async {
    // 1. Tentative de récupération en ligne via l'API
    try {
      await ApiClient.ensureAuthenticated();

      final Map<String, dynamic> queryParams = {};
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (type != null && type.isNotEmpty && type != 'ALL') {
        queryParams['type'] = type;
      }
      if (locality != null && locality.trim().isNotEmpty) {
        queryParams['locality'] = locality.trim();
      }
      if (stationId != null) {
        queryParams['station_id'] = stationId;
      }
      if (province != null && province.isNotEmpty && province != 'ALL') {
        queryParams['province'] = province;
      }

      final response = await ApiClient.dio.get(
        '/emergency-contacts',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final rawData = response.data['data'] ?? response.data;
        if (rawData is List) {
          final items = rawData
              .map<EmergencyContactModel>((json) =>
                  EmergencyContactModel.fromJson(Map<String, dynamic>.from(json)))
              .toList();

          if (items.isNotEmpty && queryParams.isEmpty) {
            // Mise en cache hors-ligne
            await OfflineStorageService.cacheEmergencyContacts(items);
          }
          return items;
        }
      }
    } catch (_) {
      // Échec réseau : bascule silencieuse sur le mode hors-ligne
    }

    // 2. Lecture du cache local
    final cached = await OfflineStorageService.getCachedEmergencyContacts();
    if (cached.isNotEmpty) {
      return _applyLocalFilters(cached, search, type, locality, province);
    }

    // 3. Fallback sur les secours par défaut de Madagascar
    return _applyLocalFilters(defaultEmergencyContacts, search, type, locality, province);
  }

  /// Récupère les données complètes carte et stations (secours + stations Galana)
  static Future<Map<String, dynamic>> getMapData() async {
    try {
      await ApiClient.ensureAuthenticated();
      final response = await ApiClient.dio.get('/emergency-contacts/map-data');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final contactsRaw = data['contacts'] as List? ?? [];
        final sitesRaw = data['sites'] as List? ?? [];

        final contacts = contactsRaw
            .map<EmergencyContactModel>((j) =>
                EmergencyContactModel.fromJson(Map<String, dynamic>.from(j)))
            .toList();

        final sites = sitesRaw
            .map<EmergencySiteModel>((j) =>
                EmergencySiteModel.fromJson(Map<String, dynamic>.from(j)))
            .toList();

        if (contacts.isNotEmpty) {
          await OfflineStorageService.cacheEmergencyContacts(contacts);
        }
        if (sites.isNotEmpty) {
          await OfflineStorageService.cacheEmergencySites(sites);
        }

        return {
          'contacts': contacts,
          'sites': sites,
          'stats': data['stats'] ?? {},
        };
      }
    } catch (_) {}

    // Fallback local pour les stations et secours
    final cachedContacts = await OfflineStorageService.getCachedEmergencyContacts();
    final cachedSites = await OfflineStorageService.getCachedEmergencySites();

    return {
      'contacts': cachedContacts.isNotEmpty ? cachedContacts : defaultEmergencyContacts,
      'sites': cachedSites,
      'stats': {
        'total_contacts': (cachedContacts.isNotEmpty ? cachedContacts : defaultEmergencyContacts).length,
        'total_sites': cachedSites.length,
      },
    };
  }

  /// Filtrage en mémoire pour le mode hors-ligne
  static List<EmergencyContactModel> _applyLocalFilters(
    List<EmergencyContactModel> list,
    String? search,
    String? type,
    String? locality,
    String? province,
  ) {
    return list.where((item) {
      if (type != null && type.isNotEmpty && type != 'ALL') {
        if (item.type.toUpperCase() != type.toUpperCase()) return false;
      }
      if (province != null && province.isNotEmpty && province != 'ALL') {
        if (item.province?.toUpperCase() != province.toUpperCase()) return false;
      }
      if (locality != null && locality.trim().isNotEmpty) {
        if (!item.locality.toUpperCase().contains(locality.toUpperCase().trim())) return false;
      }
      if (search != null && search.trim().isNotEmpty) {
        final q = search.toLowerCase().trim();
        final matchName = item.name.toLowerCase().contains(q);
        final matchLocality = item.locality.toLowerCase().contains(q);
        final matchContact = item.contact1.contains(q) ||
            (item.contact2 != null && item.contact2!.contains(q)) ||
            (item.contact3 != null && item.contact3!.contains(q));
        final matchSites = item.siteNames.any((s) => s.toLowerCase().contains(q));
        if (!matchName && !matchLocality && !matchContact && !matchSites) return false;
      }
      return true;
    }).toList();
  }

  /// Lance un appel téléphonique immédiat depuis le mobile
  static Future<void> callPhone(String rawPhone, BuildContext context) async {
    // Nettoyer le numéro pour ne garder que les chiffres, préfixes et le signe +
    final cleaned = rawPhone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Numéro de téléphone non valide"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final uri = Uri.parse('tel:$cleaned');
    try {
      final canCall = await canLaunchUrl(uri);
      if (canCall) {
        await launchUrl(uri);
      } else {
        // Fallback avec copie dans le presse-papiers
        await Clipboard.setData(ClipboardData(text: cleaned));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Numéro $cleaned copié dans le presse-papiers"),
              backgroundColor: const Color(0xFF0F9D58),
              action: SnackBarAction(
                label: "OK",
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: cleaned));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Numéro $cleaned copié"),
            backgroundColor: const Color(0xFF0F9D58),
          ),
        );
      }
    }
  }
}
