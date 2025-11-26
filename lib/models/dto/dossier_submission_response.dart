/// Modèle pour une soumission de dossier médical (alerte)
class DossierSubmissionResponse {
  final int id;
  final String type; // CPN, CPON
  final String status; // EN_ATTENTE, APPROUVEE, REJETEE
  final int patienteId;
  final String patienteNom;
  final String patientePrenom;
  final String payload; // JSON string
  final String? commentaire;
  final DateTime dateCreation;

  DossierSubmissionResponse({
    required this.id,
    required this.type,
    required this.status,
    required this.patienteId,
    required this.patienteNom,
    required this.patientePrenom,
    required this.payload,
    this.commentaire,
    required this.dateCreation,
  });

  factory DossierSubmissionResponse.fromJson(Map<String, dynamic> json) {
    return DossierSubmissionResponse(
      id: json['id'] as int,
      type: json['type'] as String,
      status: json['status'] as String,
      patienteId: json['patienteId'] as int,
      patienteNom: json['patienteNom'] as String,
      patientePrenom: json['patientePrenom'] as String,
      payload: json['payload'] as String,
      commentaire: json['commentaire'] as String?,
      dateCreation: DateTime.parse(json['dateCreation'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'status': status,
      'patienteId': patienteId,
      'patienteNom': patienteNom,
      'patientePrenom': patientePrenom,
      'payload': payload,
      'commentaire': commentaire,
      'dateCreation': dateCreation.toIso8601String(),
    };
  }

  /// Retourne le titre formaté de l'alerte
  String get titre {
    switch (type) {
      case 'CPN':
        return 'Formulaire Prénatal (CPN)';
      case 'CPON':
        return 'Formulaire Postnatal (CPON)';
      default:
        return 'Dossier Médical';
    }
  }

  /// Retourne le nom complet de la patiente
  String get nomComplet => '$patientePrenom $patienteNom';

  /// Retourne un message formaté
  String get message {
    return 'Une nouvelle soumission de dossier médical est en attente de validation.';
  }

  /// Retourne le temps écoulé depuis la création (format court)
  String get tempsEcoule {
    final now = DateTime.now();
    final difference = now.difference(dateCreation);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else {
      return '${(difference.inDays / 7).floor()}sem';
    }
  }
}


