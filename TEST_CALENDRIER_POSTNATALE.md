# 🧪 Guide de Test - Calendrier Postnatale

## Prérequis

Avant de commencer les tests, assurez-vous que :

1. ✅ Le backend est démarré (`start-backend.bat`)
2. ✅ La base de données contient des données de test
3. ✅ L'application Flutter est compilée sans erreur
4. ✅ Un compte patiente est créé et authentifié

## Scénarios de test

### 1. Test du calendrier vide (Patiente sans données)

**Objectif** : Vérifier que le calendrier s'affiche correctement sans données.

**Étapes** :
1. Se connecter avec une patiente qui n'a pas d'enfants ni de CPoN
2. Naviguer vers le dashboard postnatale
3. Observer le calendrier

**Résultat attendu** :
- ✅ Le calendrier s'affiche avec le mois courant
- ✅ Aucune icône d'événement n'est visible
- ✅ La légende est affichée
- ✅ Aucune carte d'événement sous le calendrier
- ✅ Pas d'erreur dans la console

### 2. Test des consultations postnatales (CPoN)

**Objectif** : Vérifier l'affichage des CPoN dans le calendrier.

**Préparation** :
```sql
-- Créer des CPoN de test
INSERT INTO consultation_postnatale (type, date_prevue, statut, patiente_id) 
VALUES 
  ('JOUR_3', '2025-11-20', 'A_VENIR', <patiente_id>),
  ('JOUR_7', '2025-11-24', 'A_VENIR', <patiente_id>),
  ('SEMAINE_6', '2025-12-25', 'A_VENIR', <patiente_id>);
```

**Étapes** :
1. Se connecter avec la patiente
2. Naviguer vers le dashboard postnatale
3. Observer le calendrier

**Résultat attendu** :
- ✅ Icône bleue (medical_services) sur les jours 20 et 24 du mois courant
- ✅ Cartes d'événements sous le calendrier : "CPON J+3" et "CPON J+7"
- ✅ Dates formatées en français
- ✅ Navigation vers décembre montre l'icône du 25

### 3. Test des vaccinations

**Objectif** : Vérifier l'affichage des vaccinations des enfants.

**Préparation** :
```sql
-- Créer un enfant
INSERT INTO enfant (nom, prenom, date_de_naissance, sexe, patiente_id) 
VALUES ('Diarra', 'Amadou', '2025-10-01', 'MASCULIN', <patiente_id>);

-- Créer des vaccinations
INSERT INTO vaccination (nom_vaccin, date_prevue, statut, enfant_id) 
VALUES 
  ('BCG', '2025-11-18', 'A_FAIRE', <enfant_id>),
  ('Polio 1', '2025-11-25', 'A_FAIRE', <enfant_id>);
```

**Étapes** :
1. Se connecter avec la patiente
2. Naviguer vers le dashboard postnatale
3. Observer le calendrier

**Résultat attendu** :
- ✅ Icône verte (vaccines) sur les jours 18 et 25
- ✅ Cartes "Vaccination BCG" et "Vaccination Polio 1"
- ✅ Console affiche "✅ 1 enfant(s) trouvé(s)"
- ✅ Console affiche "✅ 2 vaccinations chargées"

### 4. Test des rappels de médicaments

**Objectif** : Vérifier l'affichage des prises de médicaments.

**Préparation** :
```sql
-- Créer des rappels de médicament
INSERT INTO rappel (titre, message, type, statut, priorite, date_envoi, patiente_id) 
VALUES 
  ('Prise de médicament', 'Donner le sirop à votre enfant', 'RAPPEL_VACCINATION', 'ENVOYE', 'ELEVEE', '2025-11-19 08:00:00', <patiente_id>),
  ('Prise de médicament', 'Antibiotique du soir', 'RAPPEL_VACCINATION', 'ENVOYE', 'NORMALE', '2025-11-22 20:00:00', <patiente_id>);
```

**Étapes** :
1. Se connecter avec la patiente
2. Naviguer vers le dashboard postnatale
3. Observer le calendrier

