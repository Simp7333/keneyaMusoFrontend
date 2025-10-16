import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/carte_personnel.dart';
import '../../routes.dart';

class PersonnelPage extends StatefulWidget {
  const PersonnelPage({super.key});

  @override
  State<PersonnelPage> createState() => _PersonnelPageState();
}

class _PersonnelPageState extends State<PersonnelPage> {
  int _selectedIndex = 2; // Personnel page is selected
  String _suiviType = 'prenatal';

  @override
  void initState() {
    super.initState();
    _loadSuiviType();
  }

  Future<void> _loadSuiviType() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _suiviType = prefs.getString('suiviType') ?? 'prenatal';
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        if (_suiviType == 'prenatal') {
          Navigator.pushReplacementNamed(context, AppRoutes.patienteDashboard);
        } else {
          Navigator.pushReplacementNamed(
              context, AppRoutes.patienteDashboardPostnatal);
        }
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.patienteContent);
        break;
      case 2:
        // Already on this page
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.patienteSettings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            const Text('Personnels', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black),
            onPressed: () {
              // Action for profile icon
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nos Personnels',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  CartePersonnel(
                    name: 'Mme Diawara Mana Diawara',
                    title: 'Sage-femme diplômée d\'État',
                    location: 'Clinique La Renaissance - Bamako',
                    imageUrl: 'assets/images/malmatou.jpg', // Example image
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.patientePersonnelProfile,
                        arguments: {
                          'name': 'Mme Diawara Mana Diawara',
                          'title': 'Sage-femme diplômée d\'État',
                          'location': 'Clinique La Renaissance - Bamako',
                          'imageUrl': 'assets/images/malmatou.jpg',
                        },
                      );
                    },
                  ),
                  // Add other personnel cards here
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
