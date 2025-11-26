import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/dto/api_response.dart';
import '../models/conseil.dart';

/// Service pour la gestion des conseils éducatifs
class ConseilService {
  /// Récupère les conseils pertinents pour la patiente connectée selon son type de suivi
  Future<ApiResponse<List<Conseil>>> getConseilsPourPatiente({String? typeSuivi}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<List<Conseil>>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      // Utiliser /pour-patiente pour éviter le conflit avec /{id}
      String url = '${ApiConfig.baseUrl}/api/conseils/pour-patiente';
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
          final conseils = data
              .map((item) => Conseil.fromJson(item as Map<String, dynamic>))
              .toList();
          return ApiResponse<List<Conseil>>(
            success: true,
            message: jsonResponse['message'] ?? 'Conseils récupérés avec succès',
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

  /// Récupère tous les conseils actifs avec filtres optionnels
  Future<ApiResponse<List<Conseil>>> getConseils({
    String? type, // 'video' ou 'conseil'
    String? categorie,
    String? cible, // 'Prenatale', 'Postnatale', etc.
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<List<Conseil>>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      // Construire l'URL avec les paramètres de filtre
      String url = '${ApiConfig.baseUrl}/api/conseils';
      List<String> params = [];
      
      if (type != null && type.isNotEmpty) {
        params.add('type=$type');
      }
      if (categorie != null && categorie.isNotEmpty) {
        params.add('categorie=$categorie');
      }
      if (cible != null && cible.isNotEmpty) {
        params.add('cible=$cible');
      }
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
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
            message: jsonResponse['message'] ?? 'Conseils récupérés avec succès',
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

  /// Récupère les conseils créés par le médecin connecté
  Future<ApiResponse<List<Conseil>>> getMesConseils() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<List<Conseil>>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/conseils/mes-conseils');

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
            message: jsonResponse['message'] ?? 'Vos conseils récupérés avec succès',
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
          message: jsonResponse['message'] ?? 'Erreur lors de la récupération de vos conseils',
        );
      }
    } catch (e) {
      return ApiResponse<List<Conseil>>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Crée un nouveau conseil
  Future<ApiResponse<Conseil>> createConseil({
    required String titre,
    String? contenu,
    String? lienMedia,
    required String categorie,
    required String cible,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<Conseil>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/conseils');

      final body = {
        'titre': titre,
        'categorie': categorie,
        'cible': cible,
      };

      if (contenu != null && contenu.isNotEmpty) {
        body['contenu'] = contenu;
      }
      if (lienMedia != null && lienMedia.isNotEmpty) {
        body['lienMedia'] = lienMedia;
      }

      final response = await http.post(
        url,
        headers: ApiConfig.headersWithAuth(token),
        body: jsonEncode(body),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final conseil = Conseil.fromJson(jsonResponse['data'] as Map<String, dynamic>);
          return ApiResponse<Conseil>(
            success: true,
            message: jsonResponse['message'] ?? 'Conseil créé avec succès',
            data: conseil,
          );
        }
        return ApiResponse<Conseil>(
          success: false,
          message: 'Erreur lors de la création du conseil',
        );
      } else {
        return ApiResponse<Conseil>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la création du conseil',
        );
      }
    } catch (e) {
      return ApiResponse<Conseil>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Met à jour un conseil
  Future<ApiResponse<Conseil>> updateConseil({
    required int id,
    required String titre,
    String? contenu,
    String? lienMedia,
    required String categorie,
    required String cible,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<Conseil>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/conseils/id/$id');

      final body = {
        'titre': titre,
        'categorie': categorie,
        'cible': cible,
      };

      if (contenu != null && contenu.isNotEmpty) {
        body['contenu'] = contenu;
      }
      if (lienMedia != null && lienMedia.isNotEmpty) {
        body['lienMedia'] = lienMedia;
      }

      final response = await http.put(
        url,
        headers: ApiConfig.headersWithAuth(token),
        body: jsonEncode(body),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final conseil = Conseil.fromJson(jsonResponse['data'] as Map<String, dynamic>);
          return ApiResponse<Conseil>(
            success: true,
            message: jsonResponse['message'] ?? 'Conseil mis à jour avec succès',
            data: conseil,
          );
        }
        return ApiResponse<Conseil>(
          success: false,
          message: 'Erreur lors de la mise à jour du conseil',
        );
      } else {
        return ApiResponse<Conseil>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la mise à jour du conseil',
        );
      }
    } catch (e) {
      return ApiResponse<Conseil>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Supprime un conseil
  Future<ApiResponse<void>> deleteConseil(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<void>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/conseils/id/$id');

      final response = await http.delete(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<void>(
          success: true,
          message: jsonResponse['message'] ?? 'Conseil supprimé avec succès',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la suppression du conseil',
        );
      }
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Upload une vidéo et retourne l'URL du fichier
  Future<ApiResponse<Map<String, String>>> uploadVideo(File videoFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<Map<String, String>>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/conseils/upload/video');

      var request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Ajouter le fichier vidéo
      var multipartFile = await http.MultipartFile.fromPath(
        'file',
        videoFile.path,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final data = jsonResponse['data'] as Map<String, dynamic>;
          return ApiResponse<Map<String, String>>(
            success: true,
            message: jsonResponse['message'] ?? 'Vidéo uploadée avec succès',
            data: {
              'fileName': data['fileName'] as String? ?? '',
              'fileUrl': data['fileUrl'] as String? ?? '',
              'originalFileName': data['originalFileName'] as String? ?? '',
            },
          );
        }
        return ApiResponse<Map<String, String>>(
          success: false,
          message: 'Erreur lors de l\'upload de la vidéo',
        );
      } else {
        return ApiResponse<Map<String, String>>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de l\'upload de la vidéo',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, String>>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }
}

