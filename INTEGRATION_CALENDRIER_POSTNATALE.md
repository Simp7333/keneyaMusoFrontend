# 📅 Intégration Calendrier Postnatale - Documentation

## Vue d'ensemble

Le calendrier postnatale a été transformé d'un composant statique en un widget dynamique entièrement intégré avec le backend. Il affiche maintenant en temps réel :

- 🔵 **Consultations postnatales (CPoN)** : J+3, J+7, 6e semaine
- 🟢 **Vaccinations des enfants** : Calendrier vaccinal complet
- 🔴 **Prises de médicaments** : Rappels pour la mère et l'enfant

## Architecture

### 📁 Nouveaux fichiers créés

#### 1. **Modèles**
- `lib/models/vaccination.dart` - Modèle pour les vaccinations
- `lib/models/enfant_brief.dart` - Modèle simplifié pour les enfants
- `lib/models/enums/type_consultation.dart` - Enum pour les types de consultation

#### 2. **Services**
- `lib/services/vaccination_service.dart` - Service API pour les vaccinations

#### 3. **Widgets**
- `lib/widgets/calendar_postnatale.dart` - Calendrier dynamique (mis à jour)

#### 4. **Pages**
- `lib/pages/patiente/postnatale/dashboard_postnatale_page.dart` - Dashboard avec calendrier intégré (mis à jour)

## Fonctionnalités

### 🎯 Calendrier Postnatale Dynamique

Le widget `CalendarPostnatale` accepte 3 listes de données :

```dart
CalendarPostnatale(
  consultations: List<ConsultationPostnatale>, // CPoN
  vaccinations: List<Vaccination>,              // Vaccins enfants
  rappels: List<Rappel>,                        // Médicaments
)
```

#### Affichage des événements

**Priorité d'affichage** (si plusieurs événements le même jour) :
1. 🔵 Consultation postnatale (CPoN)
2. 🟢 Vaccination
3. 🔴 Prise de médicament

**Badge multiple** : Si plusieurs événements tombent le même jour, un badge orange avec le nombre total s'affiche.

#### Navigation mensuelle

- Flèches gauche/droite pour naviguer entre les mois
- Affichage du mois et de l'année en français
- Calcul automatique des jours du mois

### 📊 Chargement des données

Le `DashboardPostnatalePage` charge automatiquement :

```dart
@override
void initState() {
  super.initState();
  _loadDashboardData(); // Charge toutes les données
}
```

**Méthode de chargement** :
1. Récupère l'ID de la patiente depuis `SharedPreferences`
2. Charge en parallèle :
   - Consultations postnatales de la patiente
   - Rappels/notifications de la patiente
   - Enfants de la patiente
   - Vaccinations de chaque enfant

### 🔄 Rafraîchissement

Le dashboard dispose d'un **pull-to-refresh** :

```dart
RefreshIndicator(
  onRefresh: _loadDashboardData,
  child: SingleChildScrollView(...),
)
```

## API Backend

### Endpoints utilisés

#### 1. **Consultations Postnatales**
```
GET /api/consultations-postnatales/patiente/{patienteId}
```
Retourne toutes les CPoN d'une patiente (J+3, J+7, 6e semaine).

#### 2. **Vaccinations**
```
GET /api/vaccinations/enfant/{enfantId}
```
Retourne toutes les vaccinations d'un enfant.

#### 3. **Enfants**
```
GET /api/enfants/patiente/{patienteId}
```
Retourne tous les enfants d'une patiente.

#### 4. **Rappels**
```
GET /api/notifications/me
```
Retourne tous les rappels de l'utilisateur connecté.

## Types de données

### ConsultationPostnatale

```dart
class ConsultationPostnatale {
  final int id;
  final String type;        // JOUR_3, JOUR_7, SEMAINE_6
  final String datePrevue;  // Format ISO 8601
  final String? dateRealisee;
  final String statut;      // A_VENIR, REALISEE, MANQUEE
  final String? notesMere;
  final String? notesNouveauNe;
  final int patienteId;
  final int? enfantId;
}
```

### Vaccination

```dart
class Vaccination {
  final int id;
  final String nomVaccin;   // BCG, Polio, Pentavalent, etc.
  final String datePrevue;  // Format ISO 8601
  final String? dateRealisee;
  final String statut;      // A_FAIRE, FAIT, MANQUE
  final String? notes;
  final int enfantId;
}
```

### Rappel

```dart
class Rappel {
  final int id;
  final String message;
  final String dateCreation;
  final String? dateEnvoi;
  final String type;        // RAPPEL_CONSULTATION, RAPPEL_VACCINATION, CONSEIL
  final String statut;      // NON_LUE, LUE, TRAITEE
  final String priorite;    // ELEVEE, NORMALE, FAIBLE
  final String titre;
}
```

## Gestion des événements

### Regroupement par jour

