import 'package:flutter/material.dart';
import '../pages/common/app_colors.dart';

/// Type de message à afficher
enum MessageType {
  success,
  error,
  warning,
  info,
}

/// Widget de popup stylisé pour afficher des messages
class MessagePopup extends StatelessWidget {
  final String title;
  final String message;
  final MessageType type;
  final String? buttonText;
  final VoidCallback? onPressed;

  const MessagePopup({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    this.buttonText,
    this.onPressed,
  });

  /// Affiche un popup de message stylisé
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    required MessageType type,
    String? buttonText,
    VoidCallback? onPressed,
    bool barrierDismissible = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return MessagePopup(
          title: title,
          message: message,
          type: type,
          buttonText: buttonText,
          onPressed: onPressed ?? () => Navigator.of(context).pop(),
        );
      },
    );
  }

  /// Affiche un popup de succès
  static Future<void> showSuccess({
    required BuildContext context,
    required String message,
    String title = 'Succès',
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      type: MessageType.success,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  /// Affiche un popup d'erreur
  static Future<void> showError({
    required BuildContext context,
    required String message,
    String title = 'Erreur',
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      type: MessageType.error,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  /// Affiche un popup d'avertissement
  static Future<void> showWarning({
    required BuildContext context,
    required String message,
    String title = 'Avertissement',
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      type: MessageType.warning,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  /// Affiche un popup d'information
  static Future<void> showInfo({
    required BuildContext context,
    required String message,
    String title = 'Information',
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      type: MessageType.info,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  Color get _primaryColor {
    switch (type) {
      case MessageType.success:
        return const Color(0xFF4CAF50);
      case MessageType.error:
        return const Color(0xFFD32F2F);
      case MessageType.warning:
        return const Color(0xFFFF9800);
      case MessageType.info:
        return const Color(0xFF2196F3);
    }
  }

  Color get _backgroundColor {
    switch (type) {
      case MessageType.success:
        return const Color(0xFFE8F5E9);
      case MessageType.error:
        return const Color(0xFFFEEBEE);
      case MessageType.warning:
        return const Color(0xFFFFF3E0);
      case MessageType.info:
        return const Color(0xFFE3F2FD);
    }
  }

  IconData get _icon {
    switch (type) {
      case MessageType.success:
        return Icons.check_circle;
      case MessageType.error:
        return Icons.error;
      case MessageType.warning:
        return Icons.warning_amber_rounded;
      case MessageType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône avec cercle de couleur
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icon,
                size: 40,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            
            // Titre
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Message
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Bouton
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed ?? () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  buttonText ?? 'OK',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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

