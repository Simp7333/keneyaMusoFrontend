import 'dart:convert';

/// DTO pour la création d'un enfant
class EnfantRequest {
  final String nom;
  final String prenom;
  final String dateDeNaissance; // Format: YYYY-MM-DD
  final String sexe; // MASCULIN ou FEMININ
  final int patienteId;

  EnfantRequest({
    required this.nom,
    required this.prenom,
    required this.dateDeNaissance,
    required this.sexe,
    required this.patienteId,
  });

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'prenom': prenom,
      'dateDeNaissance': dateDeNaissance,
      'sexe': sexe,
      'patienteId': patienteId,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

