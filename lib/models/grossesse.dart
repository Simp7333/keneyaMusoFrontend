/// Modèle pour une grossesse
class Grossesse {
  final int id;
  final String? dateDebut;
  final String? datePrevueAccouchement;
  final String statut; // EN_COURS, TERMINEE
  final int? patienteId;

  Grossesse({
    required this.id,
    this.dateDebut,
    this.datePrevueAccouchement,
    required this.statut,
    this.patienteId,
  });

  factory Grossesse.fromJson(Map<String, dynamic> json) {
    return Grossesse(
      id: json['id'] as int,
      dateDebut: json['dateDebut'] as String?,
      datePrevueAccouchement: json['datePrevueAccouchement'] as String?,
      statut: json['statut'] as String? ?? 'EN_COURS',
      patienteId: json['patiente']?['id'] as int?,
    );
  }

  bool get isEnCours => statut == 'EN_COURS';
  bool get isTerminee => statut == 'TERMINEE';
}

