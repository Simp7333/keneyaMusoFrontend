import 'dart:convert';
import '../enums/role_utilisateur.dart';
import '../enums/specialite.dart';

/// DTO pour la requête d'inscription
class RegisterRequest {
  final String nom;
  final String prenom;
  final String telephone;
  final String motDePasse;
  final RoleUtilisateur role;
  final String langue;
  
  // Champs spécifiques pour PATIENTE
  final DateTime? dateDeNaissance;
  final String? adresse;
  final int? professionnelSanteId;
  
  // Champs spécifiques pour MEDECIN
  final Specialite? specialite;
  final String? identifiantProfessionnel;

  RegisterRequest({
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.motDePasse,
    required this.role,
    this.langue = 'fr',
    this.dateDeNaissance,
    this.adresse,
    this.professionnelSanteId,
    this.specialite,
    this.identifiantProfessionnel,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'motDePasse': motDePasse,
      'role': role.toJson(),
      'langue': langue,
    };

    // Ajouter les champs optionnels s'ils sont présents
    if (dateDeNaissance != null) {
      map['dateDeNaissance'] = dateDeNaissance!.toIso8601String().split('T')[0];
    }
    if (adresse != null && adresse!.isNotEmpty) {
      map['adresse'] = adresse!;
    }
    if (professionnelSanteId != null) {
      map['professionnelSanteId'] = professionnelSanteId!;
    }
    if (specialite != null) {
      map['specialite'] = specialite!.toJson();
    }
    if (identifiantProfessionnel != null && identifiantProfessionnel!.isNotEmpty) {
      map['identifiantProfessionnel'] = identifiantProfessionnel!;
    }

    return map;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

