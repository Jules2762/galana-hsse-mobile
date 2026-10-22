import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/services/sync_service.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/cores/services/personnel_service.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/inspection_app_bar.dart';

class CorrectiveActionPage extends StatefulWidget {
  const CorrectiveActionPage({super.key});

  @override
  State<CorrectiveActionPage> createState() => _CorrectiveActionPageState();
}

class _CorrectiveActionPageState extends State<CorrectiveActionPage> {
  final descriptionController = TextEditingController(
    text:
        "Remplacer le boîtier de verrouillage endommagé et apposer une signalétique haute tension conforme aux normes NF.",
  );

  String assignee = "ARIMANANA Maherison Jules (Inspecteur HSSE)";

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,

      appBar: InspectionAppBar(title: "Nouvelle action corrective"),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // ====================
                      // DESCRIPTION
                      // ====================
                      const Text(
                        "Description de l'action *",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: descriptionController,
                        maxLines: 4,
                      ),

                      const SizedBox(height: 24),

                      // ====================
                      // RESPONSABLE
                      // ====================
                      const Text(
                        "Responsable *",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),

                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 20,
                              child: Icon(Icons.person_outline),
                            ),

                            const SizedBox(width: 12),

                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    "Marie Razafi",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),

                                  SizedBox(height: 2),

                                  Text(
                                    "Superviseur Maintenance",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.person_outline),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ====================
                      // RESPONSABLE (PERSONNEL)
                      // ====================
                      const Text(
                        "Responsable / Personnel assigné *",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 8),

                      InkWell(
                        onTap: () async {
                          final picked = await PersonnelService.showPersonnelPicker(
                            context,
                            currentName: assignee,
                          );
                          if (picked != null) {
                            setState(() {
                              assignee = "${picked.fullName} (${picked.fonction})";
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person, color: Color(0xFF1D4ED8), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  assignee.isNotEmpty
                                      ? assignee
                                      : "Sélectionner un responsable du personnel...",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: assignee.isNotEmpty
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: assignee.isNotEmpty
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ====================
              // ACTIONS
              // ====================
              SizedBox(
                width: double.infinity,
                height: 54,

                child: ElevatedButton(
                  onPressed: () {
                    if (descriptionController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Veuillez saisir une description de l'action"),
                        ),
                      );
                      return;
                    }
                    final desc = descriptionController.text.trim();
                    final actionData = {
                      'description': desc,
                      'assignee': assignee,
                    };

                    SyncService.instance.queueAction(
                      SyncAction(
                        id: 'action_create_${DateTime.now().millisecondsSinceEpoch}',
                        type: 'ACTION_CREATE',
                        title: 'Action corrective : $desc',
                        endpoint: '/home/actions/checklist',
                        method: 'POST',
                        payload: {
                          'description': desc,
                          'status': 'PENDING',
                        },
                        createdAt: DateTime.now(),
                      ),
                    );

                    Navigator.pop(context, actionData);
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),

                  child: const Text("Créer l'action"),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Annuler"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
