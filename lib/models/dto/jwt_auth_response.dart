import '../enums/role_utilisateur.dart';

/// DTO pour la réponse d'authentification JWT
class JwtAuthResponse {
  final String token;
  final String type;
  final int id;
  final String nom;
  final String prenom;
  final String telephone;
  final RoleUtilisateur role;
  final DateTime? dateDeNaissance;

  JwtAuthResponse({
    required this.token,
    this.type = 'Bearer',
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.role,
    this.dateDeNaissance,
  });

  factory JwtAuthResponse.fromJson(Map<String, dynamic> json) {
    return JwtAuthResponse(
      token: json['token'] as String,
      type: json['type'] as String? ?? 'Bearer',
      id: json['id'] as int,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      telephone: json['telephone'] as String,
      role: RoleUtilisateur.fromJson(json['role'] as String),
      dateDeNaissance: json['dateDeNaissance'] != null
          ? DateTime.parse(json['dateDeNaissance'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'type': type,
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'role': role.toJson(),
      'dateDeNaissance': dateDeNaissance?.toIso8601String().split('T')[0],
    };
  }
}

