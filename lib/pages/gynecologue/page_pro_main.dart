import 'package:flutter/material.dart';
import 'package:keneya_muso/pages/gynecologue/page_dashboard_pro.dart';
import 'package:keneya_muso/pages/gynecologue/page_patientes.dart';
import 'package:keneya_muso/widgets/pro_bottom_nav_bar.dart';

class PageProMain extends StatefulWidget {
  const PageProMain({super.key});

  @override
  State<PageProMain> createState() => _PageProMainState();
}

class _PageProMainState extends State<PageProMain> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const PageDashboardPro(),
    const PagePatientes(),
    // Add other pages here for 'Accompagnements' and 'Parametre'
    const Center(child: Text('Accompagnements Page')),
    const Center(child: Text('Parametre Page')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: ProBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}
