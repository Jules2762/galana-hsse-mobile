import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';

class ReportDetailPage extends StatelessWidget {
  const ReportDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          "Détail du rapport",
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // =====================
            // HEADER
            // =====================

            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(24),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFF1F5F9,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            8,
                          ),
                        ),
                        child: const Text(
                          "Sécurité",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),

                      const Spacer(),

                      const Text(
                        "15 Juil 2025",
                        style: TextStyle(
                          color:
                              Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Inspection Sécurité Incendie",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Inspecteur : Jules Rakoto",
                    style: TextStyle(
                      color:
                          Color(0xFF64748B),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Text(
                        "Conformité globale",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const Spacer(),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              const Color(
                                0xFFFDE68A,
                              ),
                          borderRadius:
                              BorderRadius.circular(
                            8,
                          ),
                        ),
                        child: const Text(
                          "78%",
                          style: TextStyle(
                            color:
                                Color(
                                  0xFFD97706,
                                ),
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                    child:
                        LinearProgressIndicator(
                      value: 0.78,
                      minHeight: 8,
                      backgroundColor:
                          const Color(
                            0xFFE2E8F0,
                          ),
                      valueColor:
                          const AlwaysStoppedAnimation(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // =====================
            // RESUME
            // =====================

            _sectionTitle(
              "Résumé exécutif",
            ),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  24,
                ),
              ),

              child: const Text(
                "L'inspection a permis de vérifier la conformité des installations de sécurité incendie. Quelques écarts mineurs ont été identifiés concernant la signalisation et la maintenance de certains équipements.",
                style: TextStyle(
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // =====================
            // SECTIONS
            // =====================

            _sectionTitle(
              "Résultats par section",
            ),

            _ScoreTile(
              title:
                  "Équipements de protection",
              score: 100,
              color:
                  const Color(0xFF22C55E),
            ),

            _ScoreTile(
              title:
                  "Installations électriques",
              score: 67,
              color:
                  const Color(0xFFF59E0B),
            ),

            _ScoreTile(
              title:
                  "Stockage matières dangereuses",
              score: 53,
              color:
                  const Color(0xFFEF4444),
            ),

            const SizedBox(height: 16),

            // =====================
            // NON CONFORMITES
            // =====================

            _sectionTitle(
              "Non-conformités",
            ),

            _NonConformityCard(
              title:
                  "Signalisation haute tension absente",
              priority: "Moyenne",
            ),

            _NonConformityCard(
              title:
                  "Extincteur expiré zone B",
              priority: "Critique",
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.picture_as_pdf_outlined,
                ),
                label: const Text(
                  "Exporter en PDF",
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 52,

              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.share_outlined,
                ),
                label: const Text(
                  "Partager le rapport",
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
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
      margin:
          const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          Expanded(
            child: Text(title),
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color:
                  color.withValues(alpha: .15),
              borderRadius:
                  BorderRadius.circular(
                8,
              ),
            ),
            child: Text(
              "$score%",
              style: TextStyle(
                color: color,
                fontWeight:
                    FontWeight.bold,
              ),
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

  const _NonConformityCard({
    required this.title,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(title),
          ),

          Text(
            priority,
            style: const TextStyle(
              color: Colors.red,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}