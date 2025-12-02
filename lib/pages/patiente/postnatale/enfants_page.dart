import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/app_colors.dart';
import '../../../services/enfant_service.dart';
import '../../../services/vaccination_service.dart';
import '../../../models/enfant_brief.dart';
import '../../../models/vaccination.dart';
import '../../../models/dto/enfant_request.dart';
import '../../../models/dto/api_response.dart';
import '../../../utils/message_helper.dart';
import 'package:intl/intl.dart';

class EnfantsPage extends StatefulWidget {
  const EnfantsPage({super.key});

  @override
  State<EnfantsPage> createState() => _EnfantsPageState();
}

class _EnfantsPageState extends State<EnfantsPage> {
  final EnfantService _service = EnfantService();
  final VaccinationService _vaccinationService = VaccinationService();
  List<EnfantBrief> _enfants = [];
  Map<int, List<Vaccination>> _vaccinationsParEnfant = {}; // Map<enfantId, vaccinations>
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEnfants();
  }

  Future<void> _loadEnfants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final patienteId = prefs.getInt('user_id');

      if (patienteId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'ID patiente non trouvé';
        });
        return;
      }

      final response = await _service.getEnfantsByPatiente(patienteId);

      if (mounted) {
        setState(() {
          if (response.success && response.data != null) {
            _enfants = response.data!;
            // Charger les vaccinations pour chaque enfant
            _loadVaccinationsPourEnfants(response.data!);
          } else {
            _enfants = [];
            _errorMessage = response.message;
            _isLoading = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erreur: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _ajouterEnfant() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AjouterModifierEnfantDialog(),
    );

    if (result != null && mounted) {
      // Recharger la liste
      await _loadEnfants();
    }
  }

  Future<void> _modifierEnfant(EnfantBrief enfant) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AjouterModifierEnfantDialog(enfant: enfant),
    );

    if (result != null && mounted) {
      // Recharger la liste
      await _loadEnfants();
    }
  }

  /// Charge les vaccinations pour tous les enfants
  Future<void> _loadVaccinationsPourEnfants(List<EnfantBrief> enfants) async {
    Map<int, List<Vaccination>> vaccinationsMap = {};

    for (var enfant in enfants) {
      try {
        final response = await _vaccinationService.getVaccinationsByEnfant(enfant.id);
        if (response.success && response.data != null) {
          vaccinationsMap[enfant.id] = response.data!;
        } else {
          vaccinationsMap[enfant.id] = [];
        }
      } catch (e) {
        print('❌ Erreur chargement vaccinations pour enfant ${enfant.id}: $e');
        vaccinationsMap[enfant.id] = [];
      }
    }

    if (mounted) {
      setState(() {
        _vaccinationsParEnfant = vaccinationsMap;
        _isLoading = false;
      });
    }
  }

  String _calculerAge(String dateNaissance) {
    try {
      final date = DateTime.parse(dateNaissance);
      final maintenant = DateTime.now();
      final difference = maintenant.difference(date);
      final jours = difference.inDays;

      if (jours < 30) {
        return '$jours jour${jours > 1 ? 's' : ''}';
      } else if (jours < 365) {
        final mois = jours ~/ 30;
        return '$mois mois';
      } else {
        final annees = maintenant.year - date.year;
        if (maintenant.month < date.month ||
            (maintenant.month == date.month && maintenant.day < date.day)) {
          return '${annees - 1} an${annees - 1 > 1 ? 's' : ''}';
        }
        return '$annees an${annees > 1 ? 's' : ''}';
      }
    } catch (e) {
      return '--';
    }
  }

  /// Convertit le sexe du format backend (GARCON/FILLE) vers le format frontend (MASCULIN/FEMININ)
  String _convertirSexeBackendVersFrontend(String sexe) {
    switch (sexe.toUpperCase()) {
      case 'GARCON':
        return 'MASCULIN';
      case 'FILLE':
        return 'FEMININ';
      case 'MASCULIN':
      case 'FEMININ':
        return sexe.toUpperCase();
      default:
        return 'MASCULIN';
    }
  }

  /// Convertit le sexe du format frontend (MASCULIN/FEMININ) vers le format backend (GARCON/FILLE)
  String _convertirSexeFrontendVersBackend(String sexe) {
    switch (sexe.toUpperCase()) {
      case 'MASCULIN':
        return 'GARCON';
      case 'FEMININ':
        return 'FILLE';
      case 'GARCON':
      case 'FILLE':
        return sexe.toUpperCase();
      default:
        return 'GARCON';
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
            // Contenu
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null && _enfants.isEmpty
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
                                onPressed: _loadEnfants,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Réessayer'),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              // Titre
                              const Text(
                                'Mes Enfants',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Liste des enfants
                              if (_enfants.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.child_care,
                                          size: 64,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Aucun enfant enregistré',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ..._enfants.map((enfant) => _buildEnfantCard(enfant)),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _ajouterEnfant,
        backgroundColor: AppColors.primaryPink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
                    Expanded(child: Container(color: const Color(0xFF14B53A))),
                    Expanded(child: Container(color: const Color(0xFFFCD116))),
                    Expanded(child: Container(color: const Color(0xFFCE1126))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnfantCard(EnfantBrief enfant) {
    final age = _calculerAge(enfant.dateDeNaissance);
    final sexeNormalise = _convertirSexeBackendVersFrontend(enfant.sexe);
    final sexeText = sexeNormalise == 'MASCULIN' ? 'Masculin' : 'Féminin';
    final dateNaissance = _formatDate(enfant.dateDeNaissance);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primaryPink.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  sexeNormalise == 'MASCULIN' ? Icons.boy : Icons.girl,
                  color: AppColors.primaryPink,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enfant.nomComplet,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$age • $sexeText',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: AppColors.primaryPink),
                onPressed: () => _modifierEnfant(enfant),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          _buildInfoRow('Date de naissance', dateNaissance),
          _buildDivider(),
          _buildInfoRow('Sexe', sexeText),
          _buildDivider(),
          _buildInfoRow('Âge', age),
          // Section Vaccinations
          _buildVaccinationsSection(enfant.id),
        ],
      ),
    );
  }

  /// Construit la section des vaccinations pour un enfant
  Widget _buildVaccinationsSection(int enfantId) {
    final vaccinations = _vaccinationsParEnfant[enfantId] ?? [];
    
    if (vaccinations.isEmpty) {
      return const SizedBox.shrink();
    }

    final vaccinationsFaites = vaccinations.where((v) => v.isFait).toList();
    final vaccinationsAFaire = vaccinations.where((v) => v.isAFaire).toList();

    // Trier les vaccinations à faire par date prévue
    vaccinationsAFaire.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.datePrevue);
        final dateB = DateTime.parse(b.datePrevue);
        return dateA.compareTo(dateB);
      } catch (e) {
        return 0;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 12),
        // Titre de la section
        Row(
          children: [
            Icon(Icons.vaccines, color: AppColors.primaryColor, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Vaccinations',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Prochaines vaccinations
        if (vaccinationsAFaire.isNotEmpty) ...[
          Text(
            'Prochaines vaccinations (${vaccinationsAFaire.length})',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          ...vaccinationsAFaire.take(3).map((vacc) => _buildVaccinationItem(vacc, isFait: false)),
          if (vaccinationsAFaire.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${vaccinationsAFaire.length - 3} autre(s) vaccination(s) à venir',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          const SizedBox(height: 12),
        ],
        // Vaccinations réalisées
        if (vaccinationsFaites.isNotEmpty) ...[
          Text(
            'Vaccinations réalisées (${vaccinationsFaites.length})',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 8),
          ...vaccinationsFaites.take(3).map((vacc) => _buildVaccinationItem(vacc, isFait: true)),
          if (vaccinationsFaites.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${vaccinationsFaites.length - 3} autre(s) vaccination(s) réalisée(s)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
        // Message si aucune vaccination
        if (vaccinationsAFaire.isEmpty && vaccinationsFaites.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Aucune vaccination enregistrée',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  /// Construit un élément de vaccination
  Widget _buildVaccinationItem(Vaccination vaccination, {required bool isFait}) {
    String dateStr = '';
    try {
      final date = DateTime.parse(isFait ? (vaccination.dateRealisee ?? vaccination.datePrevue) : vaccination.datePrevue);
      dateStr = DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      dateStr = isFait ? (vaccination.dateRealisee ?? vaccination.datePrevue) : vaccination.datePrevue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFait ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isFait ? Colors.green.shade200 : Colors.orange.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isFait ? Icons.check_circle : Icons.pending_outlined,
            color: isFait ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vaccination.nomVaccin,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (isFait)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Fait',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'À faire',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
              fontWeight: FontWeight.w500,
            ),
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

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

/// Dialogue pour ajouter ou modifier un enfant
class _AjouterModifierEnfantDialog extends StatefulWidget {
  final EnfantBrief? enfant;

  const _AjouterModifierEnfantDialog({this.enfant});

  @override
  State<_AjouterModifierEnfantDialog> createState() =>
      _AjouterModifierEnfantDialogState();
}

class _AjouterModifierEnfantDialogState
    extends State<_AjouterModifierEnfantDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _dateNaissanceController = TextEditingController();
  String _selectedSexe = 'MASCULIN';
  DateTime? _selectedDate;
  bool _isLoading = false;

  final EnfantService _service = EnfantService();

  @override
  void initState() {
    super.initState();
    if (widget.enfant != null) {
      _nomController.text = widget.enfant!.nom;
      _prenomController.text = widget.enfant!.prenom;
      _dateNaissanceController.text =
          DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.enfant!.dateDeNaissance));
      // Convertir le sexe du format backend vers le format frontend
      _selectedSexe = _convertirSexeBackendVersFrontend(widget.enfant!.sexe);
      _selectedDate = DateTime.parse(widget.enfant!.dateDeNaissance);
    }
  }

  /// Convertit le sexe du format backend (GARCON/FILLE) vers le format frontend (MASCULIN/FEMININ)
  String _convertirSexeBackendVersFrontend(String sexe) {
    switch (sexe.toUpperCase()) {
      case 'GARCON':
        return 'MASCULIN';
      case 'FILLE':
        return 'FEMININ';
      case 'MASCULIN':
      case 'FEMININ':
        return sexe.toUpperCase();
      default:
        return 'MASCULIN';
    }
  }

  /// Convertit le sexe du format frontend (MASCULIN/FEMININ) vers le format backend (GARCON/FILLE)
  String _convertirSexeFrontendVersBackend(String sexe) {
    switch (sexe.toUpperCase()) {
      case 'MASCULIN':
        return 'GARCON';
      case 'FEMININ':
        return 'FILLE';
      case 'GARCON':
      case 'FILLE':
        return sexe.toUpperCase();
      default:
        return 'GARCON';
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _dateNaissanceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateNaissanceController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _sauvegarder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      await MessageHelper.showError(
        context: context,
        message: 'Veuillez sélectionner une date de naissance',
        title: 'Champ requis',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final patienteId = prefs.getInt('user_id');

      if (patienteId == null) {
        throw Exception('ID patiente non trouvé');
      }

      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      // Convertir le sexe du format frontend vers le format backend
      final sexeBackend = _convertirSexeFrontendVersBackend(_selectedSexe);
      final request = EnfantRequest(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        dateDeNaissance: dateStr,
        sexe: sexeBackend,
        patienteId: patienteId,
      );

      ApiResponse response;
      if (widget.enfant != null) {
        // Mise à jour
        response = await _service.updateEnfant(widget.enfant!.id, request);
      } else {
        // Création
        response = await _service.createEnfant(request);
      }

      if (!mounted) return;

      if (response.success) {
        Navigator.pop(context, {'success': true});
        await MessageHelper.showSuccess(
          context: context,
          message: widget.enfant != null
              ? 'Enfant mis à jour avec succès'
              : 'Enfant ajouté avec succès',
          title: 'Succès',
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        await MessageHelper.showApiResponse(
          context: context,
          response: response,
          errorTitle: 'Erreur',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        await MessageHelper.showError(
          context: context,
          message: 'Erreur: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.enfant != null ? 'Modifier l\'enfant' : 'Ajouter un enfant',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                // Nom
                TextFormField(
                  controller: _nomController,
                  decoration: InputDecoration(
                    labelText: 'Nom *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le nom est requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Prénom
                TextFormField(
                  controller: _prenomController,
                  decoration: InputDecoration(
                    labelText: 'Prénom *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le prénom est requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Date de naissance
                TextFormField(
                  controller: _dateNaissanceController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Date de naissance *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La date de naissance est requise';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Sexe
                DropdownButtonFormField<String>(
                  value: _selectedSexe,
                  decoration: InputDecoration(
                    labelText: 'Sexe *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.people),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'MASCULIN',
                      child: Text('Masculin'),
                    ),
                    DropdownMenuItem(
                      value: 'FEMININ',
                      child: Text('Féminin'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedSexe = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                // Boutons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _sauvegarder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPink,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(widget.enfant != null ? 'Modifier' : 'Ajouter'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

