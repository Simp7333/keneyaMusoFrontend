/// Modèle pour les détails complets d'une patiente
class PatienteDetail {
  final int id;
  final String nom;
  final String prenom;
  final String telephone;
  final String? dateDeNaissance;
  final String? adresse;
  final int? age;
  final MedecinBrief? medecinAssigne;
  final List<GrossesseDetail>? grossesses;
  final List<EnfantDetail>? enfants;
  final List<ConsultationPrenataleDetail>? consultationsPrenatales;
  final List<ConsultationPostnataleDetail>? consultationsPostnatales;

  PatienteDetail({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    this.dateDeNaissance,
    this.adresse,
    this.age,
    this.medecinAssigne,
    this.grossesses,
    this.enfants,
    this.consultationsPrenatales,
    this.consultationsPostnatales,
  });

  factory PatienteDetail.fromJson(Map<String, dynamic> json) {
    return PatienteDetail(
      id: json['id'] as int,
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      telephone: json['telephone'] as String? ?? '',
      dateDeNaissance: json['dateDeNaissance'] as String?,
      adresse: json['adresse'] as String?,
      age: json['age'] as int?,
      medecinAssigne: json['medecinAssigne'] != null
          ? MedecinBrief.fromJson(json['medecinAssigne'] as Map<String, dynamic>)
          : null,
      grossesses: json['grossesses'] != null
          ? (json['grossesses'] as List)
              .map((e) => GrossesseDetail.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      enfants: json['enfants'] != null
          ? (json['enfants'] as List)
              .map((e) => EnfantDetail.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      consultationsPrenatales: json['consultationsPrenatales'] != null
          ? (json['consultationsPrenatales'] as List)
              .map((e) => ConsultationPrenataleDetail.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      consultationsPostnatales: json['consultationsPostnatales'] != null
          ? (json['consultationsPostnatales'] as List)
              .map((e) => ConsultationPostnataleDetail.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  String get fullName => '$prenom $nom'.trim();
  
  /// Récupère la date d'accouchement depuis le premier enfant
  String? get dateAccouchement {
    if (enfants != null && enfants!.isNotEmpty) {
      // La date d'accouchement est la date de naissance du premier enfant
      return enfants!.first.dateDeNaissance;
    }
    return null;
  }
}

class MedecinBrief {
  final int id;
  final String nom;
  final String prenom;
  final String? telephone;
  final String? specialite;

  MedecinBrief({
    required this.id,
    required this.nom,
    required this.prenom,
    this.telephone,
    this.specialite,
  });

  factory MedecinBrief.fromJson(Map<String, dynamic> json) {
    return MedecinBrief(
      id: json['id'] as int,
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      telephone: json['telephone'] as String?,
      specialite: json['specialite'] as String?,
    );
  }

  String get fullName => '$prenom $nom'.trim();
}

class GrossesseDetail {
  final int id;
  final String? dateDebut;
  final String? datePrevueAccouchement;
  final String statut;
  final int nombreConsultations;

  GrossesseDetail({
    required this.id,
    this.dateDebut,
    this.datePrevueAccouchement,
    required this.statut,
    required this.nombreConsultations,
  });

  factory GrossesseDetail.fromJson(Map<String, dynamic> json) {
    return GrossesseDetail(
      id: json['id'] as int,
      dateDebut: json['dateDebut'] as String?,
      datePrevueAccouchement: json['datePrevueAccouchement'] as String?,
      statut: json['statut'] as String? ?? '',
      nombreConsultations: json['nombreConsultations'] as int? ?? 0,
    );
  }
}

class EnfantDetail {
  final int id;
  final String nom;
  final String prenom;
  final String dateDeNaissance;
  final String sexe;
  final int? age;
  final int nombreVaccinations;
  final int nombreConsultations;

  EnfantDetail({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.dateDeNaissance,
    required this.sexe,
    this.age,
    required this.nombreVaccinations,
    required this.nombreConsultations,
  });

  factory EnfantDetail.fromJson(Map<String, dynamic> json) {
    return EnfantDetail(
      id: json['id'] as int,
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      dateDeNaissance: json['dateDeNaissance'] as String,
      sexe: json['sexe'] as String? ?? '',
      age: json['age'] as int?,
      nombreVaccinations: json['nombreVaccinations'] as int? ?? 0,
      nombreConsultations: json['nombreConsultations'] as int? ?? 0,
    );
  }

  String get fullName => '$prenom $nom'.trim();
}

class ConsultationPrenataleDetail {
  final int id;
  final String? datePrevue;
  final String? dateRealisee;
  final String statut;
  final double? poids;
  final String? tensionArterielle;
  final double? hauteurUterine;
  final String? notes;

  ConsultationPrenataleDetail({
    required this.id,
    this.datePrevue,
    this.dateRealisee,
    required this.statut,
    this.poids,
    this.tensionArterielle,
    this.hauteurUterine,
    this.notes,
  });

  factory ConsultationPrenataleDetail.fromJson(Map<String, dynamic> json) {
    return ConsultationPrenataleDetail(
      id: json['id'] as int,
      datePrevue: json['datePrevue'] as String?,
      dateRealisee: json['dateRealisee'] as String?,
      statut: json['statut'] as String? ?? '',
      poids: json['poids'] != null ? (json['poids'] as num).toDouble() : null,
      tensionArterielle: json['tensionArterielle'] as String?,
      hauteurUterine: json['hauteurUterine'] != null ? (json['hauteurUterine'] as num).toDouble() : null,
      notes: json['notes'] as String?,
    );
  }
}

class ConsultationPostnataleDetail {
  final int id;
  final String type;
  final String? datePrevue;
  final String? dateRealisee;
  final String statut;
  final String? notesMere;
  final String? notesNouveauNe;

  ConsultationPostnataleDetail({
    required this.id,
    required this.type,
    this.datePrevue,
    this.dateRealisee,
    required this.statut,
    this.notesMere,
    this.notesNouveauNe,
  });

  factory ConsultationPostnataleDetail.fromJson(Map<String, dynamic> json) {
    return ConsultationPostnataleDetail(
      id: json['id'] as int,
      type: json['type'] as String? ?? '',
      datePrevue: json['datePrevue'] as String?,
      dateRealisee: json['dateRealisee'] as String?,
      statut: json['statut'] as String? ?? '',
      notesMere: json['notesMere'] as String?,
      notesNouveauNe: json['notesNouveauNe'] as String?,
    );
  }
}

