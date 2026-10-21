import 'dart:async';
import 'package:gestion_hsse/cores/api/api_client.dart';
import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';
import 'package:gestion_hsse/cores/services/realtime_service.dart';
import 'package:gestion_hsse/cores/services/sync_service.dart';
import 'package:gestion_hsse/cores/services/vmc_pdf_service.dart';
import 'package:gestion_hsse/cores/services/vmc_service.dart';

import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/views/home/inspection/vmc/widgets/vmc_card.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/inspection_filter_chip.dart';

class VmcItemData {
  final int? id;
  final String reference;
  final String title;
  final String type;
  final String code;
  final String category;
  final String site;
  final String inspector;
  final String date;
  final String status;
  final int positivePoints;
  final int deviations;
  final double complianceRate;
  final int participantsCount;
  final String? theme;
  final Map<String, dynamic>? rawData;

  const VmcItemData({
    this.id,
    required this.reference,
    required this.title,
    required this.type,
    this.code = "HSSE GALANA",
    this.category = "INSPECTION",
    required this.site,
    required this.inspector,
    required this.date,
    required this.status,
    required this.positivePoints,
    required this.deviations,
    required this.complianceRate,
    this.participantsCount = 0,
    this.theme,
    this.rawData,
  });

  /// Instancie un VmcItemData à partir de la réponse JSON de l'API Laravel (VmcResource)
  factory VmcItemData.fromJson(Map<String, dynamic> json) {
    final int? id = json['id'] is int
        ? json['id']
        : int.tryParse(json['id']?.toString() ?? '');
    final String rawType = json['type']?.toString() ?? 'Station-Service';
    final String masterType = json['master_type']?.toString() ?? 'INSPECTION';

    // Normalisation du type pour affichage
    String displayType = rawType;
    final upperType = rawType.toUpperCase();
    if (upperType.contains('STATION') || upperType == 'STATION_SERVICE') {
      displayType = 'Station-Service';
    } else if (upperType.contains('CAMION') || upperType == 'INSPECTION_CAMION') {
      displayType = 'Inspection Camion';
    } else if (upperType.contains('MAGASIN') || upperType == 'VISITE_MAGASINS_AGENCES') {
      displayType = 'Visite Magasins & Agences';
    } else if (upperType.contains('MOMENT') || masterType == 'SAFETY_MOMENT') {
      displayType = 'Safety Moment';
    } else if (upperType.contains('AWARENESS') || masterType == 'SAFETY_AWARENESS') {
      displayType = 'Safety Awareness';
    } else if (upperType.contains('REPORT') ||
        rawType.toLowerCase().contains('remontée') ||
        masterType == 'SAFETY_REPORT') {
      displayType = 'Fiche de Remontée';
    }

    // Normalisation du statut
    final String rawStatus = json['status']?.toString() ?? 'IN_PROGRESS';
    String status = 'En cours';
    if (rawStatus.toUpperCase() == 'COMPLETED' ||
        rawStatus.toLowerCase().contains('clôtur') ||
        rawStatus.toLowerCase().contains('clotur') ||
        rawStatus.toLowerCase().contains('termin')) {
      status = 'Terminée';
    } else if (rawStatus.toUpperCase() == 'IN_PROGRESS' ||
        rawStatus.toLowerCase().contains('cours')) {
      status = 'En cours';
    } else if (rawStatus.toUpperCase() == 'DRAFT' ||
        rawStatus.toLowerCase().contains('brouillon') ||
        rawStatus.toLowerCase().contains('planifi')) {
      status = 'Planifiée';
    } else if (rawStatus.toUpperCase() == 'CANCELLED' ||
        rawStatus.toLowerCase().contains('annul')) {
      status = 'Annulée';
    }

    // Récupération de l'inspecteur
    String inspector = json['inspector']?.toString() ?? '';
    if (inspector.isEmpty && json['assigned_to'] is Map) {
      final a = json['assigned_to'];
      inspector = "${a['first_name'] ?? ''} ${a['last_name'] ?? ''}".trim();
    }
    if (inspector.isEmpty && json['created_by'] is Map) {
      final c = json['created_by'];
      inspector = "${c['first_name'] ?? ''} ${c['last_name'] ?? ''}".trim();
    }
    if (inspector.isEmpty) {
      inspector = 'Inspecteur HSSE';
    }

    // Calcul points positifs / écarts / conformité
    int pos = 0;
    int dev = 0;
    int evalCount = 0;
    if (json['inspection'] is Map && json['inspection']['items'] is List) {
      for (var it in json['inspection']['items']) {
        final ans = it['answer']?.toString().toUpperCase();
        if (ans == 'YES' || ans == 'OUI') {
          pos++;
          evalCount++;
        } else if (ans == 'NO' || ans == 'NON') {
          dev++;
          evalCount++;
        }
      }
    }

    // Nombre de participants
    int participants = 0;
    if (json['safety_moment'] is Map &&
        json['safety_moment']['participants'] is List) {
      participants = (json['safety_moment']['participants'] as List).length;
    } else if (json['safety_awareness_items'] is List) {
      participants = (json['safety_awareness_items'] as List).length;
    }

    // Code officiel
    final String code = VmcPdfService.getCodeForType(displayType);

    return VmcItemData(
      id: id,
      reference: id != null ? "#VMC-$id" : "#VMC-2026",
      title: json['title']?.toString() ?? "VMC $displayType",
      type: displayType,
      code: code,
      category: masterType,
      site: json['site']?.toString() ?? "Site principal Galana",
      inspector: inspector,
      date: json['date']?.toString() ?? "14 Oct 2026",
      status: status,
      positivePoints: pos,
      deviations: dev,
      complianceRate: evalCount > 0 ? (pos / evalCount) : 1.0,
      participantsCount: participants > 0 ? participants : 6,
      theme: json['recommendation']?.toString(),
      rawData: json,
    );
  }
}

