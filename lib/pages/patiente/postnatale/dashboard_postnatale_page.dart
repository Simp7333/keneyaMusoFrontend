import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:keneya_muso/widgets/bottom_nav_bar.dart';
import 'package:keneya_muso/widgets/calendar_postnatale.dart';
import 'package:keneya_muso/widgets/task_card.dart';
import 'package:keneya_muso/widgets/confirmation_rappel_dialog.dart';
import 'package:keneya_muso/widgets/confirmation_date_depassee_dialog.dart';
import 'package:keneya_muso/widgets/creer_rappel_dialog.dart';
import 'package:keneya_muso/routes.dart';
import 'package:keneya_muso/widgets/suivi_options_panel.dart';
import 'package:keneya_muso/services/consultation_service.dart';
import 'package:keneya_muso/services/vaccination_service.dart';
import 'package:keneya_muso/services/dashboard_service.dart';
import 'package:keneya_muso/services/enfant_service.dart';
import 'package:keneya_muso/services/dossier_medical_service.dart';
import 'package:keneya_muso/services/conseil_predefini_service.dart';
import 'package:keneya_muso/models/consultation_postnatale.dart';
import 'package:keneya_muso/models/vaccination.dart';
import 'package:keneya_muso/models/rappel.dart';
import 'package:keneya_muso/models/enfant_brief.dart';
import 'package:keneya_muso/pages/common/app_colors.dart';

class DashboardPostnatalePage extends StatefulWidget {
  const DashboardPostnatalePage({super.key});

  @override
  State<DashboardPostnatalePage> createState() => _DashboardPostnatalePageState();
}

class _DashboardPostnatalePageState extends State<DashboardPostnatalePage> {
  int _selectedIndex = 0;
  String _suiviType = 'postnatal';
  
  // Services
  final ConsultationService _consultationService = ConsultationService();
  final VaccinationService _vaccinationService = VaccinationService();
  final DashboardService _dashboardService = DashboardService();
  final EnfantService _enfantService = EnfantService();
  final DossierMedicalService _dossierService = DossierMedicalService();
  
  // Données pour le calendrier
  List<ConsultationPostnatale> _consultations = [];
  List<Vaccination> _vaccinations = [];
  List<Rappel> _rappels = [];
  bool _isLoading = true;
  
  // Données pour les conseils
  String? _typeAccouchement;
  List<EnfantBrief> _enfants = [];

  @override
  void initState() {
    super.initState();
    _loadSuiviType();
    _loadDashboardData();
  }

  Future<void> _loadSuiviType() async {
    final prefs = await SharedPreferences.getInstance();
    final suiviType = prefs.getString('suiviType') ?? 'postnatal';
    setState(() {
      _suiviType = suiviType;
    });
    
    // Si le type de suivi est prénatal, rediriger vers le dashboard prénatal
    if (suiviType == 'prenatal' && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.patienteDashboard);
    }
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
      
      // Charger les vaccinations séparément (cela charge aussi les enfants)
      await _loadVaccinationsForPatiente(patienteId);
      
