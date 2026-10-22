import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/services/camera_service.dart';
import 'package:gestion_hsse/cores/services/personnel_service.dart';
import 'package:gestion_hsse/cores/models/inspection_map_item.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';
import 'package:gestion_hsse/cores/services/checklist_pdf_service.dart';
import 'package:gestion_hsse/cores/services/checklist_service.dart';
import 'package:gestion_hsse/cores/services/realtime_service.dart';
import 'package:gestion_hsse/cores/services/sync_service.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/views/home/inspection/checklist/checklist_list_view.dart';

class ChecklistDetailPage extends StatefulWidget {
  final ChecklistItemData? checklist;

  const ChecklistDetailPage({super.key, this.checklist});

  @override
  State<ChecklistDetailPage> createState() => _ChecklistDetailPageState();
}

class _ChecklistDetailPageState extends State<ChecklistDetailPage> {
  late ChecklistItemData checklist;
  late List<Map<String, dynamic>> checklistItems;
  bool _hasLoadedFromArgs = false;
  String department = "Opérations & Dépôt";

  @override
  void initState() {
    super.initState();
    checklist = widget.checklist ??
        const ChecklistItemData(
          id: 1,
          title: "Inspection Sécurité Incendie",
          site: "Dépôt Antsirabe",
          inspector: "Jules Rakoto",
          date: "14 Oct 2026",
          progress: 0.65,
          status: "En cours",
        );
    _initDefaultChecklistItems();
  }

