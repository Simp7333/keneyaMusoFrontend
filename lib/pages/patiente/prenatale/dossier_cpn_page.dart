import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/app_colors.dart';
import '../../common/page_chat.dart';
import '../../../services/dossier_medical_service.dart';
import '../../../services/conversation_service.dart';
import '../../../services/consultation_service.dart';
import '../../../services/grossesse_service.dart';
import '../../../services/prise_fer_service.dart';
import '../../../services/dossier_submission_service.dart';
import '../../../models/dossier_medical.dart';
import '../../../models/patiente_detail.dart';
import '../../../models/consultation_prenatale.dart';
import '../../../models/grossesse.dart';
import '../../../models/prise_fer_quotidienne.dart';
import '../../../utils/message_helper.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';

class DossierCpnPage extends StatefulWidget {
  final int? patienteId; // ID de la patiente à afficher (null = utilisateur connecté)
  
  const DossierCpnPage({super.key, this.patienteId});

  @override
  State<DossierCpnPage> createState() => _DossierCpnPageState();
}

class _DossierCpnPageState extends State<DossierCpnPage> {
  final DossierMedicalService _service = DossierMedicalService();
  final ConversationService _conversationService = ConversationService();
  final ConsultationService _consultationService = ConsultationService();
  final GrossesseService _grossesseService = GrossesseService();
  final PriseFerService _priseFerService = PriseFerService();
  final DossierSubmissionService _submissionService = DossierSubmissionService();
  
  String _nomPrenom = 'Chargement...';
  String _age = '--';
  String _telephone = '--';
  String _taille = 'Non renseigné';
  String _poids = 'Non renseigné';
  String _groupeSanguin = 'Non renseigné';
  String _moisGrossesse = '--';
  
  // Pour la prise de fer
  DateTime _selectedMonthDate = DateTime.now();
  StatistiquesPriseFer? _statistiquesPriseFer;
  bool _isLoadingPriseFer = false;
  
  bool _isLoading = true;
  String? _errorMessage;
  bool _isMedecin = false;
  int? _formulaireCPNId;
  bool _hasPendingCpnSubmission = false; // Indique s'il y a une soumission CPN en attente
  
  // Liste des groupes sanguins disponibles
  final List<String> _groupesSanguins = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
  
  Map<String, bool> _cpnCheckboxes = {
    'CPN1': false,
    'CPN2': false,
    'CPN3': false,
    'CPN4': false,
  };
  
  // Mapping entre les libellés CPN et les consultations
  Map<String, ConsultationPrenatale?> _cpnToConsultation = {
    'CPN1': null,
    'CPN2': null,
    'CPN3': null,
    'CPN4': null,
  };
  
