import 'package:flutter/material.dart';
import '../widgets/message_popup.dart';
import '../models/dto/api_response.dart';

/// Helper pour afficher des messages stylisés dans toute l'application
class MessageHelper {
  /// Affiche un message basé sur une ApiResponse
  static Future<void> showApiResponse({
    required BuildContext context,
    required ApiResponse response,
    String? successTitle,
    String? errorTitle,
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) {
    if (response.success) {
      return MessagePopup.showSuccess(
        context: context,
        message: response.message ?? 'Opération réussie',
        title: successTitle ?? 'Succès',
        onPressed: onSuccess ?? () => Navigator.of(context).pop(),
      );
    } else {
      return MessagePopup.showError(
        context: context,
        message: response.message ?? 'Une erreur est survenue',
        title: errorTitle ?? 'Erreur',
        onPressed: onError ?? () => Navigator.of(context).pop(),
      );
    }
  }

  /// Affiche un message de succès
  static Future<void> showSuccess({
    required BuildContext context,
    required String message,
    String title = 'Succès',
    VoidCallback? onPressed,
  }) {
    return MessagePopup.showSuccess(
      context: context,
      message: message,
      title: title,
      onPressed: onPressed,
    );
  }

  /// Affiche un message d'erreur
  static Future<void> showError({
    required BuildContext context,
    required String message,
    String title = 'Erreur',
    VoidCallback? onPressed,
  }) {
    return MessagePopup.showError(
      context: context,
      message: message,
      title: title,
      onPressed: onPressed,
    );
  }

  /// Affiche un message d'avertissement
  static Future<void> showWarning({
    required BuildContext context,
    required String message,
    String title = 'Avertissement',
    VoidCallback? onPressed,
  }) {
    return MessagePopup.showWarning(
      context: context,
      message: message,
      title: title,
      onPressed: onPressed,
    );
  }

  /// Affiche un message d'information
  static Future<void> showInfo({
    required BuildContext context,
    required String message,
    String title = 'Information',
    VoidCallback? onPressed,
  }) {
    return MessagePopup.showInfo(
      context: context,
      message: message,
      title: title,
      onPressed: onPressed,
    );
  }
}

