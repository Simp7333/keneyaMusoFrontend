/// Modèle pour une consultation prénatale (CPN)
class ConsultationPrenatale {
  final int id;
  final String datePrevue;
  final String? dateRealisee;
  final String statut; // A_VENIR, REALISEE, MANQUEE
  final String? notes;
  final double? poids;
  final String? tensionArterielle;
  final double? hauteurUterine;
  final int grossesseId;

  ConsultationPrenatale({
    required this.id,
    required this.datePrevue,
    this.dateRealisee,
    required this.statut,
    this.notes,
    this.poids,
    this.tensionArterielle,
    this.hauteurUterine,
    required this.grossesseId,
  });

  factory ConsultationPrenatale.fromJson(Map<String, dynamic> json) {
    return ConsultationPrenatale(
      id: json['id'] as int,
      datePrevue: json['datePrevue'] as String,
      dateRealisee: json['dateRealisee'] as String?,
      statut: json['statut'] as String,
      notes: json['notes'] as String?,
      poids: json['poids'] != null ? (json['poids'] as num).toDouble() : null,
      tensionArterielle: json['tensionArterielle'] as String?,
      hauteurUterine: json['hauteurUterine'] != null 
          ? (json['hauteurUterine'] as num).toDouble() 
          : null,
      grossesseId: json['grossesse']?['id'] as int? ?? 0,
    );
  }

  bool get isAVenir => statut == 'A_VENIR';
  bool get isRealisee => statut == 'REALISEE';
  bool get isManquee => statut == 'MANQUEE';
}

