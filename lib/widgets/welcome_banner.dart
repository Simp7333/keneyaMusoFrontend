import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/dossier_medical_service.dart';

class WelcomeBanner extends StatefulWidget {
  const WelcomeBanner({super.key});

  @override
  State<WelcomeBanner> createState() => _WelcomeBannerState();
}

class _WelcomeBannerState extends State<WelcomeBanner> {
  final DossierMedicalService _service = DossierMedicalService();
  String _prenom = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      // Essayer de charger depuis le backend
      final response = await _service.getMyPatienteInfo();
      
      if (response.success && response.data != null) {
        final prenom = response.data!['prenom'] ?? 'Utilisateur';
        
        if (mounted) {
          setState(() {
            _prenom = prenom;
            _isLoading = false;
          });
        }
        
        // Sauvegarder dans SharedPreferences pour un accès rapide futur
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_prenom', prenom);
      } else {
        // Fallback sur SharedPreferences si l'API échoue
        final prefs = await SharedPreferences.getInstance();
        final prenom = prefs.getString('user_prenom') ?? 'Utilisateur';
        
        if (mounted) {
          setState(() {
            _prenom = prenom;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // Fallback sur SharedPreferences en cas d'erreur
      try {
        final prefs = await SharedPreferences.getInstance();
        final prenom = prefs.getString('user_prenom') ?? 'Utilisateur';
        
        if (mounted) {
          setState(() {
            _prenom = prenom;
            _isLoading = false;
          });
        }
      } catch (e2) {
        if (mounted) {
          setState(() {
            _prenom = 'Utilisateur';
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF0F0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isLoading ? 'Salut...' : 'Salut, $_prenom',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bienvenue sur votre espace de suivi',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Image.asset(
            'assets/images/docP.png',
            height: 120,
            width: 100,
            fit: BoxFit.contain,
          )
        ],
      ),
    );
  }
}
