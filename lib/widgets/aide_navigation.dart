import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes.dart';

class AideNavigation {
  static Future<void> navigateToPage(BuildContext context, int index) async {
    switch (index) {
      case 0:
        // Navigate to Dashboard - vérifier le type de suivi
        final prefs = await SharedPreferences.getInstance();
        final suiviType = prefs.getString('suiviType') ?? 'prenatal';
        
        if (suiviType == 'prenatal') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.patienteDashboard,
            (route) => false,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.patienteDashboardPostnatal,
            (route) => false,
          );
        }
        break;
      case 1:
        // Navigate to Content
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.patienteContent,
          (route) => false,
        );
        break;
      case 2:
        // Navigate to Personnel
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.patientePersonnel,
          (route) => false,
        );
        break;
      case 3:
        // Navigate to Settings - Route supprimée
        // Navigator.pushNamedAndRemoveUntil(
        //   context,
        //   AppRoutes.patienteSettings,
        //   (route) => false,
        // );
        break;
    }
  }
}

