import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/api/api_client.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';
import 'package:gestion_hsse/cores/services/equipment_service.dart';
import 'package:gestion_hsse/cores/services/realtime_service.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/views/home/inspection/equipment/widgets/equipment_monitoring_card.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/inspection_filter_chip.dart';

class EquipmentItemData {
  final int? id;
  final dynamic monitoringId;
  final String tagNumber;
  final String designation;
  final String type;
  final String site;
  final String location;
  final String lastControlDate;
  final String nextDueDate;
  final String status;
  final String inspectionStatus;
  final String pressureStatus;
  final bool conformity;
  final dynamic value;
  final String valueType;
  final List<String> attachments;
  final String? comment;

  const EquipmentItemData({
    this.id,
    this.monitoringId,
    required this.tagNumber,
    required this.designation,
    required this.type,
    required this.site,
    required this.location,
    required this.lastControlDate,
    required this.nextDueDate,
    required this.status,
    this.inspectionStatus = "En cours",
    required this.pressureStatus,
    this.conformity = true,
    this.value = 1,
    this.valueType = "number",
    this.attachments = const [],
    this.comment,
  });

  EquipmentItemData copyWith({
    int? id,
    dynamic monitoringId,
    String? tagNumber,
    String? designation,
    String? type,
    String? site,
    String? location,
    String? lastControlDate,
    String? nextDueDate,
    String? status,
    String? inspectionStatus,
    String? pressureStatus,
    bool? conformity,
    dynamic value,
    String? valueType,
    List<String>? attachments,
    String? comment,
  }) {
    return EquipmentItemData(
      id: id ?? this.id,
      monitoringId: monitoringId ?? this.monitoringId,
      tagNumber: tagNumber ?? this.tagNumber,
      designation: designation ?? this.designation,
      type: type ?? this.type,
      site: site ?? this.site,
      location: location ?? this.location,
      lastControlDate: lastControlDate ?? this.lastControlDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      status: status ?? this.status,
      inspectionStatus: inspectionStatus ?? this.inspectionStatus,
      pressureStatus: pressureStatus ?? this.pressureStatus,
      conformity: conformity ?? this.conformity,
      value: value ?? this.value,
      valueType: valueType ?? this.valueType,
      attachments: attachments ?? this.attachments,
      comment: comment ?? this.comment,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'monitoringId': monitoringId,
      'tagNumber': tagNumber,
      'designation': designation,
      'name': designation,
      'type': type,
      'site': site,
      'site_name': site,
      'location': location,
      'lastControlDate': lastControlDate,
      'nextDueDate': nextDueDate,
      'status': status,
      'inspectionStatus': inspectionStatus,
      'pressureStatus': pressureStatus,
      'conformity': conformity,
      'value': value,
      'valueType': valueType,
      'attachments': attachments,
      'comment': comment,
    };
  }

  factory EquipmentItemData.fromJson(Map<String, dynamic> json) {
    final bool isConforme = json['conformity'] == true || json['conformity'] == 1;
    final int? id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    final String designation = json['designation']?.toString() ?? json['name']?.toString() ?? 'Équipement';
    final String tag = json['tagNumber']?.toString() ?? (id != null ? 'EQ-$id' : 'EQ-00');

    List<String> photoUrls = [];
    if (json['attachments'] is List) {
      for (final att in (json['attachments'] as List)) {
        if (att is String) {
          photoUrls.add(att);
        } else if (att is Map) {
          final p = att['file_path']?.toString() ?? '';
          if (p.isNotEmpty) {
            if (p.startsWith('http')) {
              photoUrls.add(p);
            } else {
              photoUrls.add('${ApiClient.baseUrl.replaceAll('/api', '')}$p');
            }
          }
        }
      }
    }

    return EquipmentItemData(
      id: id,
      monitoringId: json['monitoringId'] ?? json['monitoring_id'],
      tagNumber: tag,
      designation: designation,
      type: json['type']?.toString() ?? 'Extincteur P50',
      site: json['site']?.toString() ?? json['site_name']?.toString() ?? 'Station Galana',
      location: json['location']?.toString() ?? 'Piste distribution',
      lastControlDate: json['lastControlDate']?.toString() ?? json['date']?.toString() ?? '16 Oct 2026',
      nextDueDate: json['nextDueDate']?.toString() ?? '16 Nov 2026',
      status: isConforme ? 'Conforme' : 'Non-conforme',
      inspectionStatus: json['inspectionStatus']?.toString() ?? 'En cours',
      pressureStatus: json['pressureStatus']?.toString() ?? (isConforme ? 'Normal' : 'Anomalie'),
      conformity: isConforme,
      value: json['value'],
      valueType: json['valueType']?.toString() ?? 'number',
      attachments: photoUrls,
      comment: json['comment']?.toString(),
    );
  }
}

