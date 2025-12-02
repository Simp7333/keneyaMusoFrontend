import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/app_colors.dart';
import '../../common/page_chat.dart';
import '../../../services/dossier_medical_service.dart';
import '../../../services/consultation_service.dart';
import '../../../services/conversation_service.dart';
import '../../../services/enfant_service.dart';
import '../../../models/dossier_medical.dart';
import '../../../models/consultation_postnatale.dart';
import '../../../models/patiente_detail.dart';
import '../../../models/enfant_brief.dart';
import '../../../utils/message_helper.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class DossierPostPage extends StatefulWidget {
  final int? patienteId; // ID de la patiente à afficher (null = utilisateur connecté)
  
  const DossierPostPage({super.key, this.patienteId});

  @override
  State<DossierPostPage> createState() => _DossierPostPageState();
}

class _DossierPostPageState extends State<DossierPostPage> {
  final DossierMedicalService _service = DossierMedicalService();
  final ConsultationService _consultationService = ConsultationService();
  final ConversationService _conversationService = ConversationService();
  final EnfantService _enfantService = EnfantService();
  
  String _nomPrenom = 'Chargement...';
  String _age = '--';
  String _telephone = '--';
  String _typeAccouchement = 'Non renseigné';
  String _dateAccouchement = 'Non renseigné';
  
  bool _isLoading = true;
  String? _errorMessage;
  
  Map<String, bool> _cponCheckboxes = {
    'CPON1': false,
    'CPON2': false,
    'CPON3': false,
  };
  
  List<ConsultationPostnatale> _consultations = [];
  List<EnfantBrief> _enfants = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Charger les détails complets de la patiente
      // Si patienteId est fourni, charger cette patiente, sinon charger l'utilisateur connecté
      final targetPatienteId = widget.patienteId;
      print('🔍 Chargement données patiente - patienteId: $targetPatienteId');
      
      final patienteResponse = targetPatienteId != null
          ? await _service.getPatienteDetails(targetPatienteId)
          : await _service.getMyPatienteDetails();
      
