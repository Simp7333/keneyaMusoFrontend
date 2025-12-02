import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../common/app_colors.dart';
import '../../services/auth_service.dart';
import '../../models/dto/register_request.dart';
import '../../models/enums/role_utilisateur.dart';
import '../../models/enums/specialite.dart';
import '../../routes.dart';
import '../../utils/message_helper.dart';

class PageInscriptionPro extends StatefulWidget {
  const PageInscriptionPro({super.key});

  @override
  State<PageInscriptionPro> createState() => _PageInscriptionProState();
}

class _PageInscriptionProState extends State<PageInscriptionPro> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _healthCenterController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  Specialite? _selectedSpecialite;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _healthCenterController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              'assets/images/inscr.png', 
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.4,
              fit: BoxFit.cover,
            ),
            Transform.translate(
              offset: const Offset(0, -40),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'S\'inscrire',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildInputField(controller: _nameController, hintText: 'Nom et Prénom'),
                    const SizedBox(height: 20),
                    _buildInputField(controller: _phoneController, hintText: 'Numéro Téléphone', keyboardType: TextInputType.phone),
                    const SizedBox(height: 20),
                    _buildSpecialiteDropdown(),
                    const SizedBox(height: 20),
                    _buildInputField(controller: _healthCenterController, hintText: 'Centre de santé'),
                    const SizedBox(height: 20),
                    _buildInputField(controller: _passwordController, hintText: 'Mot de passe', isPassword: true),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 2,
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
                            : const Text(
                                'S\'inscrire',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                     const SizedBox(height: 16),
                      RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                            children: [
                              const TextSpan(text: 'Déjà un compte? '),
                              TextSpan(
                                text: 'Se connecter',
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pop(context);
                                  },
                              ),
                            ],
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
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

  Widget _buildSpecialiteDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<Specialite>(
        value: _selectedSpecialite,
        decoration: InputDecoration(
          hintText: 'Sélectionner une spécialité',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryColor),
          ),
        ),
        items: Specialite.values.map((specialite) {
          return DropdownMenuItem<Specialite>(
            value: specialite,
            child: Text(specialite.displayName),
          );
        }).toList(),
        onChanged: (Specialite? value) {
          setState(() {
            _selectedSpecialite = value;
          });
        },
      ),
    );
  }

  void _handleRegister() async {
    if (_nameController.text.isEmpty || 
        _phoneController.text.isEmpty || 
        _healthCenterController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _selectedSpecialite == null) {
      await MessageHelper.showError(
        context: context,
        message: 'Veuillez remplir tous les champs, y compris la spécialité',
        title: 'Champs requis',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Séparer nom et prénom
      final nameParts = _nameController.text.trim().split(' ');
      final nom = nameParts.isNotEmpty ? nameParts[0] : '';
      final prenom = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      // Créer la requête d'inscription
      final registerRequest = RegisterRequest(
        nom: nom,
        prenom: prenom.isNotEmpty ? prenom : nom,
        telephone: _phoneController.text.trim(),
        motDePasse: _passwordController.text,
        role: RoleUtilisateur.MEDECIN,
        specialite: _selectedSpecialite!, // Spécialité sélectionnée
        identifiantProfessionnel: _healthCenterController.text.trim(),
      );

      final response = await _authService.register(registerRequest);

      if (!mounted) return;

      if (response.success && response.data != null) {
        await MessageHelper.showSuccess(
          context: context,
          message: 'Inscription réussie ! Bienvenue Dr. ${response.data!.nom}',
          title: 'Inscription réussie',
          onPressed: () {
            // Redirection vers le dashboard professionnel
            Navigator.pushReplacementNamed(context, AppRoutes.proDashboard);
          },
        );
      } else {
        await MessageHelper.showApiResponse(
          context: context,
          response: response,
          errorTitle: 'Erreur',
        );
      }
    } catch (e) {
      if (!mounted) return;
      await MessageHelper.showError(
        context: context,
        message: 'Erreur: $e',
        title: 'Erreur',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}