class VmcListView extends StatefulWidget {
  final Function(VmcItemData)? onVmcTap;

  const VmcListView({super.key, this.onVmcTap});

  @override
  State<VmcListView> createState() => _VmcListViewState();
}

class _VmcListViewState extends State<VmcListView> {
  int selectedStatusFilter = 0;
  bool onlyAssignedToMe = false;
  int selectedTypeFilter = 0;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  bool isLoading = false;
  bool isLiveFromApi = false;

  final List<String> statusFilters = const [
    "Tous les statuts",
    "Planifiée",
    "En cours",
    "Terminée",
    "Annulée",
  ];

  final List<String> typeFilters = const [
    "Tous les types",
    "Station-Service (SS)",
    "Inspection Camion (CC)",
    "Magasins & Agences",
    "Safety Moment",
    "Safety Awareness",
    "Fiche de Remontée",
  ];

  List<VmcItemData> vmcList = [];

  static const List<VmcItemData> _defaultSeedList = [
    VmcItemData(
      id: 12,
      reference: "#VMC-CAM-2026-045",
      title: "Inspection Camion Citerne Hydrocarbures (Scania 480)",
      type: "Inspection Camion",
      code: "HSSE GALANA 2",
      category: "INSPECTION",
      site: "Terminal Pétrolier Toamasina",
      inspector: "Mireille R. (Superviseur HSSE)",
      date: "13 Oct 2026",
      status: "En cours",
      positivePoints: 13,
      deviations: 1,
      complianceRate: 0.93,
    ),
    VmcItemData(
      id: 11,
      reference: "#VMC-SS-2026-012",
      title: "Visite VMC Station-Service Antsirabe Centre",
      type: "Station-Service",
      code: "HSSE GALANA 1",
      category: "INSPECTION",
      site: "Station Antsirabe Centre",
      inspector: "Jean Rakoto (Directeur Réseau)",
      date: "14 Oct 2026",
      status: "En cours",
      positivePoints: 11,
      deviations: 2,
      complianceRate: 0.85,
    ),
    VmcItemData(
      id: 10,
      reference: "#VMC-MAG-2026-008",
      title: "Visite Conformité Magasin Lubrifiants & Agence",
      type: "Visite Magasins & Agences",
      code: "HSSE GALANA 3",
      category: "INSPECTION",
      site: "Agence Commerciale Ankorondrano",
      inspector: "Jules Rakoto (Inspecteur HSSE)",
      date: "11 Oct 2026",
      status: "Planifiée",
      positivePoints: 6,
      deviations: 1,
      complianceRate: 0.86,
    ),
    VmcItemData(
      id: 5,
      reference: "#VMC-SM-2026-031",
      title: "Quart d'Heure Sécurité : Risques Électrostatiques & Dépotage",
      type: "Safety Moment",
      code: "SAFETY MOMENTS",
      category: "SAFETY MOMENT",
      site: "Terminal Pétrolier Toamasina",
      inspector: "Chef de Quart Dépotage",
      date: "14 Oct 2026",
      status: "En cours",
      positivePoints: 5,
      deviations: 0,
      complianceRate: 1.0,
      participantsCount: 8,
      theme: "Mise à la terre et équipotentialité des citernes",
    ),
    VmcItemData(
      id: 8,
      reference: "#VMC-SA-2026-019",
      title: "Sensibilisation : Manipulation Produits Chimiques & Port des EPI",
      type: "Safety Awareness",
      code: "SAFETY TRAINING",
      category: "SAFETY AWARENESS",
      site: "Dépôt Antsirabe",
      inspector: "Mireille R. (HSSE)",
      date: "10 Oct 2026",
      status: "Clôturée",
      positivePoints: 4,
      deviations: 0,
      complianceRate: 1.0,
      participantsCount: 14,
      theme: "Fiches FDS et règles de manipulation",
    ),
    VmcItemData(
      id: 9,
      reference: "#VMC-SR-2026-005",
      title: "Fiche de Remontée : Suintement bride vanne cuve C-04",
      type: "Fiche de Remontée",
      code: "FOR01-HSSE-ACC",
      category: "SAFETY REPORT",
      site: "Dépôt Ivato",
      inspector: "Alain Rajaona (Chef Dépôt)",
      date: "09 Oct 2026",
      status: "En cours",
      positivePoints: 3,
      deviations: 1,
      complianceRate: 0.75,
      theme: "Incident d'étanchéité sous rétention",
    ),
  ];