      if (patienteResponse.success && patienteResponse.data != null) {
        final patiente = patienteResponse.data!;
        print('✅ Patiente chargée: ${patiente.fullName}');
        print('🔍 Nombre d\'enfants dans PatienteDetail: ${patiente.enfants?.length ?? 0}');
        
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
          
          // Récupérer la date d'accouchement depuis les enfants
          // D'abord essayer depuis PatienteDetail
          String? dateAccouchementStr = patiente.dateAccouchement;
          print('🔍 Date accouchement depuis getter: $dateAccouchementStr');
          
          // Si pas trouvée dans PatienteDetail, chercher dans la liste des enfants
          if (dateAccouchementStr == null && patiente.enfants != null && patiente.enfants!.isNotEmpty) {
            print('🔍 Recherche date accouchement dans la liste des enfants');
            // Trier les enfants par date de naissance (plus ancien = premier)
            final enfantsTries = List<EnfantDetail>.from(patiente.enfants!);
            enfantsTries.sort((a, b) {
              try {
                final dateA = DateTime.parse(a.dateDeNaissance);
                final dateB = DateTime.parse(b.dateDeNaissance);
                return dateA.compareTo(dateB);
              } catch (e) {
                return 0;
              }
            });
            dateAccouchementStr = enfantsTries.first.dateDeNaissance;
            print('✅ Date accouchement trouvée depuis enfants: $dateAccouchementStr');
          }
          
          if (dateAccouchementStr != null) {
            try {
              final dateAcc = DateTime.parse(dateAccouchementStr);
              _dateAccouchement = DateFormat('dd/MM/yyyy').format(dateAcc);
              print('✅ Date accouchement formatée: $_dateAccouchement');
            } catch (e) {
              print('❌ Erreur formatage date accouchement: $e');
              _dateAccouchement = 'Non renseigné';
            }
          } else {
            _dateAccouchement = 'Non renseigné';
            print('⚠️ Date accouchement non trouvée');
          }
          
          // Stocker la liste des enfants si disponible
          if (patiente.enfants != null && patiente.enfants!.isNotEmpty) {
            print('✅ ${patiente.enfants!.length} enfant(s) chargé(s) depuis PatienteDetail');
            // Convertir EnfantDetail en EnfantBrief pour compatibilité
            _enfants = patiente.enfants!.map((e) => EnfantBrief(
              id: e.id,
              nom: e.nom,
              prenom: e.prenom,
              dateDeNaissance: e.dateDeNaissance,
              sexe: e.sexe,
            )).toList();
          } else {
            print('⚠️ Aucun enfant dans PatienteDetail');
          }
        });
      } else {
        print('❌ Erreur chargement patiente: ${patienteResponse.message}');
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
      
      // Si les enfants n'ont pas été chargés via PatienteDetail, les charger séparément
      final prefs = await SharedPreferences.getInstance();
      final finalPatienteId = targetPatienteId ?? prefs.getInt('user_id');
      
      if (_enfants.isEmpty && finalPatienteId != null) {
        print('🔍 Chargement séparé des enfants pour patienteId: $finalPatienteId');
        final enfantsResponse = await _enfantService.getEnfantsByPatiente(finalPatienteId);
        if (enfantsResponse.success && enfantsResponse.data != null) {
          print('✅ ${enfantsResponse.data!.length} enfant(s) chargé(s) séparément');
          setState(() {
            _enfants = enfantsResponse.data!;
            
            // Mettre à jour la date d'accouchement depuis les enfants si pas encore défini
            if (_dateAccouchement == 'Non renseigné' && _enfants.isNotEmpty) {
              try {
                // Trier par date de naissance
                final enfantsTries = List<EnfantBrief>.from(_enfants);
                enfantsTries.sort((a, b) {
                  try {
                    final dateA = DateTime.parse(a.dateDeNaissance);
                    final dateB = DateTime.parse(b.dateDeNaissance);
                    return dateA.compareTo(dateB);
                  } catch (e) {
                    return 0;
                  }
                });
                final dateAcc = DateTime.parse(enfantsTries.first.dateDeNaissance);
                _dateAccouchement = DateFormat('dd/MM/yyyy').format(dateAcc);
                print('✅ Date accouchement mise à jour depuis enfants séparés: $_dateAccouchement');
              } catch (e) {
                print('❌ Erreur mise à jour date accouchement: $e');
                // Garder 'Non renseigné'
              }
            }
          });
        } else {
          print('⚠️ Aucun enfant trouvé ou erreur: ${enfantsResponse.message}');
        }
      } else {
        print('✅ ${_enfants.length} enfant(s) déjà chargé(s), pas besoin de recharger');
      }

      // Charger le dossier médical
      // Utiliser le patienteId fourni ou celui de l'utilisateur connecté
      final dossierResponse = targetPatienteId != null
          ? await _service.getPatienteDossierMedical(targetPatienteId)
          : await _service.getMyDossierMedical();
      
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
          
          setState(() {
            _typeAccouchement = _formatTypeAccouchement(typeAccouchement);
            
            // Calculer le nombre de CPON réalisés
            int nombreCPON = dossier.formulairesCPON!.length;
            for (int i = 1; i <= min(nombreCPON, 3); i++) {
              _cponCheckboxes['CPON$i'] = true;
            }
          });
        }
      }

      // Charger les consultations postnatales pour vérifier les CPON confirmées
      if (finalPatienteId != null) {
        final consultationsResponse = await _consultationService.getConsultationsPostnatalesByPatiente(finalPatienteId);
        
        if (consultationsResponse.success && consultationsResponse.data != null) {
          setState(() {
            _consultations = consultationsResponse.data!;
            // Cocher automatiquement les CPON confirmées (statut REALISEE)
            _updateCponCheckboxesFromConsultations();
          });
        }
      }

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

  String _formatTypeAccouchement(String? type) {
    if (type == null || type.isEmpty) return 'Non renseigné';
    switch (type.toUpperCase()) {
      case 'NORMAL':
      case 'VAGINAL':
        return 'Normal (Vaginal)';
      case 'CESARIENNE':
        return 'Césarienne';
      default:
        return type;
    }
  }

  /// Met à jour les cases à cocher CPON en fonction des consultations confirmées
  void _updateCponCheckboxesFromConsultations() {
    // Réinitialiser toutes les cases
    _cponCheckboxes = {
      'CPON1': false,
      'CPON2': false,
      'CPON3': false,
    };

    // Parcourir les consultations et cocher celles qui sont confirmées (REALISEE)
    for (var consultation in _consultations) {
      if (consultation.isRealisee) {
        // Déterminer quelle CPON c'est selon le type
        switch (consultation.type.toUpperCase()) {
          case 'JOUR_3':
            _cponCheckboxes['CPON1'] = true;
            break;
          case 'JOUR_7':
            _cponCheckboxes['CPON2'] = true;
            break;
          case 'SEMAINE_6':
          case '6E_SEMAINE':
            _cponCheckboxes['CPON3'] = true;
            break;
        }
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
          title: 'Erreur',
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
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                                child: Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _loadData,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Réessayer'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  foregroundColor: Colors.white,
                                ),
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
                              // Vos rendez-vous CPON Card
                              _buildRendezVousCPONCard(),
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
          _buildInfoRow('Nom et prenom', _nomPrenom),
          _buildDivider(),
          _buildInfoRow('Age', _age),
          _buildDivider(),
          _buildInfoRow('Téléphone', _telephone),
          _buildDivider(),
          _buildInfoRowWithDropdown('Type d\'accouchement', _typeAccouchement),
          _buildDivider(),
          _buildInfoRow('Date d\'accouchement', _dateAccouchement),
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

  Widget _buildInfoRowWithDropdown(String label, String value) {
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
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
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

  Widget _buildRendezVousCPONCard() {
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
            'Vos rendez-vous CPON',
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
          _buildCheckboxRow('CPON1'),
          const SizedBox(height: 16),
          _buildCheckboxRow('CPON2'),
          const SizedBox(height: 16),
          _buildCheckboxRow('CPON3'),
        ],
      ),
    );
  }

  Widget _buildCheckboxRow(String cponLabel) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _cponCheckboxes[cponLabel] = !_cponCheckboxes[cponLabel]!;
            });
          },
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primaryColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: _cponCheckboxes[cponLabel]!
                ? Icon(
                    Icons.check,
                    size: 18,
                    color: AppColors.primaryColor,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          cponLabel,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

