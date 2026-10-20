import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';
import 'package:gestion_hsse/cores/services/notification_service.dart';
import 'package:gestion_hsse/cores/services/sync_service.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/views/home/dashboard/dashboard_page.dart';
import 'package:gestion_hsse/views/home/inspection/inspection_page.dart';
import 'package:gestion_hsse/views/home/notification/notification_page.dart';
import 'package:gestion_hsse/views/home/profile/profile_page.dart';
import 'package:gestion_hsse/views/home/rapport/rapport_page.dart';

class HomeLayout extends StatefulWidget {
  final int initialIndex;

  const HomeLayout({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<HomeLayout> createState() => _StateHomeLayout();
}

class _StateHomeLayout extends State<HomeLayout> {
  late int currentIndex;
  int inspectionSubTab = 0;
  DateTime? _lastBackPressed;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    NotificationService.getNotifications();
  }

  void _navigateTo(int tabIndex, [int? subTab]) {
    setState(() {
      currentIndex = tabIndex;
      if (subTab != null) {
        inspectionSubTab = subTab;
      }
    });
  }

  List<Widget> get _children => [
        DashboardPage(onNavigateTab: _navigateTo),
        InspectionsPage(
          key: ValueKey('inspections_$inspectionSubTab'),
          initialTab: inspectionSubTab,
        ),
        const RapportPage(),
        const NotificationsPage(),
        const ProfilePage(),
      ];

  final List<NavigationDestination> items = [
    const NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Accueil',
    ),
    const NavigationDestination(
      icon: Icon(Icons.fact_check_outlined),
      selectedIcon: Icon(Icons.fact_check),
      label: 'Inspections',
    ),
    const NavigationDestination(
      icon: Icon(Icons.description_outlined),
      selectedIcon: Icon(Icons.description),
      label: 'Rapports',
    ),
    NavigationDestination(
      icon: ValueListenableBuilder<int>(
        valueListenable: NotificationService.unreadCountNotifier,
        builder: (context, count, _) {
          return Badge(
            isLabelVisible: count > 0,
            offset: const Offset(6, -6),
            label: Text("$count"),
            child: const Icon(Icons.notifications_outlined),
          );
        },
      ),
      selectedIcon: ValueListenableBuilder<int>(
        valueListenable: NotificationService.unreadCountNotifier,
        builder: (context, count, _) {
          return Badge(
            isLabelVisible: count > 0,
            offset: const Offset(6, -6),
            label: Text("$count"),
            child: const Icon(Icons.notifications),
          );
        },
      ),
      label: 'Notifications',
    ),
    const NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Retour à l'accueil
        if (currentIndex != 0) {
          setState(() {
            currentIndex = 0;
          });
          return;
        }

        final now = DateTime.now();
        if (_lastBackPressed == null ||
            now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
          _lastBackPressed = now;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Appuyez de nouveau pour quitter'),
                duration: Duration(seconds: 2),
              ),
            );
          return;
        }

        SystemNavigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          scrolledUnderElevation: 1,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: Color(0xFFE2E8F0)),
          ),
          leadingWidth: 54,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Image.asset(
                "assets/logo-galana.webp",
                fit: BoxFit.contain,
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "Galana HSSE",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                "Inspection & Conformité",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          actions: [
            // Bouton SOS Contacts d'Urgence
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.emergencyContacts);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.phone_in_talk, size: 13, color: Color(0xFFDC2626)),
                      SizedBox(width: 4),
                      Text(
                        'SOS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFDC2626),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ListenableBuilder(
              listenable: SyncService.instance,
              builder: (context, _) {
                final isOnline = SyncService.instance.isOnline;
                final pending = SyncService.instance.pendingCount;
                final isSyncing = SyncService.instance.isSyncing;

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      if (!isOnline) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              pending > 0
                                  ? '$pending inspection(s) en attente de synchronisation.'
                                  : 'Mode Hors-ligne actif. Données stockées localement.',
                            ),
                            backgroundColor: Colors.orange.shade800,
                          ),
                        );
                      } else {
                        SyncService.instance.syncAll();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isOnline
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isOnline
                              ? const Color(0xFF86EFAC)
                              : const Color(0xFFFCD34D),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSyncing)
                            const SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.8,
                                color: Color(0xFF15803D),
                              ),
                            )
                          else
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isOnline
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFD97706),
                              ),
                            ),
                          const SizedBox(width: 6),
                          Text(
                            isSyncing
                                ? 'SYNCHRO...'
                                : (isOnline
                                    ? 'EN LIGNE'
                                    : (pending > 0
                                        ? '$pending EN ATTENTE'
                                        : 'HORS-LIGNE')),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                              color: isOnline
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: IndexedStack(
          index: currentIndex,
          children: _children,
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
          ),
          child: NavigationBar(
            backgroundColor: Colors.white,
            elevation: 0,
            height: 68,
            indicatorColor: AppColors.primary.withValues(alpha: 0.12),
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            destinations: items,
          ),
        ),
      ),
    );
  }
}