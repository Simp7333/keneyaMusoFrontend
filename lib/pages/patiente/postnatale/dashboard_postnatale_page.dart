import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:keneya_muso/widgets/bottom_nav_bar.dart';
import 'package:keneya_muso/widgets/calendar_postnatale.dart';
import 'package:keneya_muso/widgets/task_card.dart';
import 'package:keneya_muso/widgets/confirmation_rappel_dialog.dart';
import 'package:keneya_muso/widgets/creer_rappel_dialog.dart';
import 'package:keneya_muso/routes.dart';
import 'package:keneya_muso/widgets/suivi_options_panel.dart';
import 'package:keneya_muso/services/consultation_service.dart';
import 'package:keneya_muso/services/vaccination_service.dart';
import 'package:keneya_muso/services/dashboard_service.dart';
import 'package:keneya_muso/services/enfant_service.dart';
import 'package:keneya_muso/models/consultation_postnatale.dart';
import 'package:keneya_muso/models/vaccination.dart';
import 'package:keneya_muso/models/rappel.dart';

class DashboardPostnatalePage extends StatefulWidget {
  const DashboardPostnatalePage({super.key});

  @override
  State<DashboardPostnatalePage> createState() => _DashboardPostnatalePageState();
}

class _DashboardPostnatalePageState extends State<DashboardPostnatalePage> {
  int _selectedIndex = 0;
  
  // Services
  final ConsultationService _consultationService = ConsultationService();
  final VaccinationService _vaccinationService = VaccinationService();
  final DashboardService _dashboardService = DashboardService();
  final EnfantService _enfantService = EnfantService();
  
  // Données pour le calendrier
  List<ConsultationPostnatale> _consultations = [];
  List<Vaccination> _vaccinations = [];
  List<Rappel> _rappels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  /// Charge toutes les données pour le dashboard postnatale
  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final patienteId = prefs.getInt('user_id');
      
      if (patienteId == null) {
        print('❌ Patiente ID non trouvé');
        setState(() => _isLoading = false);
        return;
      }
      
      // Charger les consultations et rappels en parallèle
      final results = await Future.wait([
        _consultationService.getConsultationsPostnatalesByPatiente(patienteId),
        _dashboardService.getMyRappels(),
      ]);
      
      // Charger les vaccinations séparément
      await _loadVaccinationsForPatiente(patienteId);
      
      setState(() {
        // Consultations postnatales
        if (results[0].success && results[0].data != null) {
          _consultations = List<ConsultationPostnatale>.from(results[0].data!);
          print('✅ ${_consultations.length} CPoN chargées');
        }
        
        // Rappels (pour prises de médicaments)
        if (results[1].success && results[1].data != null) {
          _rappels = List<Rappel>.from(results[1].data!);
          print('✅ ${_rappels.length} rappels chargés');
        }
        
        // Vaccinations (chargées via méthode séparée)
        print('✅ ${_vaccinations.length} vaccinations chargées');
        
        _isLoading = false;
      });

