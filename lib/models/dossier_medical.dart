/// Modèle pour le dossier médical
class DossierMedical {
  final int id;
  final int patienteId;
  final List<FormulaireCPN>? formulairesCPN;
  final List<FormulaireCPON>? formulairesCPON;

  DossierMedical({
    required this.id,
    required this.patienteId,
    this.formulairesCPN,
    this.formulairesCPON,
  });

  factory DossierMedical.fromJson(Map<String, dynamic> json) {
    return DossierMedical(
      id: json['id'] as int,
      patienteId: json['patiente']?['id'] as int? ?? 0,
      formulairesCPN: json['formulairesCPN'] != null
          ? (json['formulairesCPN'] as List)
              .map((e) => FormulaireCPN.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      formulairesCPON: json['formulairesCPON'] != null
          ? (json['formulairesCPON'] as List)
              .map((e) => FormulaireCPON.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

/// Modèle pour un formulaire CPN (Consultation Prénatale)
class FormulaireCPN {
  final int? id;
  final double? taille;
  final double? poids;
  final String? dernierControle;
  final String? dateDernieresRegles;
  final int? nombreMoisGrossesse;
  final String? groupeSanguin;
  final bool? complications;
  final String? complicationsDetails;
  final bool? mouvementsBebeReguliers;
  final List<String>? symptomes;
  final String? symptomesAutre;
  final bool? prendMedicamentsOuVitamines;
  final String? medicamentsOuVitaminesDetails;
  final bool? aEuMaladies;
  final String? maladiesDetails;

  FormulaireCPN({
    this.id,
    this.taille,
    this.poids,
    this.dernierControle,
    this.dateDernieresRegles,
    this.nombreMoisGrossesse,
    this.groupeSanguin,
    this.complications,
    this.complicationsDetails,
    this.mouvementsBebeReguliers,
    this.symptomes,
    this.symptomesAutre,
    this.prendMedicamentsOuVitamines,
    this.medicamentsOuVitaminesDetails,
    this.aEuMaladies,
    this.maladiesDetails,
  });

  factory FormulaireCPN.fromJson(Map<String, dynamic> json) {
    return FormulaireCPN(
      id: json['id'] as int?,
      taille: json['taille'] as double?,
      poids: json['poids'] as double?,
      dernierControle: json['dernierControle'] as String?,
      dateDernieresRegles: json['dateDernieresRegles'] as String?,
      nombreMoisGrossesse: json['nombreMoisGrossesse'] as int?,
      groupeSanguin: json['groupeSanguin'] as String?,
      complications: json['complications'] as bool?,
      complicationsDetails: json['complicationsDetails'] as String?,
      mouvementsBebeReguliers: json['mouvementsBebeReguliers'] as bool?,
      symptomes: json['symptomes'] != null
          ? List<String>.from(json['symptomes'] as List)
          : null,
      symptomesAutre: json['symptomesAutre'] as String?,
      prendMedicamentsOuVitamines: json['prendMedicamentsOuVitamines'] as bool?,
      medicamentsOuVitaminesDetails: json['medicamentsOuVitaminesDetails'] as String?,
      aEuMaladies: json['aEuMaladies'] as bool?,
      maladiesDetails: json['maladiesDetails'] as String?,
    );
  }
}

/// Modèle pour un formulaire CPON (Consultation Postnatale)
class FormulaireCPON {
  final int? id;
  final String? accouchementType;
  final int? nombreEnfants;
  final String? sentiment;
  final bool? saignements;
  final String? consultation;
  final String? sexeBebe;
  final String? alimentation;

  FormulaireCPON({
    this.id,
    this.accouchementType,
    this.nombreEnfants,
    this.sentiment,
    this.saignements,
    this.consultation,
    this.sexeBebe,
    this.alimentation,
  });

  factory FormulaireCPON.fromJson(Map<String, dynamic> json) {
    return FormulaireCPON(
      id: json['id'] as int?,
      accouchementType: json['accouchementType'] as String?,
      nombreEnfants: json['nombreEnfants'] as int?,
      sentiment: json['sentiment'] as String?,
      saignements: json['saignements'] as bool?,
      consultation: json['consultation'] as String?,
      sexeBebe: json['sexeBebe'] as String?,
      alimentation: json['alimentation'] as String?,
    );
  }
}


