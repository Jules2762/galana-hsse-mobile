import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/services/personnel_service.dart';
import 'package:gestion_hsse/cores/services/realtime_service.dart';
import 'package:gestion_hsse/cores/services/sync_service.dart';
import 'package:gestion_hsse/cores/services/vmc_pdf_service.dart';
import 'package:gestion_hsse/cores/services/vmc_service.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';

import 'package:gestion_hsse/views/home/inspection/vmc/vmc_list_view.dart';

class VmcDetailPage extends StatefulWidget {
  final VmcItemData? vmc;

  const VmcDetailPage({super.key, this.vmc});

  @override
  State<VmcDetailPage> createState() => _VmcDetailPageState();
}

class _VmcDetailPageState extends State<VmcDetailPage> {
  late VmcItemData vmc;
  late List<Map<String, dynamic>> vmcItems;
  bool _hasLoadedFromArgs = false;

  // Participant list for Safety Moment & Safety Awareness
  late List<Map<String, dynamic>> participants;
  late List<Map<String, dynamic>> awarenessSessions;

  // Safety Report specific state (Gravité officielle de 0 à 5)
  int reportGravity = 2;
  bool reportZoneSecured = true;
  String reportImmediateAction =
      "Isolement de la vanne amont, mise en place d'un bac de rétention et boudins absorbants.";
  String reportRootCause = "Usure du joint d'étanchéité sous contrainte cyclique.";

  String _getGravityLabel(int level) {
    switch (level) {
      case 0:
        return "Négligeable";
      case 1:
        return "Mineur";
      case 2:
        return "Modéré";
      case 3:
        return "Important";
      case 4:
        return "Majeur";
      case 5:
        return "Critique";
      default:
        return "Niveau $level";
    }
  }

  Color _getGravityColor(int level) {
    switch (level) {
      case 0:
        return const Color(0xFF16A34A); // Vert
      case 1:
        return const Color(0xFF0284C7); // Bleu ciel
      case 2:
        return const Color(0xFFD97706); // Ambre / Jaune-orange
      case 3:
        return const Color(0xFFEA580C); // Orange foncé
      case 4:
        return const Color(0xFFDC2626); // Rouge
      case 5:
        return const Color(0xFF991B1B); // Rouge très foncé / Critique
      default:
        return const Color(0xFFD97706);
    }
  }

  // Safety Moment specific state
  String safetyMomentFeedback =
      "Demande d'inspection préventive des câbles et pinces de mise à la terre sur le quai 2.";

  // Safety Awareness specific state
  String safetyAwarenessCommitment =
      "100% port des gants néoprène et lunettes lors des manipulations d'hydrocarbures et solvants.";

  @override
  void initState() {
    super.initState();
    vmc = widget.vmc ??
        const VmcItemData(
          reference: "#VMC-SS-2026-012",
          title: "Visite VMC Station-Service Antsirabe Centre",
          type: "Station-Service",
          code: "HSSE GALANA 1",
          site: "Station Antsirabe Centre",
          inspector: "Jean Rakoto (Directeur Réseau)",
          date: "14 Oct 2026",
          status: "En cours",
          positivePoints: 11,
          deviations: 2,
          complianceRate: 0.85,
        );
    _initItemsForVmc();
    _initParticipants();
  }

  void _initItemsForVmc() {
    final raw = VmcPdfService.getVmcItemsForType(vmc.type, deviations: vmc.deviations);
    vmcItems = raw.map<Map<String, dynamic>>((item) {
      final copy = Map<String, dynamic>.from(item);
      final bool? isYes = copy['yes'];
      copy['answer'] ??= (isYes == true ? 'OUI' : (isYes == false ? 'NON' : 'N/A'));
      return copy;
    }).toList();
    _initAwarenessSessions();
  }

  void _initAwarenessSessions() {
    awarenessSessions = [
      {
        "date": "12/10/2026",
        "type": "formation",
        "volet": "Santé",
        "intitule": "Port des EPI spécifiques & manipulation des produits chimiques",
        "intervenant": "Mireille R. (Superviseur HSSE)",
      },
      {
        "date": "12/10/2026",
        "type": "sensibilisation",
        "volet": "Sécurité",
        "intitule": "Gestes et postures lors de la manutention des fûts de lubrifiants",
        "intervenant": "Jean Rakoto (Chef de Piste)",
      },
      {
        "date": "13/10/2026",
        "type": "atelier",
        "volet": "Environnement",
        "intitule": "Déploiement du kit anti-pollution et gestion des terres souillées",
        "intervenant": "Haja Tsiresy (Opérateur)",
      },
      {
        "date": "14/10/2026",
        "type": "induction",
        "volet": "Sûreté",
        "intitule": "Consignes de sécurité visiteur et règles de circulation des engins",
        "intervenant": "Alain Bao (Maintenance)",
      },
    ];
  }

