import 'package:flutter/material.dart';
import '../../models/conseil.dart';
import '../../services/conseil_service.dart';
import '../../pages/common/app_colors.dart';
import '../../pages/gynecologue/page_ajout_accompagnement.dart';
import '../../pages/gynecologue/page_detail_accompagnement.dart';
import '../../routes.dart';
import '../../widgets/pro_bottom_nav_bar.dart';

class PageAccompagnement extends StatefulWidget {
  const PageAccompagnement({super.key});

  @override
  State<PageAccompagnement> createState() => _PageAccompagnementState();
}

class _PageAccompagnementState extends State<PageAccompagnement> {
  int _bottomNavIndex = 2;
  int _selectedTabIndex = 0; // 0: Tous, 1: Prenatale, 2: Postnatale

  final ConseilService _service = ConseilService();
  List<Conseil> _allConseils = [];
  List<Conseil> _filteredConseils = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadConseils();
  }

  Future<void> _loadConseils() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Utiliser getMesConseils() pour ne récupérer que les conseils du médecin connecté
    final response = await _service.getMesConseils();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.success && response.data != null) {
          _allConseils = response.data!;
          _filterConseils();
        } else {
          _errorMessage = response.message ?? 'Erreur lors du chargement des conseils';
          _filteredConseils = [];
        }
      });
    }
  }

  void _filterConseils() {
    setState(() {
      switch (_selectedTabIndex) {
        case 1: // Prenatale
          _filteredConseils = _allConseils
              .where((c) => c.cible.toLowerCase().contains('prenatale') ||
                           c.cible.toLowerCase().contains('enceinte') ||
                           c.cible.toLowerCase().contains('grossesse'))
              .toList();
          break;
        case 2: // Postnatale
          _filteredConseils = _allConseils
              .where((c) => c.cible.toLowerCase().contains('postnatale') ||
                           c.cible.toLowerCase().contains('mère') ||
                           c.cible.toLowerCase().contains('nouveau-né'))
              .toList();
          break;
        default: // Tous
          _filteredConseils = _allConseils;
      }
    });
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
      _filterConseils();
    });
  }

  Future<void> _deleteConseil(Conseil conseil) async {
    final response = await _service.deleteConseil(conseil.id);

    if (mounted) {
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conseil supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        _loadConseils(); // Recharger la liste
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Erreur lors de la suppression'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onNavBarItemTapped(int index) {
    if (_bottomNavIndex == index) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.proDashboard);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.proPatientes);
        break;
      case 2:
        // Already on this page
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.proSettings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildTabs(),
              const SizedBox(height: 24),
              Expanded(child: _buildContentList()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const PageAjoutAccompagnement()),
          );
          // Rafraîchir la liste si un nouveau conseil a été créé
          if (result == true) {
            _loadConseils();
          }
        },
        backgroundColor: AppColors.primaryColor,
        elevation: 2,
        child: const Icon(Icons.add_chart, color: Colors.white),
      ),
      bottomNavigationBar: ProBottomNavBar(
        selectedIndex: _bottomNavIndex,
        onItemSelected: _onNavBarItemTapped,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Accompagnements',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE91E63).withOpacity(0.63),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gestion des tutoriels & conseils',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Créer et partager des contenus éducatifs pour vos patientes.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4EC),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildTabItem(0, 'Tous'),
          _buildTabItem(1, 'Prenatale'),
          _buildTabItem(2, 'Postnatale'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String text) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabChanged(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _filteredConseils.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
      );
    }

    if (_filteredConseils.isEmpty) {
      return Center(
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
              _selectedTabIndex == 0
                  ? 'Aucun conseil disponible'
                  : _selectedTabIndex == 1
                      ? 'Aucun conseil prénatal'
                      : 'Aucun conseil postnatal',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConseils,
      child: ListView.builder(
        itemCount: _filteredConseils.length,
        itemBuilder: (context, index) {
          return _buildContentItem(_filteredConseils[index]);
        },
      ),
    );
  }

  Widget _buildContentItem(Conseil conseil) {
    // Déterminer l'icône et la couleur selon le type
    // Le type est déterminé automatiquement par le modèle Conseil
    final isVideo = conseil.type == 'video';
    final icon = isVideo ? Icons.videocam : Icons.article;
    final color = isVideo ? Colors.blue.shade400 : Colors.green.shade400;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conseil.titre,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Catégorie : ${conseil.categorieFormatee}',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  conseil.dateFormatee.isNotEmpty 
                      ? conseil.dateFormatee 
                      : conseil.cible,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _showDeleteConfirmation(conseil);
            },
            icon: const Icon(Icons.delete_outline, color: Colors.black54),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PageDetailAccompagnement(
                    title: conseil.titre,
                    category: 'Catégorie : ${conseil.categorieFormatee}',
                    date: conseil.dateFormatee.isNotEmpty 
                        ? conseil.dateFormatee 
                        : conseil.cible,
                    type: isVideo 
                        ? ContentType.video 
                        : ContentType.conseil,
                    content: conseil.contenu ?? 'Aucun contenu disponible',
                    mediaUrl: conseil.lienMedia,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.visibility_outlined, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // Vérifier si une URL est une vidéo
  bool _isVideoUrl(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.mp4') ||
        lowerUrl.endsWith('.mpeg') ||
        lowerUrl.endsWith('.mpg') ||
        lowerUrl.endsWith('.avi') ||
        lowerUrl.endsWith('.mov') ||
        lowerUrl.endsWith('.wmv') ||
        lowerUrl.endsWith('.flv') ||
        lowerUrl.endsWith('.webm') ||
        lowerUrl.endsWith('.mkv') ||
        lowerUrl.endsWith('.m4v') ||
        lowerUrl.endsWith('.3gp') ||
        lowerUrl.contains('youtube') ||
        lowerUrl.contains('youtu.be') ||
        lowerUrl.contains('vimeo') ||
        (lowerUrl.startsWith('/uploads/') && (
          lowerUrl.contains('.mp4') ||
          lowerUrl.contains('.mpeg') ||
          lowerUrl.contains('.avi') ||
          lowerUrl.contains('.mov')
        ));
  }

  void _showDeleteConfirmation(Conseil conseil) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer "${conseil.titre}" ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteConseil(conseil);
              },
              child: Text(
                'Supprimer',
                style: TextStyle(color: AppColors.primaryPink),
              ),
            ),
          ],
        );
      },
    );
  }
}
