import 'package:flutter/material.dart';
import 'package:keneya_muso/pages/common/page_detail_notification.dart';
import 'package:keneya_muso/pages/common/page_chat.dart';
import 'package:keneya_muso/services/notification_service.dart';
import 'package:keneya_muso/services/message_service.dart';
import 'package:keneya_muso/models/rappel.dart';
import 'package:keneya_muso/models/message.dart';
import 'package:intl/intl.dart';

// Enum for notification type
enum NotificationType { demande, alerte, message }

// Model for a notification
class NotificationItem {
  final int id;
  final String title;
  final String message;
  final String time;
  final NotificationType type;
  final Rappel? rappel; // Référence au rappel original
  final Message? messageData; // Référence au message original
  final int? conversationId; // ID de la conversation pour les messages

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.rappel,
    this.messageData,
    this.conversationId,
  });
}

class PageNotificationsPro extends StatefulWidget {
  const PageNotificationsPro({super.key});

  @override
  State<PageNotificationsPro> createState() => _PageNotificationsProState();
}

class _PageNotificationsProState extends State<PageNotificationsPro> {
  final NotificationService _notificationService = NotificationService();
  final MessageService _messageService = MessageService();
  List<Rappel> _rappels = [];
  List<Message> _messagesNonLus = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Charger les rappels
      final rappelsResponse = await _notificationService.getMyNotifications();
      
      // Charger les messages non lus
      final messagesResponse = await _messageService.getMessagesNonLus();
      