La méthode `_groupEventsByDay()` :
1. Parse les dates des consultations, vaccinations et rappels
2. Filtre par mois courant
3. Groupe par jour du mois
4. Crée des marqueurs d'événements avec couleur et icône

### Affichage dans le calendrier

```dart
GridView.count(
  crossAxisCount: 7, // 7 jours par semaine
  children: List.generate(weekdayOfFirst - 1 + daysInMonth, (index) {
    // Calcul du jour
    int day = index - weekdayOfFirst + 2;
    
    // Récupération des événements du jour
    List<_EventMarker>? dayEvents = eventsByDay[day];
    
    // Affichage avec icône si événements
    if (dayEvents != null && dayEvents.isNotEmpty) {
      return CircleAvatar(...); // Avec badge si multiple
    }
    
    return Center(child: Text('$day')); // Jour normal
  }),
)
```

## Légende

En bas du calendrier, une légende colorée explique les icônes :

- 🔵 **CPoN** : Consultations postnatales
- 🟢 **Vaccination** : Vaccins des enfants
- 🔴 **Médicament** : Prises de médicaments

## Événements à venir

Sous le calendrier, la section `_buildUpcomingEvents()` affiche :

1. **3 prochaines CPoN à venir** (statut A_VENIR)
2. **2 prochaines vaccinations à faire** (statut A_FAIRE)
3. **2 rappels de médicaments non lus** (type RAPPEL_VACCINATION)

Chaque événement est affiché sous forme de `TaskCard` avec :
- Icône colorée
- Titre de l'événement
- Date formatée en français

## Gestion des erreurs

### Parsing des dates

Toutes les opérations de parsing de date sont protégées par des try-catch :

```dart
try {
  DateTime date = DateTime.parse(consultation.datePrevue);
  // Traitement...
} catch (e) {
  print('❌ Erreur parsing date: $e');
}
```

### Données manquantes

- Si `patienteId` est null → Arrêt du chargement
- Si aucune donnée → Affichage d'un calendrier vide (pas d'erreur)
- Si erreur réseau → Log dans la console, calendrier vide

## États de chargement

Le dashboard gère 2 états :

1. **Chargement** (`_isLoading = true`)
   ```dart
   Center(child: CircularProgressIndicator())
   ```

2. **Données chargées** (`_isLoading = false`)
   ```dart
   RefreshIndicator(
     child: SingleChildScrollView(...)
   )
   ```

## Formatage des dates

### Fonctions utilitaires

```dart
String _getDayName(int weekday) {
  const days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 
                'Vendredi', 'Samedi', 'Dimanche'];
  return days[weekday - 1];
}

String _getMonthName(int month) {
  const months = ['janvier', 'février', 'mars', 'avril', 
                  'mai', 'juin', 'juillet', 'août', 
                  'septembre', 'octobre', 'novembre', 'décembre'];
  return months[month - 1];
}
```

Ces fonctions permettent d'éviter les problèmes de localisation Flutter.

## Performance

### Optimisations

1. **Chargement parallèle** : `Future.wait()` pour charger toutes les données en même temps
2. **Filtrage par mois** : Seuls les événements du mois courant sont affichés
3. **Limite d'affichage** : `.take(n)` pour limiter le nombre d'événements à venir

### Cache

Les données sont rechargées :
- Au lancement de la page (`initState`)
- Sur pull-to-refresh manuel
- Pas de cache automatique (données en temps réel)

## Tests

### Scénarios à tester

1. ✅ Patiente sans données (calendrier vide)
2. ✅ Patiente avec CPoN uniquement
3. ✅ Patiente avec enfants et vaccinations
4. ✅ Patiente avec rappels de médicaments
5. ✅ Plusieurs événements le même jour
6. ✅ Navigation entre les mois
7. ✅ Pull-to-refresh
8. ✅ Gestion des erreurs réseau

## Maintenance

### Points d'attention

1. **Format des dates** : Toujours vérifier que le backend envoie des dates au format ISO 8601 (`YYYY-MM-DD`)
2. **Types de rappels** : Le filtrage se base sur `type == 'RAPPEL_VACCINATION'` pour les médicaments
3. **Statuts** : Respecter les enum côté backend (`A_VENIR`, `REALISEE`, etc.)

### Évolutions possibles

- [ ] Ajout d'un détail d'événement au clic sur un jour
- [ ] Filtrage par type d'événement (toggle CPoN/Vaccin/Médoc)
- [ ] Export du calendrier (PDF/iCal)
- [ ] Notifications push pour les événements à venir
- [ ] Vue hebdomadaire en plus de la vue mensuelle

## Dépendances

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  shared_preferences: ^2.2.2
```

## Conclusion

Le calendrier postnatale est maintenant entièrement fonctionnel et intégré avec le backend. Il offre une vue complète et dynamique du suivi postnatal de la patiente et de ses enfants, avec une interface intuitive et performante.

---

**Date de création** : 17 novembre 2025  
**Version** : 1.0  
**Auteur** : KènèyaMuso Team

