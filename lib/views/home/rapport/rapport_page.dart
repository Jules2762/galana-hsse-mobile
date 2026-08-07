import 'package:flutter/material.dart';
import 'package:gestion_hsse/views/home/rapport/widget/report_card.dart';
import 'package:gestion_hsse/views/home/rapport/widget/report_filter_chip.dart';


class RapportPage extends StatefulWidget {
  const RapportPage({super.key});

  @override
  State<RapportPage> createState() =>
      _RapportPageState();
}

class _RapportPageState extends State<RapportPage> {
  int selectedFilter = 0;

  final filters = [
    "Tous",
    "Cette semaine",
    "Ce mois",
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),

      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText:
                  "Rechercher un rapport...",
              prefixIcon: const Icon(
                Icons.search,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: List.generate(
              filters.length,
              (index) {
                return Padding(
                  padding:
                      const EdgeInsets.only(
                    right: 8,
                  ),
                  child: ReportFilterChip(
                    label: filters[index],
                    selected:
                        selectedFilter ==
                            index,
                    onTap: () {
                      setState(() {
                        selectedFilter =
                            index;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          ReportCard(
            category: "Sécurité",
            title:
                "Rapport — Inspection Sécurité Incendie",
            inspector:
                "Jules Rakoto",
            date:
                "15 Juil 2025",
            conformity: 78,
          ),

          const SizedBox(height: 12),

          ReportCard(
            category: "Audit",
            title:
                "Rapport — Audit Énergie Antsirabe",
            inspector:
                "Jules Rakoto",
            date:
                "12 Juil 2025",
            conformity: 92,
          ),

          const SizedBox(height: 12),

          ReportCard(
            category: "Opérations",
            title:
                "Rapport — Inspection Cuve Carburant",
            inspector:
                "Jules Rakoto",
            date:
                "08 Juil 2025",
            conformity: 65,
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}