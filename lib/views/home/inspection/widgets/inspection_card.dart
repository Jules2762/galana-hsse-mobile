import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/api/api_client.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/inspection_progress_bar.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/inspection_status_badge.dart';

class InspectionCard extends StatelessWidget {
  final String title;
  final String site;
  final String inspector;
  final String date;
  final String status;
  final double progress;
  final bool isPendingSync;
  final VoidCallback? onTap;

  const InspectionCard({
    super.key,
    required this.title,
    required this.site,
    required this.inspector,
    required this.date,
    required this.status,
    required this.progress,
    this.isPendingSync = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAssignedToMe = ApiClient.isAssignedToCurrentUser(inspector);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? (isAssignedToMe ? const Color(0xFF3B82F6) : const Color(0xFF334155))
                : (isAssignedToMe ? const Color(0xFF93C5FD) : const Color(0xFFE2E8F0)),
            width: isAssignedToMe ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isAssignedToMe
                  ? const Color(0xFF3B82F6).withValues(alpha: .06)
                  : Colors.black.withValues(alpha: .04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================
            // HEADER
            // =====================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        site,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    InspectionStatusBadge(
                      status: status,
                    ),
                    if (isPendingSync) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF78350F).withValues(alpha: 0.6)
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
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
                              "À synchroniser",
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
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // =====================
            // PROGRESS
            // =====================
            Row(
              children: [
                Text(
                  "Progression",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                  ),
                ),
                const Spacer(),
                Text(
                  "${(progress * 100).toInt()}%",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            InspectionProgressBar(
              progress: progress,
            ),

            const SizedBox(height: 16),

            // =====================
            // INSPECTOR & ASSIGNATION
            // =====================
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: isDark
                      ? (isAssignedToMe
                          ? const Color(0xFF1E3A8A)
                          : const Color(0xFF064E2A))
                      : (isAssignedToMe
                          ? const Color(0xFFDBEAFE)
                          : const Color(0xFFE8F5EE)),
                  child: Icon(
                    isAssignedToMe ? Icons.person_pin : Icons.person,
                    size: 16,
                    color: isAssignedToMe ? const Color(0xFF3B82F6) : const Color(0xFF0F9D58),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "$inspector • $date",
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ),
                if (isAssignedToMe) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E3A8A).withValues(alpha: 0.6)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2563EB) : const Color(0xFFBFDBFE),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.assignment_ind,
                          size: 12,
                          color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Attribuée à vous",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}