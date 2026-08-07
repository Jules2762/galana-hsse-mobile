import 'package:flutter/material.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/inspection_progress_bar.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/inspection_status_badge.dart';

class InspectionCard extends StatelessWidget {
  final String title;
  final String site;
  final String inspector;
  final String date;
  final String status;
  final double progress;
  final VoidCallback? onTap;

  const InspectionCard({
    super.key,
    required this.title,
    required this.site,
    required this.inspector,
    required this.date,
    required this.status,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .04),
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
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        site,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),

                InspectionStatusBadge(
                  status: status,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // =====================
            // PROGRESS
            // =====================

            Row(
              children: [
                const Text(
                  "Progression",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),

                const Spacer(),

                Text(
                  "${(progress * 100).toInt()}%",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
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
            // INSPECTOR
            // =====================

            Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFFE8F5EE),

                  child: Icon(
                    Icons.person,
                    size: 16,
                    color: Color(0xFF0F9D58),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    "$inspector • $date",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
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