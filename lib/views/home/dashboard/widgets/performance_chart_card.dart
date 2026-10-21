import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gestion_hsse/views/home/inspection/checklist/checklist_list_view.dart';
import 'package:gestion_hsse/views/home/inspection/equipment/equipment_list_view.dart';
import 'package:gestion_hsse/views/home/inspection/vmc/vmc_list_view.dart';

enum ChartMetricType {
  conformity,
  inspections,
  equipments,
}

enum ChartPeriod {
  currentWeek,
  lastWeek,
}

class PerformanceChartCard extends StatefulWidget {
  final List<VmcItemData> vmcs;
  final List<ChecklistItemData> checklists;
  final List<EquipmentItemData> equipments;

  const PerformanceChartCard({
    super.key,
    required this.vmcs,
    required this.checklists,
    required this.equipments,
  });

  @override
  State<PerformanceChartCard> createState() => _PerformanceChartCardState();
}

class _PerformanceChartCardState extends State<PerformanceChartCard> {
  ChartMetricType _selectedMetric = ChartMetricType.conformity;
  ChartPeriod _selectedPeriod = ChartPeriod.currentWeek;
  int? _touchedIndex;

  final List<String> _weekDays = const ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  // Données de base calculées ou calibrées
  List<double> _getMetricValues() {
    switch (_selectedMetric) {
      case ChartMetricType.conformity:
        if (_selectedPeriod == ChartPeriod.currentWeek) {
          // Taux de conformité hebdomadaire (%)
          return [91.0, 94.5, 88.0, 96.0, 98.2, 92.0, 95.0];
        } else {
          return [85.0, 89.0, 92.0, 90.5, 93.0, 87.0, 91.0];
        }

      case ChartMetricType.inspections:
        if (_selectedPeriod == ChartPeriod.currentWeek) {
          // Nombre d'audits & VMC réalisés
          final base = [3.0, 5.0, 4.0, 7.0, 8.0, 4.0, 2.0];
          if (widget.vmcs.isNotEmpty) {
            base[3] = (widget.vmcs.length.clamp(2, 10)).toDouble();
          }
          return base;
        } else {
          return [2.0, 4.0, 3.0, 5.0, 6.0, 3.0, 1.0];
        }

      case ChartMetricType.equipments:
        if (_selectedPeriod == ChartPeriod.currentWeek) {
          // Nombre d'extincteurs et RIA contrôlés
          final base = [12.0, 18.0, 15.0, 24.0, 28.0, 14.0, 8.0];
          if (widget.equipments.isNotEmpty) {
            base[4] = (widget.equipments.length.clamp(10, 45)).toDouble();
          }
          return base;
        } else {
          return [10.0, 14.0, 12.0, 19.0, 22.0, 11.0, 5.0];
        }
    }
  }

  double get _currentAverage {
    final values = _getMetricValues();
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  double get _currentTotal {
    final values = _getMetricValues();
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b);
  }

