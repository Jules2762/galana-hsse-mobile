import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/answer_option_tile.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/inspection_app_bar.dart';

class InspectionQuestionModel {
  final int id;
  final String section;
  final String title;
  final String hint;
  String? answer; // 'yes', 'no', 'na'
  String? comment;
  int photoCount;
  Map<String, dynamic>? correctiveAction;

  InspectionQuestionModel({
    required this.id,
    required this.section,
    required this.title,
    required this.hint,
    this.answer,
    this.comment,
    this.photoCount = 0,
    this.correctiveAction,
  });
}

class InspectionQuestionPage extends StatefulWidget {
  const InspectionQuestionPage({super.key});

  @override
  State<InspectionQuestionPage> createState() => _InspectionQuestionPageState();
}

class _InspectionQuestionPageState extends State<InspectionQuestionPage> {
  int currentIndex = 0;

  final List<InspectionQuestionModel> questions = [
    InspectionQuestionModel(
      id: 1,
      section: "1. Équipements de Protection Incendie",
      title:
          "Les extincteurs sont-ils accessibles, non encombrés et clairement signalés ?",
      hint:
          "Vérifier l'absence d'obstacles dans un rayon d'au moins 1 mètre et la visibilité de la pancarte normalisée.",
      answer: "yes",
    ),
    InspectionQuestionModel(
      id: 2,
      section: "1. Équipements de Protection Incendie",
      title:
          "Les goupilles de sécurité et scellés plastique sont-ils intacts et datés ?",
      hint:
          "S'assurer qu'aucun extincteur n'a été percuté, utilisé ou altéré sans révision immédiate.",
      answer: "yes",
    ),
    InspectionQuestionModel(
      id: 3,
      section: "1. Équipements de Protection Incendie",
      title: "La date de vérification périodique annuelle est-elle à jour ?",
      hint:
          "Contrôler l'étiquette de contrôle apposée par l'organisme agréé pour l'année en cours.",
      answer: "yes",
    ),
    InspectionQuestionModel(
      id: 4,
      section: "2. Installations Électriques",
      title:
          "Les armoires électriques sont-elles correctement verrouillées et signalées ?",
      hint:
          "Vérifier que toutes les armoires disposent d'un système de verrouillage fonctionnel et d'une signalétique haute tension conforme.",
      answer: "no",
      comment: "Boîtier de cadenassage endommagé sur l'armoire A-2",
      photoCount: 1,
      correctiveAction: {
        'description':
            "Remplacer le boîtier de verrouillage et réapposer la signalétique haute tension.",
        'department': "Maintenance",
        'assignee': "Marie Razafi (Superviseur)",
        'priority': "Haute",
      },
    ),
    InspectionQuestionModel(
      id: 5,
      section: "2. Installations Électriques",
      title:
          "L'éclairage de secours (BAES) et le balisage d'évacuation sont-ils opérationnels ?",
      hint:
          "Vérifier que les voyants de veille sont allumés en vert et que les issues de secours ne sont pas obstruées.",
    ),
    InspectionQuestionModel(
      id: 6,
      section: "2. Installations Électriques",
      title:
          "Les câblages, prises industrielles et interrupteurs sont-ils exempts de dégradation ?",
      hint:
          "Contrôler l'absence de fils dénudés, d'échauffement anormal ou d'installations provisoires non autorisées.",
    ),
    InspectionQuestionModel(
      id: 7,
      section: "3. Stockage Matières Dangereuses",
      title:
          "Les produits pétroliers et solvants sont-ils disposés sur bacs de rétention étanches ?",
      hint:
          "La capacité de rétention doit être égale à 100% de la plus grande capacité ou 50% du volume total stocké.",
    ),
    InspectionQuestionModel(
      id: 8,
      section: "3. Stockage Matières Dangereuses",
      title:
          "Les fiches de données de sécurité (FDS) sont-elles consultables à proximité immédiate ?",
      hint:
          "Classeur de sécurité FDS disponible, à jour et en français/malgache à portée des opérateurs.",
    ),
    InspectionQuestionModel(
      id: 9,
      section: "3. Stockage Matières Dangereuses",
      title:
          "Les kits d'intervention anti-pollution (absorbants, barrages) sont-ils complets ?",
      hint:
          "Vérifier la présence et la propreté des absorbants d'hydrocarbures et des bacs étanches associés.",
    ),
    InspectionQuestionModel(
      id: 10,
      section: "4. Sécurité & Règles Générales",
      title:
          "Les intervenants et chauffeurs portent-ils l'ensemble des EPI obligatoires ?",
      hint:
          "Contrôle inopiné du port : casque avec jugulaire, gants anti-hydrocarbures, gilet haute visibilité et chaussures S3.",
    ),
  ];

