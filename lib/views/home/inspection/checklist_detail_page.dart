import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';
import 'package:gestion_hsse/cores/services/checklist_service.dart';
import 'package:gestion_hsse/cores/services/sync_service.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/views/home/inspection/checklist/checklist_list_view.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/checklist_section_tile.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/info_row.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/inspection_app_bar.dart';

class ChecklistDetailPage extends StatefulWidget {
  final ChecklistItemData? checklist;

  const ChecklistDetailPage({super.key, this.checklist});

  @override
  State<ChecklistDetailPage> createState() => _ChecklistDetailPageState();
}

class _ChecklistDetailPageState extends State<ChecklistDetailPage> {
  dynamic id;
  late String title;
  late String site;
  late String department;
  late String inspector;
  late String date;
  late double progress;
  late String status;

  @override
  void initState() {
    super.initState();
    final item = widget.checklist;
    id = item?.id;
    title = item?.title ?? "Inspection Sécurité Incendie";
    site = item?.site ?? "Dépôt Antsirabe";
    department = "Opérations & Dépôt";
    inspector = item?.inspector ?? "Jules Rakoto";
    date = item?.date ?? "14 Oct 2026";
    progress = item?.progress ?? 0.65;
    status = item?.status ?? "En cours";
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ChecklistItemData) {
      setState(() {
        id = args.id;
        title = args.title;
        site = args.site;
        inspector = args.inspector;
        date = args.date;
        progress = args.progress;
        status = args.status;
      });
    }
  }

  Future<void> _startOrContinueInspection() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.inspectionQuestion,
    );

    if (result == true) {
      final updated = ChecklistItemData(
        id: id,
        title: title,
        site: site,
        inspector: inspector,
        date: "Aujourd'hui (14 Oct 2026)",
        progress: 1.0,
        status: "Terminée",
      );

      await ChecklistService.completeChecklist(updated);

      if (!mounted) return;
      setState(() {
        progress = 1.0;
        status = "Terminée";
        date = "Aujourd'hui (14 Oct 2026)";
      });

      final isOnline = SyncService.instance.isOnline;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 4),
          backgroundColor: isOnline ? const Color(0xFF15803D) : const Color(0xFFD97706),
          content: Row(
            children: [
              Icon(isOnline ? Icons.check_circle : Icons.cloud_off, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isOnline
                      ? "Contrôle clôturé et synchronisé avec succès en ligne !"
                      : "Contrôle clôturé en mode Hors-ligne ! Synchronisation automatique dès la reconnexion.",
                ),
              ),
            ],
          ),
        ),
      );
    }
  }


  Color get _statusBgColor {
    switch (status.toLowerCase()) {
      case 'terminée':
        return const Color(0xFFDCFCE7);
      case 'en cours':
        return const Color(0xFFDBEAFE);
      case 'planifiée':
        return const Color(0xFFFEF3C7);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color get _statusTextColor {
    switch (status.toLowerCase()) {
      case 'terminée':
        return const Color(0xFF15803D);
      case 'en cours':
        return const Color(0xFF1D4ED8);
      case 'planifiée':
        return const Color(0xFFB45309);
      default:
        return const Color(0xFF475569);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = status.toLowerCase() == 'terminée' || progress >= 1.0;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: const InspectionAppBar(title: "Checklist détaillée"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================
            // INFO CARD
            // ==========================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusBgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: _statusTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  InfoRow(label: "Site:", value: site),
                  const SizedBox(height: 8),
                  InfoRow(label: "Département:", value: department),
                  const SizedBox(height: 8),
                  InfoRow(label: "Inspecteur:", value: inspector),
                  const SizedBox(height: 8),
                  InfoRow(label: "Date:", value: date),

                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade200),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Text(
                        "Progression globale",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "${(progress * 100).toInt()}% (${isCompleted ? '10/10' : '7/10'})",
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: AlwaysStoppedAnimation(
                        isCompleted ? const Color(0xFF15803D) : AppColors.primary,
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
            const Text(
              "Sections du Contrôle",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            ChecklistSectionTile(
              title: "1. Équipements de Protection Incendie",
              subtitle: isCompleted
                  ? "3 items • 100% complété"
                  : "3 items • 100% complété",
              icon: Icons.check_circle,
              iconColor: const Color(0xFF22C55E),
              borderColor: const Color(0xFF22C55E),
              onTap: _startOrContinueInspection,
            ),

            const SizedBox(height: 12),

            ChecklistSectionTile(
              title: "2. Installations Électriques",
              subtitle: isCompleted
                  ? "3 items • 100% complété"
                  : "3 items • 67% en cours (1 non-conformité)",
              icon: isCompleted ? Icons.check_circle : Icons.warning_amber,
              iconColor: isCompleted
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFF59E0B),
              borderColor: isCompleted
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFF59E0B),
              onTap: _startOrContinueInspection,
            ),

            const SizedBox(height: 12),

            ChecklistSectionTile(
              title: "3. Stockage Matières Dangereuses",
              subtitle: isCompleted
                  ? "3 items • 100% complété"
                  : "3 items • Non démarré",
              icon: isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              iconColor: isCompleted
                  ? const Color(0xFF22C55E)
                  : const Color(0xFF94A3B8),
              onTap: _startOrContinueInspection,
            ),

            const SizedBox(height: 12),

            ChecklistSectionTile(
              title: "4. Sécurité & Règles Générales",
              subtitle: isCompleted
                  ? "1 item • 100% complété"
                  : "1 item • Non démarré",
              icon: isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              iconColor: isCompleted
                  ? const Color(0xFF22C55E)
                  : const Color(0xFF94A3B8),
              onTap: _startOrContinueInspection,
            ),

            const SizedBox(height: 90),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isCompleted ? const Color(0xFF15803D) : AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(
                isCompleted ? Icons.visibility : Icons.play_arrow,
                size: 22,
              ),
              label: Text(
                isCompleted
                    ? "Revoir les réponses du contrôle"
                    : (progress > 0
                        ? "Continuer le contrôle terrain"
                        : "Démarrer le contrôle terrain"),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              onPressed: _startOrContinueInspection,
            ),
          ),
        ),
      ),
    );
  }
}