**Résultat attendu** :
- ✅ Icône rouge (medication) sur les jours 19 et 22
- ✅ Cartes "Prise de médicament"
- ✅ Messages affichés correctement

### 5. Test de plusieurs événements le même jour

**Objectif** : Vérifier le badge multiple et la priorité d'affichage.

**Préparation** :
```sql
-- Créer 3 événements le même jour (20 novembre)
INSERT INTO consultation_postnatale (type, date_prevue, statut, patiente_id) 
VALUES ('JOUR_3', '2025-11-20', 'A_VENIR', <patiente_id>);

INSERT INTO vaccination (nom_vaccin, date_prevue, statut, enfant_id) 
VALUES ('BCG', '2025-11-20', 'A_FAIRE', <enfant_id>);

INSERT INTO rappel (titre, message, type, statut, priorite, date_envoi, patiente_id) 
VALUES ('Prise de médicament', 'Triple dose', 'RAPPEL_VACCINATION', 'ENVOYE', 'ELEVEE', '2025-11-20 08:00:00', <patiente_id>);
```

**Étapes** :
1. Se connecter avec la patiente
2. Naviguer vers le dashboard postnatale
3. Observer le jour 20

**Résultat attendu** :
- ✅ Icône **bleue** (CPoN a priorité sur les autres)
- ✅ Badge orange avec le chiffre **3**
- ✅ Les 3 événements apparaissent dans la liste sous le calendrier

### 6. Test de la navigation entre mois

**Objectif** : Vérifier que la navigation fonctionne correctement.

**Étapes** :
1. Ouvrir le dashboard postnatale (novembre 2025)
2. Cliquer sur la flèche droite (→)
3. Observer le calendrier (décembre 2025)
4. Cliquer sur la flèche gauche (←) 2 fois
5. Observer le calendrier (octobre 2025)

**Résultat attendu** :
- ✅ Navigation fluide sans lag
- ✅ Titre du mois change : "Novembre 2025" → "Décembre 2025" → "Octobre 2025"
- ✅ Événements affichés uniquement pour le mois visible
- ✅ Nombre de jours correct (30, 31, etc.)
- ✅ Premier jour de la semaine bien positionné

### 7. Test du pull-to-refresh

**Objectif** : Vérifier le rechargement des données.

**Étapes** :
1. Ouvrir le dashboard postnatale
2. Tirer vers le bas (pull-down)
3. Observer l'indicateur de chargement
4. Relâcher

**Résultat attendu** :
- ✅ Indicateur circulaire de chargement apparaît
- ✅ Requêtes API relancées (voir console)
- ✅ Données rechargées
- ✅ Calendrier mis à jour

### 8. Test de la gestion des erreurs réseau

**Objectif** : Vérifier le comportement en cas d'erreur.

**Étapes** :
1. Arrêter le backend
2. Ouvrir le dashboard postnatale
3. Observer le comportement

**Résultat attendu** :
- ✅ Indicateur de chargement disparaît après timeout
- ✅ Calendrier vide affiché (pas de crash)
- ✅ Erreurs loggées dans la console : "❌ Erreur chargement dashboard"
- ✅ Application reste utilisable

### 9. Test de l'authentification

**Objectif** : Vérifier que seules les données de la patiente connectée sont affichées.

**Étapes** :
1. Se connecter avec Patiente A
2. Noter les événements affichés
3. Se déconnecter
4. Se connecter avec Patiente B
5. Observer les événements

**Résultat attendu** :
- ✅ Événements de Patiente A uniquement pour Patiente A
- ✅ Événements de Patiente B uniquement pour Patiente B
- ✅ Pas de fuite de données entre utilisateurs

### 10. Test de performance avec beaucoup de données

**Objectif** : Vérifier que l'application reste fluide avec beaucoup d'événements.

**Préparation** :
```sql
-- Créer 50 vaccinations réparties sur 12 mois
-- Créer 20 CPoN
-- Créer 100 rappels
```

