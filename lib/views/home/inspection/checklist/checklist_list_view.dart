import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/api/api_client.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';
import 'package:gestion_hsse/cores/services/checklist_service.dart';
import 'package:gestion_hsse/cores/services/realtime_service.dart';
import 'package:gestion_hsse/cores/services/sync_service.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/inspection_card.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/inspection_filter_chip.dart';

class ChecklistItemData {
  final dynamic id;
  final String title;
  final String site;
  final String inspector;
  final String date;
  final double progress;
  final String status;

  const ChecklistItemData({
    this.id,
    required this.title,
    required this.site,
    required this.inspector,
    required this.date,
    required this.progress,
    required this.status,
  });
}

class ChecklistListView extends StatefulWidget {
  const ChecklistListView({super.key});

  @override
  State<ChecklistListView> createState() => _ChecklistListViewState();
}

class _ChecklistListViewState extends State<ChecklistListView> {
  int selectedFilter = 0;
  bool onlyAssignedToMe = false;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  bool isLoading = false;
  List<ChecklistItemData> checklistItems = [];
  StreamSubscription<RealtimeEvent>? _realtimeSub;

  final List<String> filters = const [
    "Tous",
    "En cours",
    "Terminée",
    "Planifiée",
  ];

  @override
  void initState() {
    super.initState();
    _loadChecklists();

    // Abonnement temps réel
    _realtimeSub = RealtimeService.instance.onChecklistEvent.listen((_) {
      if (mounted) {
        _loadChecklists(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _realtimeSub?.cancel();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadChecklists({bool silent = false}) async {
    if (!silent) {
      setState(() => isLoading = true);
    }
    final items = await ChecklistService.getChecklists(
      search: searchQuery,
      status: selectedFilter > 0 ? filters[selectedFilter] : null,
    );
    if (mounted) {
      setState(() {
        checklistItems = items;
        isLoading = false;
      });
    }
  }

  int get assignedToMeCount =>
      checklistItems.where((it) => ApiClient.isAssignedToCurrentUser(it.inspector)).length;

  List<ChecklistItemData> get filteredChecklists {
    return checklistItems.where((item) {
      if (!ApiClient.isAssignedToCurrentUser(item.inspector, item.id)) {
        return false;
      }

      final matchesSearch = searchQuery.isEmpty ||
          item.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.site.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.inspector.toLowerCase().contains(searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (selectedFilter == 0) return true;
      final filterName = filters[selectedFilter].toLowerCase();
      return item.status.toLowerCase() == filterName;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SyncService.instance,
      builder: (context, _) {
        final filtered = filteredChecklists;

        return RefreshIndicator(
          onRefresh: _loadChecklists,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================== RECHERCHE ====================
                TextField(
                  controller: searchController,
                  onChanged: (val) {
                    setState(() {
                      searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Rechercher une checklist ou un site...",
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

                const SizedBox(height: 14),

                // ==================== FILTRES STATUTS & ASSIGNATION ====================
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Badge Mes assignations
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

                      // Filtres statuts standards
                      ...List.generate(filters.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InspectionFilterChip(
                            label: filters[index],
                            selected: selectedFilter == index,
                            onTap: () {
                              setState(() {
                                selectedFilter = index;
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ==================== LISTE DES CHECKLISTS ====================
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (filtered.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(Icons.fact_check_outlined, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          "Aucune inspection attribuée",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Aucune checklist n'est actuellement assignée à votre profil.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                else
                  ...List.generate(filtered.length, (index) {
                    final item = filtered[index];
                    final isPending = SyncService.instance.hasPendingSyncFor(item.title.hashCode.toString()) ||
                        SyncService.instance.hasPendingSyncFor(item.title);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InspectionCard(
                        title: item.title,
                        site: item.site,
                        inspector: item.inspector,
                        date: item.date,
                        progress: item.progress,
                        status: item.status,
                        isPendingSync: isPending,
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            AppRoutes.checklistDetail,
                            arguments: item,
                          );
                          _loadChecklists();
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
}