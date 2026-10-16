import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/views/home/inspection/equipment/equipment_list_view.dart';

class EquipmentMonitoringCard extends StatelessWidget {
  final EquipmentMonitoringData monitoring;
  final VoidCallback? onTap;

  const EquipmentMonitoringCard({
    super.key,
    required this.monitoring,
    this.onTap,
  });

  Color get _statusBgColor {
    final s = monitoring.status.toLowerCase();
    if (s.contains('planifi') || s.contains('brouillon') || s == 'draft') {
      return const Color(0xFFFEF3C7);
    } else if (s.contains('cours') || s == 'in_progress') {
      return const Color(0xFFDBEAFE);
    } else if (s.contains('termin') || s.contains('clôtur') || s.contains('clotur') || s == 'completed') {
      return const Color(0xFFDCFCE7);
    } else if (s.contains('annul') || s == 'cancelled') {
      return const Color(0xFFFEE2E2);
    }
    return const Color(0xFFF1F5F9);
  }

  Color get _statusTextColor {
    final s = monitoring.status.toLowerCase();
    if (s.contains('planifi') || s.contains('brouillon') || s == 'draft') {
      return const Color(0xFFB45309);
    } else if (s.contains('cours') || s == 'in_progress') {
      return const Color(0xFF1D4ED8);
    } else if (s.contains('termin') || s.contains('clôtur') || s.contains('clotur') || s == 'completed') {
      return const Color(0xFF15803D);
    } else if (s.contains('annul') || s == 'cancelled') {
      return const Color(0xFFB91C1C);
    }
    return const Color(0xFF475569);
  }

  Color get _complianceColor {
    final rate = monitoring.calculatedRate;
    if (rate >= 90) return const Color(0xFF10B981);
    if (rate >= 70) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final int total = monitoring.totalEquipments;
    final int conformes = monitoring.conformeCount;
    final int anomalies = monitoring.anomalyCount;
    final double rate = monitoring.calculatedRate;

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
            // ==================== EN-TÊTE ====================
            Row(
              children: [
                // Référence chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    monitoring.reference,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Statut de la session
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    monitoring.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusTextColor,
                    ),
                  ),
                ),

                const Spacer(),

                // Indicateur de synchro hors-ligne si besoin
                if (monitoring.isPendingSync)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDBA74)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_upload_outlined, size: 12, color: Color(0xFFEA580C)),
                        SizedBox(width: 3),
                        Text(
                          "En attente",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFEA580C),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // ==================== NOM DU SITE / STATION ====================
            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    monitoring.siteName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ==================== INSPECTEUR & DATE ====================
            Row(
              children: [
                const Icon(Icons.person_outline_rounded, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    monitoring.inspector,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  monitoring.date,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),

            // Observation si présente
            if (monitoring.observations != null && monitoring.observations!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                monitoring.observations!,
                style: const TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF94A3B8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),

            // ==================== STATS & COMPTEURS ====================
            Row(
              children: [
                // Badge Total Matériels
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "$total matériel${total > 1 ? 's' : ''}",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Conformes
                if (total > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "✓ $conformes",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ),

                if (anomalies > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "⚠ $anomalies",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB91C1C),
                      ),
                    ),
                  ),
                ],

                const Spacer(),

                // Pourcentage de conformité
                if (total > 0)
                  Text(
                    "${rate.toStringAsFixed(0)}% conforme",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _complianceColor,
                    ),
                  )
                else
                  const Text(
                    "À contrôler",
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
              ],
            ),

            // ==================== BARRE DE PROGRESSION ====================
            if (total > 0) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: rate / 100.0,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation<Color>(_complianceColor),
                  minHeight: 5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
