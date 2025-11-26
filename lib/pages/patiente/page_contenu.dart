import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/carte_video.dart';
import '../../routes.dart';
import '../common/app_colors.dart';
import 'package:keneya_muso/services/conseil_service.dart'; // Utiliser ConseilService au lieu de NotificationService
import 'package:keneya_muso/models/conseil.dart'; // Import du modèle Conseil

class PageContenu extends StatefulWidget {
  const PageContenu({super.key});

  @override
  State<PageContenu> createState() => _PageContenuState();
}

class _PageContenuState extends State<PageContenu> {
  int _currentIndex = 1; // Content page is selected
  String _suiviType = 'prenatal'; // Default value
  final ConseilService _conseilService = ConseilService(); // Utiliser ConseilService
  List<Conseil> _conseils = []; // Liste pour stocker les conseils
  bool _isLoading = true; // Pour gérer l'état de chargement
  String? _errorMessage; // Pour gérer les erreurs

  @override
  void initState() {
    super.initState();
    _loadSuiviType(); // _loadSuiviType() appelle déjà _loadConseils() maintenant
  }

  Future<void> _loadSuiviType() async {
    final prefs = await SharedPreferences.getInstance();
    final suiviType = prefs.getString('suiviType') ?? 'prenatal';
    setState(() {
      _suiviType = suiviType;
    });
    // Recharger les conseils avec le bon type de suivi
    _loadConseils();
  }

  Future<void> _loadConseils() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Charger uniquement les conseils pertinents pour la patiente selon son type de suivi
      final response = await _conseilService.getConseilsPourPatiente(
        typeSuivi: _suiviType, // 'prenatal' ou 'postnatal'
      );
      
      if (mounted) {
        if (response.success && response.data != null) {
          print('✅ Conseils chargés pour $_suiviType: ${response.data!.length}');
          setState(() {
            _conseils = response.data!;
            _isLoading = false;
          });
        } else {
          print('❌ Erreur de chargement des conseils: ${response.message}');
          setState(() {
            _errorMessage = response.message ?? 'Erreur lors du chargement des conseils';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('💥 Exception lors du chargement: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }


  void _onItemTapped(int index) {
    if (index == _currentIndex) return;

    switch (index) {
      case 0:
        // Navigate to the correct dashboard based on suiviType
        if (_suiviType == 'prenatal') {
          Navigator.pushReplacementNamed(context, AppRoutes.patienteDashboard);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.patienteDashboardPostnatal);
        }
        break;
      case 1:
        // Already on this page
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Contenu',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPink.withOpacity(0.9),
                ),
              ),
            ),

            // Content Area
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
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
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _loadConseils,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Réessayer'),
                              ),
                            ],
                          ),
                        )
                      : _buildContent(),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildContent() {
    if (_suiviType == 'prenatal') {
      return _buildPrenatalVideos();
    } else {
      return _buildPostnatalVideos();
    }
  }

  Widget _buildPrenatalVideos() {
    // Les conseils sont déjà filtrés côté backend selon le type de suivi
    // Aucun filtrage supplémentaire nécessaire
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVideoSection('Conseils pour la Grossesse', _conseils),
        ],
      ),
    );
  }

  Widget _buildPostnatalVideos() {
    // Les conseils sont déjà filtrés côté backend selon le type de suivi
    // Aucun filtrage supplémentaire nécessaire
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVideoSection('Conseils Postnatals', _conseils),
        ],
      ),
    );
  }

  Widget _buildVideoSection(String title, List<Conseil> conseils) {
    if (conseils.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Aucun contenu disponible pour le moment',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: conseils.length,
          itemBuilder: (context, index) {
            final conseil = conseils[index];
            // Utiliser une image par défaut ou une image de placeholder
            String imageUrl = 'assets/images/Contenu VIDEOS.png'; // Image par défaut
            
            // Si c'est une vidéo avec un lien, on peut utiliser une miniature
            if (conseil.lienMedia != null && conseil.lienMedia!.isNotEmpty) {
              // Pour les vidéos YouTube, on pourrait extraire une miniature
              // Pour l'instant, on utilise l'image par défaut
            }
            
            // Formater la date
            String dateStr = 'Aujourd\'hui';
            if (conseil.dateCreation != null) {
              final date = conseil.dateCreation!;
              final now = DateTime.now();
              final diff = now.difference(date);
              
              if (diff.inDays == 0) {
                dateStr = 'Aujourd\'hui';
              } else if (diff.inDays == 1) {
                dateStr = 'Hier';
              } else if (diff.inDays < 7) {
                dateStr = 'Il y a ${diff.inDays} jours';
              } else {
                dateStr = '${date.day}/${date.month}/${date.year}';
              }
            }
            
            return CarteVideo(
              title: conseil.titre,
              date: dateStr,
              imageUrl: imageUrl,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.patienteDetailVideo,
                  arguments: {
                    'title': conseil.titre,
                    'videoUrl': conseil.lienMedia ?? '',
                    'contenu': conseil.contenu ?? '',
                  },
                );
              },
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

}
