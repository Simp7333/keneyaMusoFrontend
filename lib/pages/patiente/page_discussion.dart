import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:keneya_muso/pages/common/app_colors.dart';
import 'package:keneya_muso/pages/common/page_chat.dart';
import 'package:keneya_muso/services/conversation_service.dart';
import 'package:keneya_muso/models/conversation.dart';
import 'package:intl/intl.dart';

class PageDiscussion extends StatefulWidget {
  const PageDiscussion({super.key});

  @override
  State<PageDiscussion> createState() => _PageDiscussionState();
}

class _PageDiscussionState extends State<PageDiscussion> {
  final ConversationService _conversationService = ConversationService();
  List<Conversation> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur: ID utilisateur non trouvé'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Essayer d'abord de récupérer la conversation avec le médecin assigné
      final conversationResponse = await _conversationService.getOrCreateConversationWithMedecin(userId);
      
      if (conversationResponse.success && conversationResponse.data != null) {
        if (mounted) {
          setState(() {
            _conversations = [conversationResponse.data!];
            _isLoading = false;
          });
        }
      } else {
        // Si pas de médecin assigné, essayer de récupérer toutes les conversations
        final allConversationsResponse = await _conversationService.getConversationsByUtilisateur(userId);
        
        if (mounted) {
          setState(() {
            if (allConversationsResponse.success && allConversationsResponse.data != null) {
              _conversations = allConversationsResponse.data!;
            } else {
              _conversations = [];
            }
            _isLoading = false;
          });

          if (!allConversationsResponse.success && allConversationsResponse.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(allConversationsResponse.message!),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _conversations = [];
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

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'À l\'instant';
        }
        return '${difference.inMinutes}min';
      }
      return '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
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
        title: const Text(
          'Discussions',
          style: TextStyle(
            color: AppColors.primaryPink,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadConversations,
              child: _conversations.isEmpty
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
                            'Aucune conversation trouvée.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Votre médecin assigné apparaîtra ici.',
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = _conversations[index];
                        return _buildDiscussionItem(
                          context,
                          conversation,
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildDiscussionItem(
    BuildContext context,
    Conversation conversation,
  ) {
    final medecinName = conversation.medecinFullName;
    final imageUrl = conversation.medecinImageUrl ?? 'assets/images/docP.png';
    final time = _formatTime(conversation.dateModification ?? conversation.dateCreation);
    final unreadCount = conversation.nombreMessages > 0 ? conversation.nombreMessages.toString() : '0';
    final hasUnread = conversation.nombreMessages > 0;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PageChat(
              conversationId: conversation.id,
              medecinNom: conversation.medecinNom,
              medecinPrenom: conversation.medecinPrenom,
              medecinImageUrl: conversation.medecinImageUrl,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryPink.withOpacity(0.1),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: imageUrl.startsWith('http') || imageUrl.startsWith('assets/')
                        ? (imageUrl.startsWith('http')
                            ? NetworkImage(imageUrl)
                            : AssetImage(imageUrl) as ImageProvider)
                        : AssetImage('assets/images/docP.png'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. $medecinName',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        conversation.nombreMessages > 0
                            ? '${conversation.nombreMessages} message${conversation.nombreMessages > 1 ? 's' : ''}'
                            : 'Aucun message',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      time,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    if (hasUnread)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryPink,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unreadCount,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: Colors.grey[200]),
          ],
        ),
      ),
    );
  }
}
