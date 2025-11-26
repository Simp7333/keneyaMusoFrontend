import 'package:flutter/material.dart';
import 'package:keneya_muso/routes.dart';
import '../models/dto/dashboard_stats_response.dart';
import 'stat_card.dart';

class StatsGrid extends StatelessWidget {
  final DashboardStatsResponse? stats;
  final bool isLoading;

  const StatsGrid({
    super.key,
    this.stats,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (stats == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('Aucune donnée disponible'),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1,
      children: [
        StatCard(
          value: stats!.totalPatientes.toString(),
          label: 'Patientes Suivies',
          icon: Icons.people_outline,
          color: Colors.blue,
          iconColor: Colors.white,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.proPatientes);
          },
        ),
        StatCard(
          value: stats!.suivisEnCours.toString(),
          label: 'Suivis en cours',
          icon: Icons.hourglass_bottom,
          color: Colors.amber,
          iconColor: Colors.white,
        ),
        StatCard(
          value: stats!.suivisTermines.toString(),
          label: 'Suivis terminés',
          icon: Icons.check_circle_outline,
          color: Colors.green,
          iconColor: Colors.white,
        ),
        StatCard(
          value: stats!.alertesActives.toString(),
          label: 'Alertes',
          icon: Icons.notifications_active_outlined,
          color: Colors.red,
          iconColor: Colors.white,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.proAlertes);
          },
        ),
      ],
    );
  }
}
