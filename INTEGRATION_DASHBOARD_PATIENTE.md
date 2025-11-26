# Intégration Backend - Tableau de Bord Patiente

## 📋 Résumé

Ce document décrit l'intégration complète du backend dans le tableau de bord de la patiente (`PageTableauBord`).

## ✅ Fonctionnalités Implémentées

### 1. **Service Dashboard** (`dashboard_service.dart`)
Nouveau service Flutter qui communique avec l'API backend pour :
- ✅ Récupérer les rappels/notifications de la patiente connectée
- ✅ Compter les notifications non lues
- ✅ Récupérer les statistiques de la patiente
- ✅ Marquer un rappel comme lu

**Endpoints utilisés :**
- `GET /api/notifications/me` - Récupère les notifications
- `GET /api/notifications/statistiques` - Récupère les stats
- `PUT /api/notifications/{id}/lue` - Marque comme lu

### 2. **Banner de Bienvenue** (`welcome_banner.dart`)
- ✅ Affiche le prénom de la patiente connectée (depuis `SharedPreferences`)
- ✅ Transformé en `StatefulWidget` pour charger les données dynamiquement
- ✅ Message personnalisé : "Salut, [Prénom]"

### 3. **Calendrier Dynamique** (`custom_calendar.dart`)
- ✅ Affiche les rappels/événements sur le calendrier
- ✅ Navigation entre les mois (flèches gauche/droite)
- ✅ Icônes de couleur selon le type de rappel :
  - 🔵 **Bleu** : Consultation prénatale (CPN)
  - 🔴 **Rouge** : Vaccination / Prise de médicament
- ✅ Légende en bas du calendrier
- ✅ Calcul automatique des jours du mois

### 4. **Page Tableau de Bord** (`page_tableau_bord.dart`)
- ✅ Chargement des rappels au démarrage (`initState`)
- ✅ Affichage d'un indicateur de chargement pendant la récupération
- ✅ Badge de notification avec le nombre de notifications non lues
- ✅ Affichage des 2 prochains rappels sous forme de cartes
- ✅ Pull-to-refresh pour actualiser les données
- ✅ Message si aucun rappel en attente
- ✅ Icônes et couleurs dynamiques selon le type de rappel

## 🔄 Flux de Données

```
┌─────────────────────┐
│   PageTableauBord   │
│   (Écran principal) │
└──────────┬──────────┘
           │
           │ initState()
           ├─────────────────┐
           │                 │
           ▼                 ▼
┌──────────────────┐  ┌────────────────────┐
│ DashboardService │  │ SharedPreferences  │
│  (API Backend)   │  │ (Données locales)  │
└──────────┬───────┘  └─────────┬──────────┘
           │                    │
           │ GET /api/          │ Prénom, Token
           │ notifications/me   │
           │                    │
           ▼                    ▼
┌──────────────────────────────────┐
│         État de la page          │
│  - _rappels: List<Rappel>        │
│  - _unreadCount: int             │
│  - _isLoading: bool              │
└──────────┬───────────────────────┘
           │
           │ setState()
           │
           ▼
┌──────────────────────────────────┐
│      Widgets mis à jour          │
│  - CustomCalendar(rappels)       │
│  - TaskCard (rappels)            │
│  - Badge notifications           │
└──────────────────────────────────┘
```

## 📊 Types de Rappels

Les rappels sont récupérés depuis le backend avec les types suivants :

| Type Backend           | Type Frontend          | Icône                          | Couleur |
|------------------------|------------------------|--------------------------------|---------|
| `CPN` / `CPON`         | `RAPPEL_CONSULTATION`  | `medical_services_outlined`    | Bleu    |
| `VACCINATION`          | `RAPPEL_VACCINATION`   | `medication_outlined`          | Rouge   |
| `CONSEIL`              | `CONSEIL`              | `lightbulb_outline`            | Orange  |
| Autre                  | `AUTRE`                | `notifications_outlined`       | Gris    |

## 🎨 Interface Utilisateur

### Banner de Bienvenue
```dart
// Affiche : "Salut, [Prénom]"
WelcomeBanner()
```

