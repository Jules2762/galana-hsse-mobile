import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/views/home/inspection/checklist/checklist_list_view.dart';
import 'package:gestion_hsse/views/home/inspection/equipment/equipment_list_view.dart';
import 'package:gestion_hsse/views/home/inspection/vmc/vmc_list_view.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/inspection_segment_tab.dart';
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

  @override
  Widget build(BuildContext context) {
    _ensureTabController();
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Column(
        children: [
          // ==================== BANNIÈRE AUTO-SYNC ====================
          const SyncStatusBanner(),

          // ==================== SEGMENTED CONTROLLER ====================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),

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

          // ==================== TAB BAR VIEW ====================
          Expanded(
            child: TabBarView(
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
