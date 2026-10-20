import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/api/api_client.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';
import 'package:gestion_hsse/cores/services/checklist_service.dart';
import 'package:gestion_hsse/cores/services/equipment_service.dart';
import 'package:gestion_hsse/cores/services/realtime_service.dart';
import 'package:gestion_hsse/cores/services/sync_service.dart';
import 'package:gestion_hsse/cores/services/vmc_service.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/views/home/dashboard/widgets/activity_card.dart';
import 'package:gestion_hsse/views/home/dashboard/widgets/bar_chart.dart';
import 'package:gestion_hsse/views/home/dashboard/widgets/quick_action.dart';
import 'package:gestion_hsse/views/home/dashboard/widgets/stat_card.dart';
import 'package:gestion_hsse/views/home/inspection/checklist/checklist_list_view.dart';
import 'package:gestion_hsse/views/home/inspection/equipment/equipment_list_view.dart';
import 'package:gestion_hsse/views/home/inspection/vmc/vmc_list_view.dart';

class DashboardPage extends StatefulWidget {
  final Function(int tabIndex, [int? inspectionSubTab])? onNavigateTab;

  const DashboardPage({
    super.key,
    this.onNavigateTab,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoading = false;
  List<VmcItemData> _vmcs = [];
  List<ChecklistItemData> _checklists = [];
  List<EquipmentItemData> _equipments = [];
  StreamSubscription<RealtimeEvent>? _realtimeSub;

  @override
  void initState() {
    super.initState();
    _loadAllData();

    // Abonnement temps réel pour actualiser les compteurs et activités
    _realtimeSub = RealtimeService.instance.onEvent.listen((_) {
      if (mounted) {
        _loadAllData(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _realtimeSub?.cancel();
    super.dispose();
  }

  Future<void> _loadAllData({bool silent = false}) async {
    if (!silent) {
      setState(() => _isLoading = true);
    }

    try {
      final vmcFuture = VmcService.getVmcs();
      final checklistFuture = ChecklistService.getChecklists();
      final equipmentFuture = EquipmentService.getEquipments();

      final results = await Future.wait([
        vmcFuture,
        checklistFuture,
        equipmentFuture,
      ]);

      if (mounted) {
        setState(() {
          _vmcs = results[0] as List<VmcItemData>;
          _checklists = results[1] as List<ChecklistItemData>;
          _equipments = results[2] as List<EquipmentItemData>;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted && !silent) {
        setState(() => _isLoading = false);
      }
    }
  }

  double get _overallComplianceRate {
    if (_vmcs.isEmpty) return 0.88;
    double total = 0.0;
    for (final v in _vmcs) {
      total += v.complianceRate;
    }
    return total / _vmcs.length;
  }

  int get _deviationsCount {
    int total = 0;
    for (final v in _vmcs) {
      total += v.deviations;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiClient.currentUser;
    final userName = user?['name']?.toString() ?? 'ARIMANANA Maherison Jules';
    final userRole = user?['role']?.toString() ?? 'Inspecteur HSSE • Galana Madagascar';

    return ListenableBuilder(
      listenable: SyncService.instance,
      builder: (context, _) {
        final isOnline = SyncService.instance.isOnline;
        final pendingCount = SyncService.instance.pendingCount;
        final isSyncing = SyncService.instance.isSyncing;

        return RefreshIndicator(
          onRefresh: () => _loadAllData(),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================
                // 1. BANNIÈRE DE BIENVENUE & PROFIL GALANA
                // ==========================================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0F9D58),
                        Color(0xFF0B7A45),
                        Color(0xFF064E2A),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F9D58).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bonjour $userName 👋',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  userRole,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Pill statut temps réel / offline
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isOnline
                                    ? const Color(0xFF4ADE80)
                                    : const Color(0xFFFBBF24),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isOnline
                                  ? 'Connecté au serveur • Synchronisation temps réel'
                                  : 'Mode Hors-ligne • $pendingCount inspection(s) en attente',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ==========================================
                // 2. ALERTE SYNCHRONISATION EN ATTENTE
                // ==========================================
                if (pendingCount > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.cloud_upload_outlined,
                          color: Color(0xFFD97706),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '$pendingCount inspection(s) effectuée(s) hors-ligne. Envoi automatique dès reconnexion.',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ),
                        if (isOnline)
                          TextButton(
                            onPressed: isSyncing
                                ? null
                                : () => SyncService.instance.syncAll(),
                            child: Text(
                              isSyncing ? 'En cours...' : 'Envoyer',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD97706),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 18),

                // ==========================================
                // 3. PILIERS D'INSPECTION TERRAIN (ACCÈS DIRECT)
                // ==========================================
                const Text(
                  "Piliers d'Inspection Galana",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    // Pilier 1 : VMC
                    Expanded(
                      child: _buildInspectionModuleCard(
                        title: "VMC",
                        subtitle: "${_vmcs.length} visites",
                        icon: Icons.assignment_turned_in,
                        color: const Color(0xFF0F9D58),
                        badge: "CC • SS • Mag",
                        onTap: () {
                          if (widget.onNavigateTab != null) {
                            widget.onNavigateTab!(1, 0);
                          } else {
                            Navigator.pushNamed(context, AppRoutes.inspections);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Pilier 2 : Checklists
                    Expanded(
                      child: _buildInspectionModuleCard(
                        title: "Checklists",
                        subtitle: "${_checklists.length} fiches",
                        icon: Icons.checklist_rtl_rounded,
                        color: const Color(0xFF2563EB),
                        badge: "Terrain",
                        onTap: () {
                          if (widget.onNavigateTab != null) {
                            widget.onNavigateTab!(1, 1);
                          } else {
                            Navigator.pushNamed(context, AppRoutes.inspections);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Pilier 3 : Matériel
                    Expanded(
                      child: _buildInspectionModuleCard(
                        title: "Matériel",
                        subtitle: "${_equipments.length} suivis",
                        icon: Icons.fire_extinguisher,
                        color: const Color(0xFFEA580C),
                        badge: "Extincteurs • RIA",
                        onTap: () {
                          if (widget.onNavigateTab != null) {
                            widget.onNavigateTab!(1, 2);
                          } else {
                            Navigator.pushNamed(context, AppRoutes.inspections);
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ==========================================
                // 4. ACCÈS RAPIDES
                // ==========================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    QuickAction(
                      icon: Icons.fact_check_outlined,
                      label: 'Inspections',
                      onTap: () {
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(1, 0);
                        } else {
                          Navigator.pushNamed(context, AppRoutes.inspections);
                        }
                      },
                    ),
                    QuickAction(
                      icon: Icons.description_outlined,
                      label: 'Rapports',
                      onTap: () {
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(2);
                        }
                      },
                    ),
                    QuickAction(
                      icon: Icons.settings_outlined,
                      label: 'Paramètres',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.settings);
                      },
                    ),
                    QuickAction(
                      icon: Icons.notifications_outlined,
                      label: "Alertes",
                      showBadge: _deviationsCount > 0,
                      badgeValue: _deviationsCount.toString(),
                      onTap: () {
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(3);
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ==========================================
                // 4.1 BANNIÈRE CONTACTS D'URGENCE & SECOURS
                // ==========================================
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.emergencyContacts);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFDC2626).withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.phone_in_talk_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Contacts d'Urgence & Secours",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF991B1B),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Pompiers 118 • SAMU 124 • Police 117 • Gendarmerie 119",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFB91C1C),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Color(0xFFDC2626),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // ==========================================
                // 5. INDICATEURS DE PERFORMANCE (KPIS DYNAMIQUES)
                // ==========================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Indicateurs Clés HSSE",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (_isLoading)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.45,
                  children: [
                    StatCard(
                      icon: Icons.assignment_outlined,
                      value: _vmcs.length.toString(),
                      title: 'VMC enregistrées',
                      subtitle: 'Stations, citernes, agences',
                      color: const Color(0xFF0F9D58),
                      onTap: () {
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(1, 0);
                        }
                      },
                    ),
                    StatCard(
                      icon: Icons.checklist,
                      value: _checklists.length.toString(),
                      title: 'Checklists terrain',
                      subtitle: 'Audits et conformité',
                      color: const Color(0xFF2563EB),
                      onTap: () {
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(1, 1);
                        }
                      },
                    ),
                    StatCard(
                      icon: Icons.fire_extinguisher_outlined,
                      value: _equipments.length.toString(),
                      title: 'Équipements suivis',
                      subtitle: 'P50, P9, RIA, Cuves',
                      color: const Color(0xFFEA580C),
                      onTap: () {
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(1, 2);
                        }
                      },
                    ),
                    StatCard(
                      icon: Icons.verified_outlined,
                      value: '${(_overallComplianceRate * 100).toStringAsFixed(0)}%',
                      title: 'Conformité globale',
                      subtitle: '$_deviationsCount écart(s) relevé(s)',
                      color: _overallComplianceRate >= 0.8
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ==========================================
                // 6. ACTIVITÉS & INSPECTIONS RÉCENTES (RÉELLES)
                // ==========================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Dernières Inspections",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(1, 0);
                        }
                      },
                      child: const Text(
                        "Tout voir",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                if (_vmcs.isEmpty && _checklists.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    child: const Text(
                      "Aucune inspection enregistrée pour le moment.",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  )
                else ...[
                  // Affiche les 3 premières VMC réelles
                  ..._vmcs.take(3).map((vmc) {
                    final bool isConforme = vmc.complianceRate >= 1.0;
                    return ActivityCard(
                      title: vmc.title,
                      subtitle: "${vmc.reference} • ${vmc.site} • ${vmc.date}",
                      status: isConforme ? "Conforme" : "${(vmc.complianceRate * 100).toInt()}%",
                      statusColor: isConforme
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626),
                      icon: _getIconForVmcType(vmc.type),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.vmcDetail,
                          arguments: vmc,
                        );
                      },
                    );
                  }),
                ],

                const SizedBox(height: 20),

                // ==========================================
                // 7. PERFORMANCE HEBDOMADAIRE HSSE
                // ==========================================
                const Text(
                  "Performance Hebdomadaire",
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
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      BarChart(value: 35, day: "Lun"),
                      BarChart(value: 55, day: "Mar"),
                      BarChart(value: 40, day: "Mer"),
                      BarChart(value: 80, day: "Jeu"),
                      BarChart(value: 85, day: "Ven"),
                      BarChart(value: 70, day: "Sam"),
                      BarChart(value: 65, day: "Dim"),
                    ],
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInspectionModuleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String badge,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForVmcType(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('camion')) return Icons.local_shipping_outlined;
    if (lower.contains('station')) return Icons.local_gas_station_outlined;
    if (lower.contains('magasin') || lower.contains('agence')) return Icons.store_mall_directory_outlined;
    if (lower.contains('moment')) return Icons.access_time_outlined;
    if (lower.contains('awareness')) return Icons.school_outlined;
    return Icons.report_problem_outlined;
  }
}
