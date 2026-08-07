import 'package:flutter/material.dart';
import 'package:gestion_hsse/views/home/dashboard/dashboard_page.dart';
import 'package:gestion_hsse/views/home/inspection/inspection_page.dart';
import 'package:gestion_hsse/views/home/notification/notification_page.dart';
import 'package:gestion_hsse/views/home/profile/profile_page.dart';
import 'package:gestion_hsse/views/home/rapport/rapport_page.dart';

class HomeLayout extends StatefulWidget {
  final int initialIndex;
  const HomeLayout({super.key,this.initialIndex=0});
 
  
  @override
  State<StatefulWidget> createState() => _StateHomeLayout();
}

class _StateHomeLayout extends State<HomeLayout> {
  late int currentIndex ;
  @override
  void initState(){
    super.initState();
    currentIndex=widget.initialIndex;
  }
  List<Widget> children = const [
    DashboardPage(),
    InspectionsPage(),
    RapportPage(),
    NotificationsPage(),
    ProfilePage(),
  ];
  List<NavigationDestination> items = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Accueil',
    ),
    NavigationDestination(
      icon: Icon(Icons.fact_check_outlined),
      selectedIcon: Icon(Icons.fact_check),
      label: 'Inspections',
    ),
    NavigationDestination(
      icon: Icon(Icons.description_outlined),
      selectedIcon: Icon(Icons.description),
      label: 'Rapports',
    ),
    NavigationDestination(
      icon: Badge(
        offset: const Offset(6, -6),
        label: Text("1"),
        child: Icon(Icons.notifications_outlined),
      ),
      selectedIcon: Badge(
        offset: const Offset(6, -6),
        label: Text("1"),
        child: Icon(Icons.notifications),
      ),
      label: 'Notifications',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profil',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: Image.asset("assets/logo-galana.webp",fit: BoxFit.cover),title: Text("Galana HSSE"),),
      body: IndexedStack(index: currentIndex, children: children),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: items,
      ),
    );
  }
}