**Étapes** :
1. Se connecter avec la patiente
2. Ouvrir le dashboard
3. Naviguer entre les mois rapidement

**Résultat attendu** :
- ✅ Chargement initial < 3 secondes
- ✅ Navigation fluide (pas de lag)
- ✅ Pas de freeze de l'interface
- ✅ Mémoire stable (pas de leak)

## Tests fonctionnels avancés

### 11. Test des formats de date

**Objectif** : Vérifier le parsing de différents formats de date.

**Formats à tester** :
- `2025-11-20` (standard ISO)
- `2025-11-20T08:00:00` (avec heure)
- `2025-11-20T08:00:00.000Z` (avec millisecondes et timezone)

**Résultat attendu** :
- ✅ Tous les formats sont parsés correctement
- ✅ Pas d'erreur de parsing dans la console

### 12. Test des événements passés vs futurs

**Objectif** : Vérifier que seuls les événements "à venir" apparaissent dans les cartes.

**Préparation** :
```sql
-- CPoN passée
INSERT INTO consultation_postnatale (type, date_prevue, statut, patiente_id) 
VALUES ('JOUR_3', '2025-10-01', 'REALISEE', <patiente_id>);

-- CPoN future
INSERT INTO consultation_postnatale (type, date_prevue, statut, patiente_id) 
VALUES ('JOUR_7', '2025-12-01', 'A_VENIR', <patiente_id>);
```

**Résultat attendu** :
- ✅ CPoN passée : visible dans le calendrier (octobre), PAS dans la liste des événements
- ✅ CPoN future : visible dans le calendrier ET dans la liste

## Checklist finale

Avant de considérer l'intégration comme complète :

- [ ] ✅ Tous les tests ci-dessus passent
- [ ] ✅ Aucune erreur dans la console Flutter
- [ ] ✅ Aucune erreur dans les logs backend
- [ ] ✅ Interface responsive (mobile, tablette)
- [ ] ✅ Couleurs conformes à la charte graphique
- [ ] ✅ Textes en français correct
- [ ] ✅ Performance acceptable (< 3s chargement)
- [ ] ✅ Gestion des erreurs gracieuse
- [ ] ✅ Code commenté et documenté
- [ ] ✅ Pas de duplication de code

## Logs à surveiller

### Logs Flutter (console)
```
✅ 3 CPoN chargées
✅ 1 enfant(s) trouvé(s)
✅ 5 vaccinations chargées
✅ 10 rappels chargés
```

### Logs d'erreur possibles
```
❌ Patiente ID non trouvé
❌ Erreur parsing date CPoN: <détail>
❌ Erreur chargement vaccinations: <détail>
❌ Erreur de connexion au serveur: <détail>
```

## Outils de test

### Postman / Thunder Client
Tester les endpoints individuellement :
```
GET http://localhost:8080/api/consultations-postnatales/patiente/1
GET http://localhost:8080/api/vaccinations/enfant/1
GET http://localhost:8080/api/enfants/patiente/1
GET http://localhost:8080/api/notifications/me
```

### Flutter DevTools
- Surveiller la mémoire
- Inspecter le widget tree
- Observer les requêtes réseau
- Profiler les performances

## Résolution de problèmes courants

### Problème : Calendrier vide malgré des données

**Causes possibles** :
1. Dates au mauvais format
2. Patiente ID incorrect
3. Token expiré
4. Filtrage par mois incorrect

**Solution** :
1. Vérifier les logs console
2. Tester les endpoints avec Postman
3. Vérifier SharedPreferences (user_id, auth_token)

### Problème : Badge multiple ne s'affiche pas

**Cause** : Un seul événement réellement dans `eventsByDay[day]`

**Solution** : Vérifier que plusieurs événements ont exactement la même date

### Problème : Navigation lente

**Cause** : Trop de données chargées

**Solution** : Implémenter une pagination ou un cache

---

**Date** : 17 novembre 2025  
**Version** : 1.0  
**Auteur** : KènèyaMuso Team

