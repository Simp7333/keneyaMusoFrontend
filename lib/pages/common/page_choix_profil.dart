import 'package:flutter/material.dart';
import 'package:keneya_muso/pages/common/app_colors.dart';
import '../../routes.dart';

class PageChoixProfil extends StatefulWidget {
  const PageChoixProfil({super.key});

  @override
  State<PageChoixProfil> createState() => _PageChoixProfilState();
}

class _PageChoixProfilState extends State<PageChoixProfil> with TickerProviderStateMixin {
  String? _selectedProfile;
  late AnimationController _fadeController;
  late AnimationController _bounceController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image moved up and resized
          Align(
            alignment: Alignment.topCenter,
            child: Image.asset(
              'assets/images/choixe.png',
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.55,
              fit: BoxFit.cover,
            ),
          ),
          
          // Floating Card with Margin
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Choisissez votre profil',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
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
                        'Sage femme',
                        Icons.medical_services_outlined,
                        'Sage femme',
                        isSelected: _selectedProfile == 'Sage femme',
                        onTap: () => setState(() => _selectedProfile = 'Sage femme'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: _buildProfileCard(
                      'Gynécologue',
                      Icons.medical_services_outlined,
                      'Gynécologue',
                      isSelected: _selectedProfile == 'Gynécologue',
                      onTap: () => setState(() => _selectedProfile = 'Gynécologue'),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedProfile != null ? _proceedToApp : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ).copyWith(
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.disabled)) {
                              return AppColors.primaryPink
                                  .withOpacity(0.3); // Disabled color
                            }
                            return AppColors.primaryPink
                                .withOpacity(0.63); // Enabled color
                          },
                        ),
                      ),
                      child: const Text('Suivant',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: () {
          _bounceController.forward().then((_) {
            _bounceController.reverse();
          });
          onTap();
        },
        child: AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isSelected ? _bounceAnimation.value : 1.0,
              child: Container(
                width: 110,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? Color(0xFFE91E63).withOpacity(0.63) : Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected ? Color(0xFFE91E63).withOpacity(0.63) : Colors.pink[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 25,
                        color: isSelected ? Colors.white : Color(0xFFE91E63).withOpacity(0.63),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Color(0xFFE91E63).withOpacity(0.63) : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _proceedToApp() {
    if (_selectedProfile != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil sélectionné: $_selectedProfile'),
          backgroundColor: Color(0xFFE91E63).withOpacity(0.63),
        ),
      );
      
      if (_selectedProfile == 'Patiente') {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.login,
        );
      } else if (_selectedProfile == 'Sage femme' || _selectedProfile == 'Gynécologue') {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.proLogin,
        );
      }
    }
  }
}
