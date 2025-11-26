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
    // Écouter la fin de la lecture audio
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        // L'audio a fini de jouer
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _currentlyPlayingPath = null;
          });
        }
      }
    });
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
          _messages = response.data!;
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
        _loadMessages();
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
    _player.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String path) async {
    try {
      if (_isPlaying && _currentlyPlayingPath == path) {
        await _player.pause();
        setState(() {
          _isPlaying = false;
          _currentlyPlayingPath = null;
        });
      } else {
        if (_isPlaying) {
          await _player.stop();
        }
        
        // Construire l'URL complète si c'est un chemin relatif
        String audioUrl = path;
        if (path.startsWith('/api/') || path.startsWith('/uploads/')) {
          // C'est un chemin relatif du backend, ajouter le baseUrl
          audioUrl = '${ApiConfig.baseUrl}$path';
          print('📻 Lecture audio depuis URL construite: $audioUrl');
        } else if (!path.startsWith('http')) {
          // C'est un fichier local
          print('📻 Lecture audio depuis fichier local: $path');
          await _player.setFilePath(path);
          await _player.play();
          setState(() {
            _isPlaying = true;
            _currentlyPlayingPath = path;
          });
          return;
        } else {
          print('📻 Lecture audio depuis URL complète: $audioUrl');
        }
        
        // Si c'est une URL HTTP ou construite
        await _player.setUrl(audioUrl);
        await _player.play();
        setState(() {
          _isPlaying = true;
          _currentlyPlayingPath = path;
        });
      }
    } catch (e) {
      print('Erreur lors de la lecture audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la lecture: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        _loadMessages();
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
      // Demander la permission
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission d\'accès au microphone refusée'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${directory.path}/audio_$timestamp.m4a';

      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );

        setState(() {
          _isRecording = true;
          _recordingPath = path;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission d\'accès au microphone refusée'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du démarrage de l\'enregistrement: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording({bool send = true}) async {
    try {
      final path = await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
      });

      if (path != null && send) {
        await _sendAudio(File(path));
      } else if (path != null) {
        // Supprimer le fichier si on n'envoie pas
        try {
          await File(path).delete();
        } catch (e) {
          print('Erreur lors de la suppression du fichier: $e');
        }
      }

      setState(() {
        _recordingPath = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'arrêt de l\'enregistrement: ${e.toString()}'),
            backgroundColor: Colors.red,
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
        _loadMessages();
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
    return Scaffold(
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
                            final showDateSeparator = index == 0 ||
                                _shouldShowDateSeparator(
                                  _messages[index - 1].timestamp,
                                  message.timestamp,
                                );

                            return Column(
                              children: [
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
      return _buildAudioMessage(
        '0:00', // Durée par défaut
        _formatTime(message.timestamp),
        isMe: isMe,
        audioPath: message.fileUrl!,
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
      child: Container(
        constraints: const BoxConstraints(maxWidth: 250),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              onPressed: () => _playAudio(audioPath),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  _buildWaveform(isMe),
                  Positioned(
                    left: 15,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isMe ? Colors.white : Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              duration,
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.black54,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveform(bool isMe) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(
        25,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 0.5),
          width: 2,
          height: (index % 5 + 1) * 3.5,
          decoration: BoxDecoration(
            color: isMe ? Colors.white54 : Colors.grey[600],
            borderRadius: BorderRadius.circular(2),
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
                        children: [
                          const Icon(Icons.mic, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '🎤 Enregistrement en cours...',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.w500,
                              ),
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
