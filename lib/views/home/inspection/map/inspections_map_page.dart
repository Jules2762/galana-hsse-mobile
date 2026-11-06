import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/models/inspection_map_item.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/inspections_map_view.dart';

class InspectionsMapPage extends StatelessWidget {
  final InspectionType? initialType;
  final String? focusedSite;

  const InspectionsMapPage({
    super.key,
    this.initialType,
    this.focusedSite,
  });

  @override
  Widget build(BuildContext context) {
    // Lecture éventuelle des arguments passés via Navigator
    final args = ModalRoute.of(context)?.settings.arguments;
    InspectionType? resolvedType = initialType;
    String? resolvedSite = focusedSite;

    if (args is Map<String, dynamic>) {
      if (args['type'] is InspectionType) {
        resolvedType = args['type'];
      }
      if (args['site'] != null) {
        resolvedSite = args['site'].toString();
      }
    } else if (args is InspectionType) {
      resolvedType = args;
    } else if (args is String) {
      resolvedSite = args;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        scrolledUnderElevation: 1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Cartographie des Inspections",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            Text(
              "VMC • Checklists • Suivi Matériel",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        actions: [
          // Bouton SOS Secours d'urgence
          IconButton(
            tooltip: "Secours d'urgence",
            icon: const Icon(Icons.emergency, color: Color(0xFFDC2626)),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.emergencyContacts);
            },
          ),
        ],
      ),
      body: InspectionsMapView(
        initialTypeFilter: resolvedType,
        focusedSite: resolvedSite,
      ),
    );
  }
}
