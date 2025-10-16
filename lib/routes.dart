import 'package:flutter/material.dart';

// Pages communes
import 'pages/common/page_accueil.dart';
import 'pages/common/page_connexion.dart';
import 'pages/common/page_inscription.dart';
import 'pages/common/page_choix_profil.dart';
import 'pages/common/mot_de_passe_oublie.dart';

// Pages patiente
import 'pages/patiente/prenatale/page_tableau_bord.dart';
import 'pages/patiente/prenatale/enregistrement_grossesse_page.dart';
import 'pages/patiente/type_suivi_page.dart';
import 'pages/patiente/page_profil.dart';
import 'pages/patiente/page_parametres.dart';
import 'pages/patiente/page_notifications.dart';
import 'pages/patiente/page_contenu.dart';
import 'pages/patiente/prenatale/page_formulaire_contact.dart';
import 'pages/patiente/personnel_page.dart';
import 'pages/patiente/page_profil_personnel.dart';
import 'pages/patiente/postnatale/formulaire_postnatale_page.dart';
import 'pages/patiente/postnatale/dashboard_postnatale_page.dart';

// Pages sage-femme
// À venir...

// Pages gynécologue
import 'pages/gynecologue/page_connexion_pro.dart';
import 'pages/gynecologue/page_inscription_pro.dart';
import 'pages/gynecologue/page_dashboard_pro.dart';
import 'pages/gynecologue/page_choix_ajout_suivi.dart';
import 'pages/gynecologue/page_patientes.dart';
import 'pages/gynecologue/ajout_prenatal.dart';
import 'pages/gynecologue/ajout_postnatale.dart';

class AppRoutes {
  // Routes communes
  static const String onboarding = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String profileChoice = '/profile-choice';
  static const String forgotPassword = '/forgot-password';

  // Routes patiente
  static const String patienteDashboard = '/patiente/dashboard';
  static const String patienteEnregistrementGrossesse = '/patiente/enregistrement-grossesse';
  static const String patienteTypeSuivi = '/patiente/type-suivi';
  static const String patienteProfile = '/patiente/profile';
  static const String patienteSettings = '/patiente/settings';
  static const String patienteNotifications = '/patiente/notifications';
  static const String patienteContent = '/patiente/content';
  static const String patienteContactForm = '/patiente/contact-form';
  static const String patientePersonnel = '/patiente/personnel';
  static const String patientePersonnelProfile = '/patiente/personnel-profile';
  static const String patienteFormulairePostnatal =
      '/patiente/postnatale/formulaire_postnatale';
  static const String patienteDashboardPostnatal =
      '/patiente/postnatale/dashboard_postnatale';

  // Routes sage-femme
  // À venir...

  // Routes gynécologue
  static const String proLogin = '/pro/login';
  static const String proRegister = '/pro/register';
  static const String proDashboard = '/pro/dashboard';
  static const String gynecologueDashboard = '/gynecologue/dashboard';
  static const String gynecologueAjoutSuivi = '/gynecologue/ajout-suivi';
  static const String proPatientes = '/pro/patientes';
  static const String ajoutPrenatal = '/gynecologue/ajout-prenatal';
  static const String ajoutPostnatal = '/gynecologue/ajout-postnatal';

  // Méthode pour obtenir toutes les routes
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // Routes communes
      onboarding: (context) => const PageAccueil(),
      login: (context) => const PageConnexion(),
      register: (context) => const PageInscription(),
      profileChoice: (context) => const PageChoixProfil(),
      forgotPassword: (context) => const MotDePasseOubliePage(),

      // Routes patiente
      patienteDashboard: (context) => const PageTableauBord(),
      patienteEnregistrementGrossesse: (context) => const EnregistrementGrossessePage(),
      patienteTypeSuivi: (context) => const TypeSuiviPage(),
      patienteProfile: (context) => const PageProfil(),
      patienteSettings: (context) => const PageParametres(),
      patienteNotifications: (context) => const PageNotifications(),
      patienteContent: (context) => const PageContenu(),
      patientePersonnel: (context) => const PersonnelPage(),
      patienteFormulairePostnatal: (context) => const FormulairePostnatalePage(),
      patienteDashboardPostnatal: (context) => const DashboardPostnatalePage(),
      // Note: PageFormulaireContact et PageProfilPersonnel nécessitent des paramètres, seront gérés avec onGenerateRoute

      // Routes sage-femme
      // À venir...
      
      // Routes gynécologue
      proLogin: (context) => const PageConnexionPro(),
      proRegister: (context) => const PageInscriptionPro(),
      proDashboard: (context) => const PageDashboardPro(),
      gynecologueAjoutSuivi: (context) => const PageChoixAjoutSuivi(),
      proPatientes: (context) => const PagePatientes(),
      ajoutPrenatal: (context) => const AjoutPrenatalPage(),
      ajoutPostnatal: (context) => const AjoutPostnatalePage(),
    };
  }

  // Méthode pour gérer les routes avec paramètres
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Gérer les routes qui nécessitent des arguments
    switch (settings.name) {
      case patientePersonnelProfile:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (context) => PageProfilPersonnel(
              name: args['name'] ?? '',
              title: args['title'] ?? '',
              location: args['location'] ?? '',
              imageUrl: args['imageUrl'] ?? 'assets/images/default.png',
            ),
          );
        }
        break;
      
      case patienteContactForm:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => PageFormulaireContact(
            sageFemmeName: args?['sageFemmeName'] ?? 'Sage-femme',
          ),
        );
    }
    return null;
  }
}
