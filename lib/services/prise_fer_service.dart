import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/dto/api_response.dart';
import '../models/prise_fer_quotidienne.dart';
import 'package:intl/intl.dart';

/// Service pour le suivi quotidien de la prise de fer
class PriseFerService {
  /// Enregistre une réponse de prise de fer pour aujourd'hui
  Future<ApiResponse<PriseFerQuotidienne>> enregistrerPriseFer({
    required bool prise,
    String? date,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        return ApiResponse<PriseFerQuotidienne>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      final dateAujourdhui = date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // Sauvegarder localement pour l'instant (en attendant un endpoint backend)
      final key = 'prise_fer_$dateAujourdhui';
      await prefs.setBool(key, prise);
      
      // Sauvegarder la liste des dates
      final datesKey = 'prise_fer_dates';
      final datesString = prefs.getString(datesKey) ?? '[]';
      final dates = List<String>.from(jsonDecode(datesString));
      if (!dates.contains(dateAujourdhui)) {
        dates.add(dateAujourdhui);
        await prefs.setString(datesKey, jsonEncode(dates));
      }
      
      // Créer l'objet de réponse
      final userId = prefs.getInt('user_id') ?? 0;
      final priseFer = PriseFerQuotidienne(
        id: DateTime.now().millisecondsSinceEpoch, // ID temporaire
        date: dateAujourdhui,
        prise: prise,
        patienteId: userId,
        createdAt: DateTime.now().toIso8601String(),
      );
      
      return ApiResponse<PriseFerQuotidienne>(
        success: true,
        message: 'Prise de fer enregistrée',
        data: priseFer,
      );
      
      // TODO: Implémenter l'appel API quand l'endpoint sera disponible
      /*
      final url = Uri.parse('${ApiConfig.baseUrl}/api/prise-fer');
      
      final body = jsonEncode({
        'date': dateAujourdhui,
        'prise': prise,
      });
      
      final response = await http.post(
        url,
        headers: ApiConfig.headersWithAuth(token),
        body: body,
      );
      
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final priseFer = PriseFerQuotidienne.fromJson(
            jsonResponse['data'] as Map<String, dynamic>,
          );
          return ApiResponse<PriseFerQuotidienne>(
            success: true,
            message: jsonResponse['message'] ?? 'Prise de fer enregistrée',
            data: priseFer,
          );
        }
      }
      */
    } catch (e) {
      return ApiResponse<PriseFerQuotidienne>(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }

  /// Récupère les prises de fer pour un mois donné
  Future<ApiResponse<List<PriseFerQuotidienne>>> getPrisesFerMois({
    required int annee,
    required int mois,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        return ApiResponse<List<PriseFerQuotidienne>>(
          success: false,
          message: 'Non authentifié. Veuillez vous connecter.',
        );
      }

      // Récupérer toutes les dates enregistrées
      final datesKey = 'prise_fer_dates';
      final datesString = prefs.getString(datesKey) ?? '[]';
      final dates = List<String>.from(jsonDecode(datesString));
      
      final userId = prefs.getInt('user_id') ?? 0;
      final prisesFer = <PriseFerQuotidienne>[];
      
      // Filtrer les dates du mois demandé
      for (final dateStr in dates) {
        try {
          final date = DateTime.parse(dateStr);
          if (date.year == annee && date.month == mois) {
            final prise = prefs.getBool('prise_fer_$dateStr') ?? false;
            prisesFer.add(
              PriseFerQuotidienne(
                id: date.millisecondsSinceEpoch,
                date: dateStr,
                prise: prise,
                patienteId: userId,
              ),
            );
          }
        } catch (e) {
          // Ignorer les dates invalides
        }
      }
      
      return ApiResponse<List<PriseFerQuotidienne>>(
        success: true,
        message: 'Prises de fer récupérées',
        data: prisesFer,
      );
      
      // TODO: Implémenter l'appel API
      /*
      final url = Uri.parse('${ApiConfig.baseUrl}/api/prise-fer?annee=$annee&mois=$mois');
      
      final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
      );
      
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        if (jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
          final prisesFer = data
              .map((item) => PriseFerQuotidienne.fromJson(item as Map<String, dynamic>))
              .toList();
          
          return ApiResponse<List<PriseFerQuotidienne>>(
            success: true,
            message: jsonResponse['message'] ?? 'Prises de fer récupérées',
            data: prisesFer,
          );
        }
      }
      */
    } catch (e) {
      return ApiResponse<List<PriseFerQuotidienne>>(
        success: false,
        message: 'Erreur: ${e.toString()}',
        data: [],
      );
    }
  }

  /// Calcule les statistiques pour le mois en cours
  Future<ApiResponse<StatistiquesPriseFer>> getStatistiquesMois({
    required int annee,
    required int mois,
  }) async {
    try {
      final response = await getPrisesFerMois(annee: annee, mois: mois);
      
      if (!response.success || response.data == null) {
        return ApiResponse<StatistiquesPriseFer>(
          success: false,
          message: response.message,
        );
      }
      
      final prisesFer = response.data!;
      
      // Calculer le nombre de jours dans le mois
      final joursDansMois = DateTime(annee, mois + 1, 0).day;
      
      // Compter les jours avec prise
      final joursAvecPrise = prisesFer.where((p) => p.prise).length;
      
      // Créer les statistiques
      final stats = StatistiquesPriseFer.calculer(
        joursAvecPrise: joursAvecPrise,
        joursTotal: joursDansMois,
      );
      
      return ApiResponse<StatistiquesPriseFer>(
        success: true,
        message: 'Statistiques calculées',
        data: stats,
      );
    } catch (e) {
      return ApiResponse<StatistiquesPriseFer>(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }

  /// Vérifie si la patiente a déjà répondu aujourd'hui
  Future<bool> aReponduAujourdhui() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final aujourdhui = DateFormat('yyyy-MM-dd').format(DateTime.now());
      return prefs.containsKey('prise_fer_$aujourdhui');
    } catch (e) {
      return false;
    }
  }

  /// Récupère la réponse d'aujourd'hui (si disponible)
  Future<bool?> getReponseAujourdhui() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final aujourdhui = DateFormat('yyyy-MM-dd').format(DateTime.now());
      if (prefs.containsKey('prise_fer_$aujourdhui')) {
        return prefs.getBool('prise_fer_$aujourdhui');
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

