import 'package:flutter/material.dart';
import 'package:keneya_muso/pages/common/app_colors.dart';
import '../../routes.dart';

class PageChoixProfil extends StatefulWidget {
  const PageChoixProfil({super.key});

  @override
  State<PageChoixProfil> createState() => _PageChoixProfilState();
}

class _PageChoixProfilState extends State<PageChoixProfil> {
  String? _selectedProfile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Background Image
            Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                'assets/images/choixe.png', // Main background image
                height: MediaQuery.of(context).size.height * 0.6,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            
            // White Card with content
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.55,
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Choisissez votre profil',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildProfileCard(
                          'Patiente',
                          Icons.person_outline,
                          'Patiente',
                          isSelected: _selectedProfile == 'Patiente',
                          onTap: () => setState(() => _selectedProfile = 'Patiente'),
                        ),
                        _buildProfileCard(
                          'Médecin',
                          Icons.medical_services_outlined,
                          'Médecin',
                          isSelected: _selectedProfile == 'Médecin',
                          onTap: () => setState(() => _selectedProfile = 'Médecin'),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _selectedProfile != null ? _proceedToApp : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPink.withOpacity(0.63),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Suivant',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    String title,
    IconData icon,
    String profileType, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryPink.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
              spreadRadius: 8,
              blurRadius: 25,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryPink.withOpacity(0.1) : Colors.pink[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 30,
                color: isSelected ? AppColors.primaryPink : AppColors.primaryPink.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primaryPink : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _proceedToApp() {
    if (_selectedProfile != null) {
      if (_selectedProfile == 'Patiente') {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.login,
        );
      } else if (_selectedProfile == 'Médecin') {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.proLogin,
        );
      }
    }
  }
}
