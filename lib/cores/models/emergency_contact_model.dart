import 'package:flutter/material.dart';

class EmergencyContactModel {
  final dynamic id;
  final String name;
  final String type; // POMPIER, HOPITAL, AMBULANCE, POLICE, GENDARMERIE
  final String locality;
  final String? province;
  final double? latitude;
  final double? longitude;
  final String contact1;
  final String? contact2;
  final String? contact3;
  final String? email;
  final String? address;
  final String? notes;
  final List<String> siteNames;
  final double? distanceKm;

  const EmergencyContactModel({
    required this.id,
    required this.name,
    required this.type,
    required this.locality,
    this.province,
    this.latitude,
    this.longitude,
    required this.contact1,
    this.contact2,
    this.contact3,
    this.email,
    this.address,
    this.notes,
    this.siteNames = const [],
    this.distanceKm,
  });

  String get typeLabel {
    switch (type.toUpperCase()) {
      case 'POMPIER':
        return 'Sapeurs-Pompiers';
      case 'HOPITAL':
        return 'Hôpital / Clinique';
      case 'AMBULANCE':
        return 'Ambulance / SAMU';
      case 'POLICE':
        return 'Police Nationale';
      case 'GENDARMERIE':
        return 'Gendarmerie';
      default:
        return 'Secours';
    }
  }

  String get typeEmoji {
    switch (type.toUpperCase()) {
      case 'POMPIER':
        return '🚒';
      case 'HOPITAL':
        return '🏥';
      case 'AMBULANCE':
        return '🚑';
      case 'POLICE':
        return '👮';
      case 'GENDARMERIE':
        return '🛡️';
      default:
        return '🚨';
    }
  }

  Color get typeColor {
    switch (type.toUpperCase()) {
      case 'POMPIER':
        return const Color(0xFFDC2626); // Rouge vif
      case 'HOPITAL':
        return const Color(0xFF059669); // Vert émeraude
      case 'AMBULANCE':
        return const Color(0xFF0284C7); // Bleu ciel
      case 'POLICE':
        return const Color(0xFF4F46E5); // Indigo
      case 'GENDARMERIE':
        return const Color(0xFF7C3AED); // Violet
      default:
        return const Color(0xFFEA580C);
    }
  }

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) {
    // Parsing des sites Galana rattachés
    List<String> parsedSites = [];
    if (json['sites'] is List) {
      for (final s in json['sites']) {
        if (s is Map && s['name'] != null) {
          parsedSites.add(s['name'].toString());
        } else if (s != null) {
          parsedSites.add(s.toString());
        }
      }
    } else if (json['site_names'] is List) {
      parsedSites = (json['site_names'] as List).map((e) => e.toString()).toList();
    }

    double? parseCoord(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    // Coordonnées soit directes, soit imbriquées dans location
    double? lat = parseCoord(json['latitude']);
    double? lng = parseCoord(json['longitude']);
    String? prov = json['province']?.toString();

    if (json['location'] is Map) {
      final loc = json['location'] as Map;
      lat ??= parseCoord(loc['latitude']);
      lng ??= parseCoord(loc['longitude']);
      prov ??= loc['province']?.toString();
    }

    return EmergencyContactModel(
      id: json['id'] ?? UniqueKey().toString(),
      name: json['name']?.toString() ?? 'Service de secours',
      type: (json['type']?.toString() ?? 'POMPIER').toUpperCase(),
      locality: json['locality']?.toString() ?? 'Madagascar',
      province: prov,
      latitude: lat,
      longitude: lng,
      contact1: json['contact_1']?.toString() ?? json['phone']?.toString() ?? '118',
      contact2: json['contact_2']?.toString(),
      contact3: json['contact_3']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      notes: json['notes']?.toString(),
      siteNames: parsedSites,
      distanceKm: parseCoord(json['distance_km']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'locality': locality,
      'province': province,
      'latitude': latitude,
      'longitude': longitude,
      'contact_1': contact1,
      'contact_2': contact2,
      'contact_3': contact3,
      'email': email,
      'address': address,
      'notes': notes,
      'site_names': siteNames,
      'distance_km': distanceKm,
    };
  }

  EmergencyContactModel copyWith({
    dynamic id,
    String? name,
    String? type,
    String? locality,
    String? province,
    double? latitude,
    double? longitude,
    String? contact1,
    String? contact2,
    String? contact3,
    String? email,
    String? address,
    String? notes,
    List<String>? siteNames,
    double? distanceKm,
  }) {
    return EmergencyContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      locality: locality ?? this.locality,
      province: province ?? this.province,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      contact1: contact1 ?? this.contact1,
      contact2: contact2 ?? this.contact2,
      contact3: contact3 ?? this.contact3,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      siteNames: siteNames ?? this.siteNames,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}

class EmergencySiteModel {
  final int id;
  final String name;
  final String? locality;
  final String? province;
  final double? latitude;
  final double? longitude;
  final String? code;

  const EmergencySiteModel({
    required this.id,
    required this.name,
    this.locality,
    this.province,
    this.latitude,
    this.longitude,
    this.code,
  });

  factory EmergencySiteModel.fromJson(Map<String, dynamic> json) {
    double? parseCoord(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    final rawId = json['id'];
    final id = rawId is int ? rawId : (int.tryParse(rawId.toString()) ?? 0);

    return EmergencySiteModel(
      id: id,
      name: json['name']?.toString() ?? 'Station Galana',
      locality: json['locality']?.toString() ?? json['location']?['locality']?.toString(),
      province: json['province']?.toString() ?? json['location']?['province']?.toString(),
      latitude: parseCoord(json['latitude'] ?? json['location']?['latitude']),
      longitude: parseCoord(json['longitude'] ?? json['location']?['longitude']),
      code: json['code']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'locality': locality,
      'province': province,
      'latitude': latitude,
      'longitude': longitude,
      'code': code,
    };
  }
}