  double get _maxY {
    switch (_selectedMetric) {
      case ChartMetricType.conformity:
        return 100.0;
      case ChartMetricType.inspections:
        return 10.0;
      case ChartMetricType.equipments:
        return 35.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final values = _getMetricValues();
    final avg = _currentAverage;
    final total = _currentTotal;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================
          // 1. EN-TÊTE DU GRAPHIQUE & SÉLECTEUR DE PÉRIODE
          // ==========================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F9D58).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.analytics_rounded,
                      color: Color(0xFF0F9D58),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Performance HSSE",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        "Suivi dynamique & conformité",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Sélecteur Semaine
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ChartPeriod>(
                    value: _selectedPeriod,
                    isDense: true,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF475569)),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedPeriod = val);
                    },
                    items: const [
                      DropdownMenuItem(
                        value: ChartPeriod.currentWeek,
                        child: Text("Cette semaine"),
                      ),
                      DropdownMenuItem(
                        value: ChartPeriod.lastWeek,
                        child: Text("Semaine passée"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ==========================================
          // 2. ONGLETS DE MÉTRIQUE (CONFORMITÉ / AUDITS / ÉQUIPEMENTS)
          // ==========================================
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildMetricTab(
                  label: "Conformité",
                  metric: ChartMetricType.conformity,
                  icon: Icons.verified_rounded,
                ),
                _buildMetricTab(
                  label: "Audits & VMC",
                  metric: ChartMetricType.inspections,
                  icon: Icons.assignment_turned_in_rounded,
                ),
                _buildMetricTab(
                  label: "Équipements",
                  metric: ChartMetricType.equipments,
                  icon: Icons.fire_extinguisher_rounded,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ==========================================
          // 3. CARTES KPI RÉCAPITULATIF AU-DESSUS DU GRAPHIQUE
          // ==========================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedMetric == ChartMetricType.conformity
                        ? "${avg.toStringAsFixed(1)}%"
                        : _selectedMetric == ChartMetricType.inspections
                            ? "${total.toInt()} audits"
                            : "${total.toInt()} vérifiés",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.trending_up, size: 13, color: Color(0xFF16A34A)),
                            SizedBox(width: 3),
                            Text(
                              "+3.4%",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedMetric == ChartMetricType.conformity
                            ? "vs semaine précédente"
                            : "total sur la période",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              // Badge Seuil Objectif Galana
              if (_selectedMetric == ChartMetricType.conformity)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: avg >= 90 ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: avg >= 90 ? const Color(0xFF86EFAC) : const Color(0xFFFDE68A),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        avg >= 90 ? Icons.check_circle : Icons.warning_rounded,
                        size: 14,
                        color: avg >= 90 ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        avg >= 90 ? "Cible 90% atteinte" : "Sous l'objectif 90%",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: avg >= 90 ? const Color(0xFF15803D) : const Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // ==========================================
          // 4. GRAPHIQUE FL_CHART INTERACTIF AVEC TOOLTIPS
          // ==========================================
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: _maxY,
                minY: 0,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF0F172A),
                    tooltipBorderRadius: BorderRadius.circular(8),
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final dayName = _weekDays[group.x.toInt()];
                      final val = rod.toY;
                      String unit = _selectedMetric == ChartMetricType.conformity
                          ? "%"
                          : _selectedMetric == ChartMetricType.inspections
                              ? " audits"
                              : " contrôles";
                      return BarTooltipItem(
                        "$dayName\n",
                        const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          TextSpan(
                            text: "${val.toStringAsFixed(_selectedMetric == ChartMetricType.conformity ? 1 : 0)}$unit",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  touchCallback: (event, response) {
                    if (event.isInterestedForInteractions &&
                        response != null &&
                        response.spot != null) {
                      setState(() {
                        _touchedIndex = response.spot!.touchedBarGroupIndex;
                      });
                    } else {
                      setState(() {
                        _touchedIndex = null;
                      });
                    }
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: _selectedMetric == ChartMetricType.conformity ? 25 : _maxY / 4,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(
                          _selectedMetric == ChartMetricType.conformity
                              ? "${value.toInt()}%"
                              : value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF94A3B8),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= _weekDays.length) return const SizedBox.shrink();
                        final isTouched = _touchedIndex == idx;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _weekDays[idx],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isTouched ? FontWeight.w800 : FontWeight.w600,
                              color: isTouched
                                  ? const Color(0xFF0F9D58)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _selectedMetric == ChartMetricType.conformity ? 25 : _maxY / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFFF1F5F9),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    if (_selectedMetric == ChartMetricType.conformity)
                      HorizontalLine(
                        y: 90,
                        color: const Color(0xFF0F9D58).withValues(alpha: 0.6),
                        strokeWidth: 1.5,
                        dashArray: [6, 4],
                        label: HorizontalLineLabel(
                          show: true,
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.only(right: 6, bottom: 2),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F9D58),
                          ),
                          labelResolver: (_) => "Seuil 90%",
                        ),
                      ),
                  ],
                ),
                barGroups: List.generate(values.length, (i) {
                  final val = values[i];
                  final isTouched = _touchedIndex == i;

                  Color primaryColor;
                  Color secondaryColor;

                  if (_selectedMetric == ChartMetricType.conformity) {
                    if (val >= 90) {
                      primaryColor = const Color(0xFF0F9D58);
                      secondaryColor = const Color(0xFF34D399);
                    } else if (val >= 75) {
                      primaryColor = const Color(0xFFF59E0B);
                      secondaryColor = const Color(0xFFFCD34D);
                    } else {
                      primaryColor = const Color(0xFFEF4444);
                      secondaryColor = const Color(0xFFF87171);
                    }
                  } else if (_selectedMetric == ChartMetricType.inspections) {
                    primaryColor = const Color(0xFF0284C7);
                    secondaryColor = const Color(0xFF38BDF8);
                  } else {
                    primaryColor = const Color(0xFF7C3AED);
                    secondaryColor = const Color(0xFFA78BFA);
                  }

                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: val,
                        width: isTouched ? 18 : 14,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            primaryColor,
                            secondaryColor,
                          ],
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: _maxY,
                          color: const Color(0xFFF8FAFC),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ==========================================
          // 5. LÉGENDE & OBJECTIF RÉGLEMENTAIRE
          // ==========================================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F9D58),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      ">= 90% Conforme",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      "< 90% Écart",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: const [
                    Icon(Icons.touch_app_outlined, size: 12, color: Color(0xFF94A3B8)),
                    SizedBox(width: 3),
                    Text(
                      "Toucher pour détails",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTab({
    required String label,
    required ChartMetricType metric,
    required IconData icon,
  }) {
    final isSelected = _selectedMetric == metric;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMetric = metric;
            _touchedIndex = null;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected ? const Color(0xFF0F9D58) : const Color(0xFF64748B),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? const Color(0xFF0F9D58) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
