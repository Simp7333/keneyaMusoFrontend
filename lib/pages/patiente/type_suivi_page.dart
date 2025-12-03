import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes.dart';
import '../../widgets/page_animation_mixin.dart';
import '../common/app_colors.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';

class TypeSuiviPage extends StatefulWidget {
  const TypeSuiviPage({super.key});

  @override
  State<TypeSuiviPage> createState() => _TypeSuiviPageState();
}

class _TypeSuiviPageState extends State<TypeSuiviPage>
    with TickerProviderStateMixin, PageAnimationMixin {
  String? _selectedSuiviType;
  String _prenom = '';
  AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _loadUserData();
  }

  Future<void> _initAudioPlayer() async {
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _prenom = prefs.getString('user_prenom') ?? 'Patiente';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Image.asset(
              'assets/images/Choixsuivi.png',
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.40,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: 0,
            right: 0,
            bottom: 0,
            child: SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Heureuse de vous revoir',
                            style: TextStyle(fontSize: 22, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(_prenom,
                                style: const TextStyle(
                                    fontSize: 34, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            const Text('🎉', style: TextStyle(fontSize: 28)),
                            const Spacer(),
                            GestureDetector(
                              onTap: _lireVoixTypeSuivi,
                              child: Container(
                                width: 48,
                                height: 48,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _isPlaying 
                                      ? AppColors.primaryPink.withOpacity(0.5)
                                      : AppColors.primaryPink.withOpacity(0.25),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isPlaying ? Icons.volume_off : Icons.volume_up,
                                  color: AppColors.primaryPink,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                            'Dites-nous quel type de suivi vous souhaitez effectuer',
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 32),
                        _buildSuiviCard(
                          title: 'Suivi Prénatal',
                          icon: Icons.pregnant_woman,
                          isSelected: _selectedSuiviType == 'prenatal',
                          onTap: () =>
                              setState(() => _selectedSuiviType = 'prenatal'),
                        ),
                        const SizedBox(height: 16),
                        _buildSuiviCard(
                          title: 'Suivi Postnatal',
                          icon: Icons.baby_changing_station,
                          isSelected: _selectedSuiviType == 'postnatal',
                          onTap: () =>
                              setState(() => _selectedSuiviType = 'postnatal'),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _selectedSuiviType != null
                                ? _proceedToDashboard
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryPink.withOpacity(0.63),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text('Suivant', style: TextStyle(fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuiviCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryPink.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
              spreadRadius: 4,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 28,
              color: Colors.black,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _lireVoixTypeSuivi() async {
    if (_isPlaying) {
      // Arrêter la lecture si elle est en cours
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
      });
      return;
    }

    try {
      // Essayer différents formats dans l'ordre de préférence
      final audioAssetPaths = [
        'assets/audio/type_suivi_voix.mp3',
        'assets/audio/type_suivi_voix.m4a',
        'assets/audio/type_suivi_voix.aac',
      ];
      
      String? workingPath;
      Exception? lastError;
      
      // Essayer chaque format jusqu'à trouver un qui fonctionne
      for (final assetPath in audioAssetPaths) {
        try {
          print('🔊 Tentative de chargement audio depuis asset: $assetPath');
          
          // Charger le fichier depuis les assets en tant que ByteData
          ByteData data;
          try {
            data = await rootBundle.load(assetPath);
          } catch (e) {
            print('⚠️ Fichier $assetPath non trouvé dans les assets: $e');
            continue;
          }
          
          // Créer un fichier temporaire
          final tempDir = await getTemporaryDirectory();
          final extension = assetPath.split('.').last;
          final tempFile = File('${tempDir.path}/type_suivi_voix_${DateTime.now().millisecondsSinceEpoch}.$extension');
          await tempFile.writeAsBytes(data.buffer.asUint8List());
          
          print('📁 Fichier temporaire créé: ${tempFile.path}');
          
          // Réinitialiser le lecteur
          await _audioPlayer.stop();
          
          // Charger le fichier temporaire
          await _audioPlayer.setFilePath(tempFile.path);
          
          // Vérifier si le fichier est valide en essayant de récupérer la durée
          final duration = await _audioPlayer.duration;
          if (duration != null && duration > Duration.zero) {
            workingPath = tempFile.path;
            print('✅ Fichier audio valide trouvé: $assetPath (durée: ${duration.inSeconds}s)');
            break;
          }
        } catch (e) {
          print('⚠️ Format $assetPath non supporté: $e');
          lastError = e is Exception ? e : Exception(e.toString());
          continue;
        }
      }
      
      if (workingPath == null) {
        throw lastError ?? Exception('Aucun format audio supporté trouvé. Formats essayés: ${audioAssetPaths.join(", ")}');
      }
      
      // Jouer l'audio
      await _audioPlayer.play();
      
      setState(() {
        _isPlaying = true;
      });
      
      print('✅ Lecture audio démarrée: $workingPath');
    } catch (e, stackTrace) {
      print('❌ Erreur lecture audio: $e');
      print('📋 Stack trace: $stackTrace');
      setState(() {
        _isPlaying = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: Impossible de lire le fichier audio. Vérifiez que le fichier existe dans assets/audio/ et qu\'il est dans un format valide (MP3, M4A). Erreur: ${e.toString().substring(0, e.toString().length > 100 ? 100 : e.toString().length)}...'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }
  }

  void _proceedToDashboard() async {
    if (_selectedSuiviType != null) {
      // Sauvegarder le type de suivi
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('suiviType', _selectedSuiviType!);

      // Afficher un message de confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Type de suivi sélectionné: ${_selectedSuiviType == 'prenatal' ? 'Prénatal' : 'Postnatal'}'),
          backgroundColor: AppColors.primaryPink.withOpacity(0.63),
        ),
      );
      
      // Navigation selon le type de suivi sélectionné
      if (_selectedSuiviType == 'prenatal') {
        // Redirection vers la page d'enregistrement de grossesse
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.patienteEnregistrementGrossesse,
        );
      } else {
        // Redirection vers la page d'enregistrement de l'accouchement
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.patienteEnregistrementAccouchement,
        );
      }
    }
  }
}