  void _initParticipants() {
    participants = [
      {"name": "Jean Rakoto", "role": "Chef de Piste / Quart", "present": true},
      {"name": "Marc Kely", "role": "Chauffeur Transporteur", "present": true},
      {"name": "Haja Tsiresy", "role": "Opérateur Dépotage", "present": true},
      {"name": "Mireille R.", "role": "Superviseur HSSE", "present": true},
      {"name": "Alain B.", "role": "Technicien Maintenance", "present": true},
      {"name": "Tahina Andriamihaja", "role": "Opérateur Dépotage", "present": true},
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedFromArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is VmcItemData) {
        setState(() {
          vmc = args;
          _initItemsForVmc();
        });
        _hasLoadedFromArgs = true;
        if (vmc.id != null) {
          _fetchRemoteDetails(vmc.id!);
        }
      }
    }
  }

  /// Chargement asynchrone des données réelles depuis l'API Laravel
  Future<void> _fetchRemoteDetails(int id) async {
    final detail = await VmcService.getVmcDetail(id);
    if (!mounted || detail == null) return;

    setState(() {
      // 1. Mise à jour de l'inspection si présente
      if (detail['inspection'] is Map &&
          detail['inspection']['items'] is List) {
        final items = detail['inspection']['items'] as List;
        if (items.isNotEmpty) {
          int autoIndex = 1;
          vmcItems = items.map<Map<String, dynamic>>((it) {
            final rawAns = it['answer']?.toString().toUpperCase();
            String ans = 'N/A';
            if (rawAns == 'YES' || rawAns == 'OUI') {
              ans = 'OUI';
            } else if (rawAns == 'NO' || rawAns == 'NON') {
              ans = 'NON';
            } else {
              ans = 'N/A';
            }
            final dynamic rawNum = it['order'] ?? it['num'] ?? (autoIndex++);
            return {
              'id': it['id'],
              'num': rawNum.toString(),
              'title': it['title']?.toString() ?? '',
              'answer': ans,
              'yes': ans == 'OUI' ? true : (ans == 'NON' ? false : null),
              'obs': it['observation']?.toString() ?? '',
            };
          }).toList();
        }
      }

      // 2. Mise à jour Safety Awareness
      if (detail['safety_awareness_items'] is List) {
        final sessions = detail['safety_awareness_items'] as List;
        if (sessions.isNotEmpty) {
          awarenessSessions = sessions.map<Map<String, dynamic>>((s) {
            return {
              'date': s['date']?.toString() ?? '',
              'type': s['type']?.toString().toLowerCase() ?? 'formation',
              'volet': s['volet']?.toString() ?? 'Sécurité',
              'intitule': s['title']?.toString() ?? '',
              'intervenant': s['participant']?.toString() ?? vmc.inspector,
            };
          }).toList();
        }
      }

      // 3. Mise à jour Safety Report
      if (detail['safety_report_form'] is Map) {
        final rep = detail['safety_report_form'];
        if (rep['info_gravity'] != null) {
          reportGravity =
              int.tryParse(rep['info_gravity'].toString()) ?? reportGravity;
        }
        if (rep['immediate_action_description'] != null) {
          reportImmediateAction =
              rep['immediate_action_description'].toString();
        }
        if (rep['root_cause_description'] != null) {
          reportRootCause = rep['root_cause_description'].toString();
        }
      }

      // 4. Mise à jour Safety Moment (Tous les participants sont présents)
      if (detail['safety_moment'] is Map &&
          detail['safety_moment']['participants'] is List) {
        final parts = detail['safety_moment']['participants'] as List;
        if (parts.isNotEmpty) {
          participants = parts.map<Map<String, dynamic>>((p) {
            return {
              'name':
                  "${p['first_name'] ?? ''} ${p['last_name'] ?? ''}".trim(),
              'role': p['fonction']?.toString() ?? 'Participant',
              'present': true,
            };
          }).toList();
        }
      }
    });
  }

  /// Démarre la visite VMC sur le terrain (passage du statut à "En cours")
  Future<void> _startVmcVisit() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      vmc = VmcItemData(
        id: vmc.id,
        reference: vmc.reference,
        title: vmc.title,
        type: vmc.type,
        code: vmc.code,
        category: vmc.category,
        site: vmc.site,
        inspector: vmc.inspector,
        date: vmc.date,
        status: "En cours",
        positivePoints: vmc.positivePoints,
        deviations: vmc.deviations,
        complianceRate: vmc.complianceRate,
        participantsCount: participants.length,
        theme: vmc.theme,
        rawData: vmc.rawData,
      );
    });

    if (vmc.id != null) {
      await VmcService.updateStatus(vmc.id!, 'IN_PROGRESS');
      RealtimeService.instance.notifyLocalChange(
        'VMC',
        'Visite VMC Démarrée',
        'La visite ${vmc.reference} est maintenant en cours sur le terrain',
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
                    ? "Visite démarrée ! Statut passé à 'En cours' et synchronisé."
                    : "Visite démarrée en mode hors-ligne ! Statut passé à 'En cours'.",
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CATEGORY CHECKERS ---
  bool get isInspection {
    final lower = vmc.type.toLowerCase();
    return lower.contains('station') ||
        lower.contains('ss') ||
        lower.contains('camion') ||
        lower.contains('cc') ||
        lower.contains('citerne') ||
        lower.contains('magasin') ||
        lower.contains('agence') ||
        vmc.category.toUpperCase() == 'INSPECTION';
  }

  bool get isSafetyMoment {
    final lower = vmc.type.toLowerCase();
    return lower.contains('moment') ||
        vmc.category.toUpperCase() == 'SAFETY MOMENT';
  }

  bool get isSafetyAwareness {
    final lower = vmc.type.toLowerCase();
    return lower.contains('awareness') ||
        lower.contains('sensibilisation') ||
        vmc.category.toUpperCase() == 'SAFETY AWARENESS';
  }

  bool get isSafetyReport {
    final lower = vmc.type.toLowerCase();
    return lower.contains('report') ||
        lower.contains('remontée') ||
        vmc.category.toUpperCase() == 'SAFETY REPORT';
  }

  Color get _statusBgColor {
    final s = vmc.status.toLowerCase();
    if (s.contains('planifi') || s.contains('brouillon') || s == 'draft') {
      return const Color(0xFFFEF3C7);
    }
    if (s.contains('cours') || s == 'in_progress') {
      return const Color(0xFFDBEAFE);
    }
    if (s.contains('termin') || s.contains('clôtur') || s.contains('clotur') || s == 'completed' || s == 'conforme') {
      return const Color(0xFFDCFCE7);
    }
    if (s.contains('annul') || s.contains('non-conforme') || s == 'cancelled') {
      return const Color(0xFFFEE2E2);
    }
    return const Color(0xFFF1F5F9);
  }

  Color get _statusTextColor {
    final s = vmc.status.toLowerCase();
    if (s.contains('planifi') || s.contains('brouillon') || s == 'draft') {
      return const Color(0xFFB45309);
    }
    if (s.contains('cours') || s == 'in_progress') {
      return const Color(0xFF1D4ED8);
    }
    if (s.contains('termin') || s.contains('clôtur') || s.contains('clotur') || s == 'completed' || s == 'conforme') {
      return const Color(0xFF15803D);
    }
    if (s.contains('annul') || s.contains('non-conforme') || s == 'cancelled') {
      return const Color(0xFFB91C1C);
    }
    return const Color(0xFF475569);
  }

  // =========================================================================
  // 1. MODAL D'ÉVALUATION DE GRILLE (INSPECTIONS: Station, Camion, Magasin, Dépôt)
  // =========================================================================
  void _showVmcEvaluationBottomSheet() {
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
                                "Évaluation ${vmc.code}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                "${vmc.reference} • ${vmcItems.length} points de contrôle officiels",
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
                        itemCount: vmcItems.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 20),
                        itemBuilder: (context, index) {
                          final item = vmcItems[index];
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
                          final positive = vmcItems.where((i) {
                            final a = i['answer'] ??
                                (i['yes'] == true
                                    ? 'OUI'
                                    : (i['yes'] == false ? 'NON' : 'N/A'));
                            return a == 'OUI';
                          }).length;
                          final dev = vmcItems.where((i) {
                            final a = i['answer'] ??
                                (i['yes'] == true
                                    ? 'OUI'
                                    : (i['yes'] == false ? 'NON' : 'N/A'));
                            return a == 'NON';
                          }).length;
                          final evaluated = positive + dev;
                          final rate =
                              evaluated > 0 ? (positive / evaluated) : 1.0;

                          setState(() {
                            vmc = VmcItemData(
                              id: vmc.id,
                              reference: vmc.reference,
                              title: vmc.title,
                              type: vmc.type,
                              code: vmc.code,
                              category: vmc.category,
                              site: vmc.site,
                              inspector: vmc.inspector,
                              date: vmc.date,
                              status: vmc.status,
                              positivePoints: positive,
                              deviations: dev,
                              complianceRate: rate,
                              participantsCount: vmc.participantsCount,
                              theme: vmc.theme,
                              rawData: vmc.rawData,
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
          "Observation Point ${item['num'] ?? (vmcItems.indexOf(item) + 1)}",
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

  // =========================================================================
  // 2. MODAL D'AJOUT ET ÉMARGEMENT DE PARTICIPANTS (SAFETY MOMENT)
  // =========================================================================
  void _showAddParticipantSheet({StateSetter? modalSetState}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String query = "";
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Column(
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.person_add_alt_1,
                              color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Ajouter un Participant",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                "Sélectionnez parmi la liste des personnels Galana",
                                style: TextStyle(
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
                    const SizedBox(height: 14),
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, size: 20),
                        hintText: "Rechercher par nom ou fonction...",
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                      onChanged: (val) {
                        setSheetState(() {
                          query = val.trim().toLowerCase();
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    Expanded(
                      child: FutureBuilder<List<PersonnelItem>>(
                        future: PersonnelService.getPersonnels(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.waiting &&
                              !snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final list = snapshot.data ?? [];
                          final filtered = list.where((p) {
                            if (query.isEmpty) return true;
                            return p.fullName.toLowerCase().contains(query) ||
                                p.fonction.toLowerCase().contains(query) ||
                                p.email.toLowerCase().contains(query);
                          }).toList();

                          if (filtered.isEmpty) {
                            return const Center(
                              child: Text(
                                "Aucun personnel trouvé.",
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary),
                              ),
                            );
                          }

                          return ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 12),
                            itemBuilder: (context, index) {
                              final person = filtered[index];
                              final bool alreadyAdded = participants.any(
                                  (p) =>
                                      p['name']?.toString().toLowerCase() ==
                                      person.fullName.toLowerCase());

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: alreadyAdded
                                      ? const Color(0xFFDCFCE7)
                                      : AppColors.primaryLight,
                                  child: Icon(
                                    alreadyAdded ? Icons.check : Icons.person,
                                    color: alreadyAdded
                                        ? const Color(0xFF15803D)
                                        : AppColors.primary,
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  person.fullName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  person.fonction,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                trailing: alreadyAdded
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDCFCE7),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          "Déjà présent",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF15803D),
                                          ),
                                        ),
                                      )
                                    : ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            participants.add({
                                              'name': person.fullName,
                                              'role': person.fonction,
                                              'present': true,
                                            });
                                            vmc = VmcItemData(
                                              id: vmc.id,
                                              reference: vmc.reference,
                                              title: vmc.title,
                                              type: vmc.type,
                                              code: vmc.code,
                                              category: vmc.category,
                                              site: vmc.site,
                                              inspector: vmc.inspector,
                                              date: vmc.date,
                                              status: vmc.status,
                                              positivePoints:
                                                  vmc.positivePoints,
                                              deviations: vmc.deviations,
                                              complianceRate:
                                                  vmc.complianceRate,
                                              participantsCount:
                                                  participants.length,
                                              theme: vmc.theme,
                                              rawData: vmc.rawData,
                                            );
                                          });
                                          if (modalSetState != null) {
                                            modalSetState(() {});
                                          }
                                          setSheetState(() {});
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor:
                                                  const Color(0xFF15803D),
                                              content: Text(
                                                "${person.fullName} ajouté aux participants présents.",
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "Ajouter",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                              );
                            },
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

  void _showSafetyMomentAttendanceModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final feedbackController =
                TextEditingController(text: safetyMomentFeedback);

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Column(
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.timer,
                              color: Color(0xFFB45309), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Émargement Quart d'Heure Sécurité",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                "${participants.length} participant(s) présent(s) • 15 min chrono",
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
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Participants Présents à la Séance :",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.person_add, size: 16),
                          label: const Text(
                            "Ajouter",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => _showAddParticipantSheet(
                              modalSetState: setModalState),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: participants.isEmpty
                          ? const Center(
                              child: Text(
                                "Aucun participant pour le moment.\nCliquez sur Ajouter pour sélectionner parmi le personnel.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: participants.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 12),
                              itemBuilder: (context, index) {
                                final p = participants[index];
                                return Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Color(0xFFDCFCE7),
                                      child: Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Color(0xFF15803D),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p["name"].toString(),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            p["role"].toString(),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDCFCE7),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        "Présent",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF15803D),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                        size: 20,
                                      ),
                                      tooltip: "Retirer de la séance",
                                      onPressed: () {
                                        setModalState(() {
                                          participants.removeAt(index);
                                        });
                                        setState(() {
                                          vmc = VmcItemData(
                                            id: vmc.id,
                                            reference: vmc.reference,
                                            title: vmc.title,
                                            type: vmc.type,
                                            code: vmc.code,
                                            category: vmc.category,
                                            site: vmc.site,
                                            inspector: vmc.inspector,
                                            date: vmc.date,
                                            status: vmc.status,
                                            positivePoints:
                                                vmc.positivePoints,
                                            deviations: vmc.deviations,
                                            complianceRate:
                                                vmc.complianceRate,
                                            participantsCount:
                                                participants.length,
                                            theme: vmc.theme,
                                            rawData: vmc.rawData,
                                          );
                                        });
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Questions / Remontées de l'équipe :",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: feedbackController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText:
                            "Saisir les remarques formulées par l'équipe...",
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.how_to_reg, size: 18),
                        label: const Text(
                          "Valider l'Émargement de Séance",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            safetyMomentFeedback =
                                feedbackController.text.trim();
                            vmc = VmcItemData(
                              id: vmc.id,
                              reference: vmc.reference,
                              title: vmc.title,
                              type: vmc.type,
                              code: vmc.code,
                              category: vmc.category,
                              site: vmc.site,
                              inspector: vmc.inspector,
                              date: vmc.date,
                              status: vmc.status,
                              positivePoints: vmc.positivePoints,
                              deviations: vmc.deviations,
                              complianceRate: vmc.complianceRate,
                              participantsCount: participants.length,
                              theme: vmc.theme,
                              rawData: vmc.rawData,
                            );
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.primary,
                              content: Text(
                                "Émargement validé : ${participants.length} participant(s) présents.",
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

  // =========================================================================
  // 3. MODAL D'AJOUT DE SESSION DE FORMATION (SAFETY TRAINING / AWARENESS)
  // =========================================================================
  void _showSafetyAwarenessModal() {
    String selectedType = "formation";
    String selectedVolet = "Sécurité";
    final dateCtrl = TextEditingController(text: "14/10/2026");
    final titleCtrl = TextEditingController();
    final speakerCtrl = TextEditingController(text: vmc.inspector);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF007A78).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.school_outlined,
                              color: Color(0xFF007A78), size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Ajouter une Session de Formation",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                "Registre Officiel SAFETY TRAINING / AWARENESS",
                                style: TextStyle(
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
                    const SizedBox(height: 16),

                    // Date
                    const Text(
                      "Date :",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: dateCtrl,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        suffixIcon: const Icon(Icons.calendar_today, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Type (*)
                    const Text(
                      "Type (*) :",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: ["formation", "sensibilisation", "induction", "atelier"].map((type) {
                        final isSel = selectedType == type;
                        return ChoiceChip(
                          label: Text(type),
                          selected: isSel,
                          onSelected: (val) => setModalState(() => selectedType = type),
                          selectedColor: const Color(0xFF007A78),
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Volet (**)
                    const Text(
                      "Volet (**) :",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: ["Santé", "Sécurité", "Sûreté", "Environnement"].map((volet) {
                        final isSel = selectedVolet == volet;
                        return ChoiceChip(
                          label: Text(volet),
                          selected: isSel,
                          onSelected: (val) => setModalState(() => selectedVolet = volet),
                          selectedColor: const Color(0xFF007A78),
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Intitulé
                    const Text(
                      "Intitulé de la formation / causerie :",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        hintText: "Ex : Règles d'Or Galana & Manipulation sécurisée",
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Intervenant
                    const Text(
                      "Intervenant :",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: speakerCtrl,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007A78),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.check_circle_outline, size: 20),
                        label: const Text(
                          "Enregistrer dans le Registre",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          if (titleCtrl.text.trim().isEmpty) return;
                          setState(() {
                            awarenessSessions.add({
                              "date": dateCtrl.text.trim(),
                              "type": selectedType,
                              "volet": selectedVolet,
                              "intitule": titleCtrl.text.trim(),
                              "intervenant": speakerCtrl.text.trim(),
                            });
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Ligne ajoutée au registre officiel SAFETY TRAINING"),
                              backgroundColor: Color(0xFF007A78),
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


  // =========================================================================
  // 4. MODAL DE TRAITEMENT DE REMONTÉE (SAFETY REPORT FOR01-HSSE-ACC)
  // =========================================================================
  void _showSafetyReportModal() {
    int selectedGravity = reportGravity;
    bool isSecured = reportZoneSecured;
    final actionCtrl = TextEditingController(text: reportImmediateAction);

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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.report_problem,
                              color: Color(0xFFDC2626), size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Traitement de l'Anomalie (FOR01)",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                "Niveau de gravité (0 à 5) & Mesures",
                                style: TextStyle(
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
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Niveau de Gravité (Échelle 0 à 5) :",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: _getGravityColor(selectedGravity)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: _getGravityColor(selectedGravity)
                                    .withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            "Niveau $selectedGravity : ${_getGravityLabel(selectedGravity)}",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _getGravityColor(selectedGravity),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Grille sélective des 6 niveaux de 0 à 5
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (level) {
                        final isSelected = selectedGravity == level;
                        final color = _getGravityColor(level);
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () {
                                setModalState(() {
                                  selectedGravity = level;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? color
                                      : color.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? color
                                        : color.withValues(alpha: 0.3),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    Text(
                                      "$level",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isSelected ? Colors.white : color,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _getGravityLabel(level).split(" ").first,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color:
                                            isSelected ? Colors.white : color,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        "Zone Immédiatement Sécurisée & Balisée",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: const Text(
                        "Arrêt du flux et mise en sécurité des intervenants",
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                      value: isSecured,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) {
                        setModalState(() {
                          isSecured = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Mesures Conservatoires Prises :",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: actionCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const Spacer(),
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
                        icon: const Icon(Icons.save_alt, size: 20),
                        label: const Text(
                          "Enregistrer les Mesures Conservatoires",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            reportGravity = selectedGravity;
                            reportZoneSecured = isSecured;
                            reportImmediateAction = actionCtrl.text.trim();
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.primary,
                              content: Text(
                                "Fiche mise à jour : Gravité $selectedGravity/5 (${_getGravityLabel(selectedGravity)}).",
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

  // =========================================================================
  // 5. CLÔTURE OFFICIELLE DE LA VMC SUR LE TERRAIN
  // =========================================================================
  void _showClosureDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.verified, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Clôturer la VMC",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Vous êtes sur le point de clôturer officiellement cette VMC sur le terrain :",
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${vmc.reference} • ${vmc.code}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vmc.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Évaluateur : ${vmc.inspector}\nSite : ${vmc.site}",
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Une fois clôturée, la fiche officielle Galana sera générée et disponible au format PDF certifié.",
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final nav = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                if (vmc.id != null) {
                  await VmcService.updateStatus(vmc.id!, 'COMPLETED');
                  RealtimeService.instance.notifyLocalChange(
                    'VMC',
                    'Visite VMC Clôturée',
                    'La visite ${vmc.reference} a été clôturée sur le terrain',
                  );
                }
                if (!mounted) return;
                setState(() {
                  vmc = VmcItemData(
                    id: vmc.id,
                    reference: vmc.reference,
                    title: vmc.title,
                    type: vmc.type,
                    code: vmc.code,
                    category: vmc.category,
                    site: vmc.site,
                    inspector: vmc.inspector,
                    date: vmc.date,
                    status: "Clôturée",
                    positivePoints: vmc.positivePoints,
                    deviations: vmc.deviations,
                    complianceRate: vmc.complianceRate,
                    participantsCount: vmc.participantsCount,
                    theme: vmc.theme,
                    rawData: vmc.rawData,
                  );
                });
                nav.pop();
                final isOnline = SyncService.instance.isOnline;
                messenger.showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 4),
                    content: Row(
                      children: [
                        Icon(isOnline ? Icons.check_circle : Icons.cloud_off, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isOnline
                                ? "La visite VMC a été clôturée et synchronisée avec l'API Galana !"
                                : "Visite clôturée en mode Hors-ligne ! Synchronisation automatique dès la reconnexion.",
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: isOnline ? const Color(0xFF15803D) : const Color(0xFFD97706),
                  ),
                );
              },
              child: const Text("Confirmer la Clôture"),

            ),
          ],
        );
      },
    );
  }

  // =========================================================================
  // BUILD PRINCIPAL
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(vmc.reference),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: "Télécharger la fiche officielle Galana (PDF)",
            onPressed: () {
              VmcPdfService.printOrShareVmc(
                vmc,
                customItems: isSafetyMoment
                    ? participants
                    : (isSafetyAwareness ? awarenessSessions : vmcItems),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: "Partager la fiche VMC",
            onPressed: () {
              VmcPdfService.printOrShareVmc(
                vmc,
                customItems: isSafetyMoment
                    ? participants
                    : (isSafetyAwareness ? awarenessSessions : vmcItems),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================== HERO CARD ====================
            _buildHeroCard(),

            const SizedBox(height: 20),

            // ==================== RENDU SPÉCIFIQUE SELON LE TYPE ====================
            if (isSafetyMoment)
              _buildSafetyMomentBody()
            else if (isSafetyAwareness)
              _buildSafetyAwarenessBody()
            else if (isSafetyReport)
              _buildSafetyReportBody()
            else
              _buildInspectionBody(),

            const SizedBox(height: 100),
          ],
        ),
      ),

      // ==================== BARRE D'ACTIONS INFERIEURE ====================
      bottomSheet: _buildBottomSheet(),
    );
  }

  // =========================================================================
  // 1. CARTE HERO COMMUNE
  // =========================================================================
  Widget _buildHeroCard() {
    IconData heroIcon = Icons.verified_user;
    Color iconColor = AppColors.primary;
    if (isSafetyMoment) {
      heroIcon = Icons.timer;
      iconColor = const Color(0xFFD97706);
    } else if (isSafetyAwareness) {
      heroIcon = Icons.record_voice_over;
      iconColor = const Color(0xFF7C3AED);
    } else if (isSafetyReport) {
      heroIcon = Icons.warning_amber_rounded;
      iconColor = const Color(0xFFDC2626);
    }

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
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(heroIcon, size: 28, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          vmc.reference,
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
                            vmc.code,
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
                      vmc.title,
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  vmc.status,
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
                  vmc.site,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(Icons.calendar_today,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                vmc.date,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.person, size: 14, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Leader / Évaluateur : ${vmc.inspector}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 2. CORPS POUR LES INSPECTIONS (Station, Camion, Magasins, Dépôt)
  // =========================================================================
  Widget _buildInspectionBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Détails de la visite
        const Text(
          "Détails de l'Inspection Terrain",
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
              _buildDetailRow("Type de visite", vmc.type),
              _buildDivider(),
              _buildDetailRow("Code formulaire", vmc.code),
              _buildDivider(),
              _buildDetailRow("Accompagnateurs", "Mireille R. (HSSE), Chef de quart"),
              _buildDivider(),
              _buildDetailRow("Taux de conformité", "${(vmc.complianceRate * 100).toInt()}%"),
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
              "Grille de Contrôle (${vmcItems.length} points)",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _showVmcEvaluationBottomSheet,
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
            children: List.generate(vmcItems.length, (index) {
              final item = vmcItems[index];
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
                child: Row(
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
                "${vmc.positivePoints} points",
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
        _buildConstatCard(
          title: "Port complet et conforme des EPI",
          description:
              "L'ensemble des opérateurs et intervenants sur site portent l'équipement complet conforme aux standards HSSE Galana.",
          isPositive: true,
        ),
        const SizedBox(height: 8),
        _buildConstatCard(
          title: "Rétentions et propreté générale",
          description:
              "Aires de circulation et bacs de rétention dégagés, matériel d'intervention incendie accessible et vérifié.",
          isPositive: true,
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
                "${vmc.deviations} écart(s)",
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
        if (vmc.deviations > 0)
          _buildConstatCard(
            title: "Mise à la terre ou point d'usure constaté",
            description:
                "Continuité ou serrage imparfait identifié lors du contrôle. Action corrective immédiate déclenchée.",
            isPositive: false,
          )
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
                    "Aucun écart constaté lors de cette visite managériale.",
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
  // 3. CORPS POUR SAFETY MOMENT (Quart d'Heure Sécurité)
  // =========================================================================
  Widget _buildSafetyMomentBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thème & Durée
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.flash_on, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Quart d'Heure Sécurité - 15 min Chrono",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "Thème : ${vmc.theme ?? 'Risques électrostatiques & Dépotage citernes'}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Objectif : Sensibiliser l'équipe aux risques immédiats, réviser la procédure d'urgence et assurer la coordination terrain.",
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Consignes abordées
        const Text(
          "Consignes et Démonstrations Abordées",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: List.generate(vmcItems.length, (index) {
              final it = vmcItems[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Color(0xFF16A34A), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "${it['num'] ?? (index + 1)}. ${it['title']}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 20),

        // Émargement des participants
        Row(
          children: [
            const Icon(Icons.people_alt, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              "Participants Présents (${participants.length})",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showAddParticipantSheet(),
              icon: const Icon(Icons.person_add, size: 16),
              label: const Text(
                "Ajouter",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton.icon(
              onPressed: _showSafetyMomentAttendanceModal,
              icon: const Icon(Icons.edit, size: 16),
              label: const Text(
                "Émarger",
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
          child: participants.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      "Aucun participant enregistré.\nCliquez sur Ajouter pour sélectionner un personnel présent.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                )
              : Column(
                  children: List.generate(participants.length, (index) {
                    final p = participants[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 12,
                            backgroundColor: Color(0xFFDCFCE7),
                            child: Icon(
                              Icons.check,
                              size: 14,
                              color: Color(0xFF15803D),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "${p['name']} • ${p['role']}",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "Présent",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                            tooltip: "Retirer de la séance",
                            onPressed: () {
                              setState(() {
                                participants.removeAt(index);
                                vmc = VmcItemData(
                                  id: vmc.id,
                                  reference: vmc.reference,
                                  title: vmc.title,
                                  type: vmc.type,
                                  code: vmc.code,
                                  category: vmc.category,
                                  site: vmc.site,
                                  inspector: vmc.inspector,
                                  date: vmc.date,
                                  status: vmc.status,
                                  positivePoints: vmc.positivePoints,
                                  deviations: vmc.deviations,
                                  complianceRate: vmc.complianceRate,
                                  participantsCount: participants.length,
                                  theme: vmc.theme,
                                  rawData: vmc.rawData,
                                );
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                ),
        ),

        const SizedBox(height: 20),

        // Questions & Retours de l'équipe
        const Text(
          "Retours d'Expérience & Questions de l'Équipe",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.comment, size: 18, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  safetyMomentFeedback,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 4. CORPS POUR SAFETY AWARENESS (Causerie / Sensibilisation)
  // =========================================================================
  // =========================================================================
  // 4. CORPS POUR SAFETY TRAINING / SAFETY AWARENESS (PHOTO 6 REGISTRE GALANA)
  // =========================================================================
  Widget _buildSafetyAwarenessBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Leader Commitment
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007A78).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.badge_outlined,
                        color: Color(0xFF007A78), size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Leader Commitment",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _buildLeaderInfoRow("Nom :", vmc.inspector),
              const SizedBox(height: 8),
              _buildLeaderInfoRow("Fonction :", "Superviseur HSSE & Exploitation"),
              const SizedBox(height: 8),
              _buildLeaderInfoRow(
                  "Direction:", "Direction Logistique & Distribution / Réseau"),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 2. Détails de la formation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Détails de la formation",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  "${awarenessSessions.length} sessions enregistrées",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007A78),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                "Ajouter",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              onPressed: _showSafetyAwarenessModal,
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Liste des sessions du registre
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: List.generate(awarenessSessions.length, (index) {
              final session = awarenessSessions[index];
              final String date = session["date"]?.toString() ?? "";
              final String type = session["type"]?.toString() ?? "";
              final String volet = session["volet"]?.toString() ?? "";
              final String title = session["intitule"]?.toString() ?? "";
              final String speaker = session["intervenant"]?.toString() ?? "";

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: index < awarenessSessions.length - 1
                      ? Border(
                          bottom: BorderSide(
                              color: AppColors.border.withValues(alpha: 0.6)))
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        date,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildTypeBadge(type),
                              const SizedBox(width: 6),
                              _buildVoletBadge(volet),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.person_outline,
                                  size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                "Intervenant : $speaker",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.redAccent, size: 20),
                      tooltip: "Supprimer la ligne",
                      onPressed: () {
                        setState(() {
                          awarenessSessions.removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 16),

        // Notes officielles Galana
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "(*) Type : formation, sensibilisation, induction, atelier",
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 4),
              Text(
                "(**) Volet : Santé, Sécurité, Sûreté, Environnement",
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Bouton d'export PDF officiel
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007A78),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.picture_as_pdf, size: 20),
            label: const Text(
              "Télécharger la Fiche Officielle Galana (PDF)",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              VmcPdfService.printOrShareVmc(vmc,
                  customItems: awarenessSessions);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300, width: 0.8)),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeBadge(String type) {
    Color bg = const Color(0xFFEFF6FF);
    Color fg = const Color(0xFF1D4ED8);
    final lower = type.toLowerCase();
    if (lower.contains('formation')) {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
    } else if (lower.contains('sensibilisation')) {
      bg = const Color(0xFFFAF5FF);
      fg = const Color(0xFF7C3AED);
    } else if (lower.contains('atelier')) {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFD97706);
    } else if (lower.contains('induction')) {
      bg = const Color(0xFFE0F2FE);
      fg = const Color(0xFF0369A1);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildVoletBadge(String volet) {
    Color bg = const Color(0xFFF1F5F9);
    Color fg = const Color(0xFF475569);
    final lower = volet.toLowerCase();
    if (lower.contains('santé') || lower.contains('sante')) {
      bg = const Color(0xFFFCE7F3);
      fg = const Color(0xFFBE185D);
    } else if (lower.contains('sécurité') || lower.contains('securite')) {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF166534);
    } else if (lower.contains('sûreté') || lower.contains('surete')) {
      bg = const Color(0xFFE0E7FF);
      fg = const Color(0xFF4338CA);
    } else if (lower.contains('environnement')) {
      bg = const Color(0xFFCCFBF1);
      fg = const Color(0xFF0F766E);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        volet,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }

  // =========================================================================
  // 5. CORPS POUR SAFETY REPORT (Fiche de Remontée FOR01-HSSE-ACC)
  // =========================================================================
  Widget _buildSafetyReportBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Carte d'alerte gravité
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFECACA)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.report, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Fiche de Remontée d'Anomalie (FOR01)",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                        Text(
                          "Condition dangereuse signalée le ${vmc.date}",
                          style: const TextStyle(fontSize: 11, color: Color(0xFFB91C1C)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getGravityColor(reportGravity).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _getGravityColor(reportGravity).withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      "Gravité : $reportGravity / 5 (${_getGravityLabel(reportGravity)})",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getGravityColor(reportGravity),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "Circonstances de l'événement :",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF991B1B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Constat d'un suintement d'hydrocarbures au niveau du joint de bride de vanne lors de la ronde matinale sur la zone cuves.",
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: Colors.red.shade900,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Causes et analyse
        const Text(
          "Analyse Terrain & Causes Identifiées",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildDetailRow("Niveau de gravité", "Niveau $reportGravity / 5 (${_getGravityLabel(reportGravity)})"),
              _buildDivider(),
              _buildDetailRow("Cause immédiate", reportRootCause),
              _buildDivider(),
              _buildDetailRow("Zone sécurisée", reportZoneSecured ? "Oui (Balisage en place)" : "En cours"),
              _buildDivider(),
              _buildDetailRow("Impact environnement", "Contenu dans le bac de rétention"),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Mesures conservatoires
        Row(
          children: [
            const Icon(Icons.shield, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              "Mesures Conservatoires Immédiates",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _showSafetyReportModal,
              icon: const Icon(Icons.edit, size: 16),
              label: const Text(
                "Modifier",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  reportImmediateAction,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Action corrective liée
        const Text(
          "Action Corrective Planifiée",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.build, size: 20, color: Color(0xFFB45309)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "#ACT-041 : Remplacement du joint de bride",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Assigné à : Superviseur Maintenance • Délai : 24h",
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // BOTTOM SHEET D'ACTIONS
  // =========================================================================
  Widget _buildBottomSheet() {
    final s = vmc.status.toLowerCase();
    final bool isPlanifiee =
        s.contains('planifi') || s.contains('brouillon') || s == 'draft';
    final bool isEnCours = s.contains('cours') || s == 'in_progress';

    // 1. Visite Planifiée / Brouillon -> Bouton "Commencer la visite"
    if (isPlanifiee) {
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
                backgroundColor: const Color(0xFF007A78),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.play_circle_fill, size: 24),
              label: const Text(
                "Commencer la visite",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              onPressed: _startVmcVisit,
            ),
          ),
        ),
      );
    }

    String evaluateButtonText = "Évaluer Terrain";
    VoidCallback onEvaluateTap = _showVmcEvaluationBottomSheet;

    if (isSafetyMoment) {
      evaluateButtonText = "Émarger Séance";
      onEvaluateTap = _showSafetyMomentAttendanceModal;
    } else if (isSafetyAwareness) {
      evaluateButtonText = "Ajouter Formation";
      onEvaluateTap = _showSafetyAwarenessModal;
    } else if (isSafetyReport) {
      evaluateButtonText = "Traiter Remontée";
      onEvaluateTap = _showSafetyReportModal;
    }

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
        child: Row(
          children: [
            if (isEnCours) ...[
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.edit_note,
                      color: AppColors.primary, size: 18),
                  label: Text(
                    evaluateButtonText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
                  ),
                  onPressed: onEvaluateTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text(
                    "Clôturer la VMC",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  onPressed: _showClosureDialog,
                ),
              ),
            ] else ...[
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.picture_as_pdf, size: 20),
                  label: const Text(
                    "Télécharger la Fiche Officielle Galana (PDF)",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  onPressed: () {
                    VmcPdfService.printOrShareVmc(
                      vmc,
                      customItems: isSafetyMoment
                          ? participants
                          : (isSafetyAwareness ? awarenessSessions : vmcItems),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // WIDGETS HELPERS
  // =========================================================================
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildConstatCard({
    required String title,
    required String description,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isPositive ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPositive
              ? const Color(0xFFBBF7D0)
              : const Color(0xFFFECACA),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isPositive ? Icons.check_circle : Icons.error,
            size: 20,
            color: isPositive
                ? const Color(0xFF16A34A)
                : const Color(0xFFDC2626),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isPositive
                        ? const Color(0xFF166534)
                        : const Color(0xFF991B1B),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: isPositive
                        ? const Color(0xFF15803D)
                        : const Color(0xFFB91C1C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
    );
  }
}
