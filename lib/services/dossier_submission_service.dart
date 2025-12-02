import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/dto/api_response.dart';
import '../models/dto/dossier_submission_response.dart';
import '../models/dto/dossier_submission_request.dart';

/// Service pour la gestion des soumissions de dossiers médicaux (alertes)
class DossierSubmissionService {
  /// Récupère les soumissions en attente pour le médecin connecté
  Future<ApiResponse<List<DossierSubmissionResponse>>> getPendingSubmissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<List<DossierSubmissionResponse>>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/dossiers/submissions/medecin');

      final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
          final submissions = data
              .map((item) => DossierSubmissionResponse.fromJson(item as Map<String, dynamic>))
              .toList();
          return ApiResponse<List<DossierSubmissionResponse>>(
            success: true,
            message: jsonResponse['message'] ?? 'Alertes récupérées avec succès',
            data: submissions,
          );
        }
        return ApiResponse<List<DossierSubmissionResponse>>(
          success: true,
          message: 'Aucune alerte en attente',
          data: [],
        );
      } else {
        return ApiResponse<List<DossierSubmissionResponse>>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la récupération des alertes',
        );
      }
    } catch (e) {
      return ApiResponse<List<DossierSubmissionResponse>>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Approuve une soumission
  Future<ApiResponse<String>> approveSubmission(int submissionId, {String? commentaire}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<String>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/dossiers/submissions/$submissionId/approve');

      final Map<String, dynamic> body = {};
      if (commentaire != null && commentaire.isNotEmpty) {
        body['commentaire'] = commentaire;
      }

      final response = await http.post(
        url,
        headers: ApiConfig.headersWithAuth(token),
        body: jsonEncode(body),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<String>(
          success: true,
          message: jsonResponse['message'] ?? 'Soumission approuvée avec succès',
        );
      } else {
        return ApiResponse<String>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de l\'approbation',
        );
      }
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Rejette une soumission
  Future<ApiResponse<String>> rejectSubmission(int submissionId, String raison) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<String>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/dossiers/submissions/$submissionId/reject');

      final Map<String, dynamic> body = {
        'raison': raison,
      };

      final response = await http.post(
        url,
        headers: ApiConfig.headersWithAuth(token),
        body: jsonEncode(body),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<String>(
          success: true,
          message: jsonResponse['message'] ?? 'Soumission rejetée avec succès',
        );
      } else {
        return ApiResponse<String>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors du rejet',
        );
      }
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Récupère le nombre de soumissions en attente
  Future<ApiResponse<int>> getPendingCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<int>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/dossiers/submissions/medecin/statut');

      final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final int count = jsonResponse['data'] as int? ?? 0;
        return ApiResponse<int>(
          success: true,
          message: jsonResponse['message'] ?? 'Nombre récupéré',
          data: count,
        );
      } else {
        return ApiResponse<int>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la récupération',
        );
      }
    } catch (e) {
      return ApiResponse<int>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Récupère les soumissions de la patiente connectée
  Future<ApiResponse<List<DossierSubmissionResponse>>> getMySubmissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<List<DossierSubmissionResponse>>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/dossiers/submissions/patiente');

      final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
          final submissions = data
              .map((item) => DossierSubmissionResponse.fromJson(item as Map<String, dynamic>))
              .toList();
          return ApiResponse<List<DossierSubmissionResponse>>(
            success: true,
            message: jsonResponse['message'] ?? 'Soumissions récupérées avec succès',
            data: submissions,
          );
        }
        return ApiResponse<List<DossierSubmissionResponse>>(
          success: true,
          message: 'Aucune soumission',
          data: [],
        );
      } else {
        return ApiResponse<List<DossierSubmissionResponse>>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la récupération des soumissions',
        );
      }
    } catch (e) {
      return ApiResponse<List<DossierSubmissionResponse>>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Soumet un dossier médical au médecin (CPN ou CPON)
  Future<ApiResponse<DossierSubmissionResponse>> submitDossier(DossierSubmissionRequest request) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<DossierSubmissionResponse>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/dossiers/submissions');

      final response = await http.post(
        url,
        headers: ApiConfig.headersWithAuth(token),
        body: request.toJsonString(),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final submission = DossierSubmissionResponse.fromJson(
            jsonResponse['data'] as Map<String, dynamic>,
          );
          return ApiResponse<DossierSubmissionResponse>(
            success: true,
            message: jsonResponse['message'] ?? 'Dossier soumis avec succès',
            data: submission,
          );
        }
        return ApiResponse<DossierSubmissionResponse>(
          success: true,
          message: jsonResponse['message'] ?? 'Dossier soumis avec succès',
        );
      } else {
        return ApiResponse<DossierSubmissionResponse>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la soumission',
        );
      }
    } catch (e) {
      return ApiResponse<DossierSubmissionResponse>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }
}