      // Vérifier s'il y a des notifications CPON non lues à J-1 et afficher le dialogue
      if (mounted) {
        _checkAndShowConfirmationDialog();
      }
    } catch (e) {
      print('❌ Erreur chargement dashboard: $e');
      setState(() => _isLoading = false);
    }
  }
  
  /// Charge les vaccinations de tous les enfants de la patiente
  Future<void> _loadVaccinationsForPatiente(int patienteId) async {
    try {
      // Récupérer les enfants de la patiente
      final enfantsResponse = await _enfantService.getEnfantsByPatiente(patienteId);
      
      if (enfantsResponse.success && enfantsResponse.data != null) {
        final enfants = enfantsResponse.data!;
        print('✅ ${enfants.length} enfant(s) trouvé(s)');
        
        // Charger les vaccinations de chaque enfant
        List<Vaccination> allVaccinations = [];
        for (var enfant in enfants) {
          final vaccinationsResponse = await _vaccinationService.getVaccinationsByEnfant(enfant.id);
          
          if (vaccinationsResponse.success && vaccinationsResponse.data != null) {
            allVaccinations.addAll(vaccinationsResponse.data!);
          }
        }
        
        _vaccinations = allVaccinations;
      }
    } catch (e) {
      print('❌ Erreur chargement vaccinations: $e');
    }
  }

  /// Vérifie s'il y a des rappels CPON non lus et affiche le dialogue de confirmation
  void _checkAndShowConfirmationDialog() {
    // Chercher les rappels CPON non lus
    final rappelsCPONNonLus = _rappels
        .where((r) => r.isRappelCPON && r.isNonLue)
        .toList();

    if (rappelsCPONNonLus.isNotEmpty) {
      // Afficher le dialogue pour le premier rappel CPON non lu
      final premierRappel = rappelsCPONNonLus.first;
      
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
                _loadDashboardData();
              },
              onReprogrammed: () {
                // Recharger les données après reprogrammation
                _loadDashboardData();
              },
            ),
          );
        }
      });
    }
  }

  /// Affiche le dialogue pour créer un rappel manuel
  void _showCreerRappelDialog() {
    showDialog(
      context: context,
      builder: (context) => CreerRappelDialog(
        onRappelCreated: () {
          // Recharger les données après création du rappel
          _loadDashboardData();
        },
      ),
    );
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

  void _showSuiviOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SuiviOptionsPanel(),
    );
  }

  /// Construit la liste des événements à venir (uniquement le 1er de chaque catégorie)
  Widget _buildUpcomingEvents() {
    List<Widget> eventCards = [];
    
    // Ajouter uniquement la 1ère CPoN à venir
    final cponAVenir = _consultations
        .where((c) => c.isAVenir)
        .take(1) // Prendre uniquement la première
        .toList();
    
    for (var cpon in cponAVenir) {
      try {
        final date = DateTime.parse(cpon.datePrevue);
        final dateFormatted = '${_getDayName(date.weekday)} ${date.day} ${_getMonthName(date.month)} ${date.year} à 8h00';
        
        eventCards.add(
          TaskCard(
            icon: Icons.medical_services_outlined,
            iconColor: Colors.orange,
            title: cpon.typeLabel,
            subtitle: dateFormatted,
          ),
        );
        eventCards.add(const SizedBox(height: 16));
      } catch (e) {
        print('❌ Erreur affichage CPoN: $e');
      }
    }
    
    // Ajouter uniquement la 1ère vaccination à faire
    final vaccinationsAFaire = _vaccinations
        .where((v) => v.isAFaire)
        .take(1) // Prendre uniquement la première
        .toList();
    
    for (var vaccination in vaccinationsAFaire) {
      try {
        eventCards.add(
          TaskCard(
            icon: Icons.medication_outlined,
            iconColor: Colors.green,
            title: 'Prise de medicament',
            subtitle: 'C\'est l\'heure de donner le sirop a votre enfant',
          ),
        );
        eventCards.add(const SizedBox(height: 16));
      } catch (e) {
        print('❌ Erreur affichage vaccination: $e');
      }
    }
    
    // Ajouter uniquement le 1er rappel de médicament non lu
    final rappelsMedicaments = _rappels
        .where((r) => r.isNonLue)
        .take(1) // Prendre uniquement le premier
        .toList();
    
    for (var rappel in rappelsMedicaments) {
      try {
        final date = DateTime.parse(rappel.displayDate);
        final dateFormatted = '${_getDayName(date.weekday)} ${date.day} ${_getMonthName(date.month)} ${date.year} à 10h00';
        
        eventCards.add(
          TaskCard(
            icon: Icons.content_paste,
            iconColor: Colors.pink,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/images/logo/logoknya.png', // Utilisation du logo
          height: 40,
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.black, size: 28),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.patienteNotifications);
                },
              ),
              Positioned( // Point vert de notification
                right: 11,
                top: 11,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black, size: 28),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.patienteProfile);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Contenu principal
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadDashboardData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 16),
                        
                        // Calendrier dynamique avec données du backend
                        CalendarPostnatale(
                          consultations: _consultations,
                          vaccinations: _vaccinations,
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
                        if (_consultations.isNotEmpty || _vaccinations.isNotEmpty || _rappels.isNotEmpty)
                          _buildUpcomingEvents(),
                        
                        const SizedBox(height: 200), // Space for floating buttons
                      ],
                    ),
                  ),
                ),
          
          // Boutons flottants positionnés manuellement
          Positioned(
            bottom: 100, // Au-dessus de la barre de navigation (environ 80px) + marge
            right: 16,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Bouton Audio (en haut)
                FloatingActionButton(
                  heroTag: "audio",
                  onPressed: () => print('Action Audio'), // TODO: Implémenter l'action audio
                  backgroundColor: Colors.white,
                  elevation: 4,
                  child: const Icon(Icons.volume_up, color: Colors.blueAccent, size: 28),
                ),
                const SizedBox(height: 16),
                // Bouton Livre (au milieu)
                FloatingActionButton(
                  heroTag: "livre",
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.patienteDossierPost);
                  },
                  backgroundColor: Colors.white,
                  elevation: 4,
                  child: const Icon(Icons.book_outlined, color: Colors.purpleAccent, size: 28),
                ),
                const SizedBox(height: 16),
                // Bouton Bébé
                FloatingActionButton(
                  heroTag: "bebe",
                  onPressed: () => print('Action Bébé'), // TODO: Implémenter l'action bébé
                  backgroundColor: Colors.white,
                  elevation: 4,
                  child: const Icon(Icons.child_friendly, color: Colors.pinkAccent, size: 28),
                ),
                const SizedBox(height: 16),
                // Bouton principal Add (en bas)
                FloatingActionButton(
                  heroTag: "add",
                  onPressed: () {
                    _showCreerRappelDialog();
                  },
                  backgroundColor: Colors.red,
                  elevation: 6,
                  child: const Icon(Icons.add, color: Colors.white, size: 32),
                ),
              ],
            ),
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



