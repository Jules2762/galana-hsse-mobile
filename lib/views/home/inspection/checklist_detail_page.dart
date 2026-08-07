import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/checklist_section_tile.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/info_row.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/inspection_app_bar.dart';

class ChecklistDetailPage extends StatelessWidget {
  const ChecklistDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: InspectionAppBar(title: "Checklist détailée"),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // floatingActionButton: Column(
      //   mainAxisSize: MainAxisSize.min,
      //   crossAxisAlignment: CrossAxisAlignment.end,
      //   children: [
      //     FloatingActionButton(
      //       heroTag: "comment",
      //       backgroundColor: Colors.white,
      //       foregroundColor: AppColors.primary,
      //       elevation: 4,
      //       onPressed: () {},
      //       child: const Icon(Icons.comment_outlined),
      //     ),

      //     const SizedBox(height: 12),

      //     FloatingActionButton(
      //       heroTag: "attachment",
      //       backgroundColor: AppColors.primary,
      //       foregroundColor: Colors.white,
      //       elevation: 6,
      //       onPressed: () {},
      //       child: const Badge(
      //         label: Text("3"),
      //         child: Icon(Icons.attach_file),
      //       ),
      //     ),
      //   ],
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================
            // INFO CARD
            // ==========================
            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    "Inspection Sécurité Incendie",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const InfoRow(label: "Site:", value: "Dépôt Antsirabe"),

                  const SizedBox(height: 8),

                  const InfoRow(label: "Département:", value: "Opérations"),

                  const SizedBox(height: 8),

                  const InfoRow(label: "Inspecteur:", value: "Jules Rakoto"),

                  const SizedBox(height: 8),

                  const InfoRow(label: "Date:", value: "15 Juil 2025"),

                  const SizedBox(height: 16),

                  Divider(color: Colors.grey.shade300),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Text(
                        "Questions répondues",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const Spacer(),

                      Text(
                        "65% (24/37)",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),

                    child: LinearProgressIndicator(
                      value: .65,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==========================
            // SECTIONS
            // ==========================
            ChecklistSectionTile(
              title: "1. Équipements de Protection",
              subtitle: "8 items • 100% complété",
              icon: Icons.check_circle,
              iconColor: Color(0xFF22C55E),
              borderColor: Color(0xFF22C55E),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.inspectionQuestion);
              },
            ),

            SizedBox(height: 12),

            ChecklistSectionTile(
              title: "2. Installations Électriques",
              subtitle: "6 items • 67% en cours",
              icon: Icons.warning_amber,
              iconColor: Color(0xFFF59E0B),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.inspectionQuestion);
              },
            ),

            SizedBox(height: 12),

            ChecklistSectionTile(
              title: "3. Stockage Matières Dangereuses",
              subtitle: "5 items • 0% non démarré",
              icon: Icons.remove,
              iconColor: Color(0xFF94A3B8),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.inspectionQuestion);
              },
            ),
          ],
        ),
      ),
    );
  }
}
