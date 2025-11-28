import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:keneya_muso/pages/common/app_colors.dart';
import 'package:keneya_muso/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widgets/page_animation_mixin.dart';
import '../../services/auth_service.dart';
import '../../services/grossesse_service.dart';
import '../../services/enfant_service.dart';
import '../../models/dto/login_request.dart';
import '../../models/enums/role_utilisateur.dart';

class PageConnexion extends StatefulWidget {
  const PageConnexion({super.key});

  @override
  State<PageConnexion> createState() => _PageConnexionState();
}

class _PageConnexionState extends State<PageConnexion>
    with TickerProviderStateMixin, PageAnimationMixin {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final GrossesseService _grossesseService = GrossesseService();
  final EnfantService _enfantService = EnfantService();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image
          Align(
            alignment: Alignment.topCenter,
            child: Image.asset(
              'assets/images/login.png',
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.6,
              fit: BoxFit.cover,
            ),
          ),
          
          // Login Form Card
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
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
                    // Title
                    const Text(
                      'Connexion',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Input Fields
                    _buildInputField(
                      controller: _phoneController,
                      hintText: 'Numéro Téléphone',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      controller: _passwordController,
                      hintText: 'Mot de passe',
                      isPassword: true,
                    ),
                    const SizedBox(height: 24),
                    
                    // Links
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                            children: [
                              const TextSpan(text: 'Pas de compte?'),
                              TextSpan(
                                text: ' S\'inscrire',
                                style: TextStyle(
                                  color: AppColors.primaryPink.withOpacity(0.63),
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(context, AppRoutes.register);
                                  },
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.forgotPassword);
                          },
                          child: const Text(
                            'Mot de passe oublié',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPink.withOpacity(0.63),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Se connecter', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword && !_isPasswordVisible,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }

  void _handleLogin() async {
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Appel API de connexion
      final loginRequest = LoginRequest(
        telephone: _phoneController.text.trim(),
        motDePasse: _passwordController.text,
      );

      final response = await _authService.login(loginRequest);

      if (!mounted) return;

      if (response.success && response.data != null) {
        // Vérifier que c'est bien une patiente
        if (response.data!.role != RoleUtilisateur.PATIENTE) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ce compte n\'est pas un compte patiente'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false);
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connexion réussie ! Bienvenue ${response.data!.prenom}'),
            backgroundColor: Colors.green,
          ),
        );

        // Sauvegarder les informations utilisateur
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', response.data!.id);
        await prefs.setString('user_prenom', response.data!.prenom);

        // Vérifier si un type de suivi a déjà été sélectionné dans SharedPreferences
        String? suiviType = prefs.getString('suiviType');

        // Si pas de type de suivi sauvegardé, déterminer automatiquement depuis le backend
        if (suiviType == null) {
          suiviType = await _determineSuiviType(response.data!.id);
          
          // Si un type a été déterminé, le sauvegarder
          if (suiviType != null) {
            await prefs.setString('suiviType', suiviType);
          }
        }

        // Rediriger selon le type de suivi
        if (suiviType == 'prenatal') {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.patienteDashboard,
          );
        } else if (suiviType == 'postnatal') {
          // Pour postnatal, vérifier si l'enregistrement de l'accouchement est fait
          final dateAccouchement = prefs.getString('dateAccouchement');
          if (dateAccouchement != null) {
            // Enregistrement déjà fait, aller au dashboard
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.patienteDashboardPostnatal,
            );
          } else {
            // Vérifier si des enfants existent déjà dans le backend
            final enfantsResponse = await _enfantService.getEnfantsByPatiente(response.data!.id);
            if (enfantsResponse.success && 
                enfantsResponse.data != null && 
                enfantsResponse.data!.isNotEmpty) {
              // Des enfants existent, aller directement au dashboard postnatal
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.patienteDashboardPostnatal,
              );
            } else {
              // Enregistrement pas encore fait, rediriger vers la page d'enregistrement
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.patienteEnregistrementAccouchement,
              );
            }
          }
        } else {
          // Aucun type de suivi déterminé, redirection vers la page de choix
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.patienteTypeSuivi,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Détermine automatiquement le type de suivi en vérifiant les données du backend
  /// Retourne 'prenatal' si une grossesse active existe, 'postnatal' si des enfants existent, null sinon
  Future<String?> _determineSuiviType(int patienteId) async {
    try {
      // Vérifier d'abord si une grossesse active existe (prénatal)
      final grossesseResponse = await _grossesseService.getCurrentGrossesseByPatiente(patienteId);
      if (grossesseResponse.success && grossesseResponse.data != null) {
        return 'prenatal';
      }

      // Si pas de grossesse active, vérifier si des enfants existent (postnatal)
      final enfantsResponse = await _enfantService.getEnfantsByPatiente(patienteId);
      if (enfantsResponse.success && 
          enfantsResponse.data != null && 
          enfantsResponse.data!.isNotEmpty) {
        return 'postnatal';
      }

      // Aucun type de suivi déterminé
      return null;
    } catch (e) {
      print('❌ Erreur lors de la détermination du type de suivi: $e');
      return null;
    }
  }
}