class EquipmentMonitoringData {
  final dynamic id;
  final String reference;
  final String siteName;
  final String date;
  final String status;
  final String rawStatus;
  final String inspector;
  final double conformityRate;
  final double initialConformityRate;
  final String? observations;
  final List<EquipmentItemData> items;
  final bool isPendingSync;

  const EquipmentMonitoringData({
    required this.id,
    required this.reference,
    required this.siteName,
    required this.date,
    required this.status,
    this.rawStatus = 'DRAFT',
    required this.inspector,
    this.conformityRate = 100.0,
    this.initialConformityRate = 100.0,
    this.observations,
    this.items = const [],
    this.isPendingSync = false,
  });

  int get totalEquipments => items.length;
  int get conformeCount => items.where((it) => it.conformity).length;
  int get anomalyCount => items.where((it) => !it.conformity).length;
  double get calculatedRate {
    if (items.isEmpty) return conformityRate;
    return (conformeCount / items.length) * 100.0;
  }

  Map<String, int> get categoryCounts {
    final Map<String, int> counts = {};
    for (final it in items) {
      counts[it.type] = (counts[it.type] ?? 0) + 1;
    }
    return counts;
  }

  EquipmentMonitoringData copyWith({
    dynamic id,
    String? reference,
    String? siteName,
    String? date,
    String? status,
    String? rawStatus,
    String? inspector,
    double? conformityRate,
    double? initialConformityRate,
    String? observations,
    List<EquipmentItemData>? items,
    bool? isPendingSync,
  }) {
    return EquipmentMonitoringData(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      siteName: siteName ?? this.siteName,
      date: date ?? this.date,
      status: status ?? this.status,
      rawStatus: rawStatus ?? this.rawStatus,
      inspector: inspector ?? this.inspector,
      conformityRate: conformityRate ?? this.conformityRate,
      initialConformityRate: initialConformityRate ?? this.initialConformityRate,
      observations: observations ?? this.observations,
      items: items ?? this.items,
      isPendingSync: isPendingSync ?? this.isPendingSync,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'site_name': siteName,
      'date': date,
      'status': status,
      'raw_status': rawStatus,
      'inspector': inspector,
      'conformity_rate': conformityRate,
      'initial_conformity_rate': initialConformityRate,
      'observations': observations,
      'items': items.map((it) => it.toJson()).toList(),
      'is_pending_sync': isPendingSync,
    };
  }

  factory EquipmentMonitoringData.fromJson(Map<String, dynamic> json) {
    final String rawStatus = json['status']?.toString() ?? json['raw_status']?.toString() ?? 'DRAFT';
    String normStatus = 'Planifiée';
    final upper = rawStatus.toUpperCase();
    final lower = rawStatus.toLowerCase();
    if (upper == 'COMPLETED' || lower.contains('clôtur') || lower.contains('clotur') || lower.contains('termin')) {
      normStatus = 'Clôturée';
    } else if (upper == 'IN_PROGRESS' || lower.contains('cours')) {
      normStatus = 'En cours';
    } else if (upper == 'CANCELLED' || lower.contains('annul')) {
      normStatus = 'Annulée';
    } else {
      normStatus = 'Planifiée';
    }

    String inspector = json['inspector']?.toString() ?? '';
    if (inspector.isEmpty && json['user'] is Map) {
      final u = json['user'];
      inspector = "${u['first_name'] ?? ''} ${u['last_name'] ?? ''}".trim();
      if (inspector.isEmpty) inspector = u['name']?.toString() ?? '';
    }
    if (inspector.isEmpty) inspector = 'Inspecteur HSSE';

    final List<EquipmentItemData> parsedItems = [];
    if (json['items'] is List) {
      for (final it in json['items']) {
        if (it is Map<String, dynamic>) {
          parsedItems.add(EquipmentItemData.fromJson(it));
        } else if (it is Map) {
          parsedItems.add(EquipmentItemData.fromJson(Map<String, dynamic>.from(it)));
        }
      }
    }

    final rawId = json['id'];
    final ref = json['reference']?.toString() ?? '#EQ-$rawId';

    return EquipmentMonitoringData(
      id: rawId,
      reference: ref,
      siteName: json['site_name']?.toString() ?? json['siteName']?.toString() ?? 'Station Galana',
      date: json['date']?.toString() ?? '16 Oct 2026',
      status: normStatus,
      rawStatus: rawStatus,
      inspector: inspector,
      conformityRate: (json['conformity_rate'] as num?)?.toDouble() ?? 100.0,
      initialConformityRate: (json['initial_conformity_rate'] as num?)?.toDouble() ?? 100.0,
      observations: json['observations']?.toString(),
      items: parsedItems,
      isPendingSync: json['is_pending_sync'] == true,
    );
  }
}

