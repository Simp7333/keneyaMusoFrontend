import 'package:flutter/material.dart';

/// Modèle pour un conseil prédéfini
class ConseilPredefini {
  final String titre;
  final String description;
  final IconData icon;
  final Color color;
  
  const ConseilPredefini({
    required this.titre,
    required this.description,
    required this.icon,
    required this.color,
  });
}

/// Service pour fournir des conseils prédéfinis basés sur le contexte
class ConseilPredefiniService {
  
  /// Récupère les conseils prénatals (CPN)
  static List<ConseilPredefini> getConseilsPrenatals() {
    return [
      const ConseilPredefini(
        titre: 'Prise de fer quotidienne',
        description: 'Prenez vos compléments de fer chaque jour à la même heure pour une meilleure absorption. Prenez-les avec de la vitamine C (jus d\'orange) et évitez le thé ou café pendant 1h après.',
        icon: Icons.medication_liquid,
        color: Colors.red,
      ),
      const ConseilPredefini(
        titre: 'Alimentation équilibrée',
        description: 'Mangez des fruits et légumes variés chaque jour, des protéines (poisson, viande maigre, légumineuses) et des céréales complètes. Évitez les aliments crus et limitez le sel.',
        icon: Icons.restaurant,
        color: Colors.green,
      ),
      const ConseilPredefini(
        titre: 'Hydratation régulière',
        description: 'Buvez au moins 8 verres d\'eau par jour. L\'eau aide à prévenir les infections urinaires et favorise une bonne circulation sanguine.',
        icon: Icons.water_drop,
        color: Colors.blue,
      ),
      const ConseilPredefini(
        titre: 'Repos et activité physique douce',
        description: 'Reposez-vous suffisamment (7-8h par nuit) et faites de la marche douce 30 minutes par jour si possible. Évitez les efforts intenses.',
        icon: Icons.bedtime,
        color: Colors.purple,
      ),
      const ConseilPredefini(
        titre: 'Surveillance des mouvements',
        description: 'Surveillez les mouvements de votre bébé. Vous devriez sentir au moins 10 mouvements par jour. Contactez votre médecin si les mouvements diminuent.',
        icon: Icons.favorite,
        color: Colors.pink,
      ),
    ];
  }
  
  /// Récupère les conseils postnatals selon le type d'accouchement
  static List<ConseilPredefini> getConseilsPostnatals({
    required String? typeAccouchement,
  }) {
    List<ConseilPredefini> conseils = [];
    
    // Conseils généraux postnataux
    conseils.addAll([
      const ConseilPredefini(
        titre: 'Repos et récupération',
        description: 'Reposez-vous autant que possible. Acceptez l\'aide de votre entourage pour les tâches ménagères. Le repos est essentiel pour votre guérison.',
        icon: Icons.bedtime,
        color: Colors.indigo,
      ),
      const ConseilPredefini(
        titre: 'Allaitement maternel',
        description: 'L\'allaitement maternel exclusif est recommandé jusqu\'à 6 mois. Mettez votre bébé au sein à la demande, jour et nuit (8-12 fois par jour).',
        icon: Icons.eco,
        color: Colors.green,
      ),
    ]);
    
    // Conseils spécifiques selon le type d'accouchement
    if (typeAccouchement != null && typeAccouchement.toLowerCase().contains('césarienne')) {
      conseils.addAll([
        const ConseilPredefini(
          titre: 'Soins de la cicatrice',
          description: 'Gardez votre cicatrice propre et sèche. Évitez de porter des vêtements serrés. Surveillez les signes d\'infection (rougeur, chaleur, écoulement).',
          icon: Icons.medical_services,
          color: Colors.orange,
        ),
        const ConseilPredefini(
          titre: 'Gestion de la douleur',
          description: 'Prenez vos médicaments contre la douleur selon les prescriptions. Évitez de soulever des charges lourdes pendant 6 semaines. Reposez-vous.',
          icon: Icons.healing,
          color: Colors.red,
        ),
        const ConseilPredefini(
          titre: 'Mobilité progressive',
          description: 'Marchez doucement dès le premier jour pour prévenir les complications. Augmentez progressivement votre activité. Évitez les escaliers si possible.',
          icon: Icons.directions_walk,
          color: Colors.blue,
        ),
      ]);
    } else {
      conseils.addAll([
        const ConseilPredefini(
          titre: 'Soins périnéaux',
          description: 'Lavez-vous délicatement la région périnéale avec de l\'eau tiède. Changez régulièrement vos serviettes hygiéniques. Utilisez des compresses d\'eau froide pour soulager.',
          icon: Icons.water_drop,
          color: Colors.cyan,
        ),
        const ConseilPredefini(
          titre: 'Exercices de Kegel',
          description: 'Commencez les exercices de Kegel dès que possible pour renforcer le périnée. Serrez les muscles comme pour retenir l\'urine, maintenez 5 secondes, relâchez.',
          icon: Icons.fitness_center,
          color: Colors.teal,
        ),
      ]);
    }
    
    return conseils;
  }
  
