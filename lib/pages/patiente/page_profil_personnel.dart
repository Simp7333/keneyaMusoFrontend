import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes.dart';
import '../common/app_colors.dart';
import 'package:keneya_muso/services/professionnel_sante_service.dart'; // Import du service
import 'package:keneya_muso/models/professionnel_sante.dart'; // Import du modèle
import '../../../services/dossier_submission_service.dart';
import '../../../services/grossesse_service.dart';
import '../../../models/dto/dossier_submission_request.dart';
import '../../../utils/message_helper.dart';

class PageProfilPersonnel extends StatefulWidget {
  final int professionnelId;

  const PageProfilPersonnel({super.key, required this.professionnelId});

  @override
  State<PageProfilPersonnel> createState() => _PageProfilPersonnelState();
}

class _PageProfilPersonnelState extends State<PageProfilPersonnel> {
  final ProfessionnelSanteService _professionnelSanteService = ProfessionnelSanteService();
  final DossierSubmissionService _submissionService = DossierSubmissionService();
  final GrossesseService _grossesseService = GrossesseService();
  ProfessionnelSante? _professionnel;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print('🚀 PageProfilPersonnel initialisée avec ID: ${widget.professionnelId}');
    if (widget.professionnelId <= 0) {
      print('⚠️ ID invalide détecté: ${widget.professionnelId}');
      if (mounted) {
        setState(() {
          _errorMessage = 'ID de professionnel invalide';
          _isLoading = false;
        });
      }
    } else {
      _loadProfessionnelDetails();
    }
  }

  Future<void> _loadProfessionnelDetails() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    print('🔍 Chargement du professionnel avec ID: ${widget.professionnelId}');
    
    try {
      final response = await _professionnelSanteService.getProfessionnelSanteById(widget.professionnelId);
      
      print('📥 Réponse reçue - Success: ${response.success}, Message: ${response.message}');
      
      if (!mounted) return;
      
      if (response.success && response.data != null) {
        print('✅ Données du professionnel chargées: ${response.data!.fullName}');
        setState(() {
          _professionnel = response.data!;
          _isLoading = false;
        });
      } else {
        print('❌ Erreur: ${response.message}');
        setState(() {
          _errorMessage = response.message ?? 'Erreur de chargement des détails du professionnel';
          _isLoading = false;
        });
        if (mounted) {
          await MessageHelper.showError(
            context: context,
            message: _errorMessage!,
            title: 'Erreur',
          );
        }
      }
    } catch (e, stackTrace) {
      print('💥 Exception lors du chargement: $e');
      print('Stack trace: $stackTrace');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erreur: ${e.toString()}';
        _isLoading = false;
      });
      await MessageHelper.showError(
        context: context,
        message: 'Erreur de connexion: ${e.toString()}',
        title: 'Erreur',
      );
    }
  }

  /// Soumet le dossier médical au médecin
  Future<void> _handleSubmitDossier() async {
    print('🚀 _handleSubmitDossier appelé');
    
    if (_isSubmitting) {
      print('⚠️ Déjà en cours de soumission, annulation');
      return;
    }

    if (_professionnel == null) {
      await MessageHelper.showError(
        context: context,
        message: 'Informations du professionnel non disponibles',
        title: 'Erreur',
      );
      return;
    }

    print('✅ Démarrage de la soumission...');
    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        if (!mounted) return;
        await MessageHelper.showError(
          context: context,
          message: 'Utilisateur non identifié',
          title: 'Erreur',
        );
        setState(() => _isSubmitting = false);
        return;
      }

      // Déterminer le type de soumission (CPN ou CPON)
      String submissionType = 'CPN';
      Map<String, dynamic> dossierData = {};

      // Vérifier si la patiente a une grossesse en cours
      final grossesseResponse = await _grossesseService.getCurrentGrossesseByPatiente(userId);
      
      if (grossesseResponse.success && grossesseResponse.data != null) {
        // La patiente a une grossesse en cours -> soumission CPN
        submissionType = 'CPN';
        dossierData = {
          'grossesseId': grossesseResponse.data!.id,
          'dateDernieresRegles': grossesseResponse.data!.dateDebut ?? '',
          'datePrevueAccouchement': grossesseResponse.data!.datePrevueAccouchement ?? '',
          'message': 'Demande de suivi prénatal',
        };
      } else {
        // Pas de grossesse en cours -> soumission CPON (suivi postnatal)
        submissionType = 'CPON';
        dossierData = {
          'message': 'Demande de suivi postnatal',
        };
      }

      // Créer la requête de soumission avec le téléphone du médecin
      print('📤 Soumission de dossier:');
      print('  Type: $submissionType');
      print('  Médecin téléphone: ${_professionnel!.telephone}');
      print('  Data: $dossierData');
      
      final request = DossierSubmissionRequest(
        type: submissionType,
        data: dossierData,
        medecinTelephone: _professionnel!.telephone, // Téléphone du médecin
      );

      // Soumettre le dossier
      final response = await _submissionService.submitDossier(request);
      
      print('📥 Réponse soumission:');
      print('  Success: ${response.success}');
      print('  Message: ${response.message}');
      if (response.data != null) {
        print('  Submission ID: ${response.data!.id}');
        print('  Status: ${response.data!.status}');
      }

      if (!mounted) return;

      if (response.success) {
        print('✅ Soumission réussie');
        
        await MessageHelper.showSuccess(
          context: context,
          message: submissionType == 'CPN'
              ? 'Votre dossier prénatal a été soumis avec succès ! Le médecin recevra une alerte.'
              : 'Votre dossier postnatal a été soumis avec succès ! Le médecin recevra une alerte.',
          title: 'Soumission réussie',
          onPressed: () {
            // Retourner à la page PersonnelPage
            print('🔄 Retour vers PersonnelPage');
            Navigator.pop(context);
          },
        );
      } else {
        print('❌ Erreur de soumission: ${response.message}');
        await MessageHelper.showApiResponse(
          context: context,
          response: response,
          errorTitle: 'Erreur',
        );
      }
    } catch (e) {
      if (!mounted) return;
      print('💥 Exception lors de la soumission: $e');
      await MessageHelper.showError(
        context: context,
        message: 'Erreur: ${e.toString()}',
        title: 'Erreur',
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 Build appelé - isLoading: $_isLoading, errorMessage: $_errorMessage, professionnel: ${_professionnel?.fullName ?? "null"}');
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null || _professionnel == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage ?? 'Professionnel non trouvé',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadProfessionnelDetails,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Retour'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : SizedBox.expand(
                  child: Stack(
                  children: [
                    // Background avec illustration du docteur et forme bleue
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Stack(
                        children: [
                          // Forme bleue abstraite (cloud-like) en arrière-plan
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color(0xFFE3F2FD).withOpacity(0.3),
                                    Colors.white,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Illustration du docteur
                          Center(
                            child: _professionnel!.imageUrl != null && _professionnel!.imageUrl!.isNotEmpty
                                ? Image.network(
                                    _professionnel!.imageUrl!,
                                    width: 200,
                                    height: 250,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/images/docP.png',
                                        width: 200,
                                        height: 250,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 200,
                                            height: 250,
                                            color: Colors.grey.shade200,
                                            child: const Icon(
                                              Icons.person,
                                              size: 100,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  )
                                : Image.asset(
                                    'assets/images/docP.png',
                                    width: 200,
                                    height: 250,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 200,
                                        height: 250,
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.person,
                                          size: 100,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),

                    // Back Button
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),

                    // White Card qui chevauche l'illustration
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.4,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Contenu scrollable
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Name
                                    Text(
                                      _professionnel!.fullName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 32),

                                    // Info fields avec dividers
                                    _buildInfoField(
                                      'Spécialité',
                                      _formatSpecialite(_professionnel!.specialite),
                                    ),
                                    const Divider(height: 24, thickness: 1),
                                    _buildInfoField(
                                      'Adresse',
                                      _professionnel!.adresse ?? 'Non spécifiée',
                                    ),
                                    const Divider(height: 24, thickness: 1),
                                    _buildInfoField(
                                      'Téléphone',
                                      _professionnel!.telephone,
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Bouton fixé en bas
                            Container(
                              padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, -2),
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isSubmitting ? null : _handleSubmitDossier,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE91E63).withOpacity(0.63),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 0,
                                    disabledBackgroundColor: Colors.grey.shade400,
                                  ),
                                  child: _isSubmitting
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'soumetre mon dossier',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  String _formatSpecialite(String specialite) {
    // Formater la spécialité pour l'affichage selon l'image
    switch (specialite.toUpperCase()) {
      case 'GYNECOLOGUE':
        return 'Gynécologue obstétricienne';
      case 'PEDIATRE':
        return 'Pédiatre';
      case 'GENERALISTE':
        return 'Médecin généraliste';
      default:
        return specialite;
    }
  }

  Widget _buildInfoField(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFFE91E63),
            fontWeight: FontWeight.normal,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