class EquipmentMonitoringListView extends StatefulWidget {
  final Function(EquipmentMonitoringData)? onMonitoringTap;
  final Function(EquipmentItemData)? onEquipmentTap;

  const EquipmentMonitoringListView({
    super.key,
    this.onMonitoringTap,
    this.onEquipmentTap,
  });

  @override
  State<EquipmentMonitoringListView> createState() =>
      _EquipmentMonitoringListViewState();
}

class _EquipmentMonitoringListViewState
    extends State<EquipmentMonitoringListView> {
  int selectedStatusIndex = 0;
  bool onlyAssignedToMe = false;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  final List<String> statuses = const [
    "Tous",
    "Planifiée",
    "En cours",
    "Clôturée",
    "Annulée",
  ];

  bool isLoading = false;
  List<EquipmentMonitoringData> monitoringList = [];
  StreamSubscription<RealtimeEvent>? _realtimeSub;

  @override
  void initState() {
    super.initState();
    _loadMonitorings();

    // Abonnement aux mises à jour en direct
    _realtimeSub = RealtimeService.instance.onEquipmentEvent.listen((_) {
      if (mounted) {
        _loadMonitorings(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _realtimeSub?.cancel();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMonitorings({bool silent = false}) async {
    if (!silent) {
      setState(() => isLoading = true);
    }

    final items = await EquipmentService.getMonitorings(
      search: searchQuery,
      status: selectedStatusIndex > 0 ? statuses[selectedStatusIndex] : null,
    );

    if (mounted) {
      setState(() {
        monitoringList = items;
        isLoading = false;
      });
    }
  }

  int get assignedToMeCount =>
      monitoringList.where((m) => ApiClient.isAssignedToCurrentUser(m.inspector)).length;

  List<EquipmentMonitoringData> get filteredMonitorings {
    return monitoringList.where((m) {
      if (!ApiClient.isAssignedToCurrentUser(m.inspector, m.id)) {
        return false;
      }

      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matches = m.reference.toLowerCase().contains(q) ||
            m.siteName.toLowerCase().contains(q) ||
            m.inspector.toLowerCase().contains(q) ||
            (m.observations?.toLowerCase().contains(q) ?? false);
        if (!matches) return false;
      }

      if (selectedStatusIndex > 0) {
        final targetStatus = statuses[selectedStatusIndex].toLowerCase();
        if (m.status.toLowerCase() != targetStatus) return false;
      }

      return true;
    }).toList();
  }

  int get totalCount => filteredMonitorings.length;
  int get inProgressCount => filteredMonitorings.where((m) => m.status == 'En cours').length;
  int get plannedCount => filteredMonitorings.where((m) => m.status == 'Planifiée').length;
  int get completedCount => filteredMonitorings.where((m) => m.status == 'Clôturée').length;

  void _onCardTap(EquipmentMonitoringData monitoring) async {
    if (widget.onMonitoringTap != null) {
      widget.onMonitoringTap!(monitoring);
    } else {
      await Navigator.pushNamed(
        context,
        AppRoutes.equipmentDetail,
        arguments: monitoring,
      );
      _loadMonitorings(silent: true);
    }
  }

  /// Dialogue modal pour planifier un nouveau suivi matériel (0 équipement à la création)
  void _showPlanMonitoringSheet() async {
    final siteNames = await EquipmentService.getSiteNames();
    String selectedSite = siteNames.isNotEmpty ? siteNames.first : "Station Majunga";
    String selectedStatus = "En cours";
    final inspectorController = TextEditingController(
      text: ApiClient.currentUser?['name']?.toString() ?? "ARIMANANA Jules",
    );
    final obsController = TextEditingController();

    final now = DateTime.now();
    DateTime selectedDate = now;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.88,
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
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

                      // En-tête
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.add_task_rounded,
                                color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Planifier un suivi matériel",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  "Création de la session (les matériels sont ajoutés sur place)",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),

                      // 1. Choix de la Station / Site
                      const Text(
                        "Site / Station Galana *",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: siteNames.contains(selectedSite)
                                ? selectedSite
                                : (siteNames.isNotEmpty ? siteNames.first : null),
                            isExpanded: true,
                            items: siteNames.map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(s, style: const TextStyle(fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setModalState(() => selectedSite = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 2. Date d'inspection
                      const Text(
                        "Date du contrôle *",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: selectedDate,
                            firstDate: DateTime(2025),
                            lastDate: DateTime(2028),
                          );
                          if (picked != null) {
                            setModalState(() => selectedDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Text(
                                "${selectedDate.day} Oct ${selectedDate.year}",
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 3. Inspecteur
                      const Text(
                        "Inspecteur HSSE *",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: inspectorController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person_outline, size: 20),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          hintText: "Nom de l'inspecteur",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 4. Statut initial
                      const Text(
                        "Statut initial *",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setModalState(() => selectedStatus = "Planifiée"),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: selectedStatus == "Planifiée" ? const Color(0xFFFEF3C7) : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selectedStatus == "Planifiée" ? const Color(0xFFD97706) : Colors.grey.shade300,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Planifiée",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: selectedStatus == "Planifiée" ? const Color(0xFFB45309) : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: InkWell(
                              onTap: () => setModalState(() => selectedStatus = "En cours"),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: selectedStatus == "En cours" ? const Color(0xFFDBEAFE) : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selectedStatus == "En cours" ? const Color(0xFF2563EB) : Colors.grey.shade300,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "En cours",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: selectedStatus == "En cours" ? const Color(0xFF1D4ED8) : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // 5. Observations
                      const Text(
                        "Observations / Objectifs (Optionnel)",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: obsController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: "Précisions sur cette session d'inspection...",
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Bouton d'action
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final dateStr = "${selectedDate.day} Oct ${selectedDate.year}";
                            final newM = await EquipmentService.createMonitoring(
                              siteName: selectedSite,
                              date: dateStr,
                              status: selectedStatus,
                              inspector: inspectorController.text.trim(),
                              observations: obsController.text.trim().isNotEmpty
                                  ? obsController.text.trim()
                                  : null,
                            );

                            if (ctx.mounted) Navigator.pop(ctx);
                            _loadMonitorings(silent: true);

                            // Ouvre immédiatement la page de contrôle du suivi
                            if (mounted) {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.equipmentDetail,
                                arguments: newM,
                              ).then((_) => _loadMonitorings(silent: true));
                            }
                          },
                          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                          label: const Text(
                            "Planifier le suivi",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = filteredMonitorings;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPlanMonitoringSheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          "Planifier un suivi",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadMonitorings(),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================== BARRE DE RECHERCHE ====================
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (val) {
                    setState(() => searchQuery = val);
                  },
                  decoration: InputDecoration(
                    hintText: "Rechercher par station, inspecteur, réf...",
                    hintStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              searchController.clear();
                              setState(() => searchQuery = "");
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ==================== STATS KPI SUMMARY ====================
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn("$totalCount", "Total Suivis", AppColors.primary),
                    Container(height: 28, width: 1, color: Colors.grey.shade200),
                    _buildStatColumn("$inProgressCount", "En cours", const Color(0xFF1D4ED8)),
                    Container(height: 28, width: 1, color: Colors.grey.shade200),
                    _buildStatColumn("$plannedCount", "Planifiées", const Color(0xFFB45309)),
                    Container(height: 28, width: 1, color: Colors.grey.shade200),
                    _buildStatColumn("$completedCount", "Clôturées", const Color(0xFF15803D)),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ==================== FILTRES DE STATUT ====================
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFBFDBFE),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person_pin,
                            size: 15,
                            color: Color(0xFF1D4ED8),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "Mes assignations ($assignedToMeCount)",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D4ED8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ...List.generate(statuses.length, (index) {
                    final status = statuses[index];
                    final isSelected = selectedStatusIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InspectionFilterChip(
                        label: status,
                        selected: isSelected,
                        onTap: () {
                          setState(() {
                            selectedStatusIndex = index;
                          });
                          _loadMonitorings();
                        },
                      ),
                  );
                }),
                ],
                ),
              ),

              const SizedBox(height: 16),

              // ==================== LISTE DES SUIVIS ====================
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (list.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Aucun suivi de matériel attribué",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        searchQuery.isNotEmpty || selectedStatusIndex > 0
                            ? "Essayez de modifier vos critères de recherche ou de filtre."
                            : "Aucun contrôle d'équipements n'est actuellement assigné à votre profil.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _showPlanMonitoringSheet,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text("Planifier un suivi"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (ctx, index) {
                    final item = list[index];
                    return EquipmentMonitoringCard(
                      monitoring: item,
                      onTap: () => _onCardTap(item),
                    );
                  },
                ),

              const SizedBox(height: 90), // Espace FAB
            ],
          ),
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
