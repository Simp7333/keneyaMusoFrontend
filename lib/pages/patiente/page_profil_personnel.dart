import 'package:flutter/material.dart';
import '../../routes.dart';

class PageProfilPersonnel extends StatelessWidget {
  final String name;
  final String title;
  final String location;
  final String imageUrl; // Add imageUrl

  const PageProfilPersonnel({
    super.key,
    required this.name,
    required this.title,
    required this.location,
    required this.imageUrl, // Add imageUrl
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              width: double.infinity,
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: 40,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.5),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Details Card
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Name
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Title and experience
                    Text(
                      'Gynécologue obstétricienne | 12 ans d\'expérience',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Detailed Info
                    _buildInfoRow('Etude:', 'Diplômée de la Faculté de Médecine de Bamako'),
                    _buildInfoRow('Spécialité:', 'Suivi prénatal, accouchement, santé maternelle'),
                    _buildInfoRow('Heure-visites:', 'Lundi-Vendredi : 9h à 17h'),
                    _buildInfoRow('Centre de santé:', 'CSCOM de N\'Golobougou'),
                    _buildInfoRow('Contacte:', '77 00 11 22 | mana.diawara@cscom.ml'),
                    _buildInfoRow('Adresse:', 'N\'Golobougou'),
                    _buildInfoRow('Suivis:', '128'),

                    const SizedBox(height: 32),

                    // Action Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.patienteContactForm,
                              arguments: {'sageFemmeName': name},
                            );
                          },
                          icon: const Icon(Icons.message),
                          label: const Text('Contacter'),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
