import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/dto/enfant_request.dart';
import '../models/dto/api_response.dart';
import '../models/enfant_brief.dart';

/// Service pour la gestion des enfants
class EnfantService {
  /// Crée un nouvel enfant
  Future<ApiResponse<dynamic>> createEnfant(EnfantRequest request) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        return ApiResponse<dynamic>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/enfants');
      
      final response = await http.post(
        url,
        headers: ApiConfig.headersWithAuth(token),
        body: request.toJsonString(),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ApiResponse<dynamic>.fromJson(
          jsonResponse,
          (data) => data,
        );
      } else {
        return ApiResponse<dynamic>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la création de l\'enfant',
        );
      }
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Récupère les enfants d'une patiente
  Future<ApiResponse<List<EnfantBrief>>> getEnfantsByPatiente(int patienteId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        return ApiResponse<List<EnfantBrief>>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/enfants/patiente/$patienteId');
      
      final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
          final enfants = data
              .map((item) => EnfantBrief.fromJson(item as Map<String, dynamic>))
              .toList();

          return ApiResponse<List<EnfantBrief>>(
            success: true,
            message: jsonResponse['message'] ?? 'Enfants récupérés',
            data: enfants,
          );
        }
        return ApiResponse<List<EnfantBrief>>(
          success: true,
          message: 'Aucun enfant trouvé',
          data: [],
        );
      } else {
        return ApiResponse<List<EnfantBrief>>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la récupération des enfants',
        );
      }
    } catch (e) {
      return ApiResponse<List<EnfantBrief>>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Met à jour les informations d'un enfant
  Future<ApiResponse<EnfantBrief>> updateEnfant(int enfantId, EnfantRequest request) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        return ApiResponse<EnfantBrief>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/enfants/$enfantId');
      
      final response = await http.put(
        url,
        headers: ApiConfig.headersWithAuth(token),
        body: request.toJsonString(),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final enfant = EnfantBrief.fromJson(jsonResponse['data'] as Map<String, dynamic>);
          return ApiResponse<EnfantBrief>(
            success: true,
            message: jsonResponse['message'] ?? 'Enfant mis à jour',
            data: enfant,
          );
        }
        return ApiResponse<EnfantBrief>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la mise à jour',
        );
      } else {
        return ApiResponse<EnfantBrief>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la mise à jour de l\'enfant',
        );
      }
    } catch (e) {
      return ApiResponse<EnfantBrief>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }
}

