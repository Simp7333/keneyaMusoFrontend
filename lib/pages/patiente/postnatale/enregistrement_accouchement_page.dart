import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes.dart';
import '../../common/app_colors.dart';
import '../../../services/enfant_service.dart';
import '../../../services/consultation_service.dart';
import '../../../models/dto/enfant_request.dart';

class EnregistrementAccouchementPage extends StatefulWidget {
  const EnregistrementAccouchementPage({super.key});

  @override
  State<EnregistrementAccouchementPage> createState() =>
      _EnregistrementAccouchementPageState();
}

class _EnregistrementAccouchementPageState
    extends State<EnregistrementAccouchementPage> {
  final TextEditingController _dateController = TextEditingController();
  final EnfantService _enfantService = EnfantService();
  final ConsultationService _consultationService = ConsultationService();
  String? _selectedDeliveryMode;
  String? _selectedSexe;
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
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
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF1F4),
              ),
              child: Image.asset(
                'assets/images/postnat.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Form Card
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: 0,
            right: 0,
            bottom: 0,
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
                padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with Speaker Icon
                    Row(
                      children: [
                        const Text(
                          'Dite nous ?',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.25),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.volume_up,
                            color: AppColors.primaryColor,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Date Question
                    const Text(
                      'Quand avez-vous accouché ?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Date Input Field
                    TextField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      decoration: InputDecoration(
                        hintText: 'MM/JJ/AAAA',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 16,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primaryColor.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primaryColor.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primaryColor,
                            width: 2,
                          ),
                        ),
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: AppColors.primaryColor,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Delivery Mode Question
                    const Text(
                      'Quel a été le mode de votre accouchement?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Radio Buttons
                    _buildRadioOption('Normal', isDeliveryMode: true),
                    const SizedBox(height: 12),
                    _buildRadioOption('Césarienne', isDeliveryMode: true),
                    const SizedBox(height: 32),

                    // Sexe de l'enfant
                    const Text(
                      'Sexe de l\'enfant',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRadioOption('Garçon', isDeliveryMode: false),
                    const SizedBox(height: 12),
                    _buildRadioOption('Fille', isDeliveryMode: false),
                    const SizedBox(height: 48),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSave,
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
                                'Enregistrer',
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
        ],
      ),
    );
  }

  Widget _buildRadioOption(String value, {required bool isDeliveryMode}) {
    final bool isSelected = isDeliveryMode
        ? _selectedDeliveryMode == value
        : _selectedSexe == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isDeliveryMode) {
            _selectedDeliveryMode = value;
          } else {
            _selectedSexe = value;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.black87 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    // Validation - uniquement date, mode d'accouchement et sexe
    if (_dateController.text.isEmpty ||
        _selectedDate == null ||
        _selectedDeliveryMode == null ||
        _selectedSexe == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez remplir tous les champs'),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Récupérer l'ID de la patiente depuis SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      final prenom = prefs.getString('user_prenom') ?? 'Bébé';

      if (userId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur: Utilisateur non identifié'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Formater la date au format YYYY-MM-DD
      final formattedDate =
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

      // Convertir le sexe au format attendu par le backend (GARCON ou FILLE)
      String sexeBackend = _selectedSexe == 'Garçon' ? 'GARCON' : 'FILLE';
      
      // Générer un nom temporaire basé sur le sexe et la date
      String nomTemporaire = _selectedSexe == 'Garçon' ? 'Garçon' : 'Fille';
      String prenomTemporaire = 'de $prenom';

      // Créer la requête avec des valeurs par défaut pour nom et prénom
      final request = EnfantRequest(
        nom: nomTemporaire,
        prenom: prenomTemporaire,
        dateDeNaissance: formattedDate,
        sexe: sexeBackend,
        patienteId: userId,
      );

      // Appeler l'API
      final response = await _enfantService.createEnfant(request);

      if (!mounted) return;

      if (response.success) {
        // Sauvegarder les informations localement
        await prefs.setString('dateAccouchement', _dateController.text);
        await prefs.setString('modeAccouchement', _selectedDeliveryMode!);
        
        if (response.data != null && response.data['id'] != null) {
          await prefs.setInt('current_enfant_id', response.data['id']);
        }

        // Générer automatiquement les 3 CPoN (J+3, J+7, 6e semaine)
        print('🔄 Création des CPoN automatiques...');
        final cponResponse = await _consultationService.declarerCpon(
          patienteId: userId,
          dateAccouchement: formattedDate,
        );

        if (cponResponse.success && cponResponse.data != null) {
          print('✅ ${cponResponse.data!.length} CPoN créées automatiquement');
        } else {
          print('⚠️ Erreur création CPoN: ${cponResponse.message}');
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Accouchement enregistré avec succès ! Vos consultations postnatales ont été programmées.'),
            backgroundColor: Colors.green.shade400,
            duration: const Duration(seconds: 4),
          ),
        );

        // Redirection vers le dashboard postnatal
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.patienteDashboardPostnatal,
        );
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
}

