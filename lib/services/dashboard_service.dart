import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/dto/api_response.dart';
import '../models/rappel.dart';

/// Service pour le tableau de bord de la patiente
class DashboardService {
  /// Récupère les notifications/rappels de la patiente connectée
  Future<ApiResponse<List<Rappel>>> getMyRappels() async {
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

  /// Récupère le nombre de notifications non lues
  Future<int> getUnreadNotificationsCount() async {
    try {
      final response = await getMyRappels();
      if (response.success && response.data != null) {
        return response.data!.where((r) => r.isNonLue).length;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Récupère les statistiques de la patiente
  Future<ApiResponse<Map<String, dynamic>>> getPatienteStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Non authentifié',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/notifications/statistiques');
      
      final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: jsonResponse['message'] ?? 'Statistiques récupérées',
          data: jsonResponse['data'] as Map<String, dynamic>?,
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }
  
  /// Marque un rappel comme lu
  Future<ApiResponse<Rappel>> marquerCommeLu(int rappelId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        return ApiResponse<Rappel>(
          success: false,
          message: 'Non authentifié',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/notifications/$rappelId/lue');
      
      final response = await http.put(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final rappel = Rappel.fromJson(jsonResponse['data'] as Map<String, dynamic>);
          return ApiResponse<Rappel>(
            success: true,
            message: jsonResponse['message'] ?? 'Rappel marqué comme lu',
            data: rappel,
          );
        }
      }
      
      return ApiResponse<Rappel>(
        success: false,
        message: jsonResponse['message'] ?? 'Erreur',
      );
    } catch (e) {
      return ApiResponse<Rappel>(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }

  /// Confirme un rappel (la patiente confirme sa présence)
  /// Marque la consultation/vaccination comme effectuée
  Future<ApiResponse<void>> confirmerRappel(int rappelId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        return ApiResponse<void>(
          success: false,
          message: 'Non authentifié',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/notifications/$rappelId/confirmer');
      
      final response = await http.post(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<void>(
          success: true,
          message: jsonResponse['message'] ?? 'Rappel confirmé avec succès',
        );
      }
      
      return ApiResponse<void>(
        success: false,
        message: jsonResponse['message'] ?? 'Erreur lors de la confirmation',
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }

  /// Reprogramme un rappel à une nouvelle date
  /// Met à jour la date prévue de la consultation/vaccination
  Future<ApiResponse<void>> reprogrammerRappel(int rappelId, String nouvelleDate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        return ApiResponse<void>(
          success: false,
          message: 'Non authentifié',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/notifications/$rappelId/reprogrammer?nouvelleDate=$nouvelleDate');
      
      final response = await http.post(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<void>(
          success: true,
          message: jsonResponse['message'] ?? 'Rappel reprogrammé avec succès',
        );
      }
      
      return ApiResponse<void>(
        success: false,
        message: jsonResponse['message'] ?? 'Erreur lors de la reprogrammation',
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }

  /// Crée un rappel manuel avec titre, date et heure
  Future<ApiResponse<void>> creerRappelManuel({
    required String titre,
    required String date,
    required String heure,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        return ApiResponse<void>(
          success: false,
          message: 'Non authentifié',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/notifications/manuel');
      
      final body = jsonEncode({
        'titre': titre,
        'date': date,
        'heure': heure,
      });

      final response = await http.post(
        url,
        headers: ApiConfig.headersWithAuth(token),
        body: body,
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<void>(
          success: true,
          message: jsonResponse['message'] ?? 'Rappel créé avec succès',
        );
      }
      
      return ApiResponse<void>(
        success: false,
        message: jsonResponse['message'] ?? 'Erreur lors de la création du rappel',
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }
}

