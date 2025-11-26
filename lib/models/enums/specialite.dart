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
}

