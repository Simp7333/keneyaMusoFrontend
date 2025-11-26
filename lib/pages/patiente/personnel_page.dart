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
            _filteredProfessionnels = [];
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Erreur de chargement'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _allProfessionnels = [];
          _filteredProfessionnels = [];
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

  void _filterProfessionnels() {
    setState(() {
      if (_selectedSegment == 0) {
        // Filtrer pour les sages-femmes (GENERALISTE selon la migration)
        // Les sages-femmes sont maintenant des médecins avec spécialité GENERALISTE
        _filteredProfessionnels = _allProfessionnels
            .where((p) => p.specialite.toUpperCase() == 'GENERALISTE')
            .toList();
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
