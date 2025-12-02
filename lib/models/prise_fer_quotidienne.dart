/// Modèle pour le suivi quotidien de la prise de fer
class PriseFerQuotidienne {
  final int id;
  final String date;
  final bool prise; // true = oui, false = non
  final int patienteId;
  final String? createdAt;

  PriseFerQuotidienne({
    required this.id,
    required this.date,
    required this.prise,
    required this.patienteId,
    this.createdAt,
  });

  factory PriseFerQuotidienne.fromJson(Map<String, dynamic> json) {
    return PriseFerQuotidienne(
      id: json['id'] as int,
      date: json['date'] as String,
      prise: json['prise'] as bool,
      patienteId: json['patienteId'] as int? ?? json['patiente']?['id'] as int? ?? 0,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'prise': prise,
    };
  }
}

/// Statistiques mensuelles de prise de fer
class StatistiquesPriseFer {
  final int joursAvecPrise;
  final int joursTotal;
  final double pourcentage;
  final String message;

  StatistiquesPriseFer({
    required this.joursAvecPrise,
    required this.joursTotal,
    required this.pourcentage,
    required this.message,
  });

  factory StatistiquesPriseFer.fromJson(Map<String, dynamic> json) {
    return StatistiquesPriseFer(
      joursAvecPrise: json['joursAvecPrise'] as int? ?? 0,
      joursTotal: json['joursTotal'] as int? ?? 0,
      pourcentage: (json['pourcentage'] as num?)?.toDouble() ?? 0.0,
      message: json['message'] as String? ?? '',
    );
  }

  factory StatistiquesPriseFer.calculer({
    required int joursAvecPrise,
    required int joursTotal,
  }) {
    final pourcentage = joursTotal > 0 ? (joursAvecPrise / joursTotal) * 100 : 0.0;
    
    String message;
    if (pourcentage >= 50) {
      message = 'Vous prenez bien vos fer c\'est très bien continuer ainsi';
    } else if (pourcentage >= 20) {
      message = 'Vous prenez vos fer de manière régulière, continuez vos efforts pour améliorer votre suivi';
    } else {
      message = 'Il est important de prendre vos fer régulièrement pour votre santé et celle de votre bébé. N\'oubliez pas de prendre vos fer chaque jour';
    }
    
    return StatistiquesPriseFer(
      joursAvecPrise: joursAvecPrise,
      joursTotal: joursTotal,
      pourcentage: pourcentage,
      message: message,
    );
  }
}

