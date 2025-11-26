import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/dto/api_response.dart';
import '../models/conversation.dart';

/// Service pour la gestion des conversations
class ConversationService {
  /// Récupère toutes les conversations d'un utilisateur
  Future<ApiResponse<List<Conversation>>> getConversationsByUtilisateur(int utilisateurId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<List<Conversation>>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/conversations/utilisateur/$utilisateurId');

      final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
          final conversations = data
              .map((item) => Conversation.fromJson(item as Map<String, dynamic>))
              .toList();

          return ApiResponse<List<Conversation>>(
            success: true,
            message: jsonResponse['message'] ?? 'Conversations récupérées',
            data: conversations,
          );
        }
        return ApiResponse<List<Conversation>>(
          success: true,
          message: 'Aucune conversation trouvée',
          data: [],
        );
      } else {
        return ApiResponse<List<Conversation>>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la récupération des conversations',
        );
      }
    } catch (e) {
      return ApiResponse<List<Conversation>>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Obtient ou crée une conversation entre une patiente et son médecin assigné
  Future<ApiResponse<Conversation>> getOrCreateConversationWithMedecin(int patienteId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<Conversation>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/conversations/patiente/$patienteId/medecin');

      final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final conversation = Conversation.fromJson(jsonResponse['data'] as Map<String, dynamic>);

          return ApiResponse<Conversation>(
            success: true,
            message: jsonResponse['message'] ?? 'Conversation récupérée',
            data: conversation,
          );
        }
        return ApiResponse<Conversation>(
          success: false,
          message: 'Aucune conversation trouvée',
        );
      } else {
        return ApiResponse<Conversation>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la récupération de la conversation',
        );
      }
    } catch (e) {
      return ApiResponse<Conversation>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Récupère une conversation par son ID
  Future<ApiResponse<Conversation>> getConversationById(int conversationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<Conversation>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/conversations/$conversationId');

      final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final conversation = Conversation.fromJson(jsonResponse['data'] as Map<String, dynamic>);

          return ApiResponse<Conversation>(
            success: true,
            message: jsonResponse['message'] ?? 'Conversation récupérée',
            data: conversation,
          );
        }
        return ApiResponse<Conversation>(
          success: false,
          message: 'Conversation non trouvée',
        );
      } else {
        return ApiResponse<Conversation>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la récupération de la conversation',
        );
      }
    } catch (e) {
      return ApiResponse<Conversation>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }
}

