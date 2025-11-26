import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/dto/api_response.dart';
import '../models/message.dart';

class MessageService {
  /// Récupère tous les messages d'une conversation
  Future<ApiResponse<List<Message>>> getMessagesByConversation(int conversationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<List<Message>>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/messages/conversation/$conversationId');

      final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
          final messages = data
              .map((item) => Message.fromJson(item as Map<String, dynamic>))
              .toList();
          return ApiResponse<List<Message>>(
            success: true,
            message: jsonResponse['message'] ?? 'Messages récupérés',
            data: messages,
          );
        }
        return ApiResponse<List<Message>>(
          success: true,
          message: 'Aucun message trouvé',
          data: [],
        );
      } else {
        return ApiResponse<List<Message>>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la récupération des messages',
        );
      }
    } catch (e) {
      return ApiResponse<List<Message>>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Envoie un message texte dans une conversation
  Future<ApiResponse<Message>> envoyerMessage({
    required int conversationId,
    required String contenu,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<Message>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/messages');

      final body = jsonEncode({
        'contenu': contenu,
        'conversationId': conversationId,
      });

      final response = await http.post(
        url,
        headers: ApiConfig.headersWithAuth(token),
        body: body,
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final message = Message.fromJson(jsonResponse['data'] as Map<String, dynamic>);
          return ApiResponse<Message>(
            success: true,
            message: jsonResponse['message'] ?? 'Message envoyé',
            data: message,
          );
        }
        return ApiResponse<Message>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de l\'envoi du message',
        );
      } else {
        return ApiResponse<Message>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de l\'envoi du message',
        );
      }
    } catch (e) {
      return ApiResponse<Message>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Envoie une image dans une conversation
  Future<ApiResponse<Message>> envoyerImage({
    required int conversationId,
    required File imageFile,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<Message>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/messages/upload/image');

      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(ApiConfig.headersWithAuth(token));
      request.fields['conversationId'] = conversationId.toString();
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final message = Message.fromJson(jsonResponse['data'] as Map<String, dynamic>);
          return ApiResponse<Message>(
            success: true,
            message: jsonResponse['message'] ?? 'Image envoyée',
            data: message,
          );
        }
        return ApiResponse<Message>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de l\'envoi de l\'image',
        );
      } else {
        return ApiResponse<Message>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de l\'envoi de l\'image',
        );
      }
    } catch (e) {
      return ApiResponse<Message>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Envoie un message audio dans une conversation
  Future<ApiResponse<Message>> envoyerAudio({
    required int conversationId,
    required File audioFile,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<Message>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/messages/upload/audio');

      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(ApiConfig.headersWithAuth(token));
      request.fields['conversationId'] = conversationId.toString();
      request.files.add(
        await http.MultipartFile.fromPath('file', audioFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final message = Message.fromJson(jsonResponse['data'] as Map<String, dynamic>);
          return ApiResponse<Message>(
            success: true,
            message: jsonResponse['message'] ?? 'Message audio envoyé',
            data: message,
          );
        }
        return ApiResponse<Message>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de l\'envoi du message audio',
        );
      } else {
        return ApiResponse<Message>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de l\'envoi du message audio',
        );
      }
    } catch (e) {
      return ApiResponse<Message>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Récupère tous les messages non lus de l'utilisateur connecté
  Future<ApiResponse<List<Message>>> getMessagesNonLus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<List<Message>>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/messages/non-lus');

      final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
          final messages = data
              .map((item) => Message.fromJson(item as Map<String, dynamic>))
              .toList();
          return ApiResponse<List<Message>>(
            success: true,
            message: jsonResponse['message'] ?? 'Messages non lus récupérés',
            data: messages,
          );
        }
        return ApiResponse<List<Message>>(
          success: true,
          message: 'Aucun message non lu trouvé',
          data: [],
        );
      } else {
        return ApiResponse<List<Message>>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors de la récupération des messages non lus',
        );
      }
    } catch (e) {
      return ApiResponse<List<Message>>(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  /// Marque un message comme lu
  Future<ApiResponse<void>> marquerCommeLu(int messageId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse<void>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/messages/$messageId/lire');

      final response = await http.put(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<void>(
          success: true,
          message: jsonResponse['message'] ?? 'Message marqué comme lu',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: jsonResponse['message'] ?? 'Erreur lors du marquage du message',
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