  void _initDefaultChecklistItems() {
    checklistItems = [
      {
        'id': 1,
        'num': '1',
        'title':
            'Les extincteurs sont-ils accessibles, non encombrés et clairement signalés ?',
        'section': '1. Équipements de Protection Incendie',
        'answer': 'OUI',
        'yes': true,
        'obs': 'Extincteurs vérifiés en zone de distribution.',
        'photos': <String>[],
        'action': null,
      },
      {
        'id': 2,
        'num': '2',
        'title':
            'Les goupilles de sécurité et scellés plastique sont-ils intacts et datés ?',
        'section': '1. Équipements de Protection Incendie',
        'answer': 'OUI',
        'yes': true,
        'obs': "Scellés d'origine intacts.",
        'photos': <String>[],
        'action': null,
      },
      {
        'id': 3,
        'num': '3',
        'title': 'La date de vérification périodique annuelle est-elle à jour ?',
        'section': '1. Équipements de Protection Incendie',
        'answer': 'OUI',
        'yes': true,
        'obs': "Contrôle annuel valide jusqu'en décembre 2026.",
        'photos': <String>[],
        'action': null,
      },
      {
        'id': 4,
        'num': '4',
        'title':
            'Les armoires électriques sont-elles correctement verrouillées et signalées ?',
        'section': '2. Installations Électriques',
        'answer': 'NON',
        'yes': false,
        'obs': "Boîtier de cadenassage endommagé sur l'armoire A-2.",
        'photos': <String>[],
        'action': {
          'description':
              "Remplacer le boîtier de verrouillage et réapposer la signalétique haute tension.",
          'department': "Maintenance",
          'assignee': "Marie Razafi (Superviseur)",
          'priority': "Haute",
        },
      },
      {
        'id': 5,
        'num': '5',
        'title':
            "L'éclairage de secours (BAES) et le balisage d'évacuation sont-ils opérationnels ?",
        'section': '2. Installations Électriques',
        'answer': 'OUI',
        'yes': true,
        'obs': 'Blocs autonomes opérationnels et voyants verts allumés.',
        'photos': <String>[],
        'action': null,
      },
      {
        'id': 6,
        'num': '6',
        'title':
            'Les câblages, prises industrielles et interrupteurs sont-ils exempts de dégradation ?',
        'section': '2. Installations Électriques',
        'answer': 'OUI',
        'yes': true,
        'obs': 'Aucun fil dénudé constaté.',
        'photos': <String>[],
        'action': null,
      },
      {
        'id': 7,
        'num': '7',
        'title':
            'Les produits pétroliers et solvants sont-ils disposés sur bacs de rétention étanches ?',
        'section': '3. Stockage Matières Dangereuses',
        'answer': 'OUI',
        'yes': true,
        'obs': 'Bacs de rétention propres et capacité conforme.',
        'photos': <String>[],
        'action': null,
      },
      {
        'id': 8,
        'num': '8',
        'title':
            'Les fiches de données de sécurité (FDS) sont-elles consultables à proximité immédiate ?',
        'section': '3. Stockage Matières Dangereuses',
        'answer': 'OUI',
        'yes': true,
        'obs': 'Classeur FDS complet et accessible.',
        'photos': <String>[],
        'action': null,
      },
      {
        'id': 9,
        'num': '9',
        'title':
            "Les kits d'intervention anti-pollution (absorbants, barrages) sont-ils complets ?",
        'section': '3. Stockage Matières Dangereuses',
        'answer': 'OUI',
        'yes': true,
        'obs': 'Boudins et granulés absorbants disponibles.',
        'photos': <String>[],
        'action': null,
      },
      {
        'id': 10,
        'num': '10',
        'title':
            "Les intervenants et chauffeurs portent-ils l'ensemble des EPI obligatoires ?",
        'section': '4. Sécurité & Règles Générales',
        'answer': 'OUI',
        'yes': true,
        'obs': 'Port des EPI vérifié lors de la visite.',
        'photos': <String>[],
        'action': null,
      },
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedFromArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is ChecklistItemData) {
        setState(() {
          checklist = args;
        });
        _hasLoadedFromArgs = true;
        if (checklist.id != null) {
          _fetchRemoteDetails(checklist.id!);
        }
      }
    }
  }

  Future<void> _fetchRemoteDetails(dynamic id) async {
    final detail = await ChecklistService.getChecklistDetail(id);
    if (!mounted || detail == null) return;

    setState(() {
      if (detail['sections'] is List && (detail['sections'] as List).isNotEmpty) {
        final sections = detail['sections'] as List;
        int autoNum = 1;
        final List<Map<String, dynamic>> items = [];

        for (final sec in sections) {
          final secTitle = sec['title']?.toString() ?? 'Section';
          final rawItems = sec['items'] as List? ?? [];
          for (final it in rawItems) {
            final rawAns = it['answer']?.toString().toUpperCase();
            String ans = 'N/A';
            if (rawAns == 'YES' || rawAns == 'OUI') {
              ans = 'OUI';
            } else if (rawAns == 'NO' || rawAns == 'NON') {
              ans = 'NON';
            }

            Map<String, dynamic>? action;
            if (it['action'] is Map) {
              action = Map<String, dynamic>.from(it['action']);
            } else if (ans == 'NON') {
              action = {
                'description':
                    "Action corrective pour l'écart sur : ${it['question'] ?? ''}",
                'department': 'Maintenance',
                'assignee': 'Marie Razafi (Superviseur)',
                'priority': 'Haute',
              };
            }

            List<String> photos = [];
            if (it['photos'] is List) {
              photos = (it['photos'] as List).map((p) => p.toString()).toList();
            }

            items.add({
              'id': it['id'],
              'num': (autoNum++).toString(),
              'title': it['question']?.toString() ??
                  it['title']?.toString() ??
                  'Point de contrôle',
              'section': secTitle,
              'answer': ans,
              'yes': ans == 'OUI' ? true : (ans == 'NON' ? false : null),
              'obs': it['comment']?.toString() ?? it['obs']?.toString() ?? '',
              'photos': photos,
              'action': action,
            });
          }
        }

        if (items.isNotEmpty) {
          checklistItems = items;
        }
      }

      if (detail['department'] != null) {
        department = detail['department'].toString();
      }
    });
  }

  int get conformCount =>
      checklistItems.where((i) => i['answer'] == 'OUI' || i['yes'] == true).length;

  int get deviationsCount =>
      checklistItems.where((i) => i['answer'] == 'NON' || i['yes'] == false).length;

  int get evaluatedCount => conformCount + deviationsCount;

  double get complianceRate =>
      evaluatedCount > 0 ? (conformCount / evaluatedCount) : 1.0;

  double get currentProgress =>
      checklistItems.isNotEmpty ? (evaluatedCount / checklistItems.length) : 0.0;

  bool get isCompleted =>
      checklist.status.toLowerCase().contains('termin') ||
      checklist.status.toUpperCase() == 'COMPLETED' ||
      currentProgress >= 1.0;

  String get reference => "#CHK-${checklist.id ?? '01'}";
  String get codeForm => "FOR-HSSE-CHK";

  Color get _statusBgColor {
    final s = checklist.status.toLowerCase();
    if (s.contains('planifi') || s.contains('brouillon') || s == 'draft') {
      return const Color(0xFFFEF3C7);
    }
    if (s.contains('cours') || s == 'in_progress') {
      return const Color(0xFFDBEAFE);
    }
    if (s.contains('termin') || s.contains('clôtur') || s == 'completed') {
      return const Color(0xFFDCFCE7);
    }
    return const Color(0xFFF1F5F9);
  }

  Color get _statusTextColor {
    final s = checklist.status.toLowerCase();
    if (s.contains('planifi') || s.contains('brouillon') || s == 'draft') {
      return const Color(0xFFB45309);
    }
    if (s.contains('cours') || s == 'in_progress') {
      return const Color(0xFF1D4ED8);
    }
    if (s.contains('termin') || s.contains('clôtur') || s == 'completed') {
      return const Color(0xFF15803D);
    }
    return const Color(0xFF475569);
  }

  Future<void> _startChecklist() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      checklist = ChecklistItemData(
        id: checklist.id,
        title: checklist.title,
        site: checklist.site,
        inspector: checklist.inspector,
        date: checklist.date,
        progress: currentProgress > 0 ? currentProgress : 0.1,
        status: "En cours",
      );
    });

    if (checklist.id != null) {
      await ChecklistService.updateStatus(checklist.id, 'IN_PROGRESS');
      RealtimeService.instance.notifyLocalChange(
        'CHECKLIST',
        'Contrôle Terrain Démarré',
        'Le contrôle ${checklist.title} est maintenant en cours sur site',
      );
    }

    final isOnline = SyncService.instance.isOnline;
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1D4ED8),
        content: Row(
          children: [
            const Icon(Icons.play_circle_fill, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isOnline
                    ? "Contrôle démarré ! Statut passé à 'En cours' et synchronisé."
                    : "Contrôle démarré en mode hors-ligne ! Statut passé à 'En cours'.",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _closeChecklist() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      checklist = ChecklistItemData(
        id: checklist.id,
        title: checklist.title,
        site: checklist.site,
        inspector: checklist.inspector,
        date: checklist.date,
        progress: 1.0,
        status: "Terminée",
      );
    });

    await ChecklistService.completeChecklist(checklist);

    final isOnline = SyncService.instance.isOnline;
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF15803D),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isOnline
                    ? "Contrôle clôturé avec succès et synchronisé en ligne !"
                    : "Contrôle clôturé en local ! Synchronisation automatique dès reconnexion.",
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // MODAL D'ÉVALUATION TERRAIN (MEME FORME QUE VMC)
  // =========================================================================
  void _showChecklistEvaluationBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.90,
              ),
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Column(
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.rule_folder,
                              color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Évaluation $codeForm",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                "$reference • ${checklistItems.length} points de contrôle officiels",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.separated(
                        itemCount: checklistItems.length,
                        separatorBuilder: (_, _) => const Divider(height: 20),
                        itemBuilder: (context, index) {
                          final item = checklistItems[index];
                          final String ans = item["answer"] ??
                              (item["yes"] == true
                                  ? "OUI"
                                  : (item["yes"] == false ? "NON" : "N/A"));
                          final bool isYes = ans == "OUI";
                          final bool isNo = ans == "NON";
                          final bool isNa = ans == "N/A";

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: isYes
                                        ? const Color(0xFFDCFCE7)
                                        : (isNo
                                            ? const Color(0xFFFEE2E2)
                                            : const Color(0xFFF1F5F9)),
                                    child: Text(
                                      (item["num"] ?? (index + 1)).toString(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isYes
                                            ? const Color(0xFF15803D)
                                            : (isNo
                                                ? const Color(0xFFB91C1C)
                                                : const Color(0xFF64748B)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item["title"].toString(),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        if (item["obs"] != null &&
                                            item["obs"].toString().isNotEmpty)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text(
                                              "Obs: ${item['obs']}",
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontStyle: FontStyle.italic,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const SizedBox(width: 34),
                                  ChoiceChip(
                                    label: const Text("Conforme"),
                                    selected: isYes,
                                    selectedColor: const Color(0xFFDCFCE7),
                                    labelStyle: TextStyle(
                                      color: isYes
                                          ? const Color(0xFF15803D)
                                          : AppColors.textSecondary,
                                      fontWeight: isYes
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                    onSelected: (val) {
                                      if (val) {
                                        setModalState(() {
                                          item["answer"] = "OUI";
                                          item["yes"] = true;
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  ChoiceChip(
                                    label: const Text("Écart"),
                                    selected: isNo,
                                    selectedColor: const Color(0xFFFEE2E2),
                                    labelStyle: TextStyle(
                                      color: isNo
                                          ? const Color(0xFFB91C1C)
                                          : AppColors.textSecondary,
                                      fontWeight: isNo
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                    onSelected: (val) {
                                      if (val) {
                                        setModalState(() {
                                          item["answer"] = "NON";
                                          item["yes"] = false;
                                        });
                                        _showCorrectiveActionDialogForItem(
                                            item, setModalState);
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  ChoiceChip(
                                    label: const Text("N/A"),
                                    selected: isNa,
                                    selectedColor: const Color(0xFFF1F5F9),
                                    labelStyle: TextStyle(
                                      color: isNa
                                          ? const Color(0xFF475569)
                                          : AppColors.textSecondary,
                                      fontWeight: isNa
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                    onSelected: (val) {
                                      if (val) {
                                        setModalState(() {
                                          item["answer"] = "N/A";
                                          item["yes"] = null;
                                        });
                                      }
                                    },
                                  ),
                                  const Spacer(),
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                            Icons.camera_alt_outlined,
                                            size: 20,
                                            color: AppColors.textSecondary),
                                        tooltip: "Prendre / ajouter une photo",
                                        onPressed: () {
                                          _pickPhotoForItem(
                                              item, setModalState);
                                        },
                                      ),
                                      if ((item['photos'] as List?)
                                              ?.isNotEmpty ==
                                          true)
                                        Positioned(
                                          right: 4,
                                          top: 4,
                                          child: Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: const BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                            constraints: const BoxConstraints(
                                              minWidth: 14,
                                              minHeight: 14,
                                            ),
                                            child: Text(
                                              "${(item['photos'] as List).length}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_comment_outlined,
                                        size: 18,
                                        color: AppColors.textSecondary),
                                    tooltip: "Modifier l'observation",
                                    onPressed: () {
                                      _showEditObservationDialog(
                                          item, setModalState);
                                    },
                                  ),
                                ],
                              ),
                              if ((item['photos'] as List?)?.isNotEmpty == true)
                                _buildPhotosPreview(item, setModalState),
                              if (item['action'] != null)
                                _buildActionCard(item, setModalState)
                              else if (isNo)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 34, top: 6),
                                  child: InkWell(
                                    onTap: () =>
                                        _showCorrectiveActionDialogForItem(
                                            item, setModalState),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF2F2),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                            color: const Color(0xFFFECACA)),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.warning_amber_rounded,
                                              size: 16,
                                              color: Color(0xFFDC2626)),
                                          SizedBox(width: 6),
                                          Text(
                                            "Action corrective requise • Cliquer pour définir",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFDC2626),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.check, size: 20),
                        label: const Text(
                          "Enregistrer l'évaluation terrain",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          final positive = conformCount;
                          final dev = deviationsCount;
                          final rate = complianceRate;
                          final prog = currentProgress;

                          setState(() {
                            checklist = ChecklistItemData(
                              id: checklist.id,
                              title: checklist.title,
                              site: checklist.site,
                              inspector: checklist.inspector,
                              date: checklist.date,
                              progress: prog,
                              status: checklist.status,
                            );
                          });

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.primary,
                              content: Text(
                                "Évaluation mise à jour : $positive conforme(s), $dev écart(s) - Taux: ${(rate * 100).toInt()}%",
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditObservationDialog(
      Map<String, dynamic> item, StateSetter setModalState) {
    final controller =
        TextEditingController(text: item["obs"]?.toString() ?? "");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Observation Point ${item['num'] ?? (checklistItems.indexOf(item) + 1)}",
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Préciser les constats ou remarques terrain...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              setModalState(() {
                item["obs"] = controller.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text("Valider", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _showCorrectiveActionDialogForItem(
      Map<String, dynamic> item, StateSetter setModalState) async {
    final existing = item['action'] as Map<String, dynamic>?;
    final descCtrl = TextEditingController(
      text: existing?['description']?.toString() ??
          "Corriger l'écart constaté sur : ${item['title'] ?? ''}",
    );
    String assignee =
        existing?['assignee']?.toString() ?? "ARIMANANA Maherison Jules (Inspecteur HSSE)";

    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFDC2626), size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Action Corrective • Pt ${item['num'] ?? ''}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          item['title']?.toString() ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Description du plan d'action *",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: descCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Préciser l'action à mener...",
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "Responsable / Personnel assigné *",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final picked = await PersonnelService.showPersonnelPicker(
                          ctx,
                          currentName: assignee,
                        );
                        if (picked != null) {
                          setDialogState(() {
                            assignee = "${picked.fullName} (${picked.fonction})";
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 11),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.person,
                                  size: 16, color: Color(0xFF1D4ED8)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                assignee.isNotEmpty
                                    ? assignee
                                    : "Sélectionner un responsable du personnel...",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: assignee.isNotEmpty
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: assignee.isNotEmpty
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down,
                                size: 20, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text("Ignorer"),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text("Enregistrer l'action"),
                  onPressed: () {
                    if (descCtrl.text.trim().isEmpty) return;
                    Navigator.pop(ctx, true);
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (res == true) {
      final actionMap = {
        'description': descCtrl.text.trim(),
        'assignee': assignee,
        'createdAt': DateTime.now().toIso8601String(),
      };

      setModalState(() {
        item['action'] = actionMap;
      });
      setState(() {});

      final actId =
          'checklist_action_${item['id'] ?? DateTime.now().millisecondsSinceEpoch}';
      SyncService.instance.queueAction(
        SyncAction(
          id: actId,
          type: 'CHECKLIST_ACTION_CREATE',
          title: 'Action corrective Checklist: ${descCtrl.text.trim()}',
          endpoint: '/home/actions/checklist',
          method: 'POST',
          payload: {
            'checklist_item_id': item['id'],
            'description': descCtrl.text.trim(),
            'assigned_to': assignee,
            'status': 'PENDING',
          },
          createdAt: DateTime.now(),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF16A34A),
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Action corrective enregistrée pour le point ${item['num'] ?? ''} !",
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  Future<void> _pickPhotoForItem(
      Map<String, dynamic> item, StateSetter setModalState) async {
    final path = await CameraService.pickImage(context);
    if (path != null) {
      setModalState(() {
        final List<String> current =
            List<String>.from(item['photos'] as List? ?? []);
        current.add(path);
        item['photos'] = current;
      });
      setState(() {});
    }
  }

  void _removePhotoFromItem(
      Map<String, dynamic> item, int index, StateSetter setModalState) {
    setModalState(() {
      final List<String> current =
          List<String>.from(item['photos'] as List? ?? []);
      if (index >= 0 && index < current.length) {
        current.removeAt(index);
        item['photos'] = current;
      }
    });
    setState(() {});
  }

  void _viewFullPhoto(String photoPath) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: photoPath.startsWith('http')
                  ? Image.network(photoPath, fit: BoxFit.contain)
                  : Image.file(File(photoPath), fit: BoxFit.contain),
            ),
            IconButton(
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosPreview(
      Map<String, dynamic> item, StateSetter setModalState,
      {bool readOnly = false}) {
    final List<String> photos =
        List<String>.from(item['photos'] as List? ?? []);
    if (photos.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 34, top: 8),
      child: SizedBox(
        height: 60,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: photos.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, idx) {
            final p = photos[idx];
            return Stack(
              children: [
                GestureDetector(
                  onTap: () => _viewFullPhoto(p),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: p.startsWith('http')
                          ? Image.network(p, fit: BoxFit.cover)
                          : Image.file(
                              File(p),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.broken_image,
                                size: 24,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                ),
                if (!readOnly)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () =>
                          _removePhotoFromItem(item, idx, setModalState),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Color(0xFFDC2626),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 11, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionCard(
      Map<String, dynamic> item, StateSetter setModalState,
      {bool readOnly = false}) {
    final action = item['action'] as Map<String, dynamic>?;
    if (action == null) return const SizedBox.shrink();

    final desc = action['description']?.toString() ?? '';
    final assignee = action['assignee']?.toString() ?? 'Non assigné';

    return Container(
      margin: const EdgeInsets.only(left: 34, top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_turned_in,
                  size: 16, color: Color(0xFFEA580C)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  "Action Corrective Définie",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9A3412),
                  ),
                ),
              ),
              if (!readOnly) ...[
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.edit,
                      size: 15, color: Color(0xFF9A3412)),
                  tooltip: "Modifier l'action",
                  onPressed: () =>
                      _showCorrectiveActionDialogForItem(item, setModalState),
                ),
                const SizedBox(width: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete_outline,
                      size: 16, color: Color(0xFFDC2626)),
                  tooltip: "Supprimer l'action",
                  onPressed: () {
                    setModalState(() {
                      item['action'] = null;
                    });
                    setState(() {});
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person, size: 13, color: Color(0xFF1D4ED8)),
                const SizedBox(width: 4),
                Text(
                  assignee,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // HERO CARD (STYLE IDENTIQUE A VMC)
  // =========================================================================
  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.fact_check_outlined,
                    size: 28, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          reference,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            codeForm,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      checklist.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  checklist.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _statusTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  checklist.site,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.inspectionsMap,
                    arguments: {
                      'type': InspectionType.checklist,
                      'site': checklist.site,
                    },
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.map_outlined, size: 13, color: Color(0xFF1D4ED8)),
                      SizedBox(width: 4),
                      Text(
                        "Carte",
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D4ED8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.calendar_today,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                checklist.date,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_outline,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                "Inspecteur : ${checklist.inspector}",
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text(
                "Progression globale",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                "${(currentProgress * 100).toInt()}% ($evaluatedCount/${checklistItems.length})",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: currentProgress,
              minHeight: 7,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation(
                isCompleted ? const Color(0xFF15803D) : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        size: 14, color: Color(0xFF15803D)),
                    const SizedBox(width: 6),
                    Text(
                      "$conformCount conforme(s)",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: deviationsCount > 0
                      ? const Color(0xFFFEE2E2)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 14,
                        color: deviationsCount > 0
                            ? const Color(0xFFB91C1C)
                            : const Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      "$deviationsCount écart(s)",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: deviationsCount > 0
                            ? const Color(0xFFB91C1C)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // DETAIL ROWS
  // =========================================================================
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
    );
  }

  // =========================================================================
  // INSPECTION BODY
  // =========================================================================
  Widget _buildInspectionBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Détails du Contrôle
        const Text(
          "Détails du Contrôle Terrain",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildDetailRow("Type de visite", checklist.title),
              _buildDivider(),
              _buildDetailRow("Code formulaire", codeForm),
              _buildDivider(),
              _buildDetailRow("Département", department),
              _buildDivider(),
              _buildDetailRow("Inspecteur", checklist.inspector),
              _buildDivider(),
              _buildDetailRow(
                  "Taux de conformité", "${(complianceRate * 100).toInt()}%"),
              _buildDivider(),
              _buildDetailRow("Politique HSSE", "Objectif Zéro Incident"),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Grille officielle Galana
        Row(
          children: [
            const Icon(Icons.rule_folder, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              "Grille de Contrôle (${checklistItems.length} points)",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _showChecklistEvaluationBottomSheet,
              icon: const Icon(Icons.edit, size: 16),
              label: const Text(
                "Évaluer Terrain",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: List.generate(checklistItems.length, (index) {
              final item = checklistItems[index];
              final String ans = item["answer"] ??
                  (item["yes"] == true
                      ? "OUI"
                      : (item["yes"] == false ? "NON" : "N/A"));
              final bool isYes = ans == "OUI";
              final bool isNo = ans == "NON";

              final IconData iconData = isYes
                  ? Icons.check_circle
                  : (isNo ? Icons.cancel : Icons.remove_circle_outline);
              final Color iconColor = isYes
                  ? const Color(0xFF16A34A)
                  : (isNo ? const Color(0xFFDC2626) : const Color(0xFF64748B));
              final String label =
                  isYes ? "Conforme" : (isNo ? "Écart" : "N/A");
              final Color badgeBg = isYes
                  ? const Color(0xFFDCFCE7)
                  : (isNo ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9));
              final Color badgeTextColor = isYes
                  ? const Color(0xFF15803D)
                  : (isNo ? const Color(0xFFB91C1C) : const Color(0xFF64748B));

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          iconData,
                          size: 16,
                          color: iconColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "${item['num'] ?? (index + 1)}. ${item['title']}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: badgeTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (item['obs'] != null &&
                        item['obs'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 24, top: 2),
                        child: Text(
                          "Obs: ${item['obs']}",
                          style: const TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    if ((item['photos'] as List?)?.isNotEmpty == true)
                      _buildPhotosPreview(item, (fn) => setState(fn),
                          readOnly: true),
                  ],
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 20),

        // Points positifs constatés
        Row(
          children: [
            const Icon(Icons.thumb_up_alt, size: 18, color: Color(0xFF15803D)),
            const SizedBox(width: 8),
            const Text(
              "Points Positifs Constatés",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "$conformCount points",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF15803D),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (checklistItems.any((i) => i['answer'] == 'OUI'))
          ...checklistItems.where((i) => i['answer'] == 'OUI').map((it) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle,
                            size: 18, color: Color(0xFF16A34A)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Point ${it['num']}: ${it['title']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF166534),
                                ),
                              ),
                              if (it['obs'] != null &&
                                  it['obs'].toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    "Obs: ${it['obs']}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF15803D),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if ((it['photos'] as List?)?.isNotEmpty == true)
                      _buildPhotosPreview(it, (fn) => setState(fn),
                          readOnly: true),
                  ],
                ),
              ),
            );
          })
        else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              "Aucun point évalué conforme pour le moment.",
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),

        const SizedBox(height: 20),

        // Écarts et actions
        Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                size: 20, color: Color(0xFFDC2626)),
            const SizedBox(width: 8),
            const Text(
              "Écarts & Risques Identifiés",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "$deviationsCount écart(s)",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB91C1C),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (checklistItems.any((i) => i['answer'] == 'NON'))
          ...checklistItems.where((i) => i['answer'] == 'NON').map((it) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.cancel,
                            size: 18, color: Color(0xFFDC2626)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Écart • Point ${it['num']}: ${it['title']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF991B1B),
                                ),
                              ),
                              if (it['obs'] != null &&
                                  it['obs'].toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    "Constat: ${it['obs']}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if ((it['photos'] as List?)?.isNotEmpty == true)
                      _buildPhotosPreview(it, (fn) => setState(fn),
                          readOnly: true),
                    if (it['action'] != null)
                      _buildActionCard(it, (fn) => setState(fn))
                    else
                      Padding(
                        padding: const EdgeInsets.only(left: 26, top: 8),
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFDC2626),
                            side: const BorderSide(color: Color(0xFFDC2626)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.add_task, size: 16),
                          label: const Text(
                            "Définir l'action corrective",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () => _showCorrectiveActionDialogForItem(
                            it,
                            (fn) => setState(fn),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          })
        else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Aucun écart constaté lors de ce contrôle terrain.",
                    style: TextStyle(fontSize: 12, color: Color(0xFF15803D)),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // =========================================================================
  // BOTTOM SHEET BAR
  // =========================================================================
  Widget _buildBottomSheetBar() {
    final s = checklist.status.toLowerCase();
    final isDraft = s.contains('planifi') || s.contains('brouillon') || s == 'draft';

    return Container(
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
              backgroundColor: isDraft
                  ? const Color(0xFF1D4ED8)
                  : (isCompleted || currentProgress >= 1.0
                      ? const Color(0xFF15803D)
                      : AppColors.primary),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: Icon(
              isDraft
                  ? Icons.play_arrow
                  : (isCompleted
                      ? Icons.picture_as_pdf
                      : (currentProgress >= 1.0
                          ? Icons.check_circle
                          : Icons.edit_note)),
              size: 22,
            ),
            label: Text(
              isDraft
                  ? "Démarrer le contrôle terrain"
                  : (isCompleted
                      ? "Télécharger la fiche officielle (PDF)"
                      : (currentProgress >= 1.0
                          ? "Clôturer le contrôle terrain"
                          : "Évaluer / Continuer le contrôle")),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            onPressed: () {
              if (isDraft) {
                _startChecklist();
              } else if (isCompleted) {
                ChecklistPdfService.printOrShareChecklist(checklist,
                    items: checklistItems);
              } else if (currentProgress >= 1.0) {
                _closeChecklist();
              } else {
                _showChecklistEvaluationBottomSheet();
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(reference),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: "Télécharger la fiche officielle Galana (PDF)",
            onPressed: () {
              ChecklistPdfService.printOrShareChecklist(checklist,
                  items: checklistItems);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: "Partager la fiche de contrôle",
            onPressed: () {
              ChecklistPdfService.printOrShareChecklist(checklist,
                  items: checklistItems);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCard(),
            const SizedBox(height: 20),
            _buildInspectionBody(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildBottomSheetBar(),
    );
  }
}
