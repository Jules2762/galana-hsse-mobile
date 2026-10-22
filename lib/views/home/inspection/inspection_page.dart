import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/models/inspection_map_item.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/views/home/inspection/checklist/checklist_list_view.dart';
import 'package:gestion_hsse/views/home/inspection/equipment/equipment_list_view.dart';
import 'package:gestion_hsse/views/home/inspection/vmc/vmc_list_view.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/inspection_segment_tab.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/inspections_map_view.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/sync_status_banner.dart';

class InspectionsPage extends StatefulWidget {
  final int initialTab;

  const InspectionsPage({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<InspectionsPage> createState() => _InspectionsPageState();
}

class _InspectionsPageState extends State<InspectionsPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _currentTabIndex = 0;
  bool _isMapView = false;

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.initialTab;
    _ensureTabController();
  }

  void _ensureTabController() {
    if (_tabController == null) {
      _tabController = TabController(
        length: 3,
        vsync: this,
        initialIndex: _currentTabIndex,
      );
      _tabController!.addListener(_handleTabChange);
    }
  }

  void _handleTabChange() {
    if (_tabController != null && _tabController!.index != _currentTabIndex) {
      setState(() {
        _currentTabIndex = _tabController!.index;
      });
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabChange);
    _tabController?.dispose();
    super.dispose();
  }

  InspectionType get _currentTypeFilter {
    switch (_currentTabIndex) {
      case 0:
        return InspectionType.vmc;
      case 1:
        return InspectionType.checklist;
      case 2:
      default:
        return InspectionType.equipment;
    }
  }

  @override
  Widget build(BuildContext context) {
    _ensureTabController();
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Column(
        children: [
          // ==================== BANNIÈRE AUTO-SYNC ====================
          const SyncStatusBanner(),

          // ==================== BARRE DE CONTRÔLE : ONGLETS & BASCULE VUE CARTE ====================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            child: Row(
              children: [
                Expanded(
                  child: InspectionSegmentTab(
                    selectedIndex: _currentTabIndex,
                    vmcCount: 14,
                    checklistCount: 8,
                    equipmentCount: 45,
                    onTabSelected: (index) {
                      setState(() {
                        _currentTabIndex = index;
                      });
                      _tabController?.animateTo(index);
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Bouton Bascule Liste <-> Carte
                InkWell(
                  onTap: () {
                    setState(() {
                      _isMapView = !_isMapView;
                    });
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: _isMapView ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isMapView
                            ? AppColors.primary
                            : const Color(0xFFE2E8F0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _isMapView
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isMapView
                              ? Icons.view_list_rounded
                              : Icons.map_outlined,
                          size: 18,
                          color: _isMapView ? Colors.white : AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isMapView ? "Liste" : "Carte",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _isMapView
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ==================== CONTENU : VUE CARTE OU VUE LISTE ====================
          Expanded(
            child: _isMapView
                ? InspectionsMapView(
                    key: ValueKey('map_tab_$_currentTabIndex'),
                    initialTypeFilter: _currentTypeFilter,
                    onSwitchToList: () {
                      setState(() {
                        _isMapView = false;
                      });
                    },
                  )
                : TabBarView(
                    controller: _tabController!,
                    children: [
                      // 1. VMC
                      VmcListView(
                        onVmcTap: (vmc) {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.vmcDetail,
                            arguments: vmc,
                          );
                        },
                      ),

                      // 2. CHECKLISTS
                      const ChecklistListView(),

                      // 3. SUIVI DU MATÉRIEL
                      EquipmentMonitoringListView(
                        onMonitoringTap: (monitoring) {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.equipmentDetail,
                            arguments: monitoring,
                          );
                        },
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
