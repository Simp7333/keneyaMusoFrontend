import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes.dart';
import '../../widgets/page_animation_mixin.dart';
import '../common/app_colors.dart';

class TypeSuiviPage extends StatefulWidget {
  const TypeSuiviPage({super.key});

  @override
  State<TypeSuiviPage> createState() => _TypeSuiviPageState();
}

class _TypeSuiviPageState extends State<TypeSuiviPage>
    with TickerProviderStateMixin, PageAnimationMixin {
  String? _selectedSuiviType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Image.asset(
              'assets/images/Choixsuivi.png',
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.40,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: 0,
            right: 0,
            bottom: 0,
            child: SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Heureuse de vous revoir',
                            style: TextStyle(fontSize: 22, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Row(
                          children: const [
                            Text('Mariam',
                                style: TextStyle(
                                    fontSize: 34, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Text('🎉', style: TextStyle(fontSize: 28)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                            'Dites-nous quel type de suivi vous souhaitez effectuer',
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 32),
                        _buildSuiviCard(
                          title: 'Suivi Prénatal',
                          icon: Icons.pregnant_woman,
                          isSelected: _selectedSuiviType == 'prenatal',
                          onTap: () =>
                              setState(() => _selectedSuiviType = 'prenatal'),
                        ),
                        const SizedBox(height: 16),
                        _buildSuiviCard(
                          title: 'Suivi Postnatal',
                          icon: Icons.baby_changing_station,
                          isSelected: _selectedSuiviType == 'postnatal',
                          onTap: () =>
                              setState(() => _selectedSuiviType = 'postnatal'),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _selectedSuiviType != null
                                ? _proceedToDashboard
                                : null,
                            child: const Text('Suivant'),
                          ),
                        ),
                      ],
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

  Widget _buildSuiviCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryColor
                  : Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 28,
              color: Colors.black,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _proceedToDashboard() async {
    if (_selectedSuiviType != null) {
      // Sauvegarder le type de suivi
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('suiviType', _selectedSuiviType!);

      // Afficher un message de confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Type de suivi sélectionné: ${_selectedSuiviType == 'prenatal' ? 'Prénatal' : 'Postnatal'}'),
          backgroundColor: AppColors.primaryColor,
        ),
      );
      
      // Navigation selon le type de suivi sélectionné
      if (_selectedSuiviType == 'prenatal') {
        // Redirection vers la page d'enregistrement de grossesse
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.patienteEnregistrementGrossesse,
        );
      } else {
        // Redirection vers le formulaire pour le suivi postnatal
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.patienteFormulairePostnatal,
        );
      }
    }
  }
}
