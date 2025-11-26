enum Sexe {
  MASCULIN,
  FEMININ
}

class Vaccination {
  final String nom;
  final DateTime date;
  final String statut;

  Vaccination({
    required this.nom,
    required this.date,
    required this.statut,
  });
}

class ConsultationPostnatale {
  final DateTime date;
  final String motif;
  final String observation;

  ConsultationPostnatale({
    required this.date,
    required this.motif,
    required this.observation,
  });
}

class Enfant {
  final int id;
  final String nom;
  final String prenom;
  final DateTime dateDeNaissance;
  final Sexe sexe;
  final String nomPatiente;
  final List<Vaccination> vaccinations;
  final List<ConsultationPostnatale> consultationsPostnatales;
  final DateTime dateCreation;
  final DateTime? dateModification;

  Enfant({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.dateDeNaissance,
    required this.sexe,
    required this.nomPatiente,
    required this.vaccinations,
    required this.consultationsPostnatales,
    required this.dateCreation,
    this.dateModification,
  });

  String get nomComplet => '$prenom $nom';
  
  int get age {
    final now = DateTime.now();
    int age = now.year - dateDeNaissance.year;
    if (now.month < dateDeNaissance.month || 
        (now.month == dateDeNaissance.month && now.day < dateDeNaissance.day)) {
      age--;
    }
    return age;
  }
}
