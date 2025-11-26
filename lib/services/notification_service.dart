import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/dto/api_response.dart';
import '../models/rappel.dart';
import '../models/conseil.dart';

/// Service pour la gestion des rappels et des conseils
class NotificationService {
  /// Récupère tous les rappels pour un utilisateur
  Future<ApiResponse<List<Rappel>>> getRappelsByUtilisateur(int utilisateurId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        return ApiResponse<List<Rappel>>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/rappels/utilisateur/$utilisateurId');
      
      final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
          final rappels = data
              .map((item) => Rappel.fromJson(item as Map<String, dynamic>))
              .toList();

          return ApiResponse<List<Rappel>>(
            success: true,
            message: jsonResponse['message'] ?? 'Rappels récupérés',
            data: rappels,
          );
        }
        return ApiResponse<List<Rappel>>(
          success: true,
          message: 'Aucun rappel trouvé',
          data: [],
        );
      } else {
        return ApiResponse<List<Rappel>>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la récupération des rappels',
        );
      }
    } catch (e) {
      return ApiResponse<List<Rappel>>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Récupère les notifications de l'utilisateur connecté
  Future<ApiResponse<List<Rappel>>> getMyNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        return ApiResponse<List<Rappel>>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/notifications/me');
      
      final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
          final notifications = data
              .map((item) => Rappel.fromJson(item as Map<String, dynamic>))
              .toList();

          return ApiResponse<List<Rappel>>(
            success: true,
            message: jsonResponse['message'] ?? 'Notifications récupérées',
            data: notifications,
          );
        }
        return ApiResponse<List<Rappel>>(
          success: true,
          message: 'Aucune notification trouvée',
          data: [],
        );
      } else {
        return ApiResponse<List<Rappel>>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la récupération des notifications',
        );
      }
    } catch (e) {
      return ApiResponse<List<Rappel>>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Marque une notification comme lue
  Future<ApiResponse<Rappel>> marquerCommeLue(int notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        return ApiResponse<Rappel>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/notifications/$notificationId/lue');
      
      final response = await http.put(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final notification = Rappel.fromJson(jsonResponse['data'] as Map<String, dynamic>);
          return ApiResponse<Rappel>(
            success: true,
            message: jsonResponse['message'] ?? 'Notification marquée comme lue',
            data: notification,
          );
        }
        return ApiResponse<Rappel>(
          success: false,
          message: 'Erreur lors de la mise à jour',
        );
      } else {
        return ApiResponse<Rappel>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la mise à jour',
        );
      }
    } catch (e) {
      return ApiResponse<Rappel>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Marque une notification comme traitée
  Future<ApiResponse<Rappel>> marquerCommeTraitee(int notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        return ApiResponse<Rappel>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/notifications/$notificationId/traitee');
      
      final response = await http.put(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final notification = Rappel.fromJson(jsonResponse['data'] as Map<String, dynamic>);
          return ApiResponse<Rappel>(
            success: true,
            message: jsonResponse['message'] ?? 'Notification marquée comme traitée',
            data: notification,
          );
        }
        return ApiResponse<Rappel>(
          success: false,
          message: 'Erreur lors de la mise à jour',
        );
      } else {
        return ApiResponse<Rappel>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la mise à jour',
        );
      }
    } catch (e) {
      return ApiResponse<Rappel>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Récupère tous les conseils actifs
  Future<ApiResponse<List<Conseil>>> getConseilsActifs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        return ApiResponse<List<Conseil>>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/conseils/actifs');
      
      final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
          final conseils = data
              .map((item) => Conseil.fromJson(item as Map<String, dynamic>))
              .toList();

          return ApiResponse<List<Conseil>>(
            success: true,
            message: jsonResponse['message'] ?? 'Conseils récupérés',
            data: conseils,
          );
        }
        return ApiResponse<List<Conseil>>(
          success: true,
          message: 'Aucun conseil trouvé',
          data: [],
        );
      } else {
        return ApiResponse<List<Conseil>>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la récupération des conseils',
        );
      }
    } catch (e) {
      return ApiResponse<List<Conseil>>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }
}
