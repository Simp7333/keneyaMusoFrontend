import 'package:flutter/material.dart';
import 'package:keneya_muso/pages/common/app_colors.dart';
import '../../routes.dart';

class PageChoixAjoutSuivi extends StatefulWidget {
  const PageChoixAjoutSuivi({super.key});

  @override
  State<PageChoixAjoutSuivi> createState() => _PageChoixAjoutSuiviState();
}

class _PageChoixAjoutSuiviState extends State<PageChoixAjoutSuivi> with TickerProviderStateMixin {
  String? _selectedSuiviType; // Can be 'prenatal' or 'postnatale'
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
      end: 1.05,
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.8, // Take 80% of screen height
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5), // Light grey
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Align content to the top
              children: [
                const Text(
                  'Voulez-vous ajouter un suivi prenatale ou postnatale',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 40),
                _buildChoiceButton('Prenatal', 'prenatal'),
                const SizedBox(height: 20),
                _buildChoiceButton('Postnatale', 'postnatale'),
                const Spacer(), // Pushes the button to the bottom
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _selectedSuiviType == null ? null : () {
                      if (_selectedSuiviType == 'prenatal') {
                        Navigator.pushNamed(context, AppRoutes.ajoutPrenatal);
                      } else if (_selectedSuiviType == 'postnatale') {
                        Navigator.pushNamed(context, AppRoutes.ajoutPostnatal);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: AppColors.primaryPink.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Suivant',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceButton(String text, String type) {
    final bool isSelected = _selectedSuiviType == type;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: () {
          _bounceController.forward().then((_) {
            _bounceController.reverse();
          });
          setState(() {
            _selectedSuiviType = type;
          });
        },
        child: AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isSelected ? _bounceAnimation.value : 1.0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryColor : Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                  ],
                ),
                child: Center(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primaryColor : Colors.black,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
