/// Modèle pour un rappel/notification
class Rappel {
  final int id;
  final String message;
  final String dateCreation;
  final String? dateEnvoi; // Date d'envoi prévue du rappel
  final String type; // RAPPEL_CONSULTATION, RAPPEL_VACCINATION, CONSEIL, AUTRE
  final String statut; // NON_LUE, LUE, TRAITEE
  final String priorite; // ELEVEE, NORMALE, FAIBLE
  final String titre;
  final int? patienteId;
  final int? medecinId;
  final int? consultationPrenataleId;
  final int? consultationPostnataleId;
  final int? vaccinationId;

  Rappel({
    required this.id,
    required this.message,
    required this.dateCreation,
    this.dateEnvoi,
    required this.type,
    required this.statut,
    required this.priorite,
    required this.titre,
    this.patienteId,
    this.medecinId,
    this.consultationPrenataleId,
    this.consultationPostnataleId,
    this.vaccinationId,
  });

  factory Rappel.fromJson(Map<String, dynamic> json) {
    // Extraire les IDs des consultations depuis les objets imbriqués si disponibles
    int? consultationPrenataleId;
    int? consultationPostnataleId;
    int? vaccinationId;
    
    if (json['consultationPrenatale'] != null) {
      final cpn = json['consultationPrenatale'] as Map<String, dynamic>;
      consultationPrenataleId = cpn['id'] as int?;
    } else if (json['consultationPrenataleId'] != null) {
      consultationPrenataleId = json['consultationPrenataleId'] as int?;
    }
    
    if (json['consultationPostnatale'] != null) {
      final cpon = json['consultationPostnatale'] as Map<String, dynamic>;
      consultationPostnataleId = cpon['id'] as int?;
    } else if (json['consultationPostnataleId'] != null) {
      consultationPostnataleId = json['consultationPostnataleId'] as int?;
    }
    
    if (json['vaccination'] != null) {
      final vacc = json['vaccination'] as Map<String, dynamic>;
      vaccinationId = vacc['id'] as int?;
    } else if (json['vaccinationId'] != null) {
      vaccinationId = json['vaccinationId'] as int?;
    }
    
    return Rappel(
      id: json['id'] as int,
      message: json['message'] as String,
      dateCreation: json['dateCreation'] as String,
      dateEnvoi: json['dateEnvoi'] as String?,
      type: json['type'] as String,
      statut: json['statut'] as String,
      priorite: json['priorite'] as String,
      titre: json['titre'] as String,
      patienteId: json['patienteId'] as int?,
      medecinId: json['medecinId'] as int?,
      consultationPrenataleId: consultationPrenataleId,
      consultationPostnataleId: consultationPostnataleId,
      vaccinationId: vaccinationId,
    );
  }

  bool get isNonLue => statut == 'NON_LUE';
  bool get isLue => statut == 'LUE';
  bool get isTraitee => statut == 'TRAITEE';
  
  /// Retourne la date à afficher (dateEnvoi si disponible, sinon dateCreation)
  String get displayDate => dateEnvoi ?? dateCreation;
  
  /// Vérifie si c'est un rappel de consultation postnatale
  bool get isRappelCPON => type == 'RAPPEL_CONSULTATION' && consultationPostnataleId != null;
  
  /// Vérifie si c'est un rappel de consultation prénatale
  bool get isRappelCPN => type == 'RAPPEL_CONSULTATION' && consultationPrenataleId != null;
}
