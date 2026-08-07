import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/inspection_card.dart';

import 'package:gestion_hsse/views/home/inspection/widgets/inspection_filter_chip.dart';

class InspectionsPage extends StatefulWidget {
  const InspectionsPage({super.key});

  @override
  State<InspectionsPage> createState() => _InspectionsPageState();
}

class _InspectionsPageState extends State<InspectionsPage> {
  int selectedFilter = 0;

  final List<String> filters = const [
    "Tous",
    "En cours",
    "Terminée",
    "Planifiée",
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // ==========================
          // SEARCH
          // ==========================
          TextField(
            decoration: InputDecoration(
              hintText: "Rechercher une inspection...",
              prefixIcon: const Icon(Icons.search),
            ),
          ),

          const SizedBox(height: 20),

          // ==========================
          // FILTERS
          // ==========================
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            child: Row(
              children: List.generate(filters.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),

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
            ),
          ),

          const SizedBox(height: 24),

          // ==========================
          // INSPECTIONS
          // ==========================
          InspectionCard(
            title: "Inspection Sécurité Incendie",
            site: "Dépôt Antsirabe",
            inspector: "Jules Rakoto",
            date: "15 Juil 2025",
            progress: .65,
            status: "En cours",
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.checklistDetail);
            },
          ),

          SizedBox(height: 16),

          InspectionCard(
            title: "Audit EPI Terrain",
            site: "Terminal Tamatave",
            inspector: "Jules Rakoto",
            date: "15 Juil 2025",
            progress: 1,
            status: "Terminée",
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.checklistDetail);
            },
          ),

          SizedBox(height: 16),

          InspectionCard(
            title: "Contrôle Stockage Carburant",
            site: "Station Majunga",
            inspector: "Jules Rakoto",
            date: "15 Juil 2025",
            progress: .12,
            status: "En cours",
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.checklistDetail);
            },
          ),

          SizedBox(height: 16),

          InspectionCard(
            title: "Inspection Environnementale",
            site: "Dépôt Ivato",
            inspector: "Jules Rakoto",
            date: "15 Juil 2025",
            progress: 0,
            status: "Planifiée",
            onTap:() {
              Navigator.pushNamed(context, AppRoutes.checklistDetail);
            }, 
            
          ),

          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
