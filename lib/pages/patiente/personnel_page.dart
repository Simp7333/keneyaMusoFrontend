import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/carte_personnel.dart';
import '../../routes.dart';
import '../common/app_colors.dart';
import 'package:keneya_muso/services/professionnel_sante_service.dart'; // Import du nouveau service
import 'package:keneya_muso/models/professionnel_sante.dart'; // Import du modèle ProfessionnelSante

class PersonnelPage extends StatefulWidget {
  const PersonnelPage({super.key});

  @override
  State<PersonnelPage> createState() => _PersonnelPageState();
}

class _PersonnelPageState extends State<PersonnelPage> {
  int _selectedIndex = 2; // Personnel page is selected
  String _suiviType = 'prenatal';
  int _selectedSegment = 0; // 0 for Sage femme, 1 for Medcin
  final ProfessionnelSanteService _professionnelSanteService = ProfessionnelSanteService();
  List<ProfessionnelSante> _allProfessionnels = [];
  List<ProfessionnelSante> _filteredProfessionnels = [];
  bool _isLoading = true;

  // Sages-femmes statiques pour la section
  static final List<ProfessionnelSante> _staticSagesFemmes = [
    ProfessionnelSante(
      id: 1001,
      nom: 'Diallo',
      prenom: 'Aissata',
      telephone: '761234567',
      specialite: 'SAGE_FEMME',
      identifiantProfessionnel: 'SF001',
      adresse: 'Bamako, Commune IV, Avenue du Mali',
      centreSante: 'Centre de Santé de Référence de Commune IV',
      heureVisites: 'Lundi - Vendredi: 8h - 16h',
      nombreSuivis: 45,
    ),
    ProfessionnelSante(
      id: 1002,
      nom: 'Traoré',
      prenom: 'Fatoumata',
      telephone: '762345678',
      specialite: 'SAGE_FEMME',
      identifiantProfessionnel: 'SF002',
      adresse: 'Bamako, Commune I, Quartier Niaréla',
      centreSante: 'Centre de Santé Communautaire de Niaréla',
      heureVisites: 'Lundi - Samedi: 7h - 18h',
      nombreSuivis: 62,
    ),
    ProfessionnelSante(
      id: 1003,
      nom: 'Keita',
      prenom: 'Mariam',
      telephone: '763456789',
      specialite: 'SAGE_FEMME',
      identifiantProfessionnel: 'SF003',
      adresse: 'Bamako, Commune II, Badalabougou',
      centreSante: 'Centre de Santé de Badalabougou',
      heureVisites: 'Lundi - Vendredi: 9h - 17h',
      nombreSuivis: 38,
    ),
    ProfessionnelSante(
      id: 1004,
      nom: 'Sangaré',
      prenom: 'Aminata',
      telephone: '764567890',
      specialite: 'SAGE_FEMME',
      identifiantProfessionnel: 'SF004',
      adresse: 'Bamako, Commune VI, Faladié',
      centreSante: 'Centre de Santé de Faladié',
      heureVisites: 'Lundi - Vendredi: 8h - 15h',
      nombreSuivis: 51,
    ),
    ProfessionnelSante(
      id: 1005,
      nom: 'Coulibaly',
      prenom: 'Kadiatou',
      telephone: '765678901',
      specialite: 'SAGE_FEMME',
      identifiantProfessionnel: 'SF005',
      adresse: 'Bamako, Commune III, Sotuba',
      centreSante: 'Centre de Santé de Sotuba',
      heureVisites: 'Lundi - Samedi: 8h - 17h',
      nombreSuivis: 67,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadSuiviType();
    _loadProfessionnelsSante();
  }

  Future<void> _loadSuiviType() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _suiviType = prefs.getString('suiviType') ?? 'prenatal';
      });
    }
  }

  Future<void> _loadProfessionnelsSante() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final response = await _professionnelSanteService.getAllProfessionnelsSante();
      if (response.success && response.data != null) {
        setState(() {
          _allProfessionnels = response.data!;
          _filterProfessionnels();
          _isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _allProfessionnels = [];
            // Même en cas d'erreur, filtrer pour afficher les sages-femmes statiques
            _filterProfessionnels();
            _isLoading = false;
          });
          // Ne pas afficher d'erreur si on a des données statiques à afficher
          if (_filteredProfessionnels.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.message ?? 'Erreur de chargement'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _allProfessionnels = [];
          // Même en cas d'erreur, filtrer pour afficher les sages-femmes statiques
          _filterProfessionnels();
          _isLoading = false;
        });
        // Ne pas afficher d'erreur si on a des données statiques à afficher
        if (_filteredProfessionnels.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _filterProfessionnels() {
    setState(() {
      if (_selectedSegment == 0) {
        // Filtrer pour les sages-femmes (SAGE_FEMME ou GENERALISTE)
        final sagesFemmesFromBackend = _allProfessionnels
            .where((p) => 
                p.specialite.toUpperCase() == 'SAGE_FEMME' ||
                p.specialite.toUpperCase() == 'GENERALISTE')
            .toList();
        
        // Combiner avec les sages-femmes statiques
        // Éviter les doublons en vérifiant les IDs
        final backendIds = sagesFemmesFromBackend.map((p) => p.id).toSet();
        final staticSagesFemmes = _staticSagesFemmes
            .where((p) => !backendIds.contains(p.id))
            .toList();
        
        _filteredProfessionnels = [...sagesFemmesFromBackend, ...staticSagesFemmes];
      } else {
        // Filtrer pour les médecins spécialisés (GYNECOLOGUE, PEDIATRE)
        _filteredProfessionnels = _allProfessionnels
            .where((p) => 
                p.specialite.toUpperCase() == 'GYNECOLOGUE' || 
                p.specialite.toUpperCase() == 'PEDIATRE')
            .toList();
      }
    });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        if (_suiviType == 'prenatal') {
          Navigator.pushReplacementNamed(context, AppRoutes.patienteDashboard);
        } else {
          Navigator.pushReplacementNamed(
              context, AppRoutes.patienteDashboardPostnatal);
        }
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.patienteContent);
        break;
      case 2:
        // Already on this page
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Nos Personnels',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE91E63).withOpacity(0.63),
                ),
              ),
            ),
            _buildSegmentedControl(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadProfessionnelsSante,
                      child: _filteredProfessionnels.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _selectedSegment == 0 
                                        ? Icons.medical_services_outlined 
                                        : Icons.person_outline,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aucun professionnel trouvé pour cette catégorie.',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: _filteredProfessionnels.length,
                              itemBuilder: (context, index) {
                                final professionnel = _filteredProfessionnels[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: CartePersonnel(
                                    name: professionnel.fullName,
                                    title: _formatSpecialite(professionnel.specialite),
                                    location: professionnel.adresse ?? 'Adresse non spécifiée',
                                    imageUrl: professionnel.imageUrl ?? 'assets/images/docP.png',
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.patienteProfilPersonnel,
                                        arguments: {
                                          'professionnelId': professionnel.id,
                                        },
                                      ).then((_) {
                                        // Rafraîchir après retour si nécessaire
                                        _loadProfessionnelsSante();
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.patienteDiscussion);
        },
        backgroundColor: Color(0xFFE91E63).withOpacity(0.63),
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  String _formatSpecialite(String specialite) {
    // Formater la spécialité pour l'affichage
    switch (specialite.toUpperCase()) {
      case 'GYNECOLOGUE':
        return 'Gynécologue';
      case 'PEDIATRE':
        return 'Pédiatre';
      case 'GENERALISTE':
        return 'Médecin généraliste / Sage-femme';
      case 'SAGE_FEMME':
        return 'Sage-femme';
      default:
        return specialite;
    }
  }

  Widget _buildSegmentedControl() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFFE91E63).withOpacity(0.1),
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSegmentButton('Sage femme', 0),
          ),
          Expanded(
            child: _buildSegmentButton('Medcin', 1),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(String text, int index) {
    bool isSelected = _selectedSegment == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSegment = index;
          _filterProfessionnels(); // Appeler le filtrage lorsque le segment change
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFE91E63).withOpacity(0.63) : Colors.transparent,
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Color(0xFFE91E63).withOpacity(0.63),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
