import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maps/ui/pages/centers/safe_centers_page.dart';
import 'package:maps/ui/pages/incident/incidents_page.dart';
import 'package:maps/ui/pages/reports/report_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        if (_tabController.indexIsChanging) {
          _pageController.animateToPage(
            _tabController.index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        }
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trujillo Reporta',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Acción para notificaciones
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Acción para perfil de usuario
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Incidentes'),
            Tab(icon: Icon(Icons.report), text: 'Reportar'),
            Tab(icon: Icon(Icons.location_on), text: 'Centros seguros'),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          _tabController.index = index;
        },
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          IncidentsMapPage(),
          ReportMapPage(),
          SafeCentersPage(),
        ],
      ),
    );
  }
}
