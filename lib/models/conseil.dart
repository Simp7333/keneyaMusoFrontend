/// Modèle pour un conseil éducatif
class Conseil {
  final int id;
  final String titre;
  final String? contenu;
  final String? lienMedia;
  final String categorie; // NUTRITION, HYGIENE, ALLAITEMENT, PREVENTION, SANTE_GENERALE
  final String cible; // Femme enceinte, Jeune mère, Prenatale, Postnatale, etc.
  final bool actif;
  final int? createurId;
  final String? createurNom;
  final DateTime? dateCreation;
  final DateTime? dateModification;

  Conseil({
    required this.id,
    required this.titre,
    this.contenu,
    this.lienMedia,
    required this.categorie,
    required this.cible,
    required this.actif,
    this.createurId,
    this.createurNom,
    this.dateCreation,
    this.dateModification,
  });

  factory Conseil.fromJson(Map<String, dynamic> json) {
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

    return Conseil(
      id: toInt(json['id']),
      titre: json['titre'] as String? ?? '',
      contenu: json['contenu'] as String?,
      lienMedia: json['lienMedia'] as String?,
      categorie: json['categorie'] as String? ?? '',
      cible: json['cible'] as String? ?? '',
      actif: json['actif'] as bool? ?? true,
      createurId: json['createurId'] != null ? toInt(json['createurId']) : null,
      createurNom: json['createurNom'] as String?,
      dateCreation: parseDate(json['dateCreation']),
      dateModification: parseDate(json['dateModification']),
    );
  }

  /// Détermine le type du conseil : "video" ou "conseil"
  String get type {
    if (lienMedia != null && lienMedia!.isNotEmpty) {
      final lien = lienMedia!.toLowerCase();
      // Vérifier les extensions vidéo
      if (lien.endsWith('.mp4') || 
          lien.endsWith('.avi') || 
          lien.endsWith('.mkv') ||
          lien.endsWith('.mov') ||
          lien.endsWith('.wmv') ||
          lien.endsWith('.flv') ||
          lien.endsWith('.webm') ||
          lien.endsWith('.m4v') ||
          // Vérifier les URLs de plateformes vidéo
          lien.contains('youtube') ||
          lien.contains('youtu.be') ||
          lien.contains('vimeo') ||
          lien.contains('dailymotion') ||
          lien.contains('video') ||
          // Vérifier les chemins uploads qui sont des vidéos
          (lien.startsWith('/uploads/') && (
            lien.contains('.mp4') ||
            lien.contains('.avi') ||
            lien.contains('.mkv') ||
            lien.contains('.mov')
          ))) {
        return 'video';
      }
    }
    return 'conseil';
  }

  /// Retourne le nom de la catégorie formaté
  String get categorieFormatee {
    switch (categorie.toUpperCase()) {
      case 'NUTRITION':
        return 'Nutrition';
      case 'HYGIENE':
        return 'Hygiène';
      case 'ALLAITEMENT':
        return 'Allaitement';
      case 'PREVENTION':
        return 'Prévention';
      case 'SANTE_GENERALE':
        return 'Santé Générale';
      default:
        return categorie;
    }
  }

  /// Formate la date de création
  String get dateFormatee {
    if (dateCreation == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dateCreation!);
    
    if (diff.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (diff.inDays == 1) {
      return 'Hier';
    } else if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays} jours';
    } else {
      return '${dateCreation!.day}/${dateCreation!.month}/${dateCreation!.year}';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'contenu': contenu,
      'lienMedia': lienMedia,
      'categorie': categorie,
      'cible': cible,
      'actif': actif,
      'createurId': createurId,
      'createurNom': createurNom,
      'dateCreation': dateCreation?.toIso8601String(),
      'dateModification': dateModification?.toIso8601String(),
    };
  }
}
