/// Modèle simple pour un enfant (version brief pour les listes)
class EnfantBrief {
  final int id;
  final String nom;
  final String prenom;
  final String dateDeNaissance;
  final String sexe;

  EnfantBrief({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.dateDeNaissance,
    required this.sexe,
  });

  factory EnfantBrief.fromJson(Map<String, dynamic> json) {
    return EnfantBrief(
      id: json['id'] as int,
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      dateDeNaissance: json['dateDeNaissance'] as String? ?? '',
      sexe: json['sexe'] as String? ?? 'MASCULIN',
    );
  }

  String get nomComplet => '$prenom $nom';
}

