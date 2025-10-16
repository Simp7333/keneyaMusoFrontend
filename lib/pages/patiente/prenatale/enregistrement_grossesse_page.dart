import 'package:flutter/material.dart';
import '../../../routes.dart';
import '../../../widgets/page_animation_mixin.dart';

class EnregistrementGrossessePage extends StatefulWidget {
  const EnregistrementGrossessePage({super.key});

  @override
  State<EnregistrementGrossessePage> createState() =>
      _EnregistrementGrossessePageState();
}

class _EnregistrementGrossessePageState extends State<EnregistrementGrossessePage>
    with TickerProviderStateMixin, PageAnimationMixin {
  final _dateController = TextEditingController();

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
                                  BorderSide(color: Color(0xFFE91E63).withOpacity(0.63)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _handleRegister,
                            child: const Text(
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

  void _handleRegister() {
    if (_dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir une date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Simulation d'enregistrement réussi
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Grossesse enregistrée avec succès !'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigation vers le dashboard
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.patienteDashboard,
    );
  }
}
