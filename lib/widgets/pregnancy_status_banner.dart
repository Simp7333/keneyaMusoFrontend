import 'package:flutter/material.dart';
import 'package:keneya_muso/pages/common/app_colors.dart';

class PregnancyStatusBanner extends StatelessWidget {
  final DateTime? dpa; // Date Prévue d'Accouchement
  final String? pregnancyStatus; // Ex: "6 mois 2 semaines de grossesse"

  const PregnancyStatusBanner({
    super.key,
    this.dpa,
    this.pregnancyStatus,
  });

  @override
  Widget build(BuildContext context) {
    String dpaText = dpa != null
        ? 'Votre accouchement est prévu autour du ${_formatDate(dpa!)}'
        : 'Date d\'accouchement non définie';
    String statusText = pregnancyStatus ?? 'Statut de grossesse non disponible';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryPink.withOpacity(0.71),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Text('🥳', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dpaText,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  statusText,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
