import 'package:flutter/material.dart';

// Pages communes
import 'pages/common/page_accueil.dart';
import 'pages/patiente/page_connexion.dart';
import 'pages/patiente/page_inscription.dart';
import 'pages/common/page_choix_profil.dart';
import 'pages/common/page_not_found.dart';
import 'pages/common/mot_de_passe_oublie.dart';

// Pages patiente
import 'pages/patiente/prenatale/page_tableau_bord.dart';
import 'pages/patiente/page_detail_video.dart';
import 'pages/patiente/prenatale/enregistrement_grossesse_page.dart';
import 'pages/patiente/prenatale/dossier_cpn_page.dart';
import 'pages/patiente/type_suivi_page.dart';
import 'pages/common/page_profil.dart';
// import 'pages/common/page_parametres.dart'; // Fichier supprimé
import 'pages/patiente/page_contenu.dart';
// import 'pages/patiente/prenatale/page_formulaire_contact.dart'; // Fichier supprimé
import 'pages/patiente/personnel_page.dart';
import 'pages/patiente/page_profil_personnel.dart';
import 'pages/patiente/postnatale/dashboard_postnatale_page.dart';
import 'pages/patiente/postnatale/enregistrement_accouchement_page.dart';
import 'pages/patiente/postnatale/dossier_post_page.dart';
import 'pages/patiente/postnatale/enfants_page.dart';
import 'pages/patiente/page_discussion.dart';

// Pages sage-femme
// À venir...

// Pages gynécologue
import 'pages/gynecologue/page_connexion_pro.dart';
import 'pages/gynecologue/page_inscription_pro.dart';
import 'pages/gynecologue/page_dashboard_pro.dart';
import 'pages/gynecologue/page_patientes.dart';
import 'pages/gynecologue/page_accompagnement.dart';
import 'pages/common/page_parametres_pro.dart';
import 'pages/gynecologue/page_alertes.dart';
import 'pages/common/page_notifications_pro.dart';
import 'pages/gynecologue/page_profil_pro.dart';

class AppRoutes {
  // Routes communes
  static const String onboarding = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String profileChoice = '/profile-choice';
  static const String forgotPassword = '/forgot-password';

  // Routes patiente
  static const String patienteDashboard = '/patiente/dashboard';
  static const String patienteDetailVideo = '/patiente/detail-video';
  static const String patienteEnregistrementGrossesse = '/patiente/enregistrement-grossesse';
  static const String patienteDossierCpn = '/patiente/prenatale/dossier-cpn';
  static const String patienteTypeSuivi = '/patiente/type-suivi';
  static const String patienteProfile = '/patiente/profile';
  // static const String patienteSettings = '/patiente/settings'; // Fichier supprimé
  static const String patienteNotifications = '/patiente/notifications';
  static const String patienteContent = '/patiente/content';
  static const String patienteContactForm = '/patiente/contact-form';
  static const String patientePersonnel = '/patiente/personnel';
  static const String patienteProfilPersonnel = '/patiente/profil-personnel';
  static const String patienteDiscussion = '/patiente/discussion';
  static const String patienteDashboardPostnatal =
      '/patiente/postnatale/dashboard_postnatale';
  static const String patienteEnregistrementAccouchement =
      '/patiente/postnatale/enregistrement_accouchement';
  static const String patienteDossierPost =
      '/patiente/postnatale/dossier_post';
  static const String patienteEnfants =
      '/patiente/postnatale/enfants';

  // Routes sage-femme
  // À venir...

  // Routes gynécologue
  static const String proLogin = '/pro/login';
  static const String proRegister = '/pro/register';
  static const String proDashboard = '/pro/dashboard';
  static const String gynecologueDashboard = '/gynecologue/dashboard';
  static const String proPatientes = '/pro/patientes';
  static const String proAccompagnements = '/pro/accompagnements';
  static const String proSettings = '/pro/settings';
  static const String proAlertes = '/pro/alertes';
  static const String proNotifications = '/pro/notifications';
  static const String proProfile = '/pro/profile';

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
      patienteDossierCpn: (context) => const DossierCpnPage(),
      patienteTypeSuivi: (context) => const TypeSuiviPage(),
      patienteProfile: (context) => const PageProfil(),
      // patienteSettings: (context) => const PageParametres(), // Fichier supprimé
      patienteNotifications: (context) => const PageNotificationsPro(),
      patienteContent: (context) => const PageContenu(),
      patientePersonnel: (context) => const PersonnelPage(),
      patienteDashboardPostnatal: (context) => const DashboardPostnatalePage(),
      patienteEnregistrementAccouchement: (context) => const EnregistrementAccouchementPage(),
      patienteDossierPost: (context) => const DossierPostPage(),
      patienteEnfants: (context) => const EnfantsPage(),
      patienteDiscussion: (context) => const PageDiscussion(),
      // Note: PageFormulaireContact et PageProfilPersonnel nécessitent des paramètres, seront gérés avec onGenerateRoute

      // Routes sage-femme
      // À venir...
      
      // Routes gynécologue
      proLogin: (context) => const PageConnexionPro(),
      proRegister: (context) => const PageInscriptionPro(),
      proDashboard: (context) => const PageDashboardPro(),
      proPatientes: (context) => const PagePatientes(),
      proAccompagnements: (context) => const PageAccompagnement(),
      proSettings: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return PageParametresPro(isPatiente: args?['isPatiente'] ?? false);
      },
      proAlertes: (context) => const PageAlertes(),
      proNotifications: (context) => const PageNotificationsPro(),
      proProfile: (context) => const PageProfilPro(),
    };
  }

  // Méthode pour gérer les routes avec paramètres
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Gérer les routes qui nécessitent des arguments
    switch (settings.name) {
      case patienteDetailVideo:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (context) => PageDetailVideo(
              title: args['title'] ?? 'Vidéo',
              videoUrl: args['videoUrl'] ?? '',
              contenu: args['contenu'],
            ),
          );
        }
        break;
      case patienteProfilPersonnel:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args.containsKey('professionnelId')) {
          return MaterialPageRoute(
            builder: (context) => PageProfilPersonnel(
              professionnelId: args['professionnelId'] as int,
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => const PageNotFound());

      case patienteContactForm:
        // PageFormulaireContact n'existe plus, rediriger vers PageNotFound
        return MaterialPageRoute(builder: (_) => const PageNotFound());
      default:
        return MaterialPageRoute(builder: (_) => const PageNotFound());
    }
    return null;
  }
}
