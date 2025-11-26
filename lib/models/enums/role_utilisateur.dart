/// Rôles des utilisateurs dans l'application
enum RoleUtilisateur {
  PATIENTE,
  MEDECIN,
  ADMINISTRATEUR;

  String toJson() => name;
  
  static RoleUtilisateur fromJson(String json) {
    return RoleUtilisateur.values.firstWhere(
      (role) => role.name == json,
      orElse: () => RoleUtilisateur.PATIENTE,
    );
  }
}

