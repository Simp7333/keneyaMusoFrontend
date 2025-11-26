/// Modèle pour la liste des patientes (DTO du backend)
class PatienteListDto {
  final int id;
  final String nom;
  final String prenom;
  final String telephone;
  final DateTime? dateDeNaissance;
  final String? adresse;
  final List<GrossesseBrief>? grossesses;
  final List<EnfantBrief>? enfants;

  PatienteListDto({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    this.dateDeNaissance,
    this.adresse,
    this.grossesses,
    this.enfants,
  });

  factory PatienteListDto.fromJson(Map<String, dynamic> json) {
    // Conversion robuste pour gérer les types du backend
    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    return PatienteListDto(
      id: toInt(json['id']),
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      telephone: json['telephone'] as String? ?? '',
      dateDeNaissance: parseDate(json['dateDeNaissance']),
      adresse: json['adresse'] as String?,
      grossesses: json['grossesses'] != null
          ? (json['grossesses'] as List)
              .map((g) => GrossesseBrief.fromJson(g as Map<String, dynamic>))
              .toList()
          : null,
      enfants: json['enfants'] != null
          ? (json['enfants'] as List)
              .map((e) => EnfantBrief.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  String get fullName => '$prenom $nom';

  String get age {
    if (dateDeNaissance == null) return 'N/A';
    final now = DateTime.now();
    final age = now.year - dateDeNaissance!.year;
    if (now.month < dateDeNaissance!.month ||
        (now.month == dateDeNaissance!.month && now.day < dateDeNaissance!.day)) {
      return '${age - 1} ans';
    }
    return '$age ans';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'dateDeNaissance': dateDeNaissance?.toIso8601String(),
      'adresse': adresse,
      'grossesses': grossesses?.map((g) => g.toJson()).toList(),
      'enfants': enfants?.map((e) => e.toJson()).toList(),
    };
  }
}

/// Modèle pour une grossesse brève
class GrossesseBrief {
  final int id;
  final DateTime? dateDebut;
  final DateTime? datePrevueAccouchement;
  final String statut;

  GrossesseBrief({
    required this.id,
    this.dateDebut,
    this.datePrevueAccouchement,
    required this.statut,
  });

  factory GrossesseBrief.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    return GrossesseBrief(
      id: toInt(json['id']),
      dateDebut: parseDate(json['dateDebut']),
      datePrevueAccouchement: parseDate(json['datePrevueAccouchement']),
      statut: json['statut'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateDebut': dateDebut?.toIso8601String(),
      'datePrevueAccouchement': datePrevueAccouchement?.toIso8601String(),
      'statut': statut,
    };
  }
}

/// Modèle pour un enfant brève
class EnfantBrief {
  final int id;
  final String nom;
  final String prenom;
  final DateTime? dateDeNaissance;
  final String sexe;

  EnfantBrief({
    required this.id,
    required this.nom,
    required this.prenom,
    this.dateDeNaissance,
    required this.sexe,
  });

  factory EnfantBrief.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    return EnfantBrief(
      id: toInt(json['id']),
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      dateDeNaissance: parseDate(json['dateDeNaissance']),
      sexe: json['sexe'] as String? ?? '',
    );
  }

  String get fullName => '$prenom $nom';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'dateDeNaissance': dateDeNaissance?.toIso8601String(),
      'sexe': sexe,
    };
  }
}

