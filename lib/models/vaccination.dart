/// Modèle pour une vaccination d'enfant
class Vaccination {
  final int id;
  final String nomVaccin;
  final String datePrevue;
  final String? dateRealisee;
  final String statut; // A_FAIRE, FAIT, MANQUE
  final String? notes;
  final int enfantId;

  Vaccination({
    required this.id,
    required this.nomVaccin,
    required this.datePrevue,
    this.dateRealisee,
    required this.statut,
    this.notes,
    required this.enfantId,
  });

  factory Vaccination.fromJson(Map<String, dynamic> json) {
    return Vaccination(
      id: json['id'] as int,
      nomVaccin: json['nomVaccin'] as String,
      datePrevue: json['datePrevue'] as String,
      dateRealisee: json['dateRealisee'] as String?,
      statut: json['statut'] as String,
      notes: json['notes'] as String?,
      enfantId: json['enfant']?['id'] as int? ?? 0,
    );
  }

  bool get isAFaire => statut == 'A_FAIRE';
  bool get isFait => statut == 'FAIT';
  bool get isManque => statut == 'MANQUE';

  String get dateAffichage => dateRealisee ?? datePrevue;
}

