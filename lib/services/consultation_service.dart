import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/dto/api_response.dart';
import '../models/consultation_prenatale.dart';
import '../models/consultation_postnatale.dart';

/// Service pour la gestion des consultations prénatales et postnatales
class ConsultationService {
  /// Récupère les consultations prénatales d'une patiente
  Future<ApiResponse<List<ConsultationPrenatale>>> getConsultationsPrenatalesByPatiente(
      int patienteId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<List<ConsultationPrenatale>>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse(
          '${ApiConfig.baseUrl}/api/consultations-prenatales/patiente/$patienteId');

      final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
          final consultations = data
              .map((item) => ConsultationPrenatale.fromJson(item as Map<String, dynamic>))
              .toList();

          return ApiResponse<List<ConsultationPrenatale>>(
            success: true,
            message: jsonResponse['message'] ?? 'Consultations récupérées',
            data: consultations,
          );
        }
        return ApiResponse<List<ConsultationPrenatale>>(
          success: true,
          message: 'Aucune consultation trouvée',
          data: [],
        );
      } else {
        return ApiResponse<List<ConsultationPrenatale>>(
          success: false,
          message: jsonResponse['message'] ??
              'Erreur lors de la récupération des consultations',
        );
      }
    } catch (e) {
      return ApiResponse<List<ConsultationPrenatale>>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Récupère les consultations prénatales d'une grossesse
  Future<ApiResponse<List<ConsultationPrenatale>>> getConsultationsPrenatalesByGrossesse(
      int grossesseId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<List<ConsultationPrenatale>>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse(
          '${ApiConfig.baseUrl}/api/consultations-prenatales/grossesse/$grossesseId');

      final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
          final consultations = data
              .map((item) => ConsultationPrenatale.fromJson(item as Map<String, dynamic>))
              .toList();

          return ApiResponse<List<ConsultationPrenatale>>(
            success: true,
            message: jsonResponse['message'] ?? 'Consultations récupérées',
            data: consultations,
          );
        }
        return ApiResponse<List<ConsultationPrenatale>>(
          success: true,
          message: 'Aucune consultation trouvée',
          data: [],
        );
      } else {
        return ApiResponse<List<ConsultationPrenatale>>(
          success: false,
          message: jsonResponse['message'] ??
              'Erreur lors de la récupération des consultations',
        );
      }
    } catch (e) {
      return ApiResponse<List<ConsultationPrenatale>>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Récupère les consultations postnatales d'une patiente
  Future<ApiResponse<List<ConsultationPostnatale>>> getConsultationsPostnatalesByPatiente(
      int patienteId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<List<ConsultationPostnatale>>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse(
          '${ApiConfig.baseUrl}/api/consultations-postnatales/patiente/$patienteId');

      final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
          final consultations = data
              .map((item) => ConsultationPostnatale.fromJson(item as Map<String, dynamic>))
              .toList();

          return ApiResponse<List<ConsultationPostnatale>>(
            success: true,
            message: jsonResponse['message'] ?? 'Consultations récupérées',
            data: consultations,
          );
        }
        return ApiResponse<List<ConsultationPostnatale>>(
          success: true,
          message: 'Aucune consultation trouvée',
          data: [],
        );
      } else {
        return ApiResponse<List<ConsultationPostnatale>>(
          success: false,
          message: jsonResponse['message'] ??
              'Erreur lors de la récupération des consultations',
        );
      }
    } catch (e) {
      return ApiResponse<List<ConsultationPostnatale>>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Récupère les consultations postnatales d'un enfant
  Future<ApiResponse<List<ConsultationPostnatale>>> getConsultationsPostnatalesByEnfant(
      int enfantId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<List<ConsultationPostnatale>>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse(
          '${ApiConfig.baseUrl}/api/consultations-postnatales/enfant/$enfantId');

      final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
          final consultations = data
              .map((item) => ConsultationPostnatale.fromJson(item as Map<String, dynamic>))
              .toList();

          return ApiResponse<List<ConsultationPostnatale>>(
            success: true,
            message: jsonResponse['message'] ?? 'Consultations récupérées',
            data: consultations,
          );
        }
        return ApiResponse<List<ConsultationPostnatale>>(
          success: true,
          message: 'Aucune consultation trouvée',
          data: [],
        );
      } else {
        return ApiResponse<List<ConsultationPostnatale>>(
          success: false,
          message: jsonResponse['message'] ??
              'Erreur lors de la récupération des consultations',
        );
      }
    } catch (e) {
      return ApiResponse<List<ConsultationPostnatale>>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Déclare les CPoN automatiques après un accouchement
  /// Génère automatiquement les 3 consultations : J+3, J+7, 6e semaine
  Future<ApiResponse<List<ConsultationPostnatale>>> declarerCpon({
    required int patienteId,
    required String dateAccouchement,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<List<ConsultationPostnatale>>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse(
          '${ApiConfig.baseUrl}/api/consultations-postnatales/declarer');

      final body = jsonEncode({
        'patienteId': patienteId,
        'dateAccouchement': dateAccouchement,
      });

      final response = await http.post(
        url,
        headers: ApiConfig.headersWithAuth(token),
        body: body,
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
          final consultations = data
              .map((item) => ConsultationPostnatale.fromJson(item as Map<String, dynamic>))
              .toList();

          return ApiResponse<List<ConsultationPostnatale>>(
            success: true,
            message: jsonResponse['message'] ?? 'CPoN créées avec succès',
            data: consultations,
          );
        }
        return ApiResponse<List<ConsultationPostnatale>>(
          success: true,
          message: 'CPoN créées',
          data: [],
        );
      } else {
        return ApiResponse<List<ConsultationPostnatale>>(
          success: false,
          message: jsonResponse['message'] ??
              'Erreur lors de la création des CPoN',
        );
      }
    } catch (e) {
      return ApiResponse<List<ConsultationPostnatale>>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }
}

