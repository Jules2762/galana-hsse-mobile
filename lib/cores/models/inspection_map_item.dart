import 'package:flutter/material.dart';

enum InspectionType { checklist, vmc, equipment }

class InspectionMapItem {
  final dynamic id;
  final InspectionType type;
  final String title;
  final String reference;
  final String site;
  final String locality;
  final String province;
  final double latitude;
  final double longitude;
  final String status;
  final String date;
  final String inspector;
  final double? conformityRate;
  final int? deviationsCount;
  final dynamic rawData;

  const InspectionMapItem({
    required this.id,
    required this.type,
    required this.title,
    required this.reference,
    required this.site,
    required this.locality,
    required this.province,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.date,
    required this.inspector,
    this.conformityRate,
    this.deviationsCount,
    this.rawData,
  });

  String get typeLabel {
    switch (type) {
      case InspectionType.checklist:
        return 'Checklist';
      case InspectionType.vmc:
        return 'VMC';
      case InspectionType.equipment:
        return 'Suivi Matériel';
    }
  }

  String get typeEmoji {
    switch (type) {
      case InspectionType.checklist:
        return '📋';
      case InspectionType.vmc:
        return '🛡️';
      case InspectionType.equipment:
        return '🧯';
    }
  }

  Color get typeColor {
    switch (type) {
      case InspectionType.checklist:
        return const Color(0xFF2563EB); // Bleu Royal
      case InspectionType.vmc:
        return const Color(0xFFEA580C); // Orange VMC
      case InspectionType.equipment:
        return const Color(0xFF059669); // Vert émeraude Matériel
    }
  }

  IconData get typeIcon {
    switch (type) {
      case InspectionType.checklist:
        return Icons.fact_check_rounded;
      case InspectionType.vmc:
        return Icons.verified_user_rounded;
      case InspectionType.equipment:
        return Icons.fire_extinguisher_rounded;
    }
  }

  Color get statusColor {
    final s = status.toLowerCase();
    if (s.contains('termin') ||
        (s.contains('conforme') &&
            !s.contains('non') &&
            !s.contains('partiel')) ||
        s == 'completed') {
      return const Color(0xFF16A34A); // Vert
    }
    if (s.contains('partiel') ||
        s.contains('cours') ||
        s.contains('in_progress')) {
      return const Color(0xFFD97706); // Ambre
    }
    if (s.contains('non') || s.contains('anomalie') || s.contains('alerte')) {
      return const Color(0xFFDC2626); // Rouge
    }
    return const Color(0xFF64748B); // Gris
  }
}