  InspectionQuestionModel get current => questions[currentIndex];

  int get totalCount => questions.length;
  int get answeredCount => questions.where((q) => q.answer != null).length;
  int get conformCount => questions.where((q) => q.answer == 'yes').length;
  int get nonConformCount => questions.where((q) => q.answer == 'no').length;
  int get naCount => questions.where((q) => q.answer == 'na').length;

  Future<void> _handleNonConformity() async {
    setState(() {
      current.answer = "no";
    });

    final result = await Navigator.pushNamed(
      context,
      AppRoutes.correctiveAction,
    );

    if (result is Map<String, dynamic>) {
      setState(() {
        current.correctiveAction = result;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Action corrective créée : ${result['description']}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  void _showAddCommentDialog() {
    final textController = TextEditingController(text: current.comment ?? "");
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.comment_outlined,
                      color: AppColors.primary, size: 22),
                  SizedBox(width: 10),
                  Text(
                    "Observation terrain",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                maxLines: 3,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Saisissez votre constat ou remarque terrain...",
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      current.comment = textController.text.trim().isEmpty
                          ? null
                          : textController.text.trim();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Enregistrer la remarque"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addPhotoAttachment() {
    setState(() {
      current.photoCount++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF1E293B),
        content: Row(
          children: [
            const Icon(Icons.camera_alt, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              "Photo ${current.photoCount} enregistrée pour la question ${currentIndex + 1}",
            ),
          ],
        ),
      ),
    );
  }

  void _finishInspection() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.verified,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Clôturer l'audit terrain",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Toutes les vérifications ont été passées en revue.",
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildStatRow(
                        "Points Conformes", "$conformCount", const Color(0xFF15803D)),
                    const SizedBox(height: 8),
                    _buildStatRow("Non-conformités", "$nonConformCount",
                        const Color(0xFFB91C1C)),
                    const SizedBox(height: 8),
                    _buildStatRow("Non applicables", "$naCount",
                        const Color(0xFF64748B)),
                    const Divider(height: 16),
                    _buildStatRow(
                      "Actions générées",
                      "${questions.where((q) => q.correctiveAction != null).length}",
                      AppColors.primaryDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Row(
                children: [
                  Icon(Icons.person_pin, size: 16, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    "Visa : Jules Rakoto (Inspecteur HSSE)",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Vérifier à nouveau"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context, true); // return completed = true to detail page
              },
              child: const Text("Valider et Transmettre"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double globalProgress = (currentIndex + 1) / totalCount;
    final bool isLast = currentIndex == totalCount - 1;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: InspectionAppBar(
        title: "Contrôle terrain en cours",
      ),
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
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==================== HEADER SECTION ====================
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6F4EA),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                current.section,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.primaryDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Question ${currentIndex + 1}/$totalCount",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // ==================== QUESTION TEXT ====================
                      Text(
                        current.title,
                        style: const TextStyle(
                          fontSize: 20,
                          height: 1.35,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        current.hint,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ==================== REPONSES ====================
                      AnswerOptionTile(
                        title: "Oui (Conforme)",
                        icon: Icons.check,
                        color: AppColors.primary,
                        selected: current.answer == "yes",
                        onTap: () {
                          setState(() {
                            current.answer = "yes";
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      AnswerOptionTile(
                        title: "Non (Non-conformité détectée)",
                        icon: Icons.close,
                        color: AppColors.danger,
                        selected: current.answer == "no",
                        onTap: () {
                          if (current.answer != "no") {
                            _handleNonConformity();
                          } else {
                            setState(() {
                              current.answer = "no";
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 12),

                      AnswerOptionTile(
                        title: "Non Applicable (N/A)",
                        icon: Icons.remove_circle_outline,
                        color: AppColors.textSecondary,
                        selected: current.answer == "na",
                        onTap: () {
                          setState(() {
                            current.answer = "na";
                          });
                        },
                      ),

                      // ==================== ALERTE NON-CONFORMITE ====================
                      if (current.answer == "no") ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded,
                                      color: Color(0xFFDC2626), size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    "Écart constaté sur le terrain",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF991B1B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (current.correctiveAction != null) ...[
                                Text(
                                  "Action : ${current.correctiveAction!['description']}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF7F1D1D),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Assignée à : ${current.correctiveAction!['assignee']} (${current.correctiveAction!['department']})",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF991B1B),
                                  ),
                                ),
                              ] else ...[
                                const Text(
                                  "Aucune action corrective associée pour l'instant.",
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFF7F1D1D)),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 36,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFFDC2626),
                                      side: const BorderSide(
                                          color: Color(0xFFDC2626)),
                                    ),
                                    onPressed: _handleNonConformity,
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Text(
                                      "Déclarer une action corrective",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // ==================== OBSERVATION & PHOTOS CHIPS ====================
                      Row(
                        children: [
                          // Bouton Photo
                          InkWell(
                            onTap: _addPhotoAttachment,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: current.photoCount > 0
                                    ? AppColors.primaryLight
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: current.photoCount > 0
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    size: 16,
                                    color: current.photoCount > 0
                                        ? AppColors.primaryDark
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    current.photoCount > 0
                                        ? "${current.photoCount} photo(s)"
                                        : "Ajouter photo",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: current.photoCount > 0
                                          ? AppColors.primaryDark
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Bouton Commentaire
                          InkWell(
                            onTap: _showAddCommentDialog,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: current.comment != null
                                    ? const Color(0xFFFEF3C7)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: current.comment != null
                                      ? const Color(0xFFD97706)
                                      : AppColors.border,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.comment_outlined,
                                    size: 16,
                                    color: current.comment != null
                                        ? const Color(0xFFB45309)
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    current.comment != null
                                        ? "Remarque saisie"
                                        : "Remarque",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: current.comment != null
                                          ? const Color(0xFFB45309)
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (current.comment != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          "Note : \"${current.comment}\"",
                          style: const TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // ==================== PROGRESSION ====================
                      Row(
                        children: [
                          const Text(
                            "Progression globale de l'audit",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "${(globalProgress * 100).toInt()}% ($answeredCount/$totalCount)",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: globalProgress,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ==================== NAVIGATION BAS DE PAGE ====================
            Row(
              children: [
                // Bouton Précédent
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: IconButton(
                    onPressed: currentIndex > 0
                        ? () {
                            setState(() {
                              currentIndex--;
                            });
                          }
                        : null,
                    icon: Icon(
                      Icons.chevron_left,
                      color: currentIndex > 0
                          ? AppColors.textPrimary
                          : Colors.grey.shade400,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Bouton Suivant ou Terminer
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLast
                            ? const Color(0xFF15803D)
                            : AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        if (isLast) {
                          _finishInspection();
                        } else {
                          setState(() {
                            currentIndex++;
                          });
                        }
                      },
                      icon: Icon(
                        isLast ? Icons.check_circle : Icons.chevron_right,
                        size: 20,
                      ),
                      label: Text(
                        isLast
                            ? "Terminer le contrôle ($answeredCount/$totalCount)"
                            : "Question suivante",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
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
