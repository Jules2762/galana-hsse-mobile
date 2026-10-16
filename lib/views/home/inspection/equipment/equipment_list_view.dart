import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';
import 'package:gestion_hsse/cores/services/equipment_service.dart';
import 'package:gestion_hsse/cores/services/realtime_service.dart';
import 'package:gestion_hsse/cores/services/sync_service.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/views/home/inspection/equipment/widgets/equipment_card.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/inspection_filter_chip.dart';


class EquipmentItemData {
  final int? id;
  final String tagNumber;
  final String designation;
  final String type;
  final String site;
  final String location;
  final String lastControlDate;
  final String nextDueDate;
  final String status;
  final String pressureStatus;
  final bool conformity;
  final dynamic value;
  final String valueType;
  final List<String> attachments;
  final String? comment;

  const EquipmentItemData({
    this.id,
    required this.tagNumber,
    required this.designation,
    required this.type,
    required this.site,
    required this.location,
    required this.lastControlDate,
    required this.nextDueDate,
    required this.status,
    required this.pressureStatus,
    this.conformity = true,
    this.value = 1,
    this.valueType = "number",
    this.attachments = const [],
    this.comment,
  });

  EquipmentItemData copyWith({
    int? id,
    String? tagNumber,
    String? designation,
    String? type,
    String? site,
    String? location,
    String? lastControlDate,
    String? nextDueDate,
    String? status,
    String? pressureStatus,
    bool? conformity,
    dynamic value,
    String? valueType,
    List<String>? attachments,
    String? comment,
  }) {
    return EquipmentItemData(
      id: id ?? this.id,
      tagNumber: tagNumber ?? this.tagNumber,
      designation: designation ?? this.designation,
      type: type ?? this.type,
      site: site ?? this.site,
      location: location ?? this.location,
      lastControlDate: lastControlDate ?? this.lastControlDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      status: status ?? this.status,
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
      'tagNumber': tagNumber,
      'designation': designation,
      'type': type,
      'site': site,
      'location': location,
      'lastControlDate': lastControlDate,
      'nextDueDate': nextDueDate,
      'status': status,
      'pressureStatus': pressureStatus,
      'conformity': conformity,
      'value': value,
      'valueType': valueType,
      'attachments': attachments,
      'comment': comment,
    };
  }

  factory EquipmentItemData.fromJson(Map<String, dynamic> json) {
    return EquipmentItemData(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      tagNumber: json['tagNumber']?.toString() ?? 'EQ-00',
      designation: json['designation']?.toString() ?? 'Équipement',
      type: json['type']?.toString() ?? 'Extincteur',
      site: json['site']?.toString() ?? 'Station Galana',
      location: json['location']?.toString() ?? 'Piste',
      lastControlDate: json['lastControlDate']?.toString() ?? 'Récent',
      nextDueDate: json['nextDueDate']?.toString() ?? 'Dans 1 mois',
      status: json['status']?.toString() ?? 'Conforme',
      pressureStatus: json['pressureStatus']?.toString() ?? 'Normal',
      conformity: json['conformity'] == true || json['conformity'] == 1,
      value: json['value'],
      valueType: json['valueType']?.toString() ?? 'number',
      attachments: (json['attachments'] as List?)?.map((e) => e.toString()).toList() ?? [],
      comment: json['comment']?.toString(),
    );
  }
}

class EquipmentMonitoringListView extends StatefulWidget {
  final Function(EquipmentItemData)? onEquipmentTap;

  const EquipmentMonitoringListView({super.key, this.onEquipmentTap});

  @override
  State<EquipmentMonitoringListView> createState() =>
      _EquipmentMonitoringListViewState();
}

