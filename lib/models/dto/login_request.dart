import 'dart:convert';

/// DTO pour la requête de connexion
class LoginRequest {
  final String telephone;
  final String motDePasse;

  LoginRequest({
    required this.telephone,
    required this.motDePasse,
  });

  Map<String, dynamic> toJson() {
    return {
      'telephone': telephone,
      'motDePasse': motDePasse,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

