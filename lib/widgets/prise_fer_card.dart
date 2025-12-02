import 'package:flutter/material.dart';
import 'package:keneya_muso/pages/common/app_colors.dart';
import 'package:keneya_muso/services/prise_fer_service.dart';
import 'package:keneya_muso/models/prise_fer_quotidienne.dart';
import 'package:intl/intl.dart';

/// Widget pour afficher la notification de prise de fer et les statistiques mensuelles
class PriseFerCard extends StatefulWidget {
  const PriseFerCard({super.key});

  @override
  State<PriseFerCard> createState() => _PriseFerCardState();
}

class _PriseFerCardState extends State<PriseFerCard> {
  final PriseFerService _service = PriseFerService();
  bool _isLoading = false;
  bool? _aReponduAujourdhui;
  bool? _reponseAujourdhui;
  StatistiquesPriseFer? _statistiques;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Vérifier si la patiente a déjà répondu aujourd'hui
      final aRepondu = await _service.aReponduAujourdhui();
      bool? reponse;
      if (aRepondu) {
        reponse = await _service.getReponseAujourdhui();
      }

      // Charger les statistiques du mois en cours
      final maintenant = DateTime.now();
      final statsResponse = await _service.getStatistiquesMois(
        annee: maintenant.year,
        mois: maintenant.month,
      );

      if (mounted) {
        setState(() {
          _aReponduAujourdhui = aRepondu;
          _reponseAujourdhui = reponse;
          if (statsResponse.success && statsResponse.data != null) {
            _statistiques = statsResponse.data;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _repondrePriseFer(bool prise) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _service.enregistrerPriseFer(prise: prise);

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(prise
                ? 'Prise de fer enregistrée ✓'
                : 'Réponse enregistrée'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Recharger les données
        await _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Erreur lors de l\'enregistrement'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getCircleColor() {
    if (_statistiques == null) return Colors.grey;
    
    if (_statistiques!.pourcentage >= 50) {
      return Colors.green;
    } else if (_statistiques!.pourcentage >= 20) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  IconData _getCircleIcon() {
    if (_statistiques == null) return Icons.info_outline;
    
    if (_statistiques!.pourcentage >= 50) {
      return Icons.check_circle;
    } else if (_statistiques!.pourcentage >= 20) {
      return Icons.warning_amber_rounded;
    } else {
      return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _aReponduAujourdhui == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            Row(
              children: [
                Icon(
                  Icons.medication_liquid,
                  color: AppColors.primaryPink,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Prise de fer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Notification quotidienne (si pas encore répondu)
            if (_aReponduAujourdhui == false) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Avez-vous pris vos fer aujourd\'hui ?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () => _repondrePriseFer(true),
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: const Text(
                              'Oui',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () => _repondrePriseFer(false),
                            icon: const Icon(Icons.close),
                            label: const Text('Non'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else if (_aReponduAujourdhui == true) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (_reponseAujourdhui == true
                          ? Colors.green
                          : Colors.orange)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _reponseAujourdhui == true
                          ? Icons.check_circle
                          : Icons.info_outline,
                      color: _reponseAujourdhui == true
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _reponseAujourdhui == true
                            ? 'Vous avez pris vos fer aujourd\'hui ✓'
                            : 'Vous n\'avez pas pris vos fer aujourd\'hui',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Statistiques mensuelles
            if (_statistiques != null) ...[
              Row(
                children: [
                  Text(
                    'Ce mois: ${_statistiques!.joursAvecPrise}/${_statistiques!.joursTotal} jours',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_statistiques!.pourcentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _getCircleColor(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Message d'encouragement
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getCircleColor(),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getCircleIcon(),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _statistiques!.message,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

