import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/dto/grossesse_request.dart';
import '../models/dto/api_response.dart';
import '../models/grossesse.dart';

/// Service pour la gestion des grossesses
class GrossesseService {
  /// Crée une nouvelle grossesse
  Future<ApiResponse<dynamic>> createGrossesse(GrossesseRequest request) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        return ApiResponse<dynamic>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/grossesses');
      
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
          message: jsonResponse['message'] ?? 'Erreur lors de la création de la grossesse',
        );
      }
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Récupère les grossesses d'une patiente
  Future<ApiResponse<List<dynamic>>> getGrossessesByPatiente(int patienteId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        return ApiResponse<List<dynamic>>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/grossesses/patiente/$patienteId');
      
      final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<List<dynamic>>.fromJson(
          jsonResponse,
          (data) => data as List<dynamic>,
        );
      } else {
        return ApiResponse<List<dynamic>>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la récupération des grossesses',
        );
      }
    } catch (e) {
      return ApiResponse<List<dynamic>>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Récupère la grossesse active (EN_COURS) d'une patiente
  Future<ApiResponse<Grossesse?>> getCurrentGrossesseByPatiente(int patienteId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        return ApiResponse<Grossesse?>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/grossesses/patiente/$patienteId');
      
      final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
          
          // Trouver la première grossesse active (EN_COURS)
          for (var item in data) {
            final grossesse = Grossesse.fromJson(item as Map<String, dynamic>);
            if (grossesse.isEnCours) {
              return ApiResponse<Grossesse?>(
                success: true,
                message: 'Grossesse active trouvée',
                data: grossesse,
              );
            }
          }
          
          // Si aucune grossesse active n'est trouvée, retourner null
          return ApiResponse<Grossesse?>(
            success: true,
            message: 'Aucune grossesse active trouvée',
            data: null,
          );
        }
        return ApiResponse<Grossesse?>(
          success: true,
          message: 'Aucune grossesse trouvée',
          data: null,
        );
      } else {
        return ApiResponse<Grossesse?>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la récupération de la grossesse',
        );
      }
    } catch (e) {
      return ApiResponse<Grossesse?>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Termine une grossesse (après accouchement)
  Future<ApiResponse<dynamic>> terminerGrossesse(int grossesseId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        return ApiResponse<dynamic>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/grossesses/$grossesseId/terminer');
      
      final response = await http.put(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<dynamic>.fromJson(
          jsonResponse,
          (data) => data,
        );
      } else {
        return ApiResponse<dynamic>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la clôture de la grossesse',
        );
      }
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }
}

