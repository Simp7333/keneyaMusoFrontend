import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/carte_contenu.dart';
import '../../widgets/carte_video.dart';
import '../../widgets/carte_audio.dart';
import '../../routes.dart';
import '../common/app_colors.dart';

class PageContenu extends StatefulWidget {
  const PageContenu({super.key});

  @override
  State<PageContenu> createState() => _PageContenuState();
}

class _PageContenuState extends State<PageContenu> with TickerProviderStateMixin {
  int _currentIndex = 1; // Content page is selected
  int _selectedSegment = 0; // Conseils is selected
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String _suiviType = 'prenatal'; // Default value

  @override
  void initState() {
    super.initState();
    _loadSuiviType();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    _fadeController.forward();
  }

  Future<void> _loadSuiviType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _suiviType = prefs.getString('suiviType') ?? 'prenatal';
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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
        Navigator.pushReplacementNamed(context, AppRoutes.patienteSettings);
        break;
    }
  }

  void _onSegmentChanged(int index) {
    setState(() {
      _selectedSegment = index;
    });
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

            // Segmented Control
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFFCE4EC),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  _buildSegmentButton('Conseils', 0),
                  _buildSegmentButton('Vidéos', 1),
                  _buildSegmentButton('Audio', 2),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: _buildContent(),
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

  Widget _buildSegmentButton(String text, int index) {
    final isSelected = _selectedSegment == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onSegmentChanged(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryPink.withOpacity(0.9)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_suiviType == 'prenatal') {
      return _buildPrenatalContent();
    } else {
      return _buildPostnatalContent();
    }
  }

  Widget _buildPrenatalContent() {
    switch (_selectedSegment) {
      case 0: // Conseils
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CPN1',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              const CarteContenu(
                category: 'Alimentation,',
                content:
                    'Mangez équilibré : fruits, légumes, protéines (viande maigre, poisson, œufs, légumineuses), céréales complètes',
                date: '2 septembre',
                hasNewIndicator: true,
              ),
              const CarteContenu(
                category: 'Activité physique,',
                content:
                    'Pratiquez une activité douce et régulière (marche, natation, yoga prénatal)',
                date: '25 Aout',
              ),
              const CarteContenu(
                category: 'Sommeil et repos,',
                content:
                    'Dormez sur le côté gauche pour améliorer la circulation sanguine vers le bébé',
                date: '18 Aout',
              ),
              const SizedBox(height: 24),
              const Text(
                'CPN2',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              // Add CPN2 cards here if any
            ],
          ),
        );
      case 1: // Vidéos
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVideoSection('CPN1', ['assets/images/D1.jpg', 'assets/images/D2.jpg']),
              _buildVideoSection('CPN2', ['assets/images/D3.jpg', 'assets/images/D1.jpg']),
              _buildVideoSection('CPN3', ['assets/images/D2.jpg', 'assets/images/D3.jpg']),
            ],
          ),
        );
      case 2: // Audio
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAudioSection('CPN1', 3),
              _buildAudioSection('CPN2', 1),
            ],
          ),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildPostnatalContent() {
     switch (_selectedSegment) {
      case 0: // Conseils
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CPON1',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              const CarteContenu(
                category: 'Soins du bébé,',
                content: 'Gardez le cordon ombilical propre et sec jusqu\'à ce qu\'il tombe.',
                date: '10 octobre',
                hasNewIndicator: true,
              ),
              const CarteContenu(
                category: 'Alimentation,',
                content: 'Allaitement exclusif recommandé les 6 premiers mois. Buvez beaucoup d\'eau.',
                date: '10 octobre',
              ),
            ],
          ),
        );
      case 1: // Vidéos
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVideoSection('CPON1', ['assets/images/D1.jpg']),
            ],
          ),
        );
      case 2: // Audio
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAudioSection('CPON1', 1),
            ],
          ),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildVideoSection(String title, List<String> videoImageUrls) {
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
          itemCount: videoImageUrls.length,
          itemBuilder: (context, index) {
            return CarteVideo(
              title: 'CPN 2 mois',
              date: '04/10/2025',
              imageUrl: videoImageUrls[index],
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lecture de la vidéo ${index + 1} de $title')),
                );
              },
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAudioSection(String title, int count) {
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
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: count,
          itemBuilder: (context, index) {
            return CarteAudio(
              title: 'Tutoriel CPN 6mois de grossesse',
              date: '04/10/2025',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lecture de l\'audio ${index + 1} de $title')),
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
