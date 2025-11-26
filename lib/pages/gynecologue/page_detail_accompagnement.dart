import 'package:flutter/material.dart';
import '../../pages/common/app_colors.dart';
import '../../config/api_config.dart';

// Enum simplifié pour les types de contenu : video ou conseil
enum ContentType { video, conseil }

class PageDetailAccompagnement extends StatefulWidget {
  final String title;
  final String category;
  final String date;
  final ContentType type;
  final String content;
  final String? mediaUrl;

  const PageDetailAccompagnement({
    super.key,
    required this.title,
    required this.category,
    required this.date,
    required this.type,
    required this.content,
    this.mediaUrl,
  });

  @override
  State<PageDetailAccompagnement> createState() => _PageDetailAccompagnementState();
}

class _PageDetailAccompagnementState extends State<PageDetailAccompagnement> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Détail du contenu',
          style: TextStyle(
            color: AppColors.primaryPink.withOpacity(0.8),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Media section
                _buildMediaSection(),
                
                // Content section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Category and Type
                      Row(
                        children: [
                          _buildTypeChip(),
                          const SizedBox(width: 8),
                          _buildCategoryChip(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Description section
                      const Text(
                        'DESCRIPTION',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.content,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Date
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          widget.date,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            icon: Icons.edit,
                            label: 'Modifier',
                            onPressed: () {
                              // TODO: Navigate to edit page
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.share,
                            label: 'Partager',
                            onPressed: () {
                              // TODO: Share functionality
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.delete,
                            label: 'Supprimer',
                            onPressed: () {
                              _showDeleteConfirmation();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaSection() {
    switch (widget.type) {
      case ContentType.video:
        return _buildVideoSection();
      case ContentType.conseil:
        return _buildArticleSection();
    }
  }

  Widget _buildVideoSection() {
    // Construire l'URL complète si c'est un chemin relatif
    String? videoUrl = widget.mediaUrl;
    if (videoUrl != null && videoUrl.isNotEmpty) {
      if (videoUrl.startsWith('/uploads/') || videoUrl.startsWith('/api/')) {
        // C'est un chemin relatif, ajouter le baseUrl
        videoUrl = '${ApiConfig.baseUrl}$videoUrl';
      }
    }
    
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Container(
        height: 200,
        color: Colors.black87,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Afficher l'URL de la vidéo si disponible
            if (videoUrl != null && videoUrl.isNotEmpty)
              Container(
                width: double.infinity,
                height: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.videocam,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vidéo disponible',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      videoUrl.length > 50 
                          ? '${videoUrl.substring(0, 50)}...' 
                          : videoUrl,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.purple.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline,
                color: Colors.white,
                size: 70,
              ),
              onPressed: () {
                setState(() {
                  _isPlaying = !_isPlaying;
                });
                // TODO: Implémenter la lecture vidéo avec video_player ou autre package
                if (videoUrl != null && videoUrl.isNotEmpty) {
                  // Ouvrir la vidéo dans un lecteur
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lecture de la vidéo: $videoUrl'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleSection() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.teal.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.article,
          color: Colors.white,
          size: 60,
        ),
      ),
    );
  }

  Widget _buildTypeChip() {
    Color color;
    IconData icon;
    
    switch (widget.type) {
      case ContentType.video:
        color = Colors.blue.shade400;
        icon = Icons.videocam;
        break;
      case ContentType.conseil:
        color = Colors.green.shade400;
        icon = Icons.article;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            widget.type.name.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryPink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryPink.withOpacity(0.3)),
      ),
      child: Text(
        widget.category,
        style: TextStyle(
          color: AppColors.primaryPink.withOpacity(0.8),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primaryPink.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: IconButton(
            icon: Icon(icon, color: AppColors.primaryPink),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Êtes-vous sûr de vouloir supprimer ce contenu ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contenu supprimé avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
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