### Calendrier
```dart
// Reçoit la liste des rappels et affiche les événements
CustomCalendar(rappels: _rappels)
```

### Cartes de Tâches
```dart
// Affiche les 2 prochains rappels non lus
_getProchainRappels().map((rappel) => TaskCard(
  icon: _getRappelIcon(rappel.type),
  iconColor: _getRappelColor(rappel.type),
  title: rappel.titre,
  subtitle: rappel.message,
))
```

### Badge de Notification
```dart
// Badge avec le nombre de notifications non lues
if (_unreadCount > 0)
  Badge(count: _unreadCount)
```

## 🔧 Configuration Requise

### 1. API Backend
Le backend doit être démarré sur `http://10.0.2.2:8080` (émulateur Android).

Configuration dans `lib/config/api_config.dart` :
```dart
static const String baseUrl = 'http://10.0.2.2:8080';
```

### 2. Authentification
L'utilisateur doit être connecté. Le token JWT est stocké dans `SharedPreferences` :
- `auth_token` : Token d'authentification
- `user_prenom` : Prénom de l'utilisateur
- `user_id` : ID de l'utilisateur

### 3. Dépendances
Déjà ajoutées dans `pubspec.yaml` :
```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.0.15
  intl: ^0.20.2
```

## 🚀 Utilisation

### Charger les Rappels
```dart
// Dans initState()
await _loadRappels();
```

### Rafraîchir les Données
```dart
// Pull-to-refresh
RefreshIndicator(
  onRefresh: _loadRappels,
  child: ListView(...)
)
```

### Marquer comme Lu
```dart
await _dashboardService.marquerCommeLu(rappelId);
await _loadRappels(); // Recharger la liste
```

## 📝 Modèle de Données

### Rappel (Frontend)
```dart
class Rappel {
  final int id;
  final String message;
  final String dateCreation;
  final String type;        // RAPPEL_CONSULTATION, RAPPEL_VACCINATION, etc.
  final String statut;      // NON_LUE, LUE, TRAITEE
  final String priorite;    // ELEVEE, NORMALE, FAIBLE
  final String titre;
  final int? patienteId;
  final int? medecinId;
}
```

## 🧪 Tests

Pour tester l'intégration :

1. **Démarrer le backend**
   ```bash
   cd KeneyaMusoBackend
   ./start-backend.bat
   ```

2. **Créer des rappels de test**
   - Via Postman ou l'interface Swagger : `http://localhost:8080/swagger-ui.html`
   - Endpoint : `POST /api/notifications/envoyer-rappels-manuel`

3. **Lancer l'application Flutter**
   ```bash
   cd Keneya_muso
   flutter run
   ```

4. **Se connecter en tant que patiente**
   - Les rappels s'affichent automatiquement sur le tableau de bord

## 🔍 Dépannage

### Les rappels ne s'affichent pas
- ✅ Vérifier que le backend est démarré
- ✅ Vérifier l'URL dans `api_config.dart`
- ✅ Vérifier que l'utilisateur est connecté (token présent)
- ✅ Vérifier les logs du backend pour les erreurs
- ✅ Vérifier que des rappels existent dans la base de données

### Badge de notification à 0
- ✅ Tous les rappels sont marqués comme lus
- ✅ Créer de nouveaux rappels via l'API

### Calendrier vide
- ✅ Les rappels doivent avoir des dates valides
- ✅ Naviguer vers le bon mois (flèches)

## 📚 Prochaines Étapes

### Améliorations Possibles
- [ ] Ajouter un cache local pour les rappels
- [ ] Implémenter les notifications push
- [ ] Ajouter des filtres par type de rappel
- [ ] Permettre de créer des rappels personnalisés
- [ ] Ajouter des sons/vibrations pour les rappels urgents
- [ ] Synchronisation en temps réel avec WebSocket

## 📞 Support

Pour toute question ou problème, consultez :
- `INTEGRATION_BACKEND.md` - Guide d'intégration général
- `TEST_AUTHENTIFICATION.md` - Tests d'authentification
- `API_EXAMPLES.md` - Exemples d'appels API

---

✨ **Intégration complète et fonctionnelle !**