      // Charger le type d'accouchement
      await _loadTypeAccouchement(patienteId);
      
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
        // Vérifier les dates dépassées
        _checkAndShowDateDepasseeDialog();
      }
    } catch (e) {
      print('❌ Erreur chargement dashboard: $e');
      setState(() => _isLoading = false);
    }
  }
  
  /// Charge les vaccinations de tous les enfants de la patiente
  Future<void> _loadVaccinationsForPatiente(int patienteId) async {
    try {
      print('🔍 Chargement enfants et vaccinations pour patienteId: $patienteId');
      // Récupérer les enfants de la patiente
      final enfantsResponse = await _enfantService.getEnfantsByPatiente(patienteId);
      
      if (enfantsResponse.success && enfantsResponse.data != null) {
        final enfants = enfantsResponse.data!;
        print('✅ ${enfants.length} enfant(s) trouvé(s)');
        
        // Stocker les enfants pour les conseils
        setState(() {
          _enfants = enfants;
        });
        
        if (enfants.isEmpty) {
          print('⚠️ Aucun enfant trouvé pour cette patiente');
          _vaccinations = [];
          return;
        }
        
        // Charger les vaccinations de chaque enfant
        List<Vaccination> allVaccinations = [];
        for (var enfant in enfants) {
          print('🔍 Chargement vaccinations pour enfant: ${enfant.nomComplet} (ID: ${enfant.id})');
          final vaccinationsResponse = await _vaccinationService.getVaccinationsByEnfant(enfant.id);
          
          if (vaccinationsResponse.success && vaccinationsResponse.data != null) {
            final vaccs = vaccinationsResponse.data!;
            print('✅ ${vaccs.length} vaccination(s) trouvée(s) pour ${enfant.nomComplet}');
            allVaccinations.addAll(vaccs);
          } else {
            print('⚠️ Aucune vaccination trouvée pour ${enfant.nomComplet}: ${vaccinationsResponse.message}');
          }
        }
        
        setState(() {
          _vaccinations = allVaccinations;
        });
        print('✅ Total: ${_vaccinations.length} vaccination(s) chargée(s) pour tous les enfants');
      } else {
        print('❌ Erreur chargement enfants: ${enfantsResponse.message}');
        _vaccinations = [];
      }
    } catch (e) {
      print('❌ Erreur chargement vaccinations: $e');
      _vaccinations = [];
    }
  }
  
  /// Charge le type d'accouchement depuis le dossier médical
  Future<void> _loadTypeAccouchement(int patienteId) async {
    try {
      final dossierResponse = await _dossierService.getMyDossierMedical();
      
      if (dossierResponse.success && dossierResponse.data != null) {
        final dossier = dossierResponse.data!;
        
        // Récupérer les formulaires CPON
        if (dossier.formulairesCPON != null && dossier.formulairesCPON!.isNotEmpty) {
          // Chercher le type d'accouchement dans tous les formulaires CPON
          String? typeAccouchement;
          for (var formulaire in dossier.formulairesCPON!) {
            if (formulaire.accouchementType != null && formulaire.accouchementType!.isNotEmpty) {
              typeAccouchement = formulaire.accouchementType;
              break; // Prendre le premier trouvé
            }
          }
          
          if (typeAccouchement != null) {
            // Formater le type d'accouchement
            String typeFormate;
            switch (typeAccouchement.toUpperCase()) {
              case 'NORMAL':
              case 'VAGINAL':
                typeFormate = 'Normal (Vaginal)';
                break;
              case 'CESARIENNE':
                typeFormate = 'Césarienne';
                break;
              default:
                typeFormate = typeAccouchement;
            }
            
            setState(() {
              _typeAccouchement = typeFormate;
            });
            print('✅ Type d\'accouchement chargé: $_typeAccouchement');
          }
        }
      }
    } catch (e) {
      print('❌ Erreur chargement type accouchement: $e');
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

  /// Vérifie s'il y a des consultations ou vaccinations avec dates dépassées et affiche le dialogue
  void _checkAndShowDateDepasseeDialog() {
    final maintenant = DateTime.now();
    
    // Chercher les CPON avec date dépassée et statut A_VENIR
    final cponDepassees = _consultations.where((cpon) {
      if (!cpon.isAVenir) return false;
      try {
        final datePrevue = DateTime.parse(cpon.datePrevue);
        // Vérifier si la date est dépassée (au moins 1 jour)
        return datePrevue.isBefore(maintenant.subtract(const Duration(days: 1)));
      } catch (e) {
        return false;
      }
    }).toList();

    // Chercher les vaccinations avec date dépassée et statut A_FAIRE
    final vaccinationsDepassees = _vaccinations.where((vacc) {
      if (!vacc.isAFaire) return false;
      try {
        final datePrevue = DateTime.parse(vacc.datePrevue);
        // Vérifier si la date est dépassée (au moins 1 jour)
        return datePrevue.isBefore(maintenant.subtract(const Duration(days: 1)));
      } catch (e) {
        return false;
      }
    }).toList();

    // Priorité : CPON d'abord, puis vaccinations
    if (cponDepassees.isNotEmpty) {
      final premiereCPON = cponDepassees.first;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => ConfirmationDateDepasseeDialog(
              item: premiereCPON,
              type: 'cpon',
              onConfirmed: () {
                _loadDashboardData();
              },
              onReprogrammed: () {
                _loadDashboardData();
              },
            ),
          );
        }
      });
    } else if (vaccinationsDepassees.isNotEmpty) {
      final premiereVaccination = vaccinationsDepassees.first;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => ConfirmationDateDepasseeDialog(
              item: premiereVaccination,
              type: 'vaccination',
              onConfirmed: () {
                _loadDashboardData();
              },
              onReprogrammed: () {
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
    
    // Ajouter les conseils postnatals selon le type d'accouchement (maximum 3 conseils)
    final conseilsPostnatals = ConseilPredefiniService.getConseilsPostnatals(
      typeAccouchement: _typeAccouchement,
    );
    for (var conseil in conseilsPostnatals.take(3)) {
      eventCards.add(
        TaskCard(
          icon: conseil.icon,
          iconColor: conseil.color,
          title: conseil.titre,
          subtitle: conseil.description,
        ),
      );
      eventCards.add(const SizedBox(height: 16));
    }
    
    // Ajouter les conseils pour chaque enfant selon son âge (maximum 2 conseils par enfant, 1 enfant à la fois)
    if (_enfants.isNotEmpty) {
      final premierEnfant = _enfants.first;
      final ageEnJours = ConseilPredefiniService.calculerAgeEnJours(premierEnfant.dateDeNaissance);
      final conseilsEnfant = ConseilPredefiniService.getConseilsPourEnfant(ageEnJours);
      
      for (var conseil in conseilsEnfant.take(2)) {
        eventCards.add(
          TaskCard(
            icon: conseil.icon,
            iconColor: conseil.color,
            title: '${conseil.titre} - ${premierEnfant.nomComplet}',
            subtitle: conseil.description,
          ),
        );
        eventCards.add(const SizedBox(height: 16));
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
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        title: Image.asset(
          'assets/images/logo/logoknya.png', // Utilisation du logo
          height: 80,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        shadowColor: Colors.transparent,
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
                        
                        const SizedBox(height: 300), // Space for floating buttons
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
                Container(
                  width: 56,
                  height: 56,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.volume_up,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                ),

                const SizedBox(height: 16),
                // Bouton Livre (au milieu)
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.patienteDossierPost);
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.book_outlined,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Bouton Bébé
                FloatingActionButton(
                  heroTag: "bebe",
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.patienteEnfants);
                  },
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