      setState(() {
        if (rappelsResponse.success && rappelsResponse.data != null) {
          _rappels = rappelsResponse.data!;
        } else {
          _rappels = [];
        }
        
        if (messagesResponse.success && messagesResponse.data != null) {
          _messagesNonLus = messagesResponse.data!;
        } else {
          _messagesNonLus = [];
        }
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _rappels = [];
        _messagesNonLus = [];
        _isLoading = false;
      });
    }
  }

  // Convertir Rappel en NotificationItem
  NotificationItem _rappelToNotificationItem(Rappel rappel) {
    // Déterminer le type de notification
    NotificationType type = NotificationType.demande;
    if (rappel.type.contains('ALERTE') || rappel.priorite == 'ELEVEE') {
      type = NotificationType.alerte;
    }

    // Formater la date
    String timeStr = _formatTime(rappel.dateCreation);

    return NotificationItem(
      id: rappel.id,
      title: rappel.titre,
      message: rappel.message,
      time: timeStr,
      type: type,
      rappel: rappel,
    );
  }

  // Convertir Message en NotificationItem
  NotificationItem _messageToNotificationItem(Message message) {
    // Formater la date
    String timeStr = _formatTimeFromDateTime(message.timestamp);
    
    // Créer un titre basé sur l'expéditeur
    String title = 'Message de ${message.expediteurFullName}';
    
    // Créer le message à afficher
    String messageText = message.contenu;
    if (message.isImage) {
      messageText = '📷 Photo';
    } else if (message.isAudio) {
      messageText = '🎤 Message vocal';
    } else if (message.isDocument) {
      messageText = '📄 Document';
    }

    return NotificationItem(
      id: message.id,
      title: title,
      message: messageText,
      time: timeStr,
      type: NotificationType.message,
      messageData: message,
      conversationId: message.conversationId,
    );
  }

  String _formatTimeFromDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours < 1) {
        if (difference.inMinutes < 1) {
          return 'À l\'instant';
        }
        return '${difference.inMinutes}min';
      }
      return '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}S';
    } else {
      return DateFormat('dd MMM', 'fr').format(dateTime);
    }
  }

  String _formatTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        // Aujourd'hui - afficher l'heure ou "il y a X heures"
        if (difference.inHours < 1) {
          if (difference.inMinutes < 1) {
            return 'À l\'instant';
          }
          return '${difference.inMinutes}min';
        }
        return '${difference.inHours}h';
      } else if (difference.inDays == 1) {
        return 'Hier';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}j';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '${weeks}S';
      } else {
        return DateFormat('dd MMM', 'fr').format(date);
      }
    } catch (e) {
      return dateStr;
    }
  }

  // Grouper les notifications par période
  List<NotificationItem> _getTodayNotifications() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    
    final rappelsToday = _rappels
        .where((rappel) {
          try {
            final date = DateTime.parse(rappel.dateCreation);
            return date.isAfter(todayStart) || date.isAtSameMomentAs(todayStart);
          } catch (e) {
            return false;
          }
        })
        .map(_rappelToNotificationItem)
        .toList();
    
    final messagesToday = _messagesNonLus
        .where((message) {
          return message.timestamp.isAfter(todayStart) || 
                 message.timestamp.isAtSameMomentAs(todayStart);
        })
        .map(_messageToNotificationItem)
        .toList();
    
    // Combiner et trier par date (plus récents en premier)
    final allNotifications = [...rappelsToday, ...messagesToday];
    allNotifications.sort((a, b) {
      // Comparer les dates - les plus récentes en premier
      DateTime dateA, dateB;
      if (a.rappel != null) {
        dateA = DateTime.parse(a.rappel!.dateCreation);
      } else if (a.messageData != null) {
        dateA = a.messageData!.timestamp;
      } else {
        return 0;
      }
      
      if (b.rappel != null) {
        dateB = DateTime.parse(b.rappel!.dateCreation);
      } else if (b.messageData != null) {
        dateB = b.messageData!.timestamp;
      } else {
        return 0;
      }
      
      return dateB.compareTo(dateA);
    });
    
    return allNotifications;
  }

  List<NotificationItem> _getWeekNotifications() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(const Duration(days: 7));
    
    final rappelsWeek = _rappels
        .where((rappel) {
          try {
            final date = DateTime.parse(rappel.dateCreation);
            return date.isAfter(weekStart) && date.isBefore(todayStart);
          } catch (e) {
            return false;
          }
        })
        .map(_rappelToNotificationItem)
        .toList();
    
    final messagesWeek = _messagesNonLus
        .where((message) {
          return message.timestamp.isAfter(weekStart) && 
                 message.timestamp.isBefore(todayStart);
        })
        .map(_messageToNotificationItem)
        .toList();
    
    // Combiner et trier par date
    final allNotifications = [...rappelsWeek, ...messagesWeek];
    allNotifications.sort((a, b) {
      DateTime dateA, dateB;
      if (a.rappel != null) {
        dateA = DateTime.parse(a.rappel!.dateCreation);
      } else if (a.messageData != null) {
        dateA = a.messageData!.timestamp;
      } else {
        return 0;
      }
      
      if (b.rappel != null) {
        dateB = DateTime.parse(b.rappel!.dateCreation);
      } else if (b.messageData != null) {
        dateB = b.messageData!.timestamp;
      } else {
        return 0;
      }
      
      return dateB.compareTo(dateA);
    });
    
    return allNotifications;
  }


  @override
  Widget build(BuildContext context) {
    final todayNotifications = _getTodayNotifications();
    final weekNotifications = _getWeekNotifications();

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
          'Notifications',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: todayNotifications.isEmpty && weekNotifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune notification',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        if (todayNotifications.isNotEmpty) ...[
                          _buildSectionHeader('Aujourd\'hui'),
                          ...todayNotifications
                              .map((notif) => _buildNotificationItem(context, notif)),
                        ],
                        if (weekNotifications.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _buildSectionHeader('Semaine'),
                          ...weekNotifications
                              .map((notif) => _buildNotificationItem(context, notif)),
                        ],
                      ],
                    ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationItem notif) {
    final isAlerte = notif.type == NotificationType.alerte;
    final isMessage = notif.type == NotificationType.message;
    
    Color iconColor;
    Color backgroundColor;
    IconData icon;
    
    if (isMessage) {
      iconColor = Colors.blue;
      backgroundColor = Colors.blue.withOpacity(0.1);
      icon = Icons.chat;
    } else if (isAlerte) {
      iconColor = const Color(0xFFD32F2F);
      backgroundColor = const Color(0xFFFEEBEE);
      icon = Icons.notifications_active;
    } else {
      iconColor = const Color(0xFFE91E63).withOpacity(0.63);
      backgroundColor = const Color(0xFFFCE4EC);
      icon = Icons.person_add;
    }
    
    // Vérifier si la notification est non lue
    final isNonLue = notif.rappel?.isNonLue ?? 
                     (notif.messageData != null ? !notif.messageData!.lu : false);

    return GestureDetector(
      onTap: () async {
        // Si c'est un message, naviguer vers le chat
        if (notif.type == NotificationType.message && notif.conversationId != null) {
          // Marquer le message comme lu
          if (notif.messageData != null) {
            await _messageService.marquerCommeLu(notif.messageData!.id);
          }
          
          // Naviguer vers le chat
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PageChat(
                conversationId: notif.conversationId!,
                medecinNom: notif.messageData?.expediteurNom,
                medecinPrenom: notif.messageData?.expediteurPrenom,
                medecinImageUrl: null, // Pas d'image disponible dans le message
              ),
            ),
          ).then((_) => _loadNotifications()); // Rafraîchir après retour
          return;
        }
        
        // Pour les rappels
        // Marquer comme lue si nécessaire
        if (notif.rappel != null && isNonLue) {
          await _notificationService.marquerCommeLue(notif.rappel!.id);
          _loadNotifications(); // Rafraîchir la liste
        }

        if (isAlerte) {
          // Les alertes (soumissions de dossiers) sont maintenant gérées
          // dans la page dédiée "Alertes" accessible depuis le dashboard
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Consultez la page "Alertes" depuis le dashboard'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PageDetailNotification(
                notification: notif,
                notificationService: _notificationService,
              ),
            ),
          ).then((_) => _loadNotifications()); // Rafraîchir après retour
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: isNonLue ? iconColor : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: backgroundColor,
              child: Stack(
                children: [
                  Icon(icon, color: iconColor, size: 28),
                  if (isNonLue)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontWeight: isNonLue ? FontWeight.bold : FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.message,
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: isNonLue ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              notif.time,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
