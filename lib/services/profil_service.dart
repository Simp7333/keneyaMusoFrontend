import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/dto/api_response.dart';

/// Service pour gérer le profil utilisateur
class ProfilService {
  /// Récupère les informations du profil utilisateur depuis SharedPreferences
  Future<Map<String, dynamic>> getCurrentUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'id': prefs.getInt('user_id'),
      'nom': prefs.getString('user_nom'),
      'prenom': prefs.getString('user_prenom'),
      'telephone': prefs.getString('user_telephone'),
      'role': prefs.getString('user_role'),
      'dateDeNaissance': prefs.getString('user_date_naissance'),
    };
  }

  /// Met à jour le profil utilisateur
  Future<ApiResponse<dynamic>> updateProfile({
    String? nom,
    String? prenom,
    String? telephone,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getInt('user_id');

      if (token == null || userId == null) {
        return ApiResponse<dynamic>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      // Construire le body avec les champs à mettre à jour
      final Map<String, dynamic> body = {};
      if (nom != null && nom.isNotEmpty) body['nom'] = nom;
      if (prenom != null && prenom.isNotEmpty) body['prenom'] = prenom;
      if (telephone != null && telephone.isNotEmpty) body['telephone'] = telephone;

      final url = Uri.parse('${ApiConfig.baseUrl}/api/utilisateurs/$userId');
      
      final response = await http.put(
        url,
        headers: ApiConfig.headersWithAuth(token),
        body: jsonEncode(body),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Mettre à jour les données locales si la mise à jour réussit
        if (nom != null) await prefs.setString('user_nom', nom);
        if (prenom != null) await prefs.setString('user_prenom', prenom);
        if (telephone != null) await prefs.setString('user_telephone', telephone);

        return ApiResponse<dynamic>(
          success: true,
          message: jsonResponse['message'] ?? 'Profil mis à jour avec succès',
          data: jsonResponse['data'],
        );
      } else {
        return ApiResponse<dynamic>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la mise à jour du profil',
        );
      }
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Supprime le compte de l'utilisateur connecté
  Future<ApiResponse<void>> deleteAccount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<void>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/utilisateurs/me');

      final response = await http.delete(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Nettoyer les données locales après suppression réussie
        await prefs.remove('auth_token');
        await prefs.remove('user_id');
        await prefs.remove('user_nom');
        await prefs.remove('user_prenom');
        await prefs.remove('user_telephone');
        await prefs.remove('user_role');
        await prefs.remove('user_date_naissance');

        return ApiResponse<void>(
          success: true,
          message: jsonResponse['message'] ?? 'Compte supprimé avec succès',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la suppression du compte',
        );
      }
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }
}

