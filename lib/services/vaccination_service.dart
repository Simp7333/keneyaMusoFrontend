import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/dto/api_response.dart';
import '../models/vaccination.dart';

/// Service pour la gestion des vaccinations
class VaccinationService {
  /// Récupère toutes les vaccinations d'un enfant
  Future<ApiResponse<List<Vaccination>>> getVaccinationsByEnfant(
      int enfantId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<List<Vaccination>>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse(
          '${ApiConfig.baseUrl}/api/vaccinations/enfant/$enfantId');

      final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
          final vaccinations = data
              .map((item) => Vaccination.fromJson(item as Map<String, dynamic>))
              .toList();

          return ApiResponse<List<Vaccination>>(
            success: true,
            message: jsonResponse['message'] ?? 'Vaccinations récupérées',
            data: vaccinations,
          );
        }
        return ApiResponse<List<Vaccination>>(
          success: true,
          message: 'Aucune vaccination trouvée',
          data: [],
        );
      } else {
        return ApiResponse<List<Vaccination>>(
          success: false,
          message: jsonResponse['message'] ??
              'Erreur lors de la récupération des vaccinations',
        );
      }
    } catch (e) {
      return ApiResponse<List<Vaccination>>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Récupère toutes les vaccinations (pour admin/médecin)
  Future<ApiResponse<List<Vaccination>>> getAllVaccinations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<List<Vaccination>>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/vaccinations');

      final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
          final vaccinations = data
              .map((item) => Vaccination.fromJson(item as Map<String, dynamic>))
              .toList();

          return ApiResponse<List<Vaccination>>(
            success: true,
            message: jsonResponse['message'] ?? 'Vaccinations récupérées',
            data: vaccinations,
          );
        }
        return ApiResponse<List<Vaccination>>(
          success: true,
          message: 'Aucune vaccination trouvée',
          data: [],
        );
      } else {
        return ApiResponse<List<Vaccination>>(
          success: false,
          message: jsonResponse['message'] ??
              'Erreur lors de la récupération des vaccinations',
        );
      }
    } catch (e) {
      return ApiResponse<List<Vaccination>>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Confirme une vaccination (marque comme faite)
  /// Prend la vaccination complète pour avoir tous les champs nécessaires
  Future<ApiResponse<Vaccination>> confirmerVaccination(
    Vaccination vaccination,
    String dateRealisee,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<Vaccination>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/vaccinations/${vaccination.id}');

      final body = jsonEncode({
        'nomVaccin': vaccination.nomVaccin,
        'datePrevue': vaccination.datePrevue,
        'dateRealisee': dateRealisee,
        'enfantId': vaccination.enfantId,
        if (vaccination.notes != null) 'notes': vaccination.notes,
      });

      final response = await http.put(
        url,
        headers: ApiConfig.headersWithAuth(token),
        body: body,
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final vaccination = Vaccination.fromJson(
              jsonResponse['data'] as Map<String, dynamic>);

          return ApiResponse<Vaccination>(
            success: true,
            message: jsonResponse['message'] ?? 'Vaccination confirmée',
            data: vaccination,
          );
        }
        return ApiResponse<Vaccination>(
          success: true,
          message: 'Vaccination confirmée',
        );
      } else {
        return ApiResponse<Vaccination>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la confirmation',
        );
      }
    } catch (e) {
      return ApiResponse<Vaccination>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Reprogramme une vaccination
  /// Prend la vaccination complète pour avoir tous les champs nécessaires
  Future<ApiResponse<Vaccination>> reprogrammerVaccination(
    Vaccination vaccination,
    String nouvelleDatePrevue,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<Vaccination>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/vaccinations/${vaccination.id}');

      final body = jsonEncode({
        'nomVaccin': vaccination.nomVaccin,
        'datePrevue': nouvelleDatePrevue,
        'enfantId': vaccination.enfantId,
        if (vaccination.notes != null) 'notes': vaccination.notes,
      });

      final response = await http.put(
        url,
        headers: ApiConfig.headersWithAuth(token),
        body: body,
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final vaccination = Vaccination.fromJson(
              jsonResponse['data'] as Map<String, dynamic>);

          return ApiResponse<Vaccination>(
            success: true,
            message: jsonResponse['message'] ?? 'Vaccination reprogrammée',
            data: vaccination,
          );
        }
        return ApiResponse<Vaccination>(
          success: true,
          message: 'Vaccination reprogrammée',
        );
      } else {
        return ApiResponse<Vaccination>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la reprogrammation',
        );
      }
    } catch (e) {
      return ApiResponse<Vaccination>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }
}

