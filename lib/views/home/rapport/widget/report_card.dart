import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/models/report_model.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';
import 'package:gestion_hsse/cores/services/report_pdf_service.dart';

class ReportCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback? onTap;

  const ReportCard({
    super.key,
    required this.report,
    this.onTap,
  });

  Color get badgeColor {
    if (report.conformity >= 85) {
      return const Color(0xFF16A34A); // Green
    }
    if (report.conformity >= 70) {
      return const Color(0xFFD97706); // Amber
    }
    return const Color(0xFFDC2626); // Red
  }

  Color get categoryColor {
    final cat = report.category.toLowerCase();
    if (cat.contains('sécu') || cat.contains('secu')) {
      return const Color(0xFFDC2626);
    }
    if (cat.contains('env')) {
      return const Color(0xFF0F9D58);
    }
    if (cat.contains('audit')) {
      return const Color(0xFF7C3AED);
    }
    if (cat.contains('op')) {
      return const Color(0xFF0284C7);
    }
    return const Color(0xFFD97706);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ??
          () {
            Navigator.pushNamed(
              context,
              AppRoutes.reportDetails,
              arguments: report,
            );
          },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category + Reference + Date
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    report.category,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: categoryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    report.reference,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Text(
                      report.date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Title
            Text(
              report.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                height: 1.3,
              ),
            ),

            const SizedBox(height: 8),

            // Site & Inspector Row
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    report.site,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 9,
                      backgroundColor: const Color(0xFF0F9D58).withValues(alpha: 0.15),
                      child: Text(
                        report.inspector.isNotEmpty ? report.inspector[0].toUpperCase() : 'I',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F9D58),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      report.inspector,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Bottom Section: Conformity Gauge & Actions
            Row(
              children: [
                // Conformity pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${report.conformity}%",
                        style: TextStyle(
                          color: badgeColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        report.status,
                        style: TextStyle(
                          color: badgeColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Non-conformity counter
                if (report.nonConformities.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 13, color: Color(0xFFDC2626)),
                        const SizedBox(width: 4),
                        Text(
                          "${report.nonConformities.length} écart${report.nonConformities.length > 1 ? 's' : ''}",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline, size: 13, color: Color(0xFF16A34A)),
                        SizedBox(width: 4),
                        Text(
                          "0 écart",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ),

                const Spacer(),

                // Action: Export/Print PDF
                IconButton(
                  tooltip: 'Télécharger / Imprimer PDF',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    ReportPdfService.printReport(report);
                  },
                  icon: const Icon(
                    Icons.picture_as_pdf_outlined,
                    size: 20,
                    color: Color(0xFF0F9D58),
                  ),
                ),

                const SizedBox(width: 12),

                // Action: Share
                IconButton(
                  tooltip: 'Partager le rapport',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    ReportPdfService.shareReport(report);
                  },
                  icon: const Icon(
                    Icons.share_outlined,
                    size: 20,
                    color: Color(0xFF64748B),
                  ),
                ),

                const SizedBox(width: 8),

                // Action: Details
                IconButton(
                  tooltip: 'Voir les détails',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onTap ??
                      () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.reportDetails,
                          arguments: report,
                        );
                      },
                  icon: const Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: Color(0xFF94A3B8),
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