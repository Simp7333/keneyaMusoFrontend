import 'package:flutter/material.dart';
import 'package:keneya_muso/routes.dart';
import '../common/app_colors.dart';
import '../../widgets/pro_bottom_nav_bar.dart';
import '../../widgets/stats_grid.dart';
import '../../widgets/welcome_banner.dart';

class PageDashboardPro extends StatefulWidget {
  const PageDashboardPro({super.key});

  @override
  State<PageDashboardPro> createState() => _PageDashboardProState();
}

class _PageDashboardProState extends State<PageDashboardPro> {
  int _selectedIndex = 0;

  void _onNavBarItemTapped(int index) {
    if (_selectedIndex == index) return;

    switch (index) {
      case 0:
        // Already on this page, do nothing.
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.proPatientes);
        break;
      case 2:
        // TODO: Create and navigate to Accompagnements page
        break;
      case 3:
        // TODO: Create and navigate to Pro Settings page
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            backgroundColor: Colors.black,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WelcomeBanner(),
            SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: StatsGrid(),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: ProBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavBarItemTapped,
      ),
    );
  }
}
