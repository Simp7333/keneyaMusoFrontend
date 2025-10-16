import 'package:flutter/material.dart';
import 'stat_card.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.9,
      children: const [
        StatCard(
          value: '04',
          label: 'Nombre de nouveaux suivis en attente de validation',
        ),
        StatCard(
          value: '04',
          label: 'Nombre total de patientes suivies prenatale/postnatale',
        ),
        StatCard(
          value: '11',
          label: 'Rendez-vous à venir',
        ),
        StatCard(
          value: '6',
          label: 'Alertes',
        ),
      ],
    );
  }
}
