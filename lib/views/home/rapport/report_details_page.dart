import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/models/report_model.dart';
import 'package:gestion_hsse/cores/services/report_pdf_service.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';

class ReportDetailPage extends StatelessWidget {
  final ReportModel? report;

  const ReportDetailPage({
    super.key,
    this.report,
  });

  ReportModel _resolveReport(BuildContext context) {
    if (report != null) return report!;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ReportModel) return args;
    // Fallback par défaut si accès direct
    return const ReportModel(
      id: "RPT-001",
      reference: "RPT-2026-SEC-001",
      title: "Inspection Sécurité Incendie & RIA",
      category: "Sécurité",
      site: "Dépôt Antsirabe",
      inspector: "Jules Rakoto",
      date: "14 Oct 2026",
      conformity: 78,
      status: "Partiellement conforme",
      executiveSummary:
          "L'inspection a permis de vérifier la conformité des installations de sécurité incendie. Quelques écarts mineurs ont été identifiés concernant la signalisation et la maintenance de certains équipements.",
      sections: [
        ReportSectionModel(title: "Équipements de protection incendie (RIA)", score: 100),
        ReportSectionModel(title: "Extincteurs & vérifications périodiques", score: 67),
        ReportSectionModel(title: "Signalisation & issues de secours", score: 66),
      ],
      nonConformities: [
        ReportNonConformityModel(
          title: "Signalisation issue de secours obstruée",
          priority: "Moyenne",
          section: "Signalisation & issues de secours",
        ),
        ReportNonConformityModel(
          title: "Extincteur CO2 expiré en zone B",
          priority: "Critique",
          section: "Extincteurs & vérifications",
        ),
      ],
      actions: [
        ReportActionModel(
          title: "Remplacement extincteur zone B",
          assignee: "Alain Rajaona (Maintenance)",
          dueDate: "16 Oct 2026",
          status: "En cours",
        ),
      ],
    );
  }

  Color _getBadgeColor(int conformity) {
    if (conformity >= 85) return const Color(0xFF16A34A);
    if (conformity >= 70) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  @override
  Widget build(BuildContext context) {
    final rep = _resolveReport(context);
    final badgeColor = _getBadgeColor(rep.conformity);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Détail du rapport",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: "Télécharger / Imprimer PDF",
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () {
              ReportPdfService.printReport(rep);
            },
          ),
          IconButton(
            tooltip: "Partager",
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ReportPdfService.shareReport(rep);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================
            // FICHE PRINCIPALE / HEADER CARD
            // ============================================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Catégorie, Référence & Date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          rep.category,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          rep.reference,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text(
                            rep.date,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Titre de l'inspection
                  Text(
                    rep.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Site et Inspecteur
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 15, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        rep.site,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.person_outline, size: 15, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        rep.inspector,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Jauge de conformité globale
                  Row(
                    children: [
                      const Text(
                        "Conformité globale",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          "${rep.conformity}% — ${rep.status}",
                          style: TextStyle(
                            color: badgeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: rep.conformity / 100,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation(badgeColor),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ============================================
            // KPIS DE SYNTHÈSE
            // ============================================
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: "Sections",
                    value: rep.sections.length.toString(),
                    icon: Icons.layers_outlined,
                    color: const Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    label: "Écarts",
                    value: rep.nonConformities.length.toString(),
                    icon: Icons.warning_amber_rounded,
                    color: rep.nonConformities.isEmpty ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    label: "Actions",
                    value: rep.actions.length.toString(),
                    icon: Icons.task_alt_outlined,
                    color: const Color(0xFF7C3AED),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ============================================
            // RÉSUMÉ EXÉCUTIF
            // ============================================
            _sectionTitle("Résumé exécutif"),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                rep.executiveSummary,
                style: const TextStyle(
                  height: 1.6,
                  fontSize: 13,
                  color: Color(0xFF334155),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ============================================
            // RÉSULTATS PAR SECTION
            // ============================================
            if (rep.sections.isNotEmpty) ...[
              _sectionTitle("Résultats par section"),
              for (final section in rep.sections)
                _ScoreTile(
                  title: section.title,
                  score: section.score,
                  color: _getBadgeColor(section.score),
                ),
              const SizedBox(height: 12),
            ],

            // ============================================
            // NON-CONFORMITÉS
            // ============================================
            _sectionTitle("Non-conformités constatées (${rep.nonConformities.length})"),
            if (rep.nonConformities.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Color(0xFF16A34A), size: 20),
                    SizedBox(width: 10),
                    Text(
                      "Aucune non-conformité relevée lors de cet audit.",
                      style: TextStyle(
                        color: Color(0xFF16A34A),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              )
            else
              for (final nc in rep.nonConformities)
                _NonConformityCard(
                  title: nc.title,
                  priority: nc.priority,
                  section: nc.section,
                  observation: nc.observation,
                ),

            const SizedBox(height: 20),

            // ============================================
            // ACTIONS CORRECTIVES
            // ============================================
            if (rep.actions.isNotEmpty) ...[
              _sectionTitle("Actions correctives requises (${rep.actions.length})"),
              for (final action in rep.actions)
                _ActionCard(action: action),
              const SizedBox(height: 16),
            ],

            // ============================================
            // BOUTONS D'ACTION (EXPORT & PARTAGE)
            // ============================================
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  ReportPdfService.printReport(rep);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
                label: const Text(
                  "Exporter / Imprimer en PDF",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  ReportPdfService.shareReport(rep);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF334155),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.share_outlined, size: 20),
                label: const Text(
                  "Partager le rapport officiel",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreTile extends StatelessWidget {
  final String title;
  final int score;
  final Color color;

  const _ScoreTile({
    required this.title,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "$score%",
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 6,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _NonConformityCard extends StatelessWidget {
  final String title;
  final String priority;
  final String section;
  final String? observation;

  const _NonConformityCard({
    required this.title,
    required this.priority,
    required this.section,
    this.observation,
  });

  Color get priorityColor {
    switch (priority.toLowerCase()) {
      case 'critique':
        return const Color(0xFFDC2626);
      case 'moyenne':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF0284C7);
    }
  }

  @override
  Widget build(BuildContext context) {
    final col = priorityColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, color: col, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Section : $section",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: col.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  priority,
                  style: TextStyle(
                    color: col,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          if (observation != null && observation!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                observation!,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF475569),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final ReportActionModel action;

  const _ActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.assignment_turned_in_outlined, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Assigné à : ${action.assignee} • Échéance : ${action.dueDate}",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (action.status == 'Clôturée' ? const Color(0xFF16A34A) : AppColors.primary)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              action.status,
              style: TextStyle(
                color: action.status == 'Clôturée' ? const Color(0xFF16A34A) : AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}