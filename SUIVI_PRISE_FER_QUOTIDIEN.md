# 🔔 Système de Suivi Quotidien de la Prise de Fer

## 📋 Vue d'Ensemble

Le système permet de suivre quotidiennement la prise de fer des patientes avec :
- ✅ Notifications quotidiennes pour demander si la patiente a pris ses fer
- ✅ Interface pour répondre (Oui/Non)
- ✅ Calcul automatique du pourcentage mensuel
- ✅ Messages d'encouragement personnalisés selon le pourcentage

## 🏗️ Architecture

### 1. **Modèles** (`lib/models/prise_fer_quotidienne.dart`)

- `PriseFerQuotidienne` : Modèle pour une réponse quotidienne
- `StatistiquesPriseFer` : Modèle pour les statistiques mensuelles avec calcul automatique du pourcentage et message

### 2. **Service** (`lib/services/prise_fer_service.dart`)

Fonctionnalités :
- `enregistrerPriseFer()` : Enregistre une réponse (Oui/Non) pour aujourd'hui
- `getPrisesFerMois()` : Récupère toutes les prises de fer d'un mois
- `getStatistiquesMois()` : Calcule les statistiques mensuelles
- `aReponduAujourdhui()` : Vérifie si la patiente a déjà répondu aujourd'hui
- `getReponseAujourdhui()` : Récupère la réponse d'aujourd'hui

### 3. **Widget** (`lib/widgets/prise_fer_card.dart`)

Widget réutilisable qui affiche :
- Notification quotidienne si la patiente n'a pas encore répondu
- Boutons Oui/Non pour répondre
- Confirmation si déjà répondu
- Statistiques mensuelles (X/Y jours, pourcentage)
- Message d'encouragement selon le pourcentage

## 📊 Calcul du Pourcentage et Messages

### Logique de Calcul

```dart
pourcentage = (joursAvecPrise / joursTotal) * 100
```

### Messages selon le Pourcentage

1. **≥ 50%** : 🟢
   - Message : "Vous prenez bien vos fer c'est très bien continuer ainsi"
   - Couleur : Vert
   - Icône : ✓

2. **≥ 20%** : 🟠
   - Message : "Vous prenez vos fer de manière régulière, continuez vos efforts pour améliorer votre suivi"
   - Couleur : Orange
   - Icône : ⚠️

3. **< 20%** : 🔴
   - Message : "Il est important de prendre vos fer régulièrement pour votre santé et celle de votre bébé. N'oubliez pas de prendre vos fer chaque jour"
   - Couleur : Rouge
   - Icône : ❌

## 🔔 Notifications Quotidiennes

### Fonctionnement Actuel

La carte de prise de fer affiche automatiquement une notification si :
- La patiente n'a pas encore répondu aujourd'hui
- La patiente visite le tableau de bord

### Amélioration Future

Pour une notification push automatique quotidienne, il faudra :
1. Créer un endpoint backend pour créer les notifications quotidiennes
2. Ajouter un scheduler côté backend (similaire aux rappels CPN)
3. Envoyer une notification push à 8h chaque matin

Exemple d'implémentation backend (à ajouter dans `RappelService.java`) :

```java
@Scheduled(cron = "0 0 8 * * *") // Tous les jours à 8h
public void creerNotificationsPriseFer() {
    // Récupérer toutes les patientes avec grossesse EN_COURS
    // Créer un rappel de type PRISE_FER pour chaque patiente
}
```

## 📱 Interface Utilisateur

### Localisation

La carte de prise de fer est intégrée dans :
- `page_tableau_bord.dart` : Affichée après le calendrier

### Affichage

1. **Si pas encore répondu aujourd'hui** :
   - Question : "Avez-vous pris vos fer aujourd'hui ?"
   - Boutons : Oui (vert) / Non (orange)

2. **Si déjà répondu** :
   - Confirmation avec icône
   - Message selon la réponse

3. **Statistiques mensuelles** :
   - Format : "Ce mois: X/Y jours (Z%)"
   - Message d'encouragement avec icône colorée

## 💾 Stockage des Données

### Actuel (Local)

Les données sont stockées dans `SharedPreferences` :
- Clé format : `prise_fer_YYYY-MM-DD` → booléen (true/false)
- Liste des dates : `prise_fer_dates` → JSON array

### Futur (Backend)

Il faudra créer :
1. Entité `PriseFerQuotidienne` dans le backend
2. Repository et Service
3. Controller avec endpoints :
   - `POST /api/prise-fer` : Enregistrer une réponse
   - `GET /api/prise-fer?mois=YYYY-MM` : Récupérer le mois
   - `GET /api/prise-fer/statistiques?mois=YYYY-MM` : Statistiques

## 🧪 Tests

Pour tester le système :

1. **Répondre à la notification** :
   - Ouvrir le tableau de bord
   - Cliquer sur "Oui" ou "Non"
   - Vérifier la confirmation

2. **Vérifier les statistiques** :
   - Répondre plusieurs jours
   - Vérifier le calcul du pourcentage
   - Vérifier le message selon le pourcentage

3. **Tester différents scénarios** :
   - 0 réponse → 0%
   - 10 réponses sur 31 jours → ~32%
   - 20 réponses sur 31 jours → ~65%

## 📝 Notes Techniques

- Le service utilise actuellement le stockage local (`SharedPreferences`)
- Les données sont prêtes pour être migrées vers le backend
- Le calcul du pourcentage est fait côté client
- Les messages sont générés automatiquement selon le pourcentage

## 🔄 Prochaines Étapes

1. Créer l'entité backend `PriseFerQuotidienne`
2. Implémenter les endpoints API
3. Migrer le stockage local vers le backend
4. Ajouter les notifications push quotidiennes automatiques
5. Ajouter des graphiques de suivi (optionnel)

