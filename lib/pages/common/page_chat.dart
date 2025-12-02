import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:keneya_muso/pages/common/app_colors.dart';
import 'package:keneya_muso/services/message_service.dart';
import 'package:keneya_muso/services/conversation_service.dart';
import 'package:keneya_muso/models/message.dart';
import 'package:keneya_muso/models/conversation.dart';
import 'package:keneya_muso/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io';

class PageChat extends StatefulWidget {
  final int conversationId;
  final String? medecinNom;
  final String? medecinPrenom;
  final String? medecinImageUrl;

  const PageChat({
    super.key,
    required this.conversationId,
    this.medecinNom,
    this.medecinPrenom,
    this.medecinImageUrl,
  });

  @override
  State<PageChat> createState() => _PageChatState();
}

class _PageChatState extends State<PageChat> {
  late AudioPlayer _player;
  bool _isPlaying = false;
  String? _currentlyPlayingPath;
  // Map pour stocker la durée de chaque message audio
  Map<String, Duration> _audioDurations = {};
  // Map pour stocker le temps de lecture actuel de chaque message audio
  Map<String, Duration> _audioPositions = {};

  final MessageService _messageService = MessageService();
  final ConversationService _conversationService = ConversationService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final ImagePicker _imagePicker = ImagePicker();

