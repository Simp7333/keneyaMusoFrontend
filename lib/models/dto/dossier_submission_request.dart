import 'dart:convert';

/// DTO pour la soumission d'un dossier médical
class DossierSubmissionRequest {
  final String type; // CPN ou CPON
  final Map<String, dynamic> data; // Données du formulaire
  final String? medecinTelephone; // Téléphone du médecin auquel soumettre le dossier (optionnel)

  DossierSubmissionRequest({
    required this.type,
    required this.data,
    this.medecinTelephone,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'type': type,
      'data': data,
    };
    
    if (medecinTelephone != null && medecinTelephone!.isNotEmpty) {
      json['medecinTelephone'] = medecinTelephone!;
    }
    
    return json;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

