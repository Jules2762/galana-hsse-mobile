import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';

class EquipmentCard extends StatelessWidget {
  final String tagNumber;
  final String designation;
  final String type;
  final String site;
  final String location;
  final String lastControlDate;
  final String nextDueDate;
  final String status;
  final String inspectionStatus;
  final String pressureStatus;
  final bool isPendingSync;
  final VoidCallback? onTap;
  final VoidCallback? onQuickCheck;

  const EquipmentCard({
    super.key,
    required this.tagNumber,
    required this.designation,
    required this.type,
    required this.site,
    required this.location,
    required this.lastControlDate,
    required this.nextDueDate,
    required this.status,
    this.inspectionStatus = "En cours",
    this.pressureStatus = "Normal",
    this.isPendingSync = false,
    this.onTap,
    this.onQuickCheck,
  });


  Color get _statusBgColor {
    switch (status.toLowerCase()) {
      case 'conforme':
        return const Color(0xFFDCFCE7);
      case 'contrôle requis':
      case 'controle requis':
      case 'à réviser':
        return const Color(0xFFFEF3C7);
      case 'non-conforme':
      case 'expiré':
      case 'hors service':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color get _statusTextColor {
    switch (status.toLowerCase()) {
      case 'conforme':
        return const Color(0xFF15803D);
      case 'contrôle requis':
      case 'controle requis':
      case 'à réviser':
        return const Color(0xFFB45309);
      case 'non-conforme':
      case 'expiré':
      case 'hors service':
        return const Color(0xFFB91C1C);
      default:
        return const Color(0xFF475569);
    }
  }

  Color get _inspectionStatusBgColor {
    switch (inspectionStatus.toLowerCase()) {
      case 'terminée':
      case 'clôturée':
      case 'completed':
        return const Color(0xFFDDF7E5);
      case 'en cours':
      case 'in_progress':
        return const Color(0xFFE8F0FF);
      case 'planifiée':
      case 'draft':
      case 'brouillon':
        return const Color(0xFFF1F5F9);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color get _inspectionStatusTextColor {
    switch (inspectionStatus.toLowerCase()) {
      case 'terminée':
      case 'clôturée':
      case 'completed':
        return const Color(0xFF15803D);
      case 'en cours':
      case 'in_progress':
        return const Color(0xFF1D4ED8);
      case 'planifiée':
      case 'draft':
      case 'brouillon':
        return const Color(0xFF64748B);
      default:
        return const Color(0xFF475569);
    }
  }

  IconData get _equipmentIcon {
    final t = type.toLowerCase();
    if (t.contains('p50') || t.contains('p9') || t.contains('co2') || t.contains('extincteur')) {
      return Icons.fire_extinguisher;
    }
    if (t.contains('ria')) return Icons.water_drop_outlined;
    if (t.contains('cuve') || t.contains('bac')) return Icons.storage;
    if (t.contains('poubelle') || t.contains('déchet')) return Icons.delete_outline;
    if (t.contains('sécurité') || t.contains('caf') || t.contains('caisse')) return Icons.shield_outlined;
    if (t.contains('signal') || t.contains('picto') || t.contains('panneau')) return Icons.warning_amber_rounded;
    return Icons.build_circle_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================== EN-TÊTE TAG & STATUT ====================
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_equipmentIcon, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tagNumber,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        type,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isPendingSync) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cloud_upload_outlined, size: 11, color: Color(0xFFD97706)),
                            SizedBox(width: 3),
                            Text(
                              "Sync",
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: _inspectionStatusBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        inspectionStatus,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _inspectionStatusTextColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusBgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _statusTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),


            const SizedBox(height: 12),

            // ==================== DÉSIGNATION ====================
            Text(
              designation,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            // ==================== LOCALISATION ====================
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "$site • $location",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),

            // ==================== INFOS D'INSPECTION & ACTIONS ====================
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.speed, size: 13, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            "Pression: $pressureStatus",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "Dernier: $lastControlDate • Échéance: $nextDueDate",
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onQuickCheck != null)
                  ElevatedButton.icon(
                    onPressed: onQuickCheck,
                    icon: const Icon(Icons.check_circle_outline, size: 14),
                    label: const Text("Contrôler"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
