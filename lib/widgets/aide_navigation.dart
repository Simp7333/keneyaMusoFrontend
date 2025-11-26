import 'package:flutter/material.dart';
import '../routes.dart';

class AideNavigation {
  static void navigateToPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        // Navigate to Dashboard
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.patienteDashboard,
          (route) => false,
        );
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