  /// Récupère les conseils pour un enfant selon son âge en jours
  static List<ConseilPredefini> getConseilsPourEnfant(int ageEnJours) {
    List<ConseilPredefini> conseils = [];
    
    if (ageEnJours <= 7) {
      // Nouveau-né (0-7 jours)
      conseils.addAll([
        const ConseilPredefini(
          titre: 'Soins du cordon ombilical',
          description: 'Gardez le cordon ombilical propre et sec. Nettoyez avec de l\'eau et du savon, puis séchez bien. Évitez de couvrir avec des couches. Il devrait tomber dans 1-2 semaines.',
          icon: Icons.medical_information,
          color: Colors.orange,
        ),
        const ConseilPredefini(
          titre: 'Allaitement à la demande',
          description: 'Nourrissez votre bébé toutes les 2-3 heures, même la nuit. Un nouveau-né peut téter 8-12 fois par jour. Surveillez qu\'il mouille 6 couches par jour.',
          icon: Icons.child_care,
          color: Colors.pink,
        ),
        const ConseilPredefini(
          titre: 'Température corporelle',
          description: 'Maintenez votre bébé au chaud mais pas trop. La température normale est entre 36.5°C et 37.5°C. Habillez-le d\'une couche de vêtement de plus que vous.',
          icon: Icons.thermostat,
          color: Colors.red,
        ),
      ]);
    } else if (ageEnJours <= 28) {
      // Premier mois (8-28 jours)
      conseils.addAll([
        const ConseilPredefini(
          titre: 'Rythme de sommeil',
          description: 'Votre bébé dort 16-18 heures par jour en courtes périodes. Créez un rythme jour/nuit : lumière le jour, obscurité la nuit. Ne réveillez pas pour manger après 2 semaines si tout va bien.',
          icon: Icons.bedtime,
          color: Colors.indigo,
        ),
        const ConseilPredefini(
          titre: 'Bain quotidien',
          description: 'Baignez votre bébé 2-3 fois par semaine avec de l\'eau tiède (37°C). Utilisez un savon doux. Nettoyez le visage avec un gant de toilette humide quotidiennement.',
          icon: Icons.cleaning_services,
          color: Colors.blue,
        ),
        const ConseilPredefini(
          titre: 'Contact peau à peau',
          description: 'Pratiquez le contact peau à peau régulièrement. Cela apaise votre bébé, régule sa température et renforce votre lien. Idéal pendant l\'allaitement.',
          icon: Icons.favorite,
          color: Colors.pink,
        ),
      ]);
    } else if (ageEnJours <= 90) {
      // 1-3 mois (29-90 jours)
      conseils.addAll([
        const ConseilPredefini(
          titre: 'Développement moteur',
          description: 'Placez votre bébé sur le ventre quand il est éveillé pour renforcer les muscles du cou et des épaules. Commencez par quelques minutes plusieurs fois par jour.',
          icon: Icons.child_friendly,
          color: Colors.green,
        ),
        const ConseilPredefini(
          titre: 'Communication',
          description: 'Parlez et chantez à votre bébé. Répondez à ses sourires et gazouillis. Votre bébé apprend à communiquer en vous imitant.',
          icon: Icons.record_voice_over,
          color: Colors.purple,
        ),
        const ConseilPredefini(
          titre: 'Visites médicales',
          description: 'Respectez le calendrier de vaccination et les visites de contrôle. Surveillez le poids, la taille et le développement de votre bébé.',
          icon: Icons.medical_services,
          color: Colors.blue,
        ),
      ]);
    } else if (ageEnJours <= 180) {
      // 3-6 mois (91-180 jours)
      conseils.addAll([
        const ConseilPredefini(
          titre: 'Diversification alimentaire',
          description: 'Vous pouvez commencer à introduire des aliments solides vers 6 mois. Commencez par des purées de légumes ou fruits. Continuez l\'allaitement maternel.',
          icon: Icons.restaurant,
          color: Colors.orange,
        ),
        const ConseilPredefini(
          titre: 'Développement social',
          description: 'Votre bébé reconnaît maintenant les visages familiers et sourit aux personnes qu\'il connaît. Jouez avec lui et encouragez les interactions.',
          icon: Icons.people,
          color: Colors.teal,
        ),
        const ConseilPredefini(
          titre: 'Sécurité',
          description: 'Ne laissez jamais votre bébé seul sur une surface élevée. Assurez-vous que le lit est sécurisé sans oreillers ou couvertures lourdes.',
          icon: Icons.security,
          color: Colors.red,
        ),
      ]);
    } else {
      // 6 mois et plus (181+ jours)
      conseils.addAll([
        const ConseilPredefini(
          titre: 'Alimentation variée',
          description: 'Offrez une variété d\'aliments : céréales, fruits, légumes, protéines. Évitez le sucre, le sel et le miel avant 1 an. Continuez l\'allaitement si possible.',
          icon: Icons.restaurant_menu,
          color: Colors.green,
        ),
        const ConseilPredefini(
          titre: 'Développement moteur',
          description: 'Encouragez votre bébé à ramper, s\'asseoir et explorer. Créez un espace sécurisé pour qu\'il puisse bouger librement.',
          icon: Icons.directions_walk,
          color: Colors.blue,
        ),
        const ConseilPredefini(
          titre: 'Stimulation cognitive',
          description: 'Lisez des livres à votre bébé, chantez, jouez avec des objets de différentes textures et couleurs. Cela stimule son développement intellectuel.',
          icon: Icons.menu_book,
          color: Colors.purple,
        ),
      ]);
    }
    
    return conseils;
  }
  
  /// Calcule l'âge d'un enfant en jours à partir de sa date de naissance
  static int calculerAgeEnJours(String dateNaissance) {
    try {
      final date = DateTime.parse(dateNaissance);
      final maintenant = DateTime.now();
      return maintenant.difference(date).inDays;
    } catch (e) {
      return 0;
    }
  }
}

