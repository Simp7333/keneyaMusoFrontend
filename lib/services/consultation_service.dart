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

  /// Confirme une consultation prénatale (marque comme réalisée)
  /// Prend la consultation complète pour avoir tous les champs nécessaires
  Future<ApiResponse<ConsultationPrenatale>> confirmerConsultationPrenatale(
    ConsultationPrenatale consultation,
    String dateRealisee,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<ConsultationPrenatale>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse(
          '${ApiConfig.baseUrl}/api/consultations-prenatales/${consultation.id}');

      final body = jsonEncode({
        'datePrevue': consultation.datePrevue,
        'dateRealisee': dateRealisee,
        'grossesseId': consultation.grossesseId,
        if (consultation.notes != null) 'notes': consultation.notes,
        if (consultation.poids != null) 'poids': consultation.poids,
        if (consultation.tensionArterielle != null) 'tensionArterielle': consultation.tensionArterielle,
        if (consultation.hauteurUterine != null) 'hauteurUterine': consultation.hauteurUterine,
      });

      final response = await http.put(
        url,
        headers: ApiConfig.headersWithAuth(token),
        body: body,
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final updatedConsultation = ConsultationPrenatale.fromJson(
              jsonResponse['data'] as Map<String, dynamic>);

          return ApiResponse<ConsultationPrenatale>(
            success: true,
            message: jsonResponse['message'] ?? 'Consultation confirmée',
            data: updatedConsultation,
          );
        }
        return ApiResponse<ConsultationPrenatale>(
          success: true,
          message: 'Consultation confirmée',
        );
      } else {
        return ApiResponse<ConsultationPrenatale>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la confirmation',
        );
      }
    } catch (e) {
      return ApiResponse<ConsultationPrenatale>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Reprogramme une consultation prénatale
  /// Prend la consultation complète pour avoir tous les champs nécessaires
  Future<ApiResponse<ConsultationPrenatale>> reprogrammerConsultationPrenatale(
    ConsultationPrenatale consultation,
    String nouvelleDatePrevue,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<ConsultationPrenatale>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse(
          '${ApiConfig.baseUrl}/api/consultations-prenatales/${consultation.id}');

      final body = jsonEncode({
        'datePrevue': nouvelleDatePrevue,
        'grossesseId': consultation.grossesseId,
        if (consultation.notes != null) 'notes': consultation.notes,
        if (consultation.poids != null) 'poids': consultation.poids,
        if (consultation.tensionArterielle != null) 'tensionArterielle': consultation.tensionArterielle,
        if (consultation.hauteurUterine != null) 'hauteurUterine': consultation.hauteurUterine,
      });

      final response = await http.put(
        url,
        headers: ApiConfig.headersWithAuth(token),
        body: body,
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final updatedConsultation = ConsultationPrenatale.fromJson(
              jsonResponse['data'] as Map<String, dynamic>);

          return ApiResponse<ConsultationPrenatale>(
            success: true,
            message: jsonResponse['message'] ?? 'Consultation reprogrammée',
            data: updatedConsultation,
          );
        }
        return ApiResponse<ConsultationPrenatale>(
          success: true,
          message: 'Consultation reprogrammée',
        );
      } else {
        return ApiResponse<ConsultationPrenatale>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la reprogrammation',
        );
      }
    } catch (e) {
      return ApiResponse<ConsultationPrenatale>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Confirme une consultation postnatale (marque comme réalisée)
  /// Prend la consultation complète pour avoir tous les champs nécessaires
  Future<ApiResponse<ConsultationPostnatale>> confirmerConsultationPostnatale(
    ConsultationPostnatale consultation,
    String dateRealisee,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<ConsultationPostnatale>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse(
          '${ApiConfig.baseUrl}/api/consultations-postnatales/${consultation.id}');

      final body = jsonEncode({
        'type': consultation.type,
        'datePrevue': consultation.datePrevue,
        'dateRealisee': dateRealisee,
        'patienteId': consultation.patienteId,
        if (consultation.enfantId != null) 'enfantId': consultation.enfantId,
        if (consultation.notesMere != null) 'notesMere': consultation.notesMere,
        if (consultation.notesNouveauNe != null) 'notesNouveauNe': consultation.notesNouveauNe,
      });

      final response = await http.put(
        url,
        headers: ApiConfig.headersWithAuth(token),
        body: body,
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final updatedConsultation = ConsultationPostnatale.fromJson(
              jsonResponse['data'] as Map<String, dynamic>);

          return ApiResponse<ConsultationPostnatale>(
            success: true,
            message: jsonResponse['message'] ?? 'Consultation confirmée',
            data: updatedConsultation,
          );
        }
        return ApiResponse<ConsultationPostnatale>(
          success: true,
          message: 'Consultation confirmée',
        );
      } else {
        return ApiResponse<ConsultationPostnatale>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la confirmation',
        );
      }
    } catch (e) {
      return ApiResponse<ConsultationPostnatale>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Reprogramme une consultation postnatale
  /// Prend la consultation complète pour avoir tous les champs nécessaires
  Future<ApiResponse<ConsultationPostnatale>> reprogrammerConsultationPostnatale(
    ConsultationPostnatale consultation,
    String nouvelleDatePrevue,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<ConsultationPostnatale>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse(
          '${ApiConfig.baseUrl}/api/consultations-postnatales/${consultation.id}');

      final body = jsonEncode({
        'type': consultation.type,
        'datePrevue': nouvelleDatePrevue,
        'patienteId': consultation.patienteId,
        if (consultation.enfantId != null) 'enfantId': consultation.enfantId,
        if (consultation.notesMere != null) 'notesMere': consultation.notesMere,
        if (consultation.notesNouveauNe != null) 'notesNouveauNe': consultation.notesNouveauNe,
      });

      final response = await http.put(
        url,
        headers: ApiConfig.headersWithAuth(token),
        body: body,
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final updatedConsultation = ConsultationPostnatale.fromJson(
              jsonResponse['data'] as Map<String, dynamic>);

          return ApiResponse<ConsultationPostnatale>(
            success: true,
            message: jsonResponse['message'] ?? 'Consultation reprogrammée',
            data: updatedConsultation,
          );
        }
        return ApiResponse<ConsultationPostnatale>(
          success: true,
          message: 'Consultation reprogrammée',
        );
      } else {
        return ApiResponse<ConsultationPostnatale>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la reprogrammation',
        );
      }
    } catch (e) {
      return ApiResponse<ConsultationPostnatale>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }
}

