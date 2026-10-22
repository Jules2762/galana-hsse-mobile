import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/api/api_client.dart';
import 'package:gestion_hsse/cores/models/report_model.dart';
import 'package:gestion_hsse/cores/services/report_service.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/views/home/rapport/widget/report_card.dart';
import 'package:gestion_hsse/views/home/rapport/widget/report_filter_chip.dart';

class RapportPage extends StatefulWidget {
  const RapportPage({super.key});

  @override
  State<RapportPage> createState() => _RapportPageState();
}

class _RapportPageState extends State<RapportPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<ReportModel> _reports = [];

  int _selectedPeriod = 0;
  final List<String> _periodFilters = [
    "Tous",
    "Cette semaine",
    "Ce mois",
  ];

  String _selectedCategory = "Toutes";
  final List<String> _categoryFilters = [
    "Toutes",
    "Sécurité",
    "Environnement",
    "Opérations",
    "Audit",
    "Sûreté",
  ];

  String _selectedConformity = "Tous";
  final List<String> _conformityFilters = [
    "Tous",
    "Conformes (≥85%)",
    "Non-conformes (<85%)",
  ];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    try {
      final items = await ReportService.getReports(
        search: _searchController.text,
        periodFilter: _selectedPeriod,
        categoryFilter: _selectedCategory,
        conformityFilter: _selectedConformity,
      );
      final assignedItems = items
          .where((r) => ApiClient.isAssignedToCurrentUser(r.rawInspector ?? r.inspector, r.id))
          .toList();
      if (mounted) {
        setState(() {
          _reports = assignedItems;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedPeriod = 0;
      _selectedCategory = "Toutes";
      _selectedConformity = "Tous";
    });
    _loadReports();
  }

  // Statistiques agrégées
  int get _averageConformity {
    if (_reports.isEmpty) return 0;
    final sum = _reports.fold<int>(0, (acc, r) => acc + r.conformity);
    return (sum / _reports.length).round();
  }

  int get _totalNonConformities {
    return _reports.fold<int>(0, (acc, r) => acc + r.nonConformities.length);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadReports,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================
            // BARRE DE RECHERCHE EN TEMPS RÉEL
            // ============================================
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => _loadReports(),
                decoration: InputDecoration(
                  hintText: "Rechercher par titre, site, inspecteur...",
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B), size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18, color: Color(0xFF94A3B8)),
                          onPressed: () {
                            _searchController.clear();
                            _loadReports();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ============================================
            // BANNIÈRE KPI / STATISTIQUES DES RAPPORTS
            // ============================================
            Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    title: "Rapports",
                    value: _reports.length.toString(),
                    subtitle: "Disponibles",
                    icon: Icons.description_outlined,
                    color: const Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildKpiCard(
                    title: "Conformité",
                    value: "$_averageConformity%",
                    subtitle: "Taux moyen",
                    icon: Icons.verified_outlined,
                    color: _averageConformity >= 80 ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildKpiCard(
                    title: "Écarts",
                    value: _totalNonConformities.toString(),
                    subtitle: "Non-conformités",
                    icon: Icons.warning_amber_rounded,
                    color: _totalNonConformities == 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ============================================
            // FILTRES PAR PÉRIODE & CATÉGORIE
            // ============================================
            // Période & Assignation
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
                            "Mes assignations (${_reports.length})",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D4ED8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ...List.generate(
                    _periodFilters.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ReportFilterChip(
                        label: _periodFilters[index],
                        selected: _selectedPeriod == index,
                        onTap: () {
                          setState(() => _selectedPeriod = index);
                          _loadReports();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Catégories (Sécurité, Environnement, etc.)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  _categoryFilters.length,
                  (index) {
                    final cat = _categoryFilters[index];
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => _selectedCategory = cat);
                          _loadReports();
                        },
                        selectedColor: AppColors.primary.withValues(alpha: 0.15),
                        backgroundColor: Colors.white,
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : const Color(0xFF64748B),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Filtres Conformité
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  _conformityFilters.length,
                  (index) {
                    final filter = _conformityFilters[index];
                    final isSelected = _selectedConformity == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => _selectedConformity = filter);
                          _loadReports();
                        },
                        selectedColor: const Color(0xFF0F9D58),
                        backgroundColor: const Color(0xFFF1F5F9),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF64748B),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide.none,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ============================================
            // LISTE DES RAPPORTS D'INSPECTION
            // ============================================
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (_reports.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.description_outlined, size: 48, color: Color(0xFFCBD5E1)),
                    const SizedBox(height: 12),
                    const Text(
                      "Aucun rapport assigné",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Aucun rapport disponible pour vos assignations ou critères de recherche actuels.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _resetFilters,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text("Réinitialiser les filtres"),
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
                itemCount: _reports.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final report = _reports[index];
                  return ReportCard(report: report);
                },
              ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}