  StreamSubscription<RealtimeEvent>? _realtimeSub;

  @override
  void initState() {
    super.initState();
    vmcList = List.from(_defaultSeedList);
    _loadVmcs();

    // Abonnement temps réel
    _realtimeSub = RealtimeService.instance.onVmcEvent.listen((_) {
      if (mounted) {
        _loadVmcs(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _realtimeSub?.cancel();
    searchController.dispose();
    super.dispose();
  }

  /// Chargement asynchrone des VMC depuis l'API Laravel
  Future<void> _loadVmcs({bool silent = false}) async {
    if (!silent) {
      setState(() => isLoading = true);
    }

    final String? activeType =
        selectedTypeFilter > 0 ? typeFilters[selectedTypeFilter] : null;

    String? activeStatus;
    if (selectedStatusFilter > 0) {
      final f = statusFilters[selectedStatusFilter];
      if (f == 'Planifiée') {
        activeStatus = 'DRAFT';
      } else if (f == 'En cours') {
        activeStatus = 'IN_PROGRESS';
      } else if (f == 'Terminée') {
        activeStatus = 'COMPLETED';
      } else if (f == 'Annulée') {
        activeStatus = 'CANCELLED';
      }
    }

    final apiItems = await VmcService.getVmcs(
      type: activeType,
      status: activeStatus,
      search: searchQuery.isNotEmpty ? searchQuery : null,
    );

    if (mounted) {
      setState(() {
        isLoading = false;
        if (apiItems.isNotEmpty) {
          vmcList = apiItems;
          isLiveFromApi = true;
        } else if (searchQuery.isEmpty &&
            selectedTypeFilter == 0 &&
            selectedStatusFilter == 0) {
          // Fallback hors ligne
          vmcList = List.from(_defaultSeedList);
          isLiveFromApi = false;
        } else {
          vmcList = [];
        }
      });
    }
  }

  int get assignedToMeCount =>
      vmcList.where((it) => ApiClient.isAssignedToCurrentUser(it.inspector)).length;

  List<VmcItemData> get filteredVmcList {
    return vmcList.where((item) {
      if (onlyAssignedToMe && !ApiClient.isAssignedToCurrentUser(item.inspector)) {
        return false;
      }

      final matchesSearch = searchQuery.isEmpty ||
          item.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.reference.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.type.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.code.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.site.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.inspector.toLowerCase().contains(searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      // Filtre statut
      if (selectedStatusFilter > 0) {
        final statusName = statusFilters[selectedStatusFilter].toLowerCase();
        final s = item.status.toLowerCase();
        if (statusName.contains('planifi') &&
            (s.contains('planifi') || s.contains('brouillon') || s == 'draft')) {
          // match
        } else if (statusName.contains('cours') &&
            (s.contains('cours') || s == 'in_progress')) {
          // match
        } else if ((statusName.contains('termin') || statusName.contains('clôtur')) &&
            (s.contains('termin') || s.contains('clôtur') || s.contains('clotur') || s == 'completed')) {
          // match
        } else if (statusName.contains('annul') &&
            (s.contains('annul') || s == 'cancelled')) {
          // match
        } else {
          return false;
        }
      }

      // Filtre type
      if (selectedTypeFilter > 0) {
        final filterName = typeFilters[selectedTypeFilter].toLowerCase();
        final itemData =
            "${item.type} ${item.code} ${item.category}".toLowerCase();

        if (filterName.contains("station") || filterName.contains("ss")) {
          if (!itemData.contains("station") && !itemData.contains("galana 1")) {
            return false;
          }
        } else if (filterName.contains("camion") || filterName.contains("cc")) {
          if (!itemData.contains("camion") && !itemData.contains("galana 2")) {
            return false;
          }
        } else if (filterName.contains("magasin") ||
            filterName.contains("agence")) {
          if (!itemData.contains("magasin") &&
              !itemData.contains("agence") &&
              !itemData.contains("galana 3")) {
            return false;
          }
        } else if (filterName.contains("moment")) {
          if (!itemData.contains("moment")) return false;
        } else if (filterName.contains("awareness") ||
            filterName.contains("sensibilisation")) {
          if (!itemData.contains("awareness") &&
              !itemData.contains("training")) {
            return false;
          }
        } else if (filterName.contains("remontée") ||
            filterName.contains("report")) {
          if (!itemData.contains("report") &&
              !itemData.contains("remontée") &&
              !itemData.contains("for01")) {
            return false;
          }
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredVmcList;
    final inProgressCount =
        vmcList.where((v) => v.status.toLowerCase() == 'en cours').length;
    final closedCount =
        vmcList.where((v) => v.status.toLowerCase() == 'clôturée').length;

    return RefreshIndicator(
      onRefresh: _loadVmcs,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // ==================== SEARCH BAR ====================
            TextField(
              controller: searchController,
              onChanged: (val) {
                setState(() {
                  searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: "Rechercher une VMC (Station, Camion, Safety...)",
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchQuery = "";
                          });
                        },
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 12),

            // ==================== FILTRES TYPES VMC ====================
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(typeFilters.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InspectionFilterChip(
                      label: typeFilters[index],
                      selected: selectedTypeFilter == index,
                      onTap: () {
                        setState(() {
                          selectedTypeFilter = index;
                        });
                        _loadVmcs();
                      },
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 10),

            // ==================== FILTRES STATUTS ====================
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          onlyAssignedToMe = !onlyAssignedToMe;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: onlyAssignedToMe ? const Color(0xFF2563EB) : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: onlyAssignedToMe ? const Color(0xFF1D4ED8) : const Color(0xFFBFDBFE),
                            width: onlyAssignedToMe ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              onlyAssignedToMe ? Icons.check_circle : Icons.person_pin,
                              size: 15,
                              color: onlyAssignedToMe ? Colors.white : const Color(0xFF1D4ED8),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "Attribuées à moi ($assignedToMeCount)",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: onlyAssignedToMe ? Colors.white : const Color(0xFF1D4ED8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ...List.generate(statusFilters.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InspectionFilterChip(
                      label: statusFilters[index],
                      selected: selectedStatusFilter == index,
                      onTap: () {
                        setState(() {
                          selectedStatusFilter = index;
                        });
                        _loadVmcs();
                      },
                    ),
                  );
                }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ==================== STATUT SYNC & STATS ====================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn("${vmcList.length}", "Total VMC",
                      AppColors.textPrimary),
                  Container(
                      width: 1, height: 28, color: Colors.grey.shade200),
                  _buildStatColumn("$inProgressCount", "En cours",
                      const Color(0xFF1D4ED8)),
                  Container(
                      width: 1, height: 28, color: Colors.grey.shade200),
                  _buildStatColumn(
                      "$closedCount", "Clôturées", const Color(0xFF15803D)),
                  Container(
                      width: 1, height: 28, color: Colors.grey.shade200),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isLiveFromApi
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isLiveFromApi ? "API Active" : "Hors-ligne",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isLiveFromApi
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFD97706),
                        ),
                      ),
                      if (isLoading) ...[
                        const SizedBox(width: 6),
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ==================== LISTE DES VISITES VMC ====================
            if (isLoading && vmcList.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (filtered.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.assignment_outlined,
                        size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text(
                      "Aucune visite VMC trouvée",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Essayez de modifier votre recherche ou le filtre de type.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(filtered.length, (index) {
                final item = filtered[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: VmcCard(
                    reference: item.reference,
                    title: item.title,
                    type: item.type,
                    site: item.site,
                    inspector: item.inspector,
                    date: item.date,
                    status: item.status,
                    positivePoints: item.positivePoints,
                    deviations: item.deviations,
                    complianceRate: item.complianceRate,
                    isPendingSync: item.id != null && SyncService.instance.hasPendingSyncFor(item.id.toString()),
                    onTap: () async {

                      if (widget.onVmcTap != null) {
                        widget.onVmcTap!(item);
                      } else {
                        final updated = await Navigator.pushNamed(
                          context,
                          AppRoutes.vmcDetail,
                          arguments: item,
                        );
                        if (updated is VmcItemData) {
                          final idx = vmcList.indexWhere(
                              (v) => v.reference == updated.reference);
                          if (idx != -1) {
                            setState(() {
                              vmcList[idx] = updated;
                            });
                          }
                        }
                        // Rafraîchissement automatique après retour
                        _loadVmcs();
                      }
                    },
                  ),
                );
              }),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
