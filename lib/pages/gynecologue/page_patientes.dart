import 'package:flutter/material.dart';
import 'package:keneya_muso/models/patient.dart';
import 'package:keneya_muso/routes.dart';
import 'package:keneya_muso/widgets/patient_list_item.dart';
import 'package:keneya_muso/widgets/pro_bottom_nav_bar.dart';
import '../common/app_colors.dart';

class PagePatientes extends StatefulWidget {
  const PagePatientes({super.key});

  @override
  State<PagePatientes> createState() => _PagePatientesState();
}

class _PagePatientesState extends State<PagePatientes> {
  int _selectedTabIndex = 0;
  int _bottomNavIndex = 1; // 'Patientes' is the second item

  final List<Patient> _prenatalPatients = [
    Patient(name: 'Nantenin Keita', age: '23 ans', phone: '90 11 05 65', imageUrl: 'assets/images/D1.jpg'),
    Patient(name: 'Aissata Traoré', age: '28 ans', phone: '91 22 33 44', imageUrl: 'assets/images/D3.jpg'),
    Patient(name: 'Sira Diarra', age: '22 ans', phone: '93 44 55 66', imageUrl: 'assets/images/D2.jpg'),
  ];

  final List<Patient> _postnatalPatients = [
    Patient(name: 'Mariam Diarra', age: '31 ans', phone: '94 55 66 77', imageUrl: 'assets/images/D1.jpg'),
    Patient(name: 'Oumou Sangaré', age: '29 ans', phone: '95 66 77 88', imageUrl: 'assets/images/D1.jpg'),
    Patient(name: 'Fatoumata Coulibaly', age: '25 ans', phone: '92 33 44 55', imageUrl: 'assets/images/D1.jpg'),
  ];

  void _onNavBarItemTapped(int index) {
    if (_bottomNavIndex == index) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.proDashboard);
        break;
      case 1:
        // Already on this page
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
    final patientsToShow = _selectedTabIndex == 0 ? _prenatalPatients : _postnatalPatients;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Patientes',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryPink.withOpacity(0.63),
                      ),
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.gynecologueAjoutSuivi);
                      },
                      mini: true,
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTabs(),
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: patientsToShow.length,
                    itemBuilder: (context, index) {
                      return PatientListItem(patient: patientsToShow[index]);
                    },
                  ),
                ),
              ],
            ),
        ),
      ),
      bottomNavigationBar: ProBottomNavBar(
        selectedIndex: _bottomNavIndex,
        onItemSelected: _onNavBarItemTapped,
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0 ? AppColors.primaryPink.withOpacity(0.63) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    'Prenatale',
                    style: TextStyle(
                      color: _selectedTabIndex == 0 ? Colors.white : AppColors.primaryPink.withOpacity(0.63),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1 ? AppColors.primaryPink.withOpacity(0.63) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    'Postnatale',
                    style: TextStyle(
                      color: _selectedTabIndex == 1 ? Colors.white : AppColors.primaryPink.withOpacity(0.63),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Rechercher ici...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
