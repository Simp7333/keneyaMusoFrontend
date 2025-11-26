/// Modèle pour un professionnel de santé
class ProfessionnelSante {
  final int id;
  final String nom;
  final String prenom;
  final String telephone;
  final String specialite;
  final String identifiantProfessionnel;
  final String? adresse; // Supposons que l'adresse puisse être ajoutée plus tard
  final String? imageUrl; // Supposons que l'imageUrl puisse être ajoutée plus tard
  final String? etude; // Nouveau champ anticipé
  final String? heureVisites; // Nouveau champ anticipé
  final String? centreSante; // Nouveau champ anticipé
  final String? contact; // Nouveau champ anticipé (peut être fusionné avec telephone si contact inclut email)
  final int? nombreSuivis; // Nouveau champ anticipé

  ProfessionnelSante({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.specialite,
    required this.identifiantProfessionnel,
    this.adresse,
    this.imageUrl,
    this.etude,
    this.heureVisites,
    this.centreSante,
    this.contact,
    this.nombreSuivis,
  });

  factory ProfessionnelSante.fromJson(Map<String, dynamic> json) {
    // Le backend retourne specialite comme enum (GYNECOLOGUE, PEDIATRE, GENERALISTE)
    // Convertir en String si nécessaire
    String specialiteStr = json['specialite']?.toString() ?? '';
    
    // Calculer le nombre de suivis depuis la liste des patientes si disponible
    int? nombreSuivis;
    if (json['patientes'] != null) {
      final patientes = json['patientes'] as List?;
      nombreSuivis = patientes?.length ?? 0;
    }
    
    return ProfessionnelSante(
      id: json['id'] as int? ?? (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      telephone: json['telephone'] as String? ?? '',
      specialite: specialiteStr,
      identifiantProfessionnel: json['identifiantProfessionnel'] as String? ?? '',
      adresse: json['adresse'] as String?,
      imageUrl: json['imageUrl'] as String?,
      etude: json['etude'] as String?,
      heureVisites: json['heureVisites'] as String?,
      centreSante: json['centreSante'] as String?,
      contact: json['contact'] as String?,
      nombreSuivis: nombreSuivis ?? json['nombreSuivis'] as int?,
    );
  }

  String get fullName => '$prenom $nom';
}
