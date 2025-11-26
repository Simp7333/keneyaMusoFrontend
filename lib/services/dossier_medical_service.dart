import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/dto/api_response.dart';
import '../models/dossier_medical.dart';
import '../models/patiente_detail.dart';

/// Service pour la gestion des dossiers médicaux
class DossierMedicalService {
  /// Récupère le dossier médical de la patiente connectée
  Future<ApiResponse<DossierMedical>> getMyDossierMedical() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getInt('user_id');

      if (token == null || userId == null) {
        return ApiResponse<DossierMedical>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/patients/$userId/dossier-medical');

      final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final dossier = DossierMedical.fromJson(jsonResponse);
        return ApiResponse<DossierMedical>(
          success: true,
          message: 'Dossier médical récupéré avec succès',
          data: dossier,
        );
      } else if (response.statusCode == 404) {
        // Dossier médical n'existe pas encore, on le crée
        return await createDossierMedical();
      } else {
        return ApiResponse<DossierMedical>(
          success: false,
          message: 'Erreur lors de la récupération du dossier médical',
        );
      }
    } catch (e) {
      return ApiResponse<DossierMedical>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Crée un dossier médical pour la patiente connectée
  Future<ApiResponse<DossierMedical>> createDossierMedical() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getInt('user_id');

      if (token == null || userId == null) {
        return ApiResponse<DossierMedical>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/patients/$userId/dossier-medical');

      final response = await http.post(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final dossier = DossierMedical.fromJson(jsonResponse);
        return ApiResponse<DossierMedical>(
          success: true,
          message: 'Dossier médical créé avec succès',
          data: dossier,
        );
      } else {
        return ApiResponse<DossierMedical>(
          success: false,
          message: 'Erreur lors de la création du dossier médical',
        );
      }
    } catch (e) {
      return ApiResponse<DossierMedical>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Récupère les informations de la patiente connectée
  Future<ApiResponse<Map<String, dynamic>>> getMyPatienteInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      // Récupérer les infos depuis SharedPreferences
      final nom = prefs.getString('user_nom') ?? '';
      final prenom = prefs.getString('user_prenom') ?? '';
      final telephone = prefs.getString('user_telephone') ?? '';
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'ID utilisateur non trouvé',
        );
      }

      // Pour l'instant, on retourne les données de SharedPreferences
      // TODO: Faire un appel API pour récupérer les données complètes
      final info = {
        'id': userId,
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
      };

      return ApiResponse<Map<String, dynamic>>(
        success: true,
        message: 'Informations récupérées',
        data: info,
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }

  /// Récupère les détails complets de la patiente connectée
  Future<ApiResponse<PatienteDetail>> getMyPatienteDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<PatienteDetail>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/patientes/me');

      final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final patiente = PatienteDetail.fromJson(jsonResponse['data'] as Map<String, dynamic>);
          return ApiResponse<PatienteDetail>(
            success: true,
            message: jsonResponse['message'] ?? 'Informations récupérées',
            data: patiente,
          );
        }
        return ApiResponse<PatienteDetail>(
          success: false,
          message: 'Aucune information trouvée',
        );
      } else {
        return ApiResponse<PatienteDetail>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la récupération des informations',
        );
      }
    } catch (e) {
      return ApiResponse<PatienteDetail>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Récupère les détails d'une patiente spécifique (pour les professionnels de santé)
  Future<ApiResponse<PatienteDetail>> getPatienteDetails(int patienteId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<PatienteDetail>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/patientes/$patienteId');

      final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final patiente = PatienteDetail.fromJson(jsonResponse['data'] as Map<String, dynamic>);
          return ApiResponse<PatienteDetail>(
            success: true,
            message: jsonResponse['message'] ?? 'Informations de la patiente récupérées',
            data: patiente,
          );
        }
        return ApiResponse<PatienteDetail>(
          success: false,
          message: 'Aucune information trouvée pour cette patiente',
        );
      } else {
        return ApiResponse<PatienteDetail>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la récupération des informations',
        );
      }
    } catch (e) {
      return ApiResponse<PatienteDetail>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }
}