class _EquipmentMonitoringListViewState
    extends State<EquipmentMonitoringListView> {
  int selectedCategory = 0;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  final List<String> categories = const [
    "Tous",
    "Extincteurs P50",
    "Extincteurs P9",
    "RIA",
    "Cuves & Bacs",
  ];

  bool isLoading = false;
  List<EquipmentItemData> equipmentList = [];
  StreamSubscription<RealtimeEvent>? _realtimeSub;

  @override
  void initState() {
    super.initState();
    _loadEquipments();

    // Abonnement temps réel
    _realtimeSub = RealtimeService.instance.onEquipmentEvent.listen((_) {
      if (mounted) {
        _loadEquipments(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _realtimeSub?.cancel();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEquipments({bool silent = false}) async {
    if (!silent) {
      setState(() => isLoading = true);
    }
    final items = await EquipmentService.getEquipments(
      search: searchQuery,
      category: selectedCategory > 0 ? categories[selectedCategory] : null,
    );
    if (mounted) {
      setState(() {
        equipmentList = items;
        isLoading = false;
      });
    }
  }


  List<EquipmentItemData> get filteredEquipments {
    return equipmentList.where((item) {
      final matchesSearch = searchQuery.isEmpty ||
          item.tagNumber.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.designation.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.site.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.location.toLowerCase().contains(searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (selectedCategory == 0) return true;
      final category = categories[selectedCategory];
      if (category == "Extincteurs P50") return item.type == "Extincteur P50";
      if (category == "Extincteurs P9") return item.type == "Extincteur P9";
      if (category == "RIA") return item.type == "RIA";
      if (category == "Cuves & Bacs") return item.type == "Cuves & Bacs";
      return true;
    }).toList();
  }

  int get totalEquipmentCount => equipmentList.length;
  int get conformeCount => equipmentList
      .where((e) => e.status.toLowerCase() == 'conforme')
      .length;
  int get toControlCount => equipmentList
      .where((e) =>
          e.status.toLowerCase().contains('requis') ||
          e.status.toLowerCase().contains('réviser'))
      .length;
  int get nonConformeCount => equipmentList
      .where((e) =>
          e.status.toLowerCase().contains('non-conforme') ||
          e.status.toLowerCase().contains('expiré'))
      .length;

  void _showQuickCheckDialog(EquipmentItemData equipment) {
    bool sealIntact = true;
    bool pinIntact = true;
    bool hoseGood = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.check_circle_outline,
                              color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Contrôle rapide : ${equipment.tagNumber}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                equipment.designation,
                                style: const TextStyle(
                                  fontSize: 12,
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
                    const Text(
                      "Points de contrôle visuel :",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      value: sealIntact,
                      onChanged: (val) =>
                          setModalState(() => sealIntact = val ?? true),
                      title: const Text("Scellé de sécurité en place et intact",
                          style: TextStyle(fontSize: 13)),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      activeColor: AppColors.primary,
                    ),
                    CheckboxListTile(
                      value: pinIntact,
                      onChanged: (val) =>
                          setModalState(() => pinIntact = val ?? true),
                      title: const Text("Goupille de sécurité engagée",
                          style: TextStyle(fontSize: 13)),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      activeColor: AppColors.primary,
                    ),
                    CheckboxListTile(
                      value: hoseGood,
                      onChanged: (val) =>
                          setModalState(() => hoseGood = val ?? true),
                      title: const Text(
                          "Flexible / lance en bon état sans fissure",
                          style: TextStyle(fontSize: 13)),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      activeColor: AppColors.primary,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Annuler"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              final nav = Navigator.of(context);
                              final messenger = ScaffoldMessenger.of(context);
                              final isAllConforme =
                                  sealIntact && pinIntact && hoseGood;
                              final updated = await EquipmentService.performControl(
                                equipment,
                                isConforme: isAllConforme,
                                pressureStatus: isAllConforme
                                    ? "Normal (14 bars)"
                                    : "Contrôle requis",
                              );

                              if (!mounted) return;
                              final idx = equipmentList.indexWhere(
                                  (e) => e.tagNumber == equipment.tagNumber);
                              if (idx != -1) {
                                setState(() {
                                  equipmentList[idx] = updated;
                                });
                              }

                              nav.pop();
                              final isOnline = SyncService.instance.isOnline;
                              messenger.showSnackBar(

                                SnackBar(
                                  duration: const Duration(seconds: 4),
                                  content: Row(
                                    children: [
                                      Icon(isOnline ? Icons.check_circle : Icons.cloud_off,
                                          color: Colors.white, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          isOnline
                                              ? "Contrôle de ${equipment.tagNumber} enregistré et synchronisé !"
                                              : "Contrôle de ${equipment.tagNumber} enregistré en mode Hors-ligne ! Auto-sync dès reconnexion.",
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: isAllConforme
                                      ? const Color(0xFF15803D)
                                      : const Color(0xFFDC2626),
                                ),
                              );
                            },
                            child: const Text("Valider le contrôle"),

                          ),
                        ),
                      ],
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

  void _showQrScannerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.qr_code_scanner, color: AppColors.primary),
              SizedBox(width: 10),
              Text(
                "Scanner un Matériel",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.qr_code, size: 80, color: Colors.white24),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const Positioned(
                      bottom: 10,
                      child: Text(
                        "Pointez vers le tag ou QR code",
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Sélectionnez un équipement à scanner :",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: equipmentList.map((eq) {
                  return ActionChip(
                    avatar: const Icon(Icons.qr_code,
                        size: 14, color: AppColors.primary),
                    label: Text(eq.tagNumber,
                        style: const TextStyle(fontSize: 11)),
                    onPressed: () async {
                      Navigator.pop(context);
                      final updated = await Navigator.pushNamed(
                        context,
                        AppRoutes.equipmentDetail,
                        arguments: eq,
                      );
                      if (updated is EquipmentItemData) {
                        final idx = equipmentList
                            .indexWhere((e) => e.tagNumber == updated.tagNumber);
                        if (idx != -1) {
                          setState(() {
                            equipmentList[idx] = updated;
                          });
                        }
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fermer"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SyncService.instance,
      builder: (context, _) {
        final filtered = filteredEquipments;

        return RefreshIndicator(
          onRefresh: _loadEquipments,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

          // ==================== RECHERCHE & SCANNER ====================
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: (val) {
                    setState(() {
                      searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Rechercher un tag (ex: EXT-P50), site...",
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
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.qr_code_scanner,
                      color: AppColors.primary),
                  tooltip: "Scanner le QR Code d'un matériel",
                  onPressed: _showQrScannerDialog,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ==================== CATEGORIES FILTERS ====================
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(categories.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InspectionFilterChip(
                    label: categories[index],
                    selected: selectedCategory == index,
                    onTap: () {
                      setState(() {
                        selectedCategory = index;
                      });
                    },
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 16),

          // ==================== MINI STATS EQUIPMENT ====================
          Container(
            padding: const EdgeInsets.all(12),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                    "$totalEquipmentCount", "Total suivi", AppColors.primary),
                Container(height: 24, width: 1, color: AppColors.border),
                _buildStatColumn(
                    "$conformeCount", "Conformes", const Color(0xFF15803D)),
                Container(height: 24, width: 1, color: AppColors.border),
                _buildStatColumn(
                    "$toControlCount", "À contrôler", const Color(0xFFB45309)),
                Container(height: 24, width: 1, color: AppColors.border),
                _buildStatColumn("$nonConformeCount", "Non-conforme",
                    const Color(0xFFB91C1C)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ==================== LISTE DU MATERIEL ====================
          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.fire_extinguisher_outlined,
                      size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text(
                    "Aucun équipement trouvé",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Vérifiez le numéro de tag ou la catégorie sélectionnée.",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          else
            ...List.generate(filtered.length, (index) {
              final item = filtered[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: EquipmentCard(
                  tagNumber: item.tagNumber,
                  designation: item.designation,
                  type: item.type,
                  site: item.site,
                  location: item.location,
                  lastControlDate: item.lastControlDate,
                  nextDueDate: item.nextDueDate,
                  status: item.status,
                  pressureStatus: item.pressureStatus,
                  isPendingSync: SyncService.instance.hasPendingSyncFor(item.tagNumber),
                  onTap: () async {
                    if (widget.onEquipmentTap != null) {
                      widget.onEquipmentTap!(item);
                    } else {
                      final updated = await Navigator.pushNamed(
                        context,
                        AppRoutes.equipmentDetail,
                        arguments: item,
                      );
                      if (updated is EquipmentItemData) {
                        final idx = equipmentList.indexWhere(
                            (e) => e.tagNumber == updated.tagNumber);
                        if (idx != -1) {
                          setState(() {
                            equipmentList[idx] = updated;
                          });
                        }
                      }
                      _loadEquipments();
                    }
                  },
                  onQuickCheck: () {
                    _showQuickCheckDialog(item);
                  },
                ),
              );
            }),

          const SizedBox(height: 80),
        ],
      ),
    ),
  );
      },
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
