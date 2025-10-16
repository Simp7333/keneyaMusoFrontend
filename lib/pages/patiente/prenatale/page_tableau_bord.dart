import 'package:flutter/material.dart';
import 'package:keneya_muso/widgets/bottom_nav_bar.dart';
import 'package:keneya_muso/widgets/custom_calendar.dart';
import 'package:keneya_muso/widgets/pregnancy_status_banner.dart';
import 'package:keneya_muso/widgets/task_card.dart';
import 'package:keneya_muso/routes.dart';
import 'package:keneya_muso/widgets/welcome_banner.dart';
import 'package:keneya_muso/widgets/suivi_options_panel.dart';

class PageTableauBord extends StatefulWidget {
  const PageTableauBord({super.key});

  @override
  State<PageTableauBord> createState() => _PageTableauBordState();
}

class _PageTableauBordState extends State<PageTableauBord> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    switch (index) {
      case 0:
        // Already on this page, do nothing or refresh
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.patienteContent);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.patientePersonnel);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.patienteSettings);
        break;
    }
  }

  void _showSuiviOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SuiviOptionsPanel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Tableau de bord',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.patienteNotifications);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.patienteProfile);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 16),
            const PregnancyStatusBanner(),
            const SizedBox(height: 24),
            const CustomCalendar(),
            const SizedBox(height: 24),
            const TaskCard(
              icon: Icons.medical_services_outlined,
              iconColor: Colors.blue,
              title: 'Rendez-vous CPN2',
              subtitle: 'Mercredi 2 octobre 2025 a 8h00',
            ),
            const SizedBox(height: 16),
            const TaskCard(
              icon: Icons.medication_outlined,
              iconColor: Colors.red,
              title: 'Prise de medicament',
              subtitle: 'C\'est l\'heure de votre prise de fer',
            ),
            const SizedBox(height: 100), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showSuiviOptions(context);
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}





