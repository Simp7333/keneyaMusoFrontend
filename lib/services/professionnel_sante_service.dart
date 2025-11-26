import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/dto/api_response.dart';
import '../models/dto/dashboard_stats_response.dart';
import '../models/dto/patiente_list_dto.dart';
import '../models/professionnel_sante.dart';

/// Service pour la gestion des professionnels de santé
class ProfessionnelSanteService {
  /// Récupère la liste de tous les professionnels de santé
  /// Ceci est un placeholder pour le moment, car l'API backend n'est pas encore implémentée pour lister tous les PS.
  Future<ApiResponse<List<ProfessionnelSante>>> getAllProfessionnelsSante() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<List<ProfessionnelSante>>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/utilisateurs/professionnels');

      final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
          final professionnels = data
              .map((item) => ProfessionnelSante.fromJson(item as Map<String, dynamic>))
              .toList();
          return ApiResponse<List<ProfessionnelSante>>(
            success: true,
            message: jsonResponse['message'] ?? 'Professionnels de santé récupérés',
            data: professionnels,
          );
        }
        return ApiResponse<List<ProfessionnelSante>>(
          success: true,
          message: 'Aucun professionnel de santé trouvé',
          data: [],
        );
      } else {
        return ApiResponse<List<ProfessionnelSante>>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la récupération des professionnels de santé',
        );
      }
    } catch (e) {
      return ApiResponse<List<ProfessionnelSante>>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Récupère les détails d'un professionnel de santé par son ID
  /// Ceci est un placeholder pour le moment.
  Future<ApiResponse<ProfessionnelSante>> getProfessionnelSanteById(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<ProfessionnelSante>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/utilisateurs/professionnels/$id');

      final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          try {
            final professionnel = ProfessionnelSante.fromJson(jsonResponse['data'] as Map<String, dynamic>);
            return ApiResponse<ProfessionnelSante>(
              success: true,
              message: jsonResponse['message'] ?? 'Professionnel de santé récupéré',
              data: professionnel,
            );
          } catch (parseError) {
            return ApiResponse<ProfessionnelSante>(
              success: false,
              message: 'Erreur de parsing des données: ${parseError.toString()}',
            );
          }
        }
        return ApiResponse<ProfessionnelSante>(
          success: false,
          message: 'Professionnel de santé non trouvé (données vides)',
        );
      } else {
        return ApiResponse<ProfessionnelSante>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la récupération du professionnel de santé (code: ${response.statusCode})',
        );
      }
    } catch (e) {
      return ApiResponse<ProfessionnelSante>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Récupère les statistiques du tableau de bord pour le médecin connecté
  Future<ApiResponse<DashboardStatsResponse>> getDashboardStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<DashboardStatsResponse>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/dashboard/medecin');

      final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final stats = DashboardStatsResponse.fromJson(
            jsonResponse['data'] as Map<String, dynamic>,
          );
          return ApiResponse<DashboardStatsResponse>(
            success: true,
            message: jsonResponse['message'] ?? 'Statistiques récupérées avec succès',
            data: stats,
          );
        }
        return ApiResponse<DashboardStatsResponse>(
          success: false,
          message: 'Aucune statistique disponible',
        );
      } else {
        return ApiResponse<DashboardStatsResponse>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la récupération des statistiques',
        );
      }
    } catch (e) {
      return ApiResponse<DashboardStatsResponse>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Récupère le profil du professionnel de santé connecté
  Future<ApiResponse<ProfessionnelSante>> getCurrentProfessionnelProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getInt('user_id');

      if (token == null || userId == null) {
        return ApiResponse<ProfessionnelSante>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      return await getProfessionnelSanteById(userId);
    } catch (e) {
      return ApiResponse<ProfessionnelSante>(
        success: false,
        message: 'Erreur lors de la récupération du profil: ${e.toString()}',
      );
    }
  }

  /// Met à jour le profil du professionnel de santé connecté
  Future<ApiResponse<ProfessionnelSante>> updateProfessionnelProfile({
    String? nom,
    String? prenom,
    String? telephone,
    String? specialite,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getInt('user_id');

      if (token == null || userId == null) {
        return ApiResponse<ProfessionnelSante>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      // Construire le body avec les champs à mettre à jour
      final Map<String, dynamic> body = {};
      if (nom != null && nom.isNotEmpty) body['nom'] = nom;
      if (prenom != null && prenom.isNotEmpty) body['prenom'] = prenom;
      if (telephone != null && telephone.isNotEmpty) body['telephone'] = telephone;
      // Note: La spécialité pourrait nécessiter un endpoint spécifique si elle n'est pas modifiable via PUT /utilisateurs/{id}

      final url = Uri.parse('${ApiConfig.baseUrl}/api/utilisateurs/$userId');

      final response = await http.put(
        url,
        headers: ApiConfig.headersWithAuth(token),
        body: jsonEncode(body),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Mettre à jour les données locales
        if (nom != null) await prefs.setString('user_nom', nom);
        if (prenom != null) await prefs.setString('user_prenom', prenom);
        if (telephone != null) await prefs.setString('user_telephone', telephone);

        // Récupérer le profil complet mis à jour
        if (jsonResponse['data'] != null) {
          final professionnel = ProfessionnelSante.fromJson(
            jsonResponse['data'] as Map<String, dynamic>,
          );
          return ApiResponse<ProfessionnelSante>(
            success: true,
            message: jsonResponse['message'] ?? 'Profil mis à jour avec succès',
            data: professionnel,
          );
        }

        // Si les données ne sont pas dans la réponse, récupérer le profil complet
        return await getCurrentProfessionnelProfile();
      } else {
        return ApiResponse<ProfessionnelSante>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la mise à jour du profil',
        );
      }
    } catch (e) {
      return ApiResponse<ProfessionnelSante>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Récupère la liste des patientes du médecin connecté avec filtre optionnel
  /// typeSuivi: 'PRENATAL', 'POSTNATAL', ou null pour toutes les patientes
  Future<ApiResponse<List<PatienteListDto>>> getMedecinPatientes({String? typeSuivi}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<List<PatienteListDto>>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      String url = '${ApiConfig.baseUrl}/api/dashboard/medecin/patientes';
      if (typeSuivi != null && typeSuivi.isNotEmpty) {
        url += '?typeSuivi=$typeSuivi';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
          final patientes = data
              .map((item) => PatienteListDto.fromJson(item as Map<String, dynamic>))
              .toList();
          return ApiResponse<List<PatienteListDto>>(
            success: true,
            message: jsonResponse['message'] ?? 'Liste des patientes récupérée avec succès',
            data: patientes,
          );
        }
        return ApiResponse<List<PatienteListDto>>(
          success: true,
          message: 'Aucune patiente trouvée',
          data: [],
        );
      } else {
        return ApiResponse<List<PatienteListDto>>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la récupération des patientes',
        );
      }
    } catch (e) {
      return ApiResponse<List<PatienteListDto>>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }
}
