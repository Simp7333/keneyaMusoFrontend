/// Spécialités des professionnels de santé (médecins)
enum Specialite {
  GYNECOLOGUE,
  PEDIATRE,
  GENERALISTE;

  String toJson() => name;
  
  static Specialite fromJson(String json) {
    return Specialite.values.firstWhere(
      (spec) => spec.name == json,
      orElse: () => Specialite.GYNECOLOGUE,
    );
  }

  /// Retourne le nom formaté pour l'affichage
  String get displayName {
    switch (this) {
      case Specialite.GYNECOLOGUE:
        return 'Gynécologue';
      case Specialite.PEDIATRE:
        return 'Pédiatre';
      case Specialite.GENERALISTE:
        return 'Médecin Généraliste';
    }
  }
}

