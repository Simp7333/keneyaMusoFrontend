import 'package:flutter/material.dart';
import 'package:keneya_muso/pages/common/page_notifications_pro.dart';
import 'package:keneya_muso/services/notification_service.dart';
import 'package:keneya_muso/models/enums/role_utilisateur.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class PageDetailNotification extends StatefulWidget {
  final NotificationItem notification;
  final NotificationService notificationService;

  const PageDetailNotification({
    super.key,
    required this.notification,
    required this.notificationService,
  });

  @override
  State<PageDetailNotification> createState() => _PageDetailNotificationState();
}

class _PageDetailNotificationState extends State<PageDetailNotification> {
  bool _isProcessing = false;
  RoleUtilisateur? _userRole;
  
  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }
  
  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final roleString = prefs.getString('user_role');
    if (roleString != null) {
      setState(() {
        _userRole = RoleUtilisateur.fromJson(roleString);
      });
    }
  }
  
  /// Détermine si la notification nécessite une confirmation/refus
  bool _needsAction() {
    if (widget.notification.rappel == null) return false;
    
    final rappel = widget.notification.rappel!;
    
    // Pour les médecins : seulement les demandes d'assignation nécessitent une action
    if (_userRole == RoleUtilisateur.MEDECIN) {
      return rappel.type == 'DEMANDE_ASSIGNATION' ||
             rappel.titre.toLowerCase().contains('demande') ||
             rappel.titre.toLowerCase().contains('suivre');
    }
    
    // Pour les patientes : les notifications sont généralement informatives
    return false;
  }
  
  /// Obtient l'icône selon le type de notification
  IconData _getIcon() {
    if (widget.notification.type == NotificationType.message) {
      return Icons.chat;
    } else if (widget.notification.type == NotificationType.alerte) {
      return Icons.notifications_active;
    } else if (widget.notification.rappel != null) {
      final rappel = widget.notification.rappel!;
      if (rappel.isRappelCPN || rappel.isRappelCPON) {
        return Icons.medical_services;
      } else if (rappel.type == 'RAPPEL_VACCINATION') {
        return Icons.medication;
      } else if (rappel.type == 'CONSEIL') {
        return Icons.lightbulb;
      }
    }
    return Icons.notifications;
  }
  
  /// Obtient le message à afficher selon le rôle et le type
  String _getMessageContent() {
    if (widget.notification.type == NotificationType.message) {
      return widget.notification.message;
    }
    
    if (_userRole == RoleUtilisateur.MEDECIN && _needsAction()) {
      return '${widget.notification.message}\n\nVoulez-vous suivre ce dossier?';
    }
    
    // Pour les patientes ou notifications informatives
    return widget.notification.message;
  }

  Future<void> _handleAccept() async {
    if (widget.notification.rappel == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Marquer la notification comme traitée
      final response = await widget.notificationService.marquerCommeTraitee(
          widget.notification.rappel!.id);

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande acceptée'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Retour avec succès
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _handleDecline() async {
    if (widget.notification.rappel == null) return;

    // Demander confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refuser la demande'),
        content: const Text('Êtes-vous sûr de vouloir refuser cette demande ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Refuser', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Marquer la notification comme lue (refusée)
      final response = await widget.notificationService.marquerCommeLue(
          widget.notification.rappel!.id);

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande refusée'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context, true); // Retour avec succès
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMMM yyyy', 'fr').format(date);
    } catch (e) {
      return dateStr;
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
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Détail de la notification',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFCE4EC)),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: widget.notification.type == NotificationType.message
                        ? Colors.blue.withOpacity(0.1)
                        : widget.notification.type == NotificationType.alerte
                            ? const Color(0xFFFEEBEE)
                            : const Color(0xFFFCE4EC),
                    child: Icon(
                      _getIcon(),
                      color: widget.notification.type == NotificationType.message
                          ? Colors.blue
                          : widget.notification.type == NotificationType.alerte
                              ? const Color(0xFFD32F2F)
                              : const Color(0xFFE91E63).withOpacity(0.63),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.notification.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                _userRole == RoleUtilisateur.MEDECIN && _needsAction()
                    ? 'Bonjour Dr,\n${_getMessageContent()}'
                    : _getMessageContent(),
                style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 32),
              Column(
                children: [
                  // Afficher les boutons seulement si une action est nécessaire
                  if (_needsAction())
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isProcessing ? null : _handleAccept,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF66BB6A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              disabledBackgroundColor: Colors.grey,
                            ),
                            child: _isProcessing
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Oui'),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextButton(
                            onPressed: _isProcessing ? null : _handleDecline,
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              foregroundColor: Colors.black54,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Non'),
                          ),
                        ),
                      ],
                    ),
                  if (_needsAction()) const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      widget.notification.rappel != null
                          ? _formatDate(widget.notification.rappel!.dateCreation)
                          : widget.notification.time,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
