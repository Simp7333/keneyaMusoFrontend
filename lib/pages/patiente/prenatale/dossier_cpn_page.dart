import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/app_colors.dart';
import '../../common/page_chat.dart';
import '../../../services/dossier_medical_service.dart';
import '../../../services/conversation_service.dart';
import '../../../models/dossier_medical.dart';
import '../../../models/patiente_detail.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class DossierCpnPage extends StatefulWidget {
  final int? patienteId; // ID de la patiente à afficher (null = utilisateur connecté)
  
  const DossierCpnPage({super.key, this.patienteId});

  @override
  State<DossierCpnPage> createState() => _DossierCpnPageState();
}

class _DossierCpnPageState extends State<DossierCpnPage> {
  final DossierMedicalService _service = DossierMedicalService();
  final ConversationService _conversationService = ConversationService();
  
  String _nomPrenom = 'Chargement...';
  String _age = '--';
  String _telephone = '--';
  String _taille = 'Non renseigné';
  String _poids = 'Non renseigné';
  String _groupeSanguin = 'Non renseigné';
  String _selectedMonth = 'Janvier';
  
  bool _isLoading = true;
  String? _errorMessage;
  
  Map<String, bool> _cpnCheckboxes = {
    'CPN1': false,
    'CPN2': false,
    'CPN3': false,
    'CPN4': false,
  };

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

      // Charger le dossier médical
      final dossierResponse = await _service.getMyDossierMedical();
      if (dossierResponse.success && dossierResponse.data != null) {
        final dossier = dossierResponse.data!;
        
        // Récupérer le dernier formulaire CPN
        if (dossier.formulairesCPN != null && dossier.formulairesCPN!.isNotEmpty) {
          final dernierCPN = dossier.formulairesCPN!.last;
          setState(() {
            _taille = dernierCPN.taille != null ? '${dernierCPN.taille} m' : 'Non renseigné';
            _poids = dernierCPN.poids != null ? '${dernierCPN.poids} kg' : 'Non renseigné';
            _groupeSanguin = dernierCPN.groupeSanguin ?? 'Non renseigné';
            
            // Calculer le nombre de CPN réalisés
            int nombreCPN = dossier.formulairesCPN!.length;
            for (int i = 1; i <= min(nombreCPN, 4); i++) {
              _cpnCheckboxes['CPN$i'] = true;
            }
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Erreur lors de l\'ouverture du chat'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
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
          const SizedBox(height: 16),
          // Informations de la patiente
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildPatienteInfoRow('Nom et Prénom', _nomPrenom),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPatienteInfoRow('Âge', _age),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildPatienteInfoRow('Téléphone', _telephone),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatienteInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
          _buildInfoRow('Taille', _taille),
          _buildDivider(),
          _buildInfoRow('Poids', _poids),
          _buildDivider(),
          _buildInfoRowWithDropdown('Groupe sanguin', _groupeSanguin),
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
    return GestureDetector(
      onTap: () {
        setState(() {
          _cpnCheckboxes[label] = !_cpnCheckboxes[label]!;
        });
      },
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
          // Month selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedMonth,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              Row(
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
            ],
          ),
          const SizedBox(height: 16),
          // Progress indicator
          Row(
            children: [
              const Text(
                '28/31 jours',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '🎉',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Encouragement message with green circle
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: const Text(
                  'Vous prenez bien vos fer c\'est tres bien continuer ainsi',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

