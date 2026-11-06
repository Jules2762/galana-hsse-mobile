import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/api/api_client.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';

class VmcCard extends StatelessWidget {
  final String reference;
  final String title;
  final String type;
  final String site;
  final String inspector;
  final String date;
  final String status;
  final int positivePoints;
  final int deviations;
  final double? complianceRate;
  final bool isPendingSync;
  final VoidCallback? onTap;

  const VmcCard({
    super.key,
    required this.reference,
    required this.title,
    required this.type,
    required this.site,
    required this.inspector,
    required this.date,
    required this.status,
    this.positivePoints = 0,
    this.deviations = 0,
    this.complianceRate,
    this.isPendingSync = false,
    this.onTap,
  });


  Color get _statusBgColor {
    final s = status.toLowerCase();
    if (s.contains('planifi') || s.contains('brouillon') || s == 'draft') {
      return const Color(0xFFFEF3C7);
    } else if (s.contains('cours') || s == 'in_progress') {
      return const Color(0xFFDBEAFE);
    } else if (s.contains('termin') || s.contains('clôtur') || s.contains('clotur') || s == 'completed' || s == 'conforme') {
      return const Color(0xFFDCFCE7);
    } else if (s.contains('annul') || s == 'cancelled' || s.contains('non-conforme')) {
      return const Color(0xFFFEE2E2);
    }
    return const Color(0xFFF1F5F9);
  }

  Color get _statusTextColor {
    final s = status.toLowerCase();
    if (s.contains('planifi') || s.contains('brouillon') || s == 'draft') {
      return const Color(0xFFB45309);
    } else if (s.contains('cours') || s == 'in_progress') {
      return const Color(0xFF1D4ED8);
    } else if (s.contains('termin') || s.contains('clôtur') || s.contains('clotur') || s == 'completed' || s == 'conforme') {
      return const Color(0xFF15803D);
    } else if (s.contains('annul') || s == 'cancelled' || s.contains('non-conforme')) {
      return const Color(0xFFB91C1C);
    }
    return const Color(0xFF475569);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isAssignedToMe = ApiClient.isAssignedToCurrentUser(inspector);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? (isAssignedToMe ? const Color(0xFF3B82F6) : const Color(0xFF334155))
                : (isAssignedToMe ? const Color(0xFF93C5FD) : AppColors.border.withValues(alpha: 0.8)),
            width: isAssignedToMe ? 1.5 : 1.0,
          ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F9D58).withValues(alpha: 0.2)
                        : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    reference,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF4ADE80) : AppColors.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      type,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                      ),
                    ),
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
                          color: isDark
                              ? const Color(0xFF78350F).withValues(alpha: 0.6)
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? const Color(0xFFB45309) : const Color(0xFFFDE68A),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 11,
                              color: isDark ? const Color(0xFFFDE68A) : const Color(0xFFD97706),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              "Sync",
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

            // ==================== TITRE ====================
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimary,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 10),

            // ==================== SITE & DATE ====================
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    site,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ==================== INSPECTEUR ====================
            Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: isDark
                      ? (isAssignedToMe ? const Color(0xFF1E3A8A) : const Color(0xFF064E2A))
                      : (isAssignedToMe ? const Color(0xFFDBEAFE) : AppColors.primaryLight),
                  child: Icon(
                    isAssignedToMe ? Icons.person_pin : Icons.person,
                    size: 12,
                    color: isAssignedToMe ? const Color(0xFF3B82F6) : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    inspector,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isAssignedToMe) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E3A8A).withValues(alpha: 0.6)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2563EB) : const Color(0xFFBFDBFE),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.assignment_ind,
                          size: 10,
                          color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          "Attribuée",
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (complianceRate != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: complianceRate! >= 0.8
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "${(complianceRate! * 100).toInt()}% conformité",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: complianceRate! >= 0.8
                            ? const Color(0xFF15803D)
                            : const Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // ==================== CONSTATS PILL ====================
            if (positivePoints > 0 || deviations > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.thumb_up_alt_outlined, size: 13, color: Color(0xFF16A34A)),
                    const SizedBox(width: 4),
                    Text(
                      "$positivePoints positifs",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.warning_amber_rounded, size: 13, color: Color(0xFFEA580C)),
                    const SizedBox(width: 4),
                    Text(
                      "$deviations écarts",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEA580C),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
