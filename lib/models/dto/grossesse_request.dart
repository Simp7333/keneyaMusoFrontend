import 'dart:convert';

/// DTO pour la création d'une grossesse
class GrossesseRequest {
  final String dateDernieresMenstruations; // Format: YYYY-MM-DD
  final int patienteId;

  GrossesseRequest({
    required this.dateDernieresMenstruations,
    required this.patienteId,
  });

  Map<String, dynamic> toJson() {
    return {
      'dateDernieresMenstruations': dateDernieresMenstruations,
      'patienteId': patienteId,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

