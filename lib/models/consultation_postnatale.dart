/// Modèle pour une consultation postnatale (CPON)
class ConsultationPostnatale {
  final int id;
  final String type; // JOUR_3, JOUR_7, SEMAINE_6
  final String datePrevue;
  final String? dateRealisee;
  final String statut; // A_VENIR, REALISEE, MANQUEE
  final String? notesMere;
  final String? notesNouveauNe;
  final int patienteId;
  final int? enfantId;

  ConsultationPostnatale({
    required this.id,
    required this.type,
    required this.datePrevue,
    this.dateRealisee,
    required this.statut,
    this.notesMere,
    this.notesNouveauNe,
    required this.patienteId,
    this.enfantId,
  });

  factory ConsultationPostnatale.fromJson(Map<String, dynamic> json) {
    return ConsultationPostnatale(
      id: json['id'] as int,
      type: json['type'] as String,
      datePrevue: json['datePrevue'] as String,
      dateRealisee: json['dateRealisee'] as String?,
      statut: json['statut'] as String,
      notesMere: json['notesMere'] as String?,
      notesNouveauNe: json['notesNouveauNe'] as String?,
      patienteId: json['patiente']?['id'] as int? ?? 0,
      enfantId: json['enfant']?['id'] as int?,
    );
  }

  bool get isAVenir => statut == 'A_VENIR';
  bool get isRealisee => statut == 'REALISEE';
  bool get isManquee => statut == 'MANQUEE';

  String get typeLabel {
    switch (type) {
      case 'JOUR_3':
        return 'CPON J+3';
      case 'JOUR_7':
        return 'CPON J+7';
      case 'SEMAINE_6':
        return 'CPON 6e semaine';
      default:
        return 'CPON';
    }
  }
}

