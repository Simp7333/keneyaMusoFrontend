import 'package:flutter/material.dart';
import 'package:keneya_muso/widgets/bottom_nav_bar.dart';
import 'package:keneya_muso/widgets/custom_calendar.dart';
import 'package:keneya_muso/widgets/pregnancy_status_banner.dart';
import 'package:keneya_muso/widgets/task_card.dart';
import 'package:keneya_muso/routes.dart';
import 'package:keneya_muso/widgets/ajouter_rappel_modal.dart';
import 'package:keneya_muso/widgets/confirmation_rappel_dialog.dart';
import 'package:keneya_muso/pages/common/app_colors.dart';
import 'package:keneya_muso/services/dashboard_service.dart';
import 'package:keneya_muso/services/grossesse_service.dart';
import 'package:keneya_muso/services/consultation_service.dart';
import 'package:keneya_muso/models/rappel.dart';
import 'package:keneya_muso/models/grossesse.dart';
import 'package:keneya_muso/models/consultation_prenatale.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageTableauBord extends StatefulWidget {
  const PageTableauBord({super.key});

  @override
  State<PageTableauBord> createState() => _PageTableauBordState();
}

class _PageTableauBordState extends State<PageTableauBord> {
  int _selectedIndex = 0;
  String _suiviType = 'prenatal';
  final DashboardService _dashboardService = DashboardService();
  final GrossesseService _grossesseService = GrossesseService();
  final ConsultationService _consultationService = ConsultationService();
  List<Rappel> _rappels = [];
  List<ConsultationPrenatale> _consultations = [];
  Grossesse? _grossesseActive;
  bool _isLoading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSuiviType();
    // Charger les données immédiatement
    _loadData();
    // Recharger après un court délai pour s'assurer que les CPN créées automatiquement sont bien récupérées
    // Cela garantit que les CPN générées par le backend après l'enregistrement de la grossesse sont affichées
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _loadData();
      }
    });
  }

  Future<void> _loadSuiviType() async {
    final prefs = await SharedPreferences.getInstance();
    final suiviType = prefs.getString('suiviType') ?? 'prenatal';
    setState(() {
      _suiviType = suiviType;
    });
    
    // Si le type de suivi est postnatal, rediriger vers le dashboard postnatal
    if (suiviType == 'postnatal' && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.patienteDashboardPostnatal);
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      
      if (userId == null) {
        print('❌ Patiente ID non trouvé');
        setState(() => _isLoading = false);
        return;
      }
      
      // Charger les consultations prénatales et rappels en parallèle
      final results = await Future.wait([
        _consultationService.getConsultationsPrenatalesByPatiente(userId),
        _dashboardService.getMyRappels(),
        _grossesseService.getCurrentGrossesseByPatiente(userId),
      ]);
      
      // Charger le nombre de notifications non lues séparément
      final unreadCount = await _dashboardService.getUnreadNotificationsCount();

      if (mounted) {
        setState(() {
          // Consultations prénatales
          print('🔍 Résultat CPN - success: ${results[0].success}, data: ${results[0].data}');
          if (results[0].success && results[0].data != null) {
            _consultations = List<ConsultationPrenatale>.from(results[0].data! as List<dynamic>);
            print('✅ ${_consultations.length} CPN chargées');
            // Afficher les détails de chaque CPN pour déboguer
            for (var cpn in _consultations) {
              print('   📅 CPN: ${cpn.notes ?? "Sans notes"} - Date: ${cpn.datePrevue} - Statut: ${cpn.statut}');
            }
          } else {
            print('⚠️ Aucune CPN trouvée ou erreur: ${results[0].message}');
            _consultations = [];
          }
          
          // Rappels
          print('🔍 Résultat Rappels - success: ${results[1].success}, data: ${results[1].data}');
          if (results[1].success && results[1].data != null) {
            _rappels = List<Rappel>.from(results[1].data! as List<dynamic>);
            print('✅ ${_rappels.length} rappels chargés');
          } else {
            print('⚠️ Aucun rappel trouvé ou erreur: ${results[1].message}');
            _rappels = [];
          }
          
          // Grossesse active
          if (results[2].success && results[2].data != null) {
            _grossesseActive = results[2].data as Grossesse;
          }
          
          // Nombre de notifications non lues
          _unreadCount = unreadCount;
          
          _isLoading = false;
        });
      }

      // Vérifier s'il y a des notifications CPN non lues à J-1 et afficher le dialogue
      if (mounted) {
        _checkAndShowConfirmationDialog();
      }
    } catch (e) {
      print('❌ Erreur chargement dashboard: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Vérifie s'il y a des rappels CPN non lus et affiche le dialogue de confirmation
  void _checkAndShowConfirmationDialog() {
    // Chercher les rappels CPN non lus
    final rappelsCPNNonLus = _rappels
        .where((r) => r.isRappelCPN && r.isNonLue)
        .toList();

    if (rappelsCPNNonLus.isNotEmpty) {
      // Afficher le dialogue pour le premier rappel CPN non lu
      final premierRappel = rappelsCPNNonLus.first;
      
      // Attendre un peu pour que l'UI soit prête
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => ConfirmationRappelDialog(
              rappel: premierRappel,
              onConfirmed: () {
                // Recharger les données après confirmation
                _loadData();
              },
              onReprogrammed: () {
                // Recharger les données après reprogrammation
                _loadData();
              },
            ),
          );
        }
      });
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    switch (index) {
      case 0:
      // Already on this page, do nothing or refresh
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.patienteContent);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.patientePersonnel);
        break;
      case 3:
        Navigator.pushNamed(
          context,
          AppRoutes.proSettings,
          arguments: {'isPatiente': true},
        );
        break;
    }
  }

  void _showAjouterRappel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AjouterRappelModal(),
    );
  }

  /// Construit la liste des événements à venir (uniquement le 1er de chaque catégorie)
  Widget _buildUpcomingEvents() {
    List<Widget> eventCards = [];
    
    // Ajouter uniquement la 1ère CPN à venir
    final cpnAVenir = _consultations
        .where((c) => c.isAVenir)
        .take(1) // Prendre uniquement la première
        .toList();
    
    for (var cpn in cpnAVenir) {
      try {
        final date = DateTime.parse(cpn.datePrevue);
        final dateFormatted = '${_getDayName(date.weekday)} ${date.day} ${_getMonthName(date.month)} ${date.year} à 8h00';
        
        eventCards.add(
          TaskCard(
            icon: Icons.medical_services_outlined,
            iconColor: Colors.orange,
            title: 'Consultation prénatale (CPN)',
            subtitle: dateFormatted,
          ),
        );
        eventCards.add(const SizedBox(height: 16));
      } catch (e) {
        print('❌ Erreur affichage CPN: $e');
      }
    }
    
    // Ajouter uniquement le 1er rappel non lu (tous types: vaccination, médicament, conseil, autre)
    final rappelsNonLus = _rappels
        .where((r) => r.isNonLue)
        .take(1) // Prendre uniquement le premier
        .toList();
    
    for (var rappel in rappelsNonLus) {
      try {
        final date = DateTime.parse(rappel.displayDate);
        final dateFormatted = '${_getDayName(date.weekday)} ${date.day} ${_getMonthName(date.month)} ${date.year} à 10h00';
        
        eventCards.add(
          TaskCard(
            icon: _getRappelIcon(rappel.type),
            iconColor: _getRappelColor(rappel.type),
            title: rappel.titre,
            subtitle: dateFormatted,
          ),
        );
        eventCards.add(const SizedBox(height: 16));
      } catch (e) {
        print('❌ Erreur affichage rappel: $e');
      }
    }
    
    return Column(children: eventCards);
  }
  
  /// Retourne le nom du jour en français
  String _getDayName(int weekday) {
    const days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return days[weekday - 1];
  }
  
  /// Retourne le nom du mois en français
  String _getMonthName(int month) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return months[month - 1];
  }

  String _formatRappelDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      
      // Formatage manuel sans locale
      final dayNames = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
      final monthNames = [
        'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
        'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
      ];
      
      final dayName = dayNames[date.weekday - 1];
      final monthName = monthNames[date.month - 1];
      
      return '$dayName ${date.day} $monthName ${date.year} a ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  IconData _getRappelIcon(String type) {
    switch (type) {
      case 'RAPPEL_CONSULTATION':
        return Icons.medical_services_outlined;
      case 'RAPPEL_VACCINATION':
        return Icons.medication_outlined;
      case 'CONSEIL':
        return Icons.lightbulb_outline;
      case 'AUTRE':
        return Icons.event_note;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getRappelColor(String type) {
    switch (type) {
      case 'RAPPEL_CONSULTATION':
        return Colors.blue;
      case 'RAPPEL_VACCINATION':
        return Colors.red;
      case 'CONSEIL':
        return Colors.orange;
      case 'AUTRE':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _calculatePregnancyStatus() {
    if (_grossesseActive == null || _grossesseActive!.dateDebut == null) {
      return 'Statut de grossesse non disponible';
    }

    try {
      final dateDebut = DateTime.parse(_grossesseActive!.dateDebut!);
      final now = DateTime.now();
      final difference = now.difference(dateDebut);
      final weeks = difference.inDays ~/ 7;
      final months = weeks ~/ 4;
      final remainingWeeks = weeks % 4;

      if (months == 0) {
        return '$weeks semaine${weeks > 1 ? 's' : ''} de grossesse';
      } else if (remainingWeeks == 0) {
        return '$months mois de grossesse';
      } else {
        return '$months mois $remainingWeeks semaine${remainingWeeks > 1 ? 's' : ''} de grossesse';
      }
    } catch (e) {
      return 'Statut de grossesse non disponible';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset('assets/images/logo/logoknya.png', height: 40),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.black),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.patienteNotifications);
                },
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 11,
                  top: 11,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      _unreadCount > 9 ? '9+' : '$_unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.patienteProfile);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 16),
                    PregnancyStatusBanner(
                      dpa: _grossesseActive?.datePrevueAccouchement != null
                          ? DateTime.parse(_grossesseActive!.datePrevueAccouchement!)
                          : null,
                      pregnancyStatus: _calculatePregnancyStatus(),
                    ),
                    const SizedBox(height: 24),
                    // Calendrier dynamique avec données du backend
                    CustomCalendar(
                      consultations: _consultations,
                      rappels: _rappels,
                    ),
                    const SizedBox(height: 24),
                    
                    // Titre "Tâches et rappels"
                    const Text(
                      'Tâches et rappels',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Afficher les prochains événements
                    if (_consultations.isNotEmpty || _rappels.isNotEmpty)
                      _buildUpcomingEvents()
                    else
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'Aucun rappel en attente',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 100), // Space for FAB
                  ],
                ),
              ),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'fab_volume',
            onPressed: () {
              // TODO: Implémenter la lecture vocale
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité de lecture vocale à venir'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            backgroundColor: AppColors.primaryPink.withOpacity(0.1),
            child: const Icon(Icons.volume_up, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'fab_book',
            onPressed: () {
              // Navigation vers le dossier CPN
              Navigator.pushNamed(context, AppRoutes.patienteDossierCpn);
            },
            backgroundColor: AppColors.primaryPink.withOpacity(0.3),
            child: const Icon(Icons.book_outlined, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'fab_add',
            onPressed: () {
              _showAjouterRappel(context);
            },
            backgroundColor: AppColors.primaryPink,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}





