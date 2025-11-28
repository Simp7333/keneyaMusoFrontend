import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';
import '../../config/api_config.dart';

class PageDetailVideo extends StatefulWidget {
  final String title;
  final String videoUrl;
  final String? contenu; // Contenu/description du conseil

  const PageDetailVideo({
    super.key,
    required this.title,
    required this.videoUrl,
    this.contenu,
  });

  @override
  State<PageDetailVideo> createState() => _PageDetailVideoState();
}

class _PageDetailVideoState extends State<PageDetailVideo> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() async {
    // Construire l'URL complète si c'est un chemin relatif
    String videoUrl = widget.videoUrl;
    if (videoUrl.startsWith('/uploads/') || videoUrl.startsWith('/api/')) {
      videoUrl = '${ApiConfig.baseUrl}$videoUrl';
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await _controller!.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
        // Auto-play la vidéo
        _controller!.play();
        _isPlaying = true;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erreur lors du chargement de la vidéo: ${e.toString()}';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlaying() {
    if (_controller != null && _isInitialized) {
      setState(() {
        _isPlaying = !_isPlaying;
        if (_isPlaying) {
          _controller!.play();
        } else {
          _controller!.pause();
        }
      });
    }
  }

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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section vidéo en pleine largeur
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.black87,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Afficher la vidéo si elle est initialisée
                  if (_isInitialized && _controller != null)
                    GestureDetector(
                      onTap: _togglePlaying,
                      child: SizedBox(
                        width: double.infinity,
                        child: AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        ),
                      ),
                    )
                  // Afficher un indicateur de chargement
                  else if (_isLoading)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chargement de la vidéo...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  // Afficher un message d'erreur
                  else if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade300,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Erreur de chargement',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _initializeVideo,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Réessayer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    )
                  // Placeholder si pas de vidéo
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.videocam_off,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Aucune vidéo disponible',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Contrôles de lecture (barre de progression) si la vidéo est initialisée
                  if (_isInitialized && _controller != null)
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: VideoProgressIndicator(
                        _controller!,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                          playedColor: Colors.pink,
                          bufferedColor: Colors.grey.shade300,
                          backgroundColor: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  // Bouton play/pause au centre si la vidéo est en pause
                  if (_isInitialized && _controller != null && !_isPlaying)
                    IconButton(
                      icon: Icon(
                        Icons.play_circle_filled,
                        color: Colors.white.withOpacity(0.8),
                        size: 70,
                      ),
                      onPressed: _togglePlaying,
                    ),
                ],
              ),
            ),
            
            // Section contenu dans une Card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
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
                        widget.contenu ?? 'Description non disponible',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(DateTime.now()),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
