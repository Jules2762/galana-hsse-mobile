import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/answer_option_tile.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/inspection_app_bar.dart';

class InspectionQuestionPage extends StatefulWidget {
  const InspectionQuestionPage({super.key});

  @override
  State<InspectionQuestionPage> createState() => _InspectionQuestionPageState();
}

class _InspectionQuestionPageState extends State<InspectionQuestionPage> {
  String? selectedAnswer;

  final int currentQuestion = 12;
  final int totalQuestions = 45;

  @override
  Widget build(BuildContext context) {
    final double progress = currentQuestion / totalQuestions;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,

      appBar: InspectionAppBar(title: "Inspection en cours",),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      //       floatingActionButton: Column(
      //         mainAxisSize: MainAxisSize.min,
      //         crossAxisAlignment: CrossAxisAlignment.end,
      //         children: [
      //           FloatingActionButton(
      //             heroTag: "comment",
      //             backgroundColor: Colors.white,
      //             foregroundColor: AppColors.primary,
      //             elevation: 4,
      //             onPressed: () {},
      //             child: const Icon(Icons.comment_outlined),
      //           ),

      //           const SizedBox(height: 12),

      //           FloatingActionButton(
      //             heroTag: "attachment",
      //             backgroundColor: AppColors.primary,
      //             foregroundColor: Colors.white,
      //             elevation: 6,
      //             onPressed: () {},
      //             child: const Badge(
      //               label: Text("3"),
      //               child: Icon(Icons.attach_file),
      //             ),
      //           ),
      //         ],
      //       ),
      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // ====================
                      // HEADER
                      // ====================
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),

                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4DA),
                              borderRadius: BorderRadius.circular(8),
                            ),

                            child: const Text(
                              "Installations Électriques",
                              style: TextStyle(
                                color: Color(0xFFF59E0B),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const Spacer(),

                          Text(
                            "Question $currentQuestion sur $totalQuestions",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ====================
                      // QUESTION
                      // ====================
                      const Text(
                        "Les armoires électriques sont-elles correctement verrouillées et signalées ?",
                        style: TextStyle(
                          fontSize: 28,
                          height: 1.25,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Vérifier que toutes les armoires électriques disposent d'un système de verrouillage fonctionnel et d'une signalétique conforme.",
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ====================
                      // REPONSES
                      // ====================
                      AnswerOptionTile(
                        title: "Oui",
                        icon: Icons.check,
                        color: AppColors.primary,
                        selected: selectedAnswer == "yes",
                        onTap: () {
                          setState(() {
                            selectedAnswer = "yes";
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      AnswerOptionTile(
                        title: "Non (Non-conformité)",
                        icon: Icons.close,
                        color: AppColors.danger,
                        selected: selectedAnswer == "no",
                        onTap: () {
                          setState(() {
                            selectedAnswer = "no";
                          });
                          Navigator.pushNamed(
                            context,
                            AppRoutes.correctiveAction,
                          );

                          // TODO:
                          // Navigator.pushNamed(
                          //   context,
                          //   AppRoutes.nonConformity,
                          // );
                        },
                      ),

                      const SizedBox(height: 12),

                      AnswerOptionTile(
                        title: "Non Applicable",
                        icon: Icons.remove_circle_outline,
                        color: AppColors.textSecondary,
                        selected: selectedAnswer == "na",
                        onTap: () {
                          setState(() {
                            selectedAnswer = "na";
                          });
                        },
                      ),

                      const SizedBox(height: 28),

                      // ====================
                      // PROGRESSION
                      // ====================
                      Row(
                        children: [
                          const Text(
                            "Progression globale",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const Spacer(),

                          Text(
                            "$currentQuestion/$totalQuestions",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Container(
                        height: 6,

                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ====================
            // NAVIGATION
            // ====================
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),

                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.chevron_left),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Container(
                    height: 6,

                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: FractionallySizedBox(
                      widthFactor: progress,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Container(
                  width: 52,
                  height: 52,

                  decoration: BoxDecoration(
                    color: selectedAnswer == null
                        ? Colors.grey.shade300
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: IconButton(
                    onPressed: selectedAnswer == null
                        ? null
                        : () {
                            // TODO:
                            // Question suivante
                          },
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
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
