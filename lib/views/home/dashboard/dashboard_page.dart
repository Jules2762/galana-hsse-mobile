import 'package:flutter/material.dart';
import "package:gestion_hsse/cores/routes/app_routes.dart";
import "package:gestion_hsse/views/home/dashboard/widgets/quick_action.dart";
import "package:gestion_hsse/views/layouts/home_layout.dart";
import "widgets/activity_card.dart";
import "widgets/bar_chart.dart";
import "widgets/stat_card.dart";

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // =====================
          // WELCOME CARD
          // =====================
          Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F9D58), Color(0xFF087443)],
              ),

              borderRadius: BorderRadius.circular(20),
            ),

            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  // backgroundImage: AssetImage('assets/images/avatar.png'),
                  child: Icon(Icons.person),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'Bonjour Jules 👋',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Inspecteur HSSE • Opérations • Superviseur',
                        style: TextStyle(
                          color: Colors.white.withOpacity(.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // =====================
          // QUICK ACTIONS
          // =====================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,

            children: [
              QuickAction(icon: Icons.add, label: 'Nouvelle'),

              QuickAction(
                icon: Icons.description_outlined,
                label: 'Rapports',
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HomeLayout(initialIndex: 2),
                    ),
                  );
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
                showBadge: true,
                badgeValue: "3",
              ),
            ],
          ),

          const SizedBox(height: 24),

          // =====================
          // KPI
          // =====================
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),

            crossAxisCount: 2,

            mainAxisSpacing: 12,
            crossAxisSpacing: 12,

            childAspectRatio: 1.4,

            children: const [
              StatCard(
                icon: Icons.assignment_outlined,
                value: '147',
                title: 'Inspections réalisées',
                color: Color(0xFF22C55E),
              ),

              StatCard(
                icon: Icons.warning_amber,
                value: '23',
                title: 'Actions ouvertes',
                color: Color(0xFFF59E0B),
              ),

              StatCard(
                icon: Icons.task_alt_outlined,
                value: '89',
                title: 'Actions clôturées',
                color: Color(0xFF22C55E),
              ),

              StatCard(
                icon: Icons.verified_outlined,
                value: '87%',
                title: 'Taux conformité',
                color: Color(0xFF22C55E),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // =====================
          // CHART
          // =====================
          const Text(
            "Performance Hebdomadaire",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),

            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,

              crossAxisAlignment: CrossAxisAlignment.end,

              children: [
                BarChart(value: 35, day: "Lun"),
                BarChart(value: 55, day: "Mar"),
                BarChart(value: 30, day: "Mer"),
                BarChart(value: 75, day: "Jeu"),
                BarChart(value: 80, day: "Ven"),
                BarChart(value: 70, day: "Sam"),
                BarChart(value: 68, day: "Dim"),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // =====================
          // ACTIVITES
          // =====================
          const Text(
            "Activités récentes",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 12),

          const ActivityCard(
            title: "Inspection Cuve Carburant",
            subtitle: "Aujourd'hui, 10:50",
            status: "Terminée",
            statusColor: Color(0xFF22C55E),
          ),

          const ActivityCard(
            title: "Audit Dépôt Antsirabe",
            subtitle: "Hier, 08:25",
            status: "En cours",
            statusColor: Color(0xFF3B82F6),
          ),

          const ActivityCard(
            title: "Contrôle Sécurité Incendie",
            subtitle: "Prévue 18 Juil",
            status: "Planifiée",
            statusColor: Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }
}