  List<Message> _messages = [];
  Conversation? _conversation;
  bool _isLoading = true;
  bool _isSending = false;
  bool _isRecording = false;
  String? _recordingPath;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  int? _currentUserId;
  String? _currentUserRole;
  String? _otherParticipantName;
  String? _otherParticipantImageUrl;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _messageController.addListener(_onMessageTextChanged);
    _setupAudioPlayerListeners();
    _loadCurrentUserId();
    _loadConversationDetails();
    _loadMessages();
  }

  void _setupAudioPlayerListeners() {
    // Écouter la fin de la lecture audio et les changements de durée
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        // L'audio a fini de jouer - arrêter automatiquement
        print('✅ Lecture audio terminée - arrêt automatique');
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _currentlyPlayingPath = null;
          });
          // Arrêter le player
          _player.stop();
        }
      }
    });
    
    // Écouter les changements de durée pour chaque fichier
    _player.durationStream.listen((duration) {
      if (duration != null && _currentlyPlayingPath != null) {
        if (mounted) {
          setState(() {
            _audioDurations[_currentlyPlayingPath!] = duration;
          });
          print('⏱️ Durée audio détectée pour ${_currentlyPlayingPath}: ${_formatDuration(duration)}');
        }
      }
    });
    
    // Écouter la position actuelle de lecture pour l'affichage
    _player.positionStream.listen((position) {
      if (_currentlyPlayingPath != null && mounted) {
        setState(() {
          _audioPositions[_currentlyPlayingPath!] = position;
        });
      }
    });
  }
  
  /// Formate une durée en format mm:ss
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
  
  /// Précharge la durée d'un fichier audio sans le jouer
  Future<void> _preloadAudioDuration(String audioUrl) async {
    if (_audioDurations.containsKey(audioUrl)) {
      return; // Déjà chargé
    }
    
    try {
      // Créer un player temporaire pour obtenir la durée
      final tempPlayer = AudioPlayer();
      await tempPlayer.setUrl(audioUrl);
      final duration = await tempPlayer.duration;
      
      if (duration != null && mounted) {
        setState(() {
          _audioDurations[audioUrl] = duration;
        });
        print('⏱️ Durée préchargée pour $audioUrl: ${_formatDuration(duration)}');
      }
      
      await tempPlayer.dispose();
    } catch (e) {
      print('⚠️ Erreur lors du préchargement de la durée pour $audioUrl: $e');
    }
  }

  void _onMessageTextChanged() {
    // Forcer le rebuild pour mettre à jour la couleur du bouton d'envoi
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getInt('user_id');
      _currentUserRole = prefs.getString('user_role');
    });
  }

  Future<void> _loadConversationDetails() async {
    final response = await _conversationService.getConversationById(widget.conversationId);
    if (mounted && response.success && response.data != null) {
      setState(() {
        _conversation = response.data;
        // Déterminer le nom et l'image de l'autre participant
        if (_currentUserRole != null && _currentUserRole!.contains('PATIENTE')) {
          // Si l'utilisateur actuel est une patiente, afficher le médecin
          _otherParticipantName = _conversation!.medecinFullName;
          _otherParticipantImageUrl = _conversation!.medecinImageUrl;
        } else {
          // Si l'utilisateur actuel est un médecin, extraire le nom de la patiente depuis le titre
          final titre = _conversation!.titre;
          if (titre.contains('↔')) {
            final parts = titre.split('↔');
            if (parts.isNotEmpty) {
              _otherParticipantName = parts[0].replaceFirst('Chat:', '').trim();
            }
          }
        }
      });
    }
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    final response = await _messageService.getMessagesByConversation(widget.conversationId);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.success && response.data != null) {
          // Trier les messages par timestamp (du plus ancien au plus récent)
          final messages = response.data!;
          messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          _messages = messages;
          
          // Marquer les messages non lus comme lus
          _markMessagesAsRead();
          
          // Scroller vers le bas (messages les plus récents) après un court délai
          // Avec reverse: true, 0.0 est en bas (messages les plus récents)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients && _messages.isNotEmpty) {
              _scrollController.jumpTo(0.0);
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Erreur lors du chargement des messages'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }

  Future<void> _markMessagesAsRead() async {
    for (var message in _messages) {
      if (!message.lu && message.expediteurId != _currentUserId) {
        await _messageService.marquerCommeLu(message.id);
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    final response = await _messageService.envoyerMessage(
      conversationId: widget.conversationId,
      contenu: text,
    );

    if (mounted) {
      setState(() {
        _isSending = false;
      });

      if (response.success && response.data != null) {
        _messageController.clear();
        // Recharger les messages pour avoir la liste complète
        await _loadMessages();
        // Scroller vers le bas pour voir le nouveau message
        if (mounted && _scrollController.hasClients) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Erreur lors de l\'envoi du message'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _player.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String path) async {
    try {
      print('🔊 Tentative de lecture audio - Path reçu: $path');
      
      if (_isPlaying && _currentlyPlayingPath == path) {
        await _player.pause();
        setState(() {
          _isPlaying = false;
          _currentlyPlayingPath = null;
        });
        return;
      }
      
      if (_isPlaying) {
        await _player.stop();
      }
      
      // Construire l'URL complète selon le format reçu
      String audioUrl = path;
      
      // Si l'URL commence par http:// ou https://, c'est déjà une URL complète
      if (path.startsWith('http://') || path.startsWith('https://')) {
        audioUrl = path;
        // Remplacer localhost par l'IP du baseUrl si nécessaire (pour émulateur Android)
        if (audioUrl.contains('localhost') || audioUrl.contains('127.0.0.1')) {
          final baseUrl = ApiConfig.baseUrl;
          // Extraire juste le domaine/IP du baseUrl (sans le protocole)
          final baseHost = baseUrl.replaceAll(RegExp(r'https?://'), '');
          // Remplacer localhost par l'IP du baseUrl
          audioUrl = audioUrl.replaceAll(RegExp(r'https?://(localhost|127\.0\.0\.1)'), baseUrl);
          print('🔄 URL corrigée (localhost remplacé): $audioUrl');
        }
        print('📻 Lecture audio depuis URL complète: $audioUrl');
      } 
      // Si c'est un chemin relatif du backend
      else if (path.startsWith('/api/') || path.startsWith('/uploads/')) {
        audioUrl = '${ApiConfig.baseUrl}$path';
        print('📻 Lecture audio - URL construite depuis chemin relatif: $audioUrl');
      } 
      // Si c'est un fichier local (chemin système)
      else if (path.contains('/') && !path.startsWith('http')) {
        print('📻 Lecture audio depuis fichier local: $path');
        try {
          await _player.setFilePath(path);
          await _player.play();
          setState(() {
            _isPlaying = true;
            _currentlyPlayingPath = path;
          });
          print('✅ Lecture audio locale démarrée');
          return;
        } catch (e) {
          print('❌ Erreur lecture fichier local: $e');
          throw e;
        }
      } 
      else {
        // Essayer de construire l'URL avec le baseUrl si rien ne correspond
        audioUrl = '${ApiConfig.baseUrl}/api/messages/download/$path';
        print('📻 Lecture audio - URL construite par défaut: $audioUrl');
      }
      
      // Lire depuis une URL HTTP
      print('🔊 Démarrage lecture depuis URL: $audioUrl');
      
      // Charger l'URL pour obtenir la durée avant de jouer
      await _player.setUrl(audioUrl);
      
      // Attendre que la durée soit disponible
      Duration? duration;
      try {
        duration = await _player.duration;
        if (duration != null) {
          print('⏱️ Durée audio détectée: ${_formatDuration(duration)}');
          if (mounted) {
            setState(() {
              _audioDurations[path] = duration!;
            });
          }
        }
      } catch (e) {
        print('⚠️ Impossible de récupérer la durée: $e');
      }
      
      // Jouer l'audio
      await _player.play();
      setState(() {
        _isPlaying = true;
        _currentlyPlayingPath = path;
      });
      print('✅ Lecture audio démarrée avec succès');
      
    } catch (e, stackTrace) {
      print('❌ Erreur lors de la lecture audio: $e');
      print('❌ Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la lecture: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      setState(() {
        _isPlaying = false;
        _currentlyPlayingPath = null;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      // Demander la permission (photos pour iOS, storage pour Android)
      PermissionStatus status;
      if (Platform.isAndroid) {
        // Pour Android 13+, utiliser photos, sinon storage
        try {
          status = await Permission.photos.request();
          // Si photos n'est pas disponible, essayer storage
          if (!status.isGranted && !status.isLimited) {
            status = await Permission.storage.request();
          }
        } catch (e) {
          // Fallback vers storage si photos n'est pas supporté
          status = await Permission.storage.request();
        }
      } else {
        status = await Permission.photos.request();
      }
      
      if (!status.isGranted && !status.isLimited) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission d\'accès aux photos refusée'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        await _sendImage(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de l\'image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      // Demander la permission
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission d\'accès à la caméra refusée'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        await _sendImage(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la prise de photo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendImage(File imageFile) async {
    if (_isSending) return;

    setState(() {
      _isSending = true;
    });

    final response = await _messageService.envoyerImage(
      conversationId: widget.conversationId,
      imageFile: imageFile,
    );

    if (mounted) {
      setState(() {
        _isSending = false;
      });

      if (response.success && response.data != null) {
        await _loadMessages();
        // Scroller vers le bas pour voir le nouveau message
        if (mounted && _scrollController.hasClients) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Erreur lors de l\'envoi de l\'image'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _startRecording() async {
    try {
      // Vérifier si un enregistrement est déjà en cours
      if (_isRecording) {
        print('⚠️ Un enregistrement est déjà en cours');
        return;
      }

      // Demander la permission
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission d\'accès au microphone refusée. Veuillez l\'activer dans les paramètres.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
        print('❌ Permission microphone refusée');
        return;
      }

      // Vérifier à nouveau avec le recorder
      if (!await _audioRecorder.hasPermission()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission d\'accès au microphone refusée. Veuillez l\'activer dans les paramètres.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
        print('❌ Permission microphone non disponible');
        return;
      }

      // Préparer le fichier d'enregistrement
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${directory.path}/audio_$timestamp.m4a';

      print('🎙️ Démarrage de l\'enregistrement audio...');
      print('📁 Chemin du fichier: $path');
      print('⚙️ Configuration: AAC LC, 128kbps, 44.1kHz');
      
      // Démarrer l'enregistrement
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      print('✅ Enregistrement démarré avec succès! Parlez maintenant...');
      
      // Mettre à jour l'état
      setState(() {
        _isRecording = true;
        _recordingPath = path;
        _recordingDuration = Duration.zero;
      });
      
      // Démarrer le timer pour suivre la durée d'enregistrement
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted && _isRecording) {
          setState(() {
            _recordingDuration = Duration(seconds: timer.tick);
          });
          // Logger toutes les 5 secondes
          if (timer.tick % 5 == 0) {
            print('⏱️ Enregistrement en cours: ${_formatDuration(_recordingDuration)}');
          }
        } else {
          timer.cancel();
        }
      });
    } catch (e, stackTrace) {
      print('❌ Erreur lors du démarrage de l\'enregistrement: $e');
      print('❌ Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du démarrage de l\'enregistrement: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        
        // Réinitialiser l'état en cas d'erreur
        setState(() {
          _isRecording = false;
          _recordingPath = null;
          _recordingDuration = Duration.zero;
        });
        
        if (_recordingTimer != null) {
          _recordingTimer!.cancel();
          _recordingTimer = null;
        }
      }
    }
  }

  Future<void> _stopRecording({bool send = true}) async {
    // Vérifier qu'un enregistrement est en cours
    if (!_isRecording) {
      print('⚠️ Aucun enregistrement en cours à arrêter');
      return;
    }

    try {
      print('🛑 Arrêt de l\'enregistrement... Durée totale: ${_formatDuration(_recordingDuration)}');
      
      // Arrêter l'enregistrement
      final path = await _audioRecorder.stop();
      
      if (path == null) {
        print('⚠️ Aucun fichier enregistré (enregistrement trop court ou erreur)');
        if (mounted && send) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('L\'enregistrement est trop court. Veuillez réessayer.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        print('✅ Enregistrement arrêté. Fichier sauvegardé: $path');
        try {
          final file = File(path);
          if (await file.exists()) {
            final fileSize = await file.length();
            print('📊 Taille du fichier: $fileSize bytes');
          }
        } catch (e) {
          print('⚠️ Impossible de lire la taille du fichier: $e');
        }
        print('⏱️ Durée finale: ${_formatDuration(_recordingDuration)}');
      }

      // Arrêter le timer
      if (_recordingTimer != null) {
        _recordingTimer!.cancel();
        _recordingTimer = null;
      }
      
      // Réinitialiser l'état
      setState(() {
        _isRecording = false;
        _recordingDuration = Duration.zero;
        _recordingPath = null;
      });

      // Gérer le fichier selon l'action
      if (path != null && send) {
        print('📤 Envoi du message audio...');
        await _sendAudio(File(path));
      } else if (path != null) {
        // Supprimer le fichier si on n'envoie pas
        print('🗑️ Suppression du fichier audio annulé...');
        try {
          await File(path).delete();
          print('✅ Fichier supprimé avec succès');
        } catch (e) {
          print('❌ Erreur lors de la suppression du fichier: $e');
        }
      }
    } catch (e, stackTrace) {
      print('❌ Erreur lors de l\'arrêt de l\'enregistrement: $e');
      print('❌ Stack trace: $stackTrace');
      
      // Nettoyer en cas d'erreur
      if (_recordingTimer != null) {
        _recordingTimer!.cancel();
        _recordingTimer = null;
      }
      
      if (mounted) {
        setState(() {
          _isRecording = false;
          _recordingDuration = Duration.zero;
          _recordingPath = null;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'arrêt de l\'enregistrement: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _sendAudio(File audioFile) async {
    if (_isSending) return;

    setState(() {
      _isSending = true;
    });

    final response = await _messageService.envoyerAudio(
      conversationId: widget.conversationId,
      audioFile: audioFile,
    );

    if (mounted) {
      setState(() {
        _isSending = false;
      });

      if (response.success && response.data != null) {
        await _loadMessages();
        // Scroller vers le bas pour voir le nouveau message
        if (mounted && _scrollController.hasClients) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Erreur lors de l\'envoi du message audio'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Caméra'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isRecording, // Empêcher de quitter si enregistrement en cours
      onPopInvoked: (didPop) async {
        // Si un audio est en cours de lecture, l'arrêter
        if (_isPlaying) {
          await _player.stop();
          if (mounted) {
            setState(() {
              _isPlaying = false;
              _currentlyPlayingPath = null;
            });
          }
        }

        // Si un enregistrement est en cours, demander confirmation
        if (!didPop && _isRecording) {
          final shouldCancel = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Enregistrement en cours'),
                content: const Text(
                  'Un enregistrement est en cours. Voulez-vous annuler l\'enregistrement et quitter ?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Continuer'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Annuler et quitter'),
                  ),
                ],
              );
            },
          );

          if (shouldCancel == true) {
            // Annuler l'enregistrement et quitter
            await _stopRecording(send: false);
            if (mounted) {
              Navigator.of(context).pop();
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun message',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Commencez la conversation !',
                              style: TextStyle(color: Colors.grey[500], fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadMessages,
                        child: ListView.builder(
                          controller: _scrollController,
                          reverse: true, // Messages les plus récents en bas
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isMe = message.expediteurId == _currentUserId;
                            
                            // Avec reverse: true, les messages sont affichés du plus récent (index 0, en bas) au plus ancien
                            // Pour le regroupement par date, on compare avec le message suivant (index + 1) qui est plus ancien
                            bool showDateSeparator = false;
                            if (index == 0) {
                              // Premier message affiché (le plus récent, en bas) - afficher le séparateur avant
                              showDateSeparator = true;
                            } else {
                              // Comparer avec le message suivant dans la liste (plus ancien visuellement)
                              final previousMessage = _messages[index - 1];
                              showDateSeparator = _shouldShowDateSeparator(
                                previousMessage.timestamp,
                                message.timestamp,
                              );
                            }

                            return Column(
                              children: [
                                // Afficher le séparateur AVANT le message (pour qu'il apparaisse au-dessus avec reverse)
                                if (showDateSeparator)
                                  _buildDateSeparator(_formatDate(message.timestamp)),
                                _buildMessageFromBackend(message, isMe),
                              ],
                            );
                          },
                        ),
                      ),
          ),
          _buildMessageComposer(),
        ],
      ),
      ),
    );
  }

  bool _shouldShowDateSeparator(DateTime previous, DateTime current) {
    return previous.day != current.day ||
        previous.month != current.month ||
        previous.year != current.year;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Aujourd\'hui';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Hier';
    } else {
      return DateFormat('dd MMM yyyy', 'fr').format(date);
    }
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  Widget _buildMessageFromBackend(Message message, bool isMe) {
    if (message.isTexte) {
      return _buildMessageBubble(
        context,
        message.contenu,
        _formatTime(message.timestamp),
        isMe: isMe,
      );
    } else if (message.isImage && message.fileUrl != null) {
      return _buildImageMessage(
        message.fileUrl!,
        _formatTime(message.timestamp),
        isMe: isMe,
      );
    } else if (message.isAudio && message.fileUrl != null) {
      print('🎵 Construction message audio - fileUrl: ${message.fileUrl}');
      // Si l'URL contient localhost, la remplacer par l'IP du serveur
      String audioUrl = message.fileUrl!;
      if (audioUrl.contains('localhost') || audioUrl.contains('127.0.0.1')) {
        // Remplacer localhost par l'IP du baseUrl
        final baseUrl = ApiConfig.baseUrl;
        audioUrl = audioUrl.replaceAll(RegExp(r'https?://(localhost|127\.0\.0\.1)(:\d+)?'), baseUrl);
        print('🔄 URL corrigée (localhost remplacé): $audioUrl');
      }
      
      // Précharger la durée si elle n'est pas encore chargée
      if (!_audioDurations.containsKey(audioUrl)) {
        _preloadAudioDuration(audioUrl);
      }
      
      // Récupérer la durée si elle existe déjà, sinon afficher '0:00'
      final duration = _audioDurations[audioUrl];
      final durationText = duration != null ? _formatDuration(duration) : '0:00';
      
      // Si on est en train de jouer ce message, afficher le temps actuel / durée totale
      String displayDuration = durationText;
      if (_isPlaying && _currentlyPlayingPath == audioUrl) {
        final position = _audioPositions[audioUrl] ?? Duration.zero;
        if (duration != null && duration > Duration.zero) {
          displayDuration = '${_formatDuration(position)} / ${_formatDuration(duration)}';
        }
      }
      
      return _buildAudioMessage(
        displayDuration,
        _formatTime(message.timestamp),
        isMe: isMe,
        audioPath: audioUrl,
      );
    } else {
      // Message de type inconnu ou document
      return _buildMessageBubble(
        context,
        message.contenu,
        _formatTime(message.timestamp),
        isMe: isMe,
      );
    }
  }

  AppBar _buildAppBar(BuildContext context) {
    // Déterminer le nom à afficher
    String participantName;
    if (_otherParticipantName != null) {
      participantName = _otherParticipantName!;
    } else if (widget.medecinPrenom != null && widget.medecinNom != null) {
      participantName = '${widget.medecinPrenom} ${widget.medecinNom}';
    } else {
      participantName = widget.medecinNom ?? widget.medecinPrenom ?? 'Utilisateur';
    }
    
    // Construire l'URL complète de l'image
    String imageUrl = _otherParticipantImageUrl ?? widget.medecinImageUrl ?? 'assets/images/docP.png';
    if (imageUrl.startsWith('/api/') || imageUrl.startsWith('/uploads/')) {
      imageUrl = '${ApiConfig.baseUrl}$imageUrl';
    }

    // Préfixe selon le rôle
    String displayName = participantName;
    if (_currentUserRole != null && _currentUserRole!.contains('PATIENTE')) {
      // La patiente voit "Dr. Nom"
      displayName = 'Dr. $participantName';
    }

    return AppBar(
      backgroundColor: AppColors.primaryPink.withOpacity(0.63),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: imageUrl.startsWith('http')
                ? NetworkImage(imageUrl)
                : (imageUrl.startsWith('assets/')
                    ? AssetImage(imageUrl) as ImageProvider
                    : const AssetImage('assets/images/docP.png')),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                _buildOnlineStatus(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineStatus() {
    // Pour l'instant, on affiche toujours "En ligne" mais on peut améliorer plus tard
    // avec un système de présence en temps réel
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.greenAccent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          const Flexible(
            child: Text(
              'En ligne',
              style: TextStyle(color: Colors.white70, fontSize: 11),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(String date) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, String text, String time, {required bool isMe}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryPink.withOpacity(0.63) : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(0),
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(child: Text(text, style: TextStyle(color: isMe ? Colors.white : Colors.black))),
            const SizedBox(width: 8),
            Text(time, style: TextStyle(color: isMe ? Colors.white70 : Colors.black54, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildImageMessage(String imageUrl, String time, {required bool isMe}) {
    // Construire l'URL complète si c'est un chemin relatif
    String fullImageUrl = imageUrl;
    if (imageUrl.startsWith('/api/') || imageUrl.startsWith('/uploads/')) {
      fullImageUrl = '${ApiConfig.baseUrl}$imageUrl';
    }
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: const BoxConstraints(maxWidth: 250),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: fullImageUrl.startsWith('http')
                  ? Image.network(
                      fullImageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 250,
                          height: 200,
                          color: Colors.grey[300],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('❌ Erreur chargement image: $fullImageUrl - $error');
                        return Container(
                          width: 250,
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error, color: Colors.red),
                        );
                      },
                    )
                  : Image.asset(fullImageUrl, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 8),
              child: Text(time, style: const TextStyle(color: Colors.black54, fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioMessage(String duration, String time,
      {required bool isMe, required String audioPath}) {
    // Placeholder for audio wave form
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            constraints: const BoxConstraints(maxWidth: 240),
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryPink.withOpacity(0.63) : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(0),
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isMe) ...[
              const CircleAvatar(
                radius: 15,
                backgroundImage: AssetImage('assets/images/D1.jpg'),
              ),
              const SizedBox(width: 6),
            ],
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: Icon(
                _isPlaying && _currentlyPlayingPath == audioPath
                    ? Icons.pause
                    : Icons.play_arrow,
                color: isMe ? Colors.white : Colors.black,
                size: 24,
              ),
              onPressed: () {
                print('🔘 Bouton play audio cliqué - audioPath: $audioPath');
                _playAudio(audioPath);
              },
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Stack(
                clipBehavior: Clip.hardEdge,
                alignment: Alignment.center,
                children: [
                  _buildWaveform(isMe),
                  Positioned(
                    left: 12,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isMe ? Colors.white : Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(width: 3),
            Flexible(
              flex: 0,
              child: Text(
                duration,
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.black54,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
          );
        },
      ),
    );
  }

  Widget _buildWaveform(bool isMe) {
    return SizedBox(
      width: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(
          20,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 0.4),
            width: 1.5,
            height: (index % 5 + 1) * 3.5,
            decoration: BoxDecoration(
              color: isMe ? Colors.white54 : Colors.grey[600],
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      color: Colors.grey[100],
      child: SafeArea(
        child: Row(
          children: [
            // Boutons à gauche (caméra et micro) - cachés pendant l'enregistrement
            if (!_isRecording) ...[
              IconButton(
                icon: const Icon(Icons.camera_alt, color: AppColors.primaryPink),
                onPressed: _isSending ? null : _showImageSourceDialog,
                tooltip: 'Envoyer une image',
              ),
              IconButton(
                icon: const Icon(Icons.mic, color: AppColors.primaryPink),
                onPressed: _isSending ? null : _startRecording,
                tooltip: 'Enregistrer un message vocal',
              ),
            ],
            // Bouton annuler pendant l'enregistrement
            if (_isRecording)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => _stopRecording(send: false),
                tooltip: 'Annuler l\'enregistrement',
              ),
            // Champ de texte / indicateur d'enregistrement
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: _isRecording ? Colors.red.withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: _isRecording
                      ? Border.all(color: Colors.red, width: 2)
                      : null,
                ),
                child: _isRecording
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.mic, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '🎤 ${_formatDuration(_recordingDuration)}',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    : TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Votre message...',
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _sendMessage(),
                        enabled: !_isSending,
                      ),
              ),
            ),
            const SizedBox(width: 8),
            // Bouton d'envoi unique (pour texte ET audio)
            if (_isSending)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton(
                icon: Icon(
                  Icons.send,
                  color: _isRecording || _messageController.text.trim().isNotEmpty
                      ? AppColors.primaryPink
                      : Colors.grey,
                ),
                onPressed: _isRecording
                    ? () => _stopRecording(send: true)
                    : (_messageController.text.trim().isNotEmpty ? _sendMessage : null),
                tooltip: _isRecording ? 'Envoyer le message vocal' : 'Envoyer le message',
              ),
          ],
        ),
      ),
    );
  }
}
