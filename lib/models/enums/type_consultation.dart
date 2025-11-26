/// Types de consultation disponibles dans l'application
enum TypeConsultation {
  PRENATAL,
  POSTNATAL,
  GENERALE;

  String toJson() => name;
  
  static TypeConsultation fromJson(String json) {
    return TypeConsultation.values.firstWhere(
      (type) => type.name == json,
      orElse: () => TypeConsultation.GENERALE,
    );
  }

  /// Retourne le libellé français du type de consultation
  String get libelle {
    switch (this) {
      case TypeConsultation.PRENATAL:
        return 'Suivi Prénatal';
      case TypeConsultation.POSTNATAL:
        return 'Suivi Postnatal';
      case TypeConsultation.GENERALE:
        return 'Consultation Générale';
    }
  }

  /// Retourne l'icône associée au type de consultation
  String get description {
    switch (this) {
      case TypeConsultation.PRENATAL:
        return 'Suivi de grossesse et consultations prénatales';
      case TypeConsultation.POSTNATAL:
        return 'Suivi après accouchement et soins postnataux';
      case TypeConsultation.GENERALE:
        return 'Consultation médicale générale';
    }
  }
}

