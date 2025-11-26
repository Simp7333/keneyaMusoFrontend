/// Modèle pour les statistiques du tableau de bord professionnel
class DashboardStatsResponse {
  final int totalPatientes;
  final int suivisTermines;
  final int suivisEnCours;
  final int rappelsActifs;
  final int alertesActives;

  DashboardStatsResponse({
    required this.totalPatientes,
    required this.suivisTermines,
    required this.suivisEnCours,
    required this.rappelsActifs,
    required this.alertesActives,
  });

  factory DashboardStatsResponse.fromJson(Map<String, dynamic> json) {
    // Conversion robuste pour gérer les types long du backend Java
    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return DashboardStatsResponse(
      totalPatientes: toInt(json['totalPatientes']),
      suivisTermines: toInt(json['suivisTermines']),
      suivisEnCours: toInt(json['suivisEnCours']),
      rappelsActifs: toInt(json['rappelsActifs']),
      alertesActives: toInt(json['alertesActives']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPatientes': totalPatientes,
      'suivisTermines': suivisTermines,
      'suivisEnCours': suivisEnCours,
      'rappelsActifs': rappelsActifs,
      'alertesActives': alertesActives,
    };
  }
}

