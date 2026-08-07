import 'package:flutter/material.dart';
import 'package:gestion_hsse/views/home/notification/widget/notification_card.dart';
import 'package:gestion_hsse/views/home/notification/widget/notification_filter_chip.dart';


class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() =>
      _NotificationsPageState();
}

class _NotificationsPageState
    extends State<NotificationsPage> {
  int selectedFilter = 0;

  final filters = const [
    "Toutes",
    "Inspections",
    "Actions",
    "Système",
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
            

        children: [
          // HEADER ACTION

          Row(
            children: [
              const Spacer(),

              TextButton(
                onPressed: () {},
                child: const Text(
                  "Tout marquer lu",
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),

          // FILTERS

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            child: Row(
              children: List.generate(
                filters.length,
                (index) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(
                      right: 8,
                    ),

                    child:
                        NotificationFilterChip(
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
          ),

          const SizedBox(height: 20),

          // NOTIFICATIONS

          const NotificationCard(
            title:
                "Nouvelle inspection assignée",
            description:
                "Audit EPI Dépôt Mahajanga",
            time: "Il y a 2 min",
            icon:
                Icons.description_outlined,
            color: Color(0xFF3B82F6),
            unread: true,
          ),

          SizedBox(height: 12),

          NotificationCard(
            title:
                "Action corrective échue",
            description:
                "Remplacement extincteurs Zone B",
            time: "Il y a 1 h",
            icon:
                Icons.warning_amber_rounded,
            color: Color(0xFFEF4444),
            unread: true,
          ),

          SizedBox(height: 12),

          NotificationCard(
            title:
                "Inspection approuvée",
            description:
                "Contrôle Stockage Carburant",
            time: "Il y a 3 h",
            icon: Icons.check_circle,
            color: Color(0xFF22C55E),
          ),

          SizedBox(height: 12),

          NotificationCard(
            title: "Compte activé",
            description:
                "Bienvenue sur GALANA HSSE",
            time: "Il y a 1 jour",
            icon:
                Icons.workspace_premium,
            color: Color(0xFFF59E0B),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}