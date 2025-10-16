import 'package:flutter/material.dart';

class PregnancyStatusBanner extends StatelessWidget {
  const PregnancyStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE91E63).withOpacity(0.63),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: const [
          Text('🎉', style: TextStyle(fontSize: 20)),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Votre accouchement est prévu autour du 22 Mars 2026',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Vous êtes actuellement à 6 mois de grossesse',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
