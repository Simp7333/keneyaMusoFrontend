import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/dto/login_request.dart';
import '../models/dto/register_request.dart';
import '../models/dto/jwt_auth_response.dart';
import '../models/dto/api_response.dart';
import '../models/enums/role_utilisateur.dart';

/// Service d'authentification pour gérer la connexion et l'inscription
class AuthService {
  /// Connexion d'un utilisateur
  Future<ApiResponse<JwtAuthResponse>> login(LoginRequest request) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}');
      
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: request.toJsonString(),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<JwtAuthResponse>.fromJson(
          jsonResponse,
          (data) => JwtAuthResponse.fromJson(data as Map<String, dynamic>),
        );

        // Sauvegarder le token et les informations utilisateur
        if (apiResponse.data != null) {
          await _saveAuthData(apiResponse.data!);
        }

        return apiResponse;
      } else {
        return ApiResponse<JwtAuthResponse>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur de connexion',
        );
      }
    } catch (e) {
      return ApiResponse<JwtAuthResponse>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Inscription d'un nouvel utilisateur
  Future<ApiResponse<JwtAuthResponse>> register(RegisterRequest request) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}');
      
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: request.toJsonString(),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<JwtAuthResponse>.fromJson(
          jsonResponse,
          (data) => JwtAuthResponse.fromJson(data as Map<String, dynamic>),
        );

        // Sauvegarder le token et les informations utilisateur
        if (apiResponse.data != null) {
          await _saveAuthData(apiResponse.data!);
        }

        return apiResponse;
      } else {
        return ApiResponse<JwtAuthResponse>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur d\'inscription',
        );
      }
    } catch (e) {
      return ApiResponse<JwtAuthResponse>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Déconnexion de l'utilisateur
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      try {
        final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.logoutEndpoint}');
        await http.post(
          url,
          headers: ApiConfig.headersWithAuth(token),
        );
      } catch (e) {
        // Ignorer les erreurs de logout côté serveur
      }
    }

    // Supprimer les données locales
    await _clearAuthData();
  }

  /// Sauvegarde les données d'authentification localement
  Future<void> _saveAuthData(JwtAuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('auth_token', authResponse.token);
    await prefs.setInt('user_id', authResponse.id);
    await prefs.setString('user_nom', authResponse.nom);
    await prefs.setString('user_prenom', authResponse.prenom);
    await prefs.setString('user_telephone', authResponse.telephone);
    await prefs.setString('user_role', authResponse.role.toJson());
    
    if (authResponse.dateDeNaissance != null) {
      await prefs.setString(
        'user_date_naissance',
        authResponse.dateDeNaissance!.toIso8601String(),
      );
    }
  }

  /// Supprime les données d'authentification localement
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_nom');
    await prefs.remove('user_prenom');
    await prefs.remove('user_telephone');
    await prefs.remove('user_role');
    await prefs.remove('user_date_naissance');
  }

  /// Vérifie si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }

  /// Récupère le token d'authentification
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Récupère le rôle de l'utilisateur connecté
  Future<RoleUtilisateur?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final roleString = prefs.getString('user_role');
    if (roleString != null) {
      return RoleUtilisateur.fromJson(roleString);
    }
    return null;
  }

  /// Upload une photo de profil et retourne l'URL du fichier
  Future<ApiResponse<Map<String, String>>> uploadProfileImage(File imageFile) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/utilisateurs/upload/profile-image');

      var request = http.MultipartRequest('POST', url);

      // Ajouter le fichier image
      var multipartFile = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
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
            message: jsonResponse['message'] ?? 'Photo de profil uploadée avec succès',
            data: {
              'fileName': data['fileName'] as String? ?? '',
              'fileUrl': data['fileUrl'] as String? ?? '',
              'originalFileName': data['originalFileName'] as String? ?? '',
            },
          );
        }
        return ApiResponse<Map<String, String>>(
          success: false,
          message: 'Erreur lors de l\'upload de la photo',
        );
      } else {
        return ApiResponse<Map<String, String>>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de l\'upload de la photo',
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

