import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes.dart';
import '../../../widgets/page_animation_mixin.dart';
import '../../common/app_colors.dart';
import '../../../services/grossesse_service.dart';
import '../../../models/dto/grossesse_request.dart';
import '../../../utils/message_helper.dart';

class EnregistrementGrossessePage extends StatefulWidget {
  const EnregistrementGrossessePage({super.key});

  @override
  State<EnregistrementGrossessePage> createState() =>
      _EnregistrementGrossessePageState();
}

class _EnregistrementGrossessePageState extends State<EnregistrementGrossessePage>
    with TickerProviderStateMixin, PageAnimationMixin {
  final _dateController = TextEditingController();
  final GrossesseService _grossesseService = GrossesseService();
  bool _isLoading = false;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _dateController.dispose();
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
              'assets/images/test.jpg',
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.5,
              fit: BoxFit.cover,
            ),
          ),

          // Form Card
          Positioned(
            top: MediaQuery.of(context).size.height * 0.50,
            left: 0,
            right: 0,
            bottom: 0,
            child: SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        const Text(
                          'Enregistrer votre grossesse',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Description
                        const Text(
                          'Pouvez-vous nous indiquer la date de vos dernières règles ou le mois approximatif où votre grossesse a commencé ?\n(ou la date de votre dernière échographie si vous en avez une)',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Date Input Field
                        TextField(
                          controller: _dateController,
                          readOnly: true,
                          onTap: _selectDate,
                          decoration: InputDecoration(
                            hintText: 'MM/JJ/AAAA',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
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
                              borderSide:
                                  BorderSide(color: AppColors.primaryPink.withOpacity(0.63)),
                            ),
                            suffixIcon: Icon(
                              Icons.calendar_today,
                              color: AppColors.primaryPink.withOpacity(0.63),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryPink.withOpacity(0.63),
                              foregroundColor: Colors.white,
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
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryPink.withOpacity(0.63),
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

  Future<void> _handleRegister() async {
    if (_dateController.text.isEmpty || _selectedDate == null) {
      await MessageHelper.showError(
        context: context,
        message: 'Veuillez saisir une date',
        title: 'Champ requis',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Récupérer l'ID de la patiente depuis SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        if (!mounted) return;
        await MessageHelper.showError(
          context: context,
          message: 'Utilisateur non identifié',
          title: 'Erreur',
        );
        setState(() => _isLoading = false);
        return;
      }

      // Formater la date au format YYYY-MM-DD
      final formattedDate =
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

      // Créer la requête
      final request = GrossesseRequest(
        dateDernieresMenstruations: formattedDate,
        patienteId: userId,
      );

      // Appeler l'API
      final response = await _grossesseService.createGrossesse(request);

      if (!mounted) return;

      if (response.success) {
        // Sauvegarder l'ID de la grossesse si nécessaire
        if (response.data != null && response.data['id'] != null) {
          await prefs.setInt('current_grossesse_id', response.data['id']);
        }

        await MessageHelper.showSuccess(
          context: context,
          message: 'Grossesse enregistrée avec succès ! Les consultations prénatales ont été créées automatiquement.',
          title: 'Succès',
          onPressed: () {
            // Navigation vers le dashboard prénatal
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.patienteDashboard,
            );
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