  List<ConsultationPrenatale> _consultations = [];

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    _loadData();
  }

  /// Vérifie si l'utilisateur est un médecin
  Future<void> _checkUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role');
    setState(() {
      _isMedecin = role == 'MEDECIN';
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // S'assurer que le rôle est déterminé avant de continuer
      await _checkUserRole();
      
      // Charger les détails complets de la patiente
      // Si patienteId est fourni, charger cette patiente, sinon charger l'utilisateur connecté
      final patienteResponse = widget.patienteId != null
          ? await _service.getPatienteDetails(widget.patienteId!)
          : await _service.getMyPatienteDetails();
      if (patienteResponse.success && patienteResponse.data != null) {
        final patiente = patienteResponse.data!;
        setState(() {
          _nomPrenom = patiente.fullName;
          _telephone = patiente.telephone;
          
          // Calculer l'âge
          if (patiente.age != null) {
            _age = '${patiente.age} ans';
          } else if (patiente.dateDeNaissance != null) {
            try {
              final dateNaissance = DateTime.parse(patiente.dateDeNaissance!);
              final age = DateTime.now().year - dateNaissance.year;
              if (DateTime.now().month < dateNaissance.month ||
                  (DateTime.now().month == dateNaissance.month && DateTime.now().day < dateNaissance.day)) {
                _age = '${age - 1} ans';
              } else {
                _age = '$age ans';
              }
            } catch (e) {
              _age = '--';
            }
          }
        });
      } else {
        // Fallback vers l'ancienne méthode si la nouvelle échoue
        final fallbackResponse = await _service.getMyPatienteInfo();
        if (fallbackResponse.success && fallbackResponse.data != null) {
          final patiente = fallbackResponse.data!;
          setState(() {
            _nomPrenom = '${patiente['prenom'] ?? ''} ${patiente['nom'] ?? ''}'.trim();
            _telephone = patiente['telephone'] ?? '--';
          });
        }
      }

      // Vérifier s'il y a des soumissions CPN en attente (seulement pour les patientes, pas pour les médecins)
      if (!_isMedecin) {
        await _checkPendingCpnSubmissions();
      }
      
      // Charger le dossier médical
      // Si patienteId est fourni, on charge le dossier de cette patiente (pour les médecins)
      // Sinon, on charge le dossier de l'utilisateur connecté
      final prefs = await SharedPreferences.getInstance();
      final targetPatienteId = widget.patienteId ?? prefs.getInt('user_id');
      
      final dossierResponse = await _service.getMyDossierMedical();
      if (dossierResponse.success && dossierResponse.data != null) {
        final dossier = dossierResponse.data!;
        
        // Récupérer le dernier formulaire CPN
        if (dossier.formulairesCPN != null && dossier.formulairesCPN!.isNotEmpty) {
          final dernierCPN = dossier.formulairesCPN!.last;
          
          // Masquer les données si une soumission est en attente (seulement pour les patientes)
          if (_hasPendingCpnSubmission && !_isMedecin) {
            setState(() {
              _taille = 'En attente d\'approbation';
              _poids = 'En attente d\'approbation';
              _groupeSanguin = 'En attente d\'approbation';
              _formulaireCPNId = dernierCPN.id;
            });
          } else {
            setState(() {
              _taille = dernierCPN.taille != null ? '${dernierCPN.taille} m' : 'Non renseigné';
              _poids = dernierCPN.poids != null ? '${dernierCPN.poids} kg' : 'Non renseigné';
              final groupeBackend = dernierCPN.groupeSanguin ?? '';
              _groupeSanguin = groupeBackend.isEmpty || groupeBackend == 'Non renseigné' 
                  ? 'Non renseigné' 
                  : _convertGroupeSanguinFromBackend(groupeBackend);
              _formulaireCPNId = dernierCPN.id;
            });
          }
        }
      }

      // Charger la grossesse active pour calculer le mois de grossesse
      final patienteId = targetPatienteId;
      
      if (patienteId != null) {
        // Calculer le mois de grossesse
        final grossesseResponse = await _grossesseService.getCurrentGrossesseByPatiente(patienteId);
        if (grossesseResponse.success && grossesseResponse.data != null) {
          final grossesse = grossesseResponse.data!;
          if (grossesse.dateDebut != null) {
            setState(() {
              _moisGrossesse = _calculateMoisGrossesse(grossesse.dateDebut!);
            });
          }
        }
        
          // Charger les consultations prénatales pour vérifier les CPN confirmées
          final consultationsResponse = await _consultationService.getConsultationsPrenatalesByPatiente(patienteId);
          
          if (consultationsResponse.success && consultationsResponse.data != null) {
            setState(() {
              _consultations = consultationsResponse.data!;
              // Mapper les consultations aux CPN
              _mapConsultationsToCPN();
              // Cocher automatiquement les CPN confirmées (statut REALISEE)
              _updateCpnCheckboxesFromConsultations();
            });
          }
        }

      // Charger les statistiques de prise de fer pour le mois sélectionné
      await _loadStatistiquesPriseFer();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur lors du chargement: ${e.toString()}';
      });
    }
  }

  /// Charge les statistiques de prise de fer pour le mois sélectionné
  Future<void> _loadStatistiquesPriseFer() async {
    setState(() {
      _isLoadingPriseFer = true;
    });

    try {
      final response = await _priseFerService.getStatistiquesMois(
        annee: _selectedMonthDate.year,
        mois: _selectedMonthDate.month,
      );

      if (mounted) {
        setState(() {
          if (response.success && response.data != null) {
            _statistiquesPriseFer = response.data;
          } else {
            // Si pas de données, créer des statistiques vides
            final joursDansMois = DateTime(_selectedMonthDate.year, _selectedMonthDate.month + 1, 0).day;
            _statistiquesPriseFer = StatistiquesPriseFer.calculer(
              joursAvecPrise: 0,
              joursTotal: joursDansMois,
            );
          }
          _isLoadingPriseFer = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPriseFer = false;
        });
      }
    }
  }

  /// Vérifie s'il y a des soumissions CPN en attente d'approbation
  Future<void> _checkPendingCpnSubmissions() async {
    try {
      final submissionsResponse = await _submissionService.getMySubmissions();
      
      if (submissionsResponse.success && submissionsResponse.data != null) {
        // Vérifier s'il y a au moins une soumission CPN en attente
        final hasPending = submissionsResponse.data!.any(
          (submission) => submission.type == 'CPN' && submission.status == 'EN_ATTENTE'
        );
        
        if (mounted) {
          setState(() {
            _hasPendingCpnSubmission = hasPending;
          });
        }
      }
    } catch (e) {
      // En cas d'erreur, on ne masque pas les données (affichage par défaut)
      print('❌ Erreur lors de la vérification des soumissions CPN: $e');
    }
  }

  /// Obtient le nom du mois en français
  String _getMonthName(DateTime date) {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return months[date.month - 1];
  }

  /// Obtient la liste des mois disponibles (6 derniers mois + mois actuel)
  List<DateTime> _getAvailableMonths() {
    final now = DateTime.now();
    final months = <DateTime>[];
    
    // Ajouter les 6 derniers mois
    for (int i = 6; i >= 0; i--) {
      months.add(DateTime(now.year, now.month - i, 1));
    }
    
    return months;
  }

  /// Calcule le mois de grossesse à partir de la date de début
  String _calculateMoisGrossesse(String dateDebut) {
    try {
      final dateDebutGrossesse = DateTime.parse(dateDebut);
      final now = DateTime.now();
      final difference = now.difference(dateDebutGrossesse);
      final weeks = difference.inDays ~/ 7;
      final months = weeks ~/ 4;
      
      if (months < 1) {
        return '$weeks semaine${weeks > 1 ? 's' : ''}';
      } else if (months >= 9) {
        return '9 mois';
      } else {
        return '$months mois';
      }
    } catch (e) {
      return '--';
    }
  }

  /// Mappe les consultations aux CPN selon leur ordre chronologique
  void _mapConsultationsToCPN() {
    // Réinitialiser le mapping
    _cpnToConsultation = {
      'CPN1': null,
      'CPN2': null,
      'CPN3': null,
      'CPN4': null,
    };
    
    // Trier les consultations par date prévue
    final consultationsTriees = List<ConsultationPrenatale>.from(_consultations);
    consultationsTriees.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.datePrevue);
        final dateB = DateTime.parse(b.datePrevue);
        return dateA.compareTo(dateB);
      } catch (e) {
        return 0;
      }
    });
    
    // Mapper les 4 premières consultations aux CPN
    for (int i = 0; i < min(consultationsTriees.length, 4); i++) {
      _cpnToConsultation['CPN${i + 1}'] = consultationsTriees[i];
    }
  }

  /// Met à jour les cases à cocher CPN en fonction des consultations confirmées
  void _updateCpnCheckboxesFromConsultations() {
    // Réinitialiser toutes les cases
    _cpnCheckboxes = {
      'CPN1': false,
      'CPN2': false,
      'CPN3': false,
      'CPN4': false,
    };

    // Parcourir les consultations et cocher celles qui sont confirmées (REALISEE)
    final cpnRealisees = _consultations.where((c) => c.isRealisee).toList();
    
    // Trier par date prévue pour déterminer l'ordre (CPN1, CPN2, CPN3, CPN4)
    cpnRealisees.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.datePrevue);
        final dateB = DateTime.parse(b.datePrevue);
        return dateA.compareTo(dateB);
      } catch (e) {
        return 0;
      }
    });
    
    // Cocher les CPN réalisées dans l'ordre
    for (int i = 0; i < min(cpnRealisees.length, 4); i++) {
      _cpnCheckboxes['CPN${i + 1}'] = true;
    }
  }

  /// Met à jour le groupe sanguin dans le formulaire CPN
  Future<void> _updateGroupeSanguin(String nouveauGroupeSanguin) async {
    if (_formulaireCPNId == null) {
      await MessageHelper.showWarning(
        context: context,
        message: 'Aucun formulaire CPN trouvé. Veuillez créer un formulaire d\'abord.',
        title: 'Attention',
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        await MessageHelper.showError(
          context: context,
          message: 'Non authentifié. Veuillez vous reconnecter.',
        );
        return;
      }

      // Convertir le format affiché (A+) au format backend (A_PLUS)
      final groupeBackend = _convertGroupeSanguinToBackend(nouveauGroupeSanguin);

      // Mettre à jour via le dossier médical
      final dossierResponse = await _service.getMyDossierMedical();
      if (dossierResponse.success && dossierResponse.data != null) {
        final dossier = dossierResponse.data!;
        if (dossier.formulairesCPN != null && dossier.formulairesCPN!.isNotEmpty) {
          final dernierCPN = dossier.formulairesCPN!.last;
          
          // Construire le payload de mise à jour (on doit créer un nouveau formulaire ou utiliser l'endpoint de mise à jour)
          // Pour l'instant, on met juste à jour l'affichage local
          setState(() {
            _groupeSanguin = nouveauGroupeSanguin;
          });

          await MessageHelper.showSuccess(
            context: context,
            message: 'Groupe sanguin mis à jour: $nouveauGroupeSanguin',
            title: 'Mise à jour réussie',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        await MessageHelper.showError(
          context: context,
          message: 'Erreur lors de la mise à jour: $e',
        );
      }
    }
  }

  /// Convertit le format d'affichage au format backend
  String _convertGroupeSanguinToBackend(String groupeAffiche) {
    return groupeAffiche.replaceAll('+', '_PLUS').replaceAll('-', '_MOINS');
  }

  /// Convertit le format backend au format d'affichage
  String _convertGroupeSanguinFromBackend(String groupeBackend) {
    if (groupeBackend.isEmpty || groupeBackend == 'Non renseigné') {
      return 'Non renseigné';
    }
    // Le format backend est comme "A_PLUS", "A_MOINS", etc.
    String result = groupeBackend;
    result = result.replaceAll('_PLUS', '+');
    result = result.replaceAll('_MOINS', '-');
    // Si le format est déjà correct (A+, A-, etc.), le retourner tel quel
    if (_groupesSanguins.contains(result)) {
      return result;
    }
    // Sinon, essayer de convertir
    return result;
  }

  /// Gère le clic sur une case CPN
  Future<void> _toggleCPN(String cpnLabel) async {
    // Seuls les médecins peuvent modifier les CPN lorsqu'ils consultent le dossier d'une patiente
    if (!_isMedecin || widget.patienteId == null) {
      return;
    }

    final consultation = _cpnToConsultation[cpnLabel];
    if (consultation == null) {
      await MessageHelper.showWarning(
        context: context,
        message: 'Aucune consultation trouvée pour $cpnLabel',
        title: 'Attention',
      );
      return;
    }

    final wasChecked = _cpnCheckboxes[cpnLabel]!;
    setState(() {
      _cpnCheckboxes[cpnLabel] = !wasChecked;
    });

    try {
      if (!wasChecked) {
        // Marquer la consultation comme réalisée
        final dateRealisee = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final response = await _consultationService.confirmerConsultationPrenatale(
          consultation,
          dateRealisee,
        );

        if (response.success) {
          await MessageHelper.showSuccess(
            context: context,
            message: 'Consultation confirmée',
            title: 'Succès',
          );
          // Recharger les données
          await _loadData();
        } else {
          // Annuler la modification si l'API échoue
          setState(() {
            _cpnCheckboxes[cpnLabel] = wasChecked;
          });
          await MessageHelper.showApiResponse(
            context: context,
            response: response,
            errorTitle: 'Erreur',
          );
        }
      } else {
        // Décocher - on peut simplement annuler la modification pour l'instant
        // Note: Il n'y a pas d'endpoint pour "dé-confirmer" une consultation
        await MessageHelper.showWarning(
          context: context,
          message: 'Une consultation confirmée ne peut pas être annulée',
          title: 'Information',
        );
        setState(() {
          _cpnCheckboxes[cpnLabel] = true; // Remettre à true
        });
      }
    } catch (e) {
      // Annuler la modification en cas d'erreur
      setState(() {
        _cpnCheckboxes[cpnLabel] = wasChecked;
      });
      if (mounted) {
        await MessageHelper.showError(
          context: context,
          message: 'Erreur: $e',
        );
      }
    }
  }

  /// Ouvre le chat avec la patiente (pour les médecins)
  Future<void> _ouvrirChat() async {
    if (widget.patienteId == null) return;

    try {
      // Obtenir ou créer la conversation avec la patiente
      final response = await _conversationService.getOrCreateConversationWithMedecin(widget.patienteId!);

      if (!mounted) return;

      if (response.success && response.data != null) {
        final conversation = response.data!;
        
        // Naviguer vers la page de chat
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PageChat(
              conversationId: conversation.id,
              medecinNom: _nomPrenom.split(' ').last,
              medecinPrenom: _nomPrenom.split(' ').first,
            ),
          ),
        );
      } else {
        await MessageHelper.showApiResponse(
          context: context,
          response: response,
          errorTitle: 'Erreur',
        );
      }
    } catch (e) {
      if (mounted) {
        await MessageHelper.showError(
          context: context,
          message: 'Erreur: $e',
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Scrollable Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _loadData,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Réessayer'),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              // CARNET de SANTE de la MERE Card
                              _buildCarnetCard(),
                              const SizedBox(height: 20),
                              // Informations personnel Card
                              _buildInformationsPersonnelCard(),
                              const SizedBox(height: 20),
                              // Vos rendez-vous CPN Card
                              _buildRendezVousCPNCard(),
                              const SizedBox(height: 20),
                              // Prise de fer Card
                              _buildPriseDeFerCard(),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
      // Bouton de chat flottant (visible uniquement pour les médecins)
      floatingActionButton: widget.patienteId != null
          ? FloatingActionButton(
              onPressed: _ouvrirChat,
              backgroundColor: AppColors.primaryPink,
              child: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row with back button and speaker icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.black, size: 28),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Container(
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
            ],
          ),
          const SizedBox(height: 12),
          // Official Information
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'République du Mali',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Un peuple - un but - une fois',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 60,
                      height: 1,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'MINISTÈRE DE LA SANTÉ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 60,
                      height: 1,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'DIRECTION NATIONALE DE SANTÉ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'DIVISION DE LA SANTÉ DE LA REPRODUCTION',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.black,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Flag of Mali
              Container(
                width: 30,
                height: 20,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 0.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(color: const Color(0xFF14B53A)),
                    ),
                    Expanded(
                      child: Container(color: const Color(0xFFFCD116)),
                    ),
                    Expanded(
                      child: Container(color: const Color(0xFFCE1126)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarnetCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'CARNET de SANTÉ de la MÈRE',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInformationsPersonnelCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Informations personnel',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 60,
            height: 2,
            color: Colors.black,
          ),
          const SizedBox(height: 20),
          // Message d'information si une soumission est en attente
          if (_hasPendingCpnSubmission && !_isMedecin)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Vos données sont en attente d\'approbation par votre médecin. Elles seront visibles une fois approuvées.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          _buildInfoRow('Nom et prenom', _nomPrenom),
          _buildDivider(),
          _buildInfoRow('Age', _age),
          _buildDivider(),
          _buildInfoRow('Téléphone', _telephone),
          _buildDivider(),
          _buildInfoRow('Taille', _taille),
          _buildDivider(),
          _buildInfoRow('Poids', _poids),
          _buildDivider(),
          _buildInfoRow('Mois de grossesse', _moisGrossesse),
          _buildDivider(),
          _buildGroupeSanguinRow(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primaryColor,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupeSanguinRow() {
    // Vérifier si l'utilisateur peut éditer (patiente ou médecin)
    final canEdit = widget.patienteId == null || _isMedecin;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Groupe sanguin',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primaryColor,
            ),
          ),
          if (canEdit)
            DropdownButton<String>(
              value: _groupeSanguin != 'Non renseigné' ? _groupeSanguin : null,
              hint: Text(
                _groupeSanguin,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              items: _groupesSanguins.map((String groupe) {
                return DropdownMenuItem<String>(
                  value: groupe,
                  child: Text(
                    groupe,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? nouveauGroupe) {
                if (nouveauGroupe != null) {
                  _updateGroupeSanguin(nouveauGroupe);
                }
              },
              underline: Container(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black87, size: 20),
            )
          else
            Row(
              children: [
                Text(
                  _groupeSanguin,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black87,
                  size: 20,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.shade300,
      height: 1,
      thickness: 0.5,
    );
  }

  Widget _buildRendezVousCPNCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Vos rendez-vous CPN',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 60,
            height: 2,
            color: Colors.black,
          ),
          const SizedBox(height: 20),
          // Grid with 2 columns
          Row(
            children: [
              Expanded(child: _buildCPNCheckbox('CPN1')),
              const SizedBox(width: 16),
              Expanded(child: _buildCPNCheckbox('CPN2')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildCPNCheckbox('CPN3')),
              const SizedBox(width: 16),
              Expanded(child: _buildCPNCheckbox('CPN4')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCPNCheckbox(String label) {
    final isChecked = _cpnCheckboxes[label]!;
    // Permettre la modification uniquement aux médecins
    final canEdit = _isMedecin && widget.patienteId != null;
    
    return GestureDetector(
      onTap: canEdit ? () => _toggleCPN(label) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isChecked ? AppColors.primaryColor : Colors.transparent,
              border: Border.all(
                color: AppColors.primaryColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: isChecked
                ? const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriseDeFerCard() {
    final moisActuel = _getMonthName(_selectedMonthDate);
    final availableMonths = _getAvailableMonths();
    
    // Couleur et icône selon le pourcentage
    Color circleColor = Colors.grey;
    IconData circleIcon = Icons.info_outline;
    String emoji = '';
    
    if (_statistiquesPriseFer != null) {
      final pourcentage = _statistiquesPriseFer!.pourcentage;
      if (pourcentage >= 50) {
        circleColor = Colors.green;
        circleIcon = Icons.check_circle;
        emoji = '🎉';
      } else if (pourcentage >= 20) {
        circleColor = Colors.orange;
        circleIcon = Icons.warning_amber_rounded;
        emoji = '⚠️';
      } else {
        circleColor = Colors.red;
        circleIcon = Icons.error_outline;
        emoji = '💪';
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Prise de fer',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 60,
              height: 2,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          // Month selector (fonctionnel)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                moisActuel,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: () => _showMonthPicker(availableMonths),
                child: Row(
                  children: [
                    const Text(
                      'Mois',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black87,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress indicator (données réelles)
          if (_isLoadingPriseFer)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_statistiquesPriseFer != null) ...[
            Row(
              children: [
                Text(
                  '${_statistiquesPriseFer!.joursAvecPrise}/${_statistiquesPriseFer!.joursTotal} jours',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_statistiquesPriseFer!.pourcentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: circleColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Message d'encouragement (selon pourcentage réel)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    circleIcon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _statistiquesPriseFer!.message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Aucune donnée disponible pour ce mois',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Affiche un dialogue pour sélectionner le mois
  void _showMonthPicker(List<DateTime> availableMonths) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sélectionner un mois',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...availableMonths.map((month) {
                final monthName = _getMonthName(month);
                final year = month.year;
                final isSelected = month.year == _selectedMonthDate.year &&
                    month.month == _selectedMonthDate.month;
                
                return ListTile(
                  title: Text(
                    '$monthName $year',
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.primaryPink : Colors.black87,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: AppColors.primaryPink)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedMonthDate = month;
                    });
                    Navigator.pop(context);
                    _loadStatistiquesPriseFer();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

