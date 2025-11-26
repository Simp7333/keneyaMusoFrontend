# 🧪 Test d'Intégration Dashboard - Guide Pratique

## 📋 Prérequis

- ✅ Backend démarré sur `http://localhost:8080`
- ✅ Émulateur Android ou iOS lancé
- ✅ Compte médecin créé dans la base de données

---

## 🚀 Procédure de Test

### Étape 1: Démarrer le Backend

```bash
cd c:\Projects\KeneyaMusoBackend
start-backend.bat
```

**Vérification**: Le backend affiche `Started KeneyaMusoBackendApplication`

### Étape 2: Tester l'Endpoint Backend

Exécuter le script de test PowerShell:

```bash
cd c:\Projects\KeneyaMusoBackend
.\test-dashboard-integration.ps1
```

**Résultat Attendu**:
```
[1/4] Vérification du backend...
✓ Backend est actif

[2/4] Authentification...
✓ Authentification réussie
  Utilisateur: Koné Mamadou
  Rôle: MEDECIN

[3/4] Récupération des statistiques du dashboard...
✓ Statistiques récupérées avec succès

  STATISTIQUES DU DASHBOARD:
  ─────────────────────────────────────
  📊 Total Patientes      : 45
  ⏳ Suivis En Cours      : 33
  ✓  Suivis Terminés      : 12
  🔔 Rappels Actifs       : 8
  ⚠️  Alertes Actives      : 3
  ─────────────────────────────────────

[4/4] Validation de la structure de réponse...
✓ Structure de réponse valide

=====================================================
   ✓ TOUS LES TESTS SONT PASSES
=====================================================
```

### Étape 3: Démarrer l'Application Flutter

```bash
cd c:\Projects\Keneya_muso
flutter run
```

### Étape 4: Test de l'Interface

#### 4.1 Connexion

1. Ouvrir l'application sur l'émulateur
2. Accéder à la page de connexion
3. Se connecter avec:
   - **Téléphone**: `+22377777777`
   - **Mot de passe**: `medecin123`
4. Appuyer sur "Se connecter"

**Résultat Attendu**: Redirection vers le Dashboard Pro

#### 4.2 Vérification du Dashboard

Le dashboard doit afficher **5 cartes statistiques** organisées en 3 lignes:

##### **Ligne 1: Patientes et Suivis en cours**

```
┌──────────────────────────┬──────────────────────────┐
│  👥 Patientes Suivies    │  ⏳ Suivis en cours      │
│      45                  │      33                  │
│  (Fond bleu clair)       │  (Fond ambre clair)      │
└──────────────────────────┴──────────────────────────┘
```

**Tests**:
- ✅ Le nombre affiché correspond aux données backend
- ✅ Icône `people_outline` visible (bleu)
- ✅ Icône `hourglass_bottom` visible (ambre)
- ✅ Tap sur "Patientes Suivies" → Navigation vers `/pro-patientes`

##### **Ligne 2: Suivis terminés et Rappels**

```
┌──────────────────────────┬──────────────────────────┐
│  ✓ Suivis terminés       │  🔔 Rappels              │
│      12                  │      8                   │
│  (Fond vert clair)       │  (Fond violet clair)     │
└──────────────────────────┴──────────────────────────┘
```

**Tests**:
- ✅ Le nombre affiché correspond aux données backend
- ✅ Icône `check_circle_outline` visible (vert)
- ✅ Icône `notifications_outlined` visible (violet)
- ✅ Tap sur "Rappels" → Navigation vers `/pro-notifications`

##### **Ligne 3: Alertes (pleine largeur)**

```
┌───────────────────────────────────────────────────────┐
│  ⚠️ Alertes de dossiers en attente                    │
│           3                                           │
│      (Fond rouge clair)                               │
└───────────────────────────────────────────────────────┘
```

**Tests**:
- ✅ Le nombre affiché correspond aux données backend
- ✅ Icône `warning_amber_outlined` visible (rouge)
- ✅ Tap sur "Alertes" → Navigation vers `/pro-alertes`

#### 4.3 Test du Pull-to-Refresh

1. Sur le Dashboard, tirer l'écran vers le bas
2. Un indicateur de chargement doit apparaître
3. Les statistiques doivent se recharger

**Résultat Attendu**:
- ✅ Indicateur de chargement visible
- ✅ Statistiques mises à jour après le rechargement
- ✅ Pas d'erreur affichée

#### 4.4 Test de Déconnexion/Reconnexion

1. Se déconnecter de l'application
2. Se reconnecter avec les mêmes identifiants
3. Retourner sur le Dashboard

**Résultat Attendu**:
- ✅ Nouveau token JWT généré
- ✅ Statistiques chargées correctement
- ✅ Pas d'erreur "Token invalide"

---

## 🔍 Tests de Cas Limites

### Test 1: Backend Non Disponible

**Procédure**:
1. Arrêter le backend
2. Ouvrir l'application Flutter
3. Essayer de charger le Dashboard

**Résultat Attendu**:
- ❌ Message d'erreur: "Erreur de connexion au serveur"
- ✅ Bouton "Réessayer" visible
- ✅ Pas de crash de l'application

### Test 2: Token Expiré

**Procédure**:
1. Se connecter à l'application
2. Attendre l'expiration du token (configurable dans le backend)
3. Pull-to-refresh sur le Dashboard

**Résultat Attendu**:
- ❌ Message d'erreur: "Non authentifié. Veuillez vous connecter."
- ✅ Redirection vers la page de connexion

### Test 3: Médecin Sans Patientes

**Procédure**:
1. Créer un nouveau compte médecin sans patientes assignées
2. Se connecter avec ce compte
3. Accéder au Dashboard

**Résultat Attendu**:
- ✅ Toutes les statistiques affichent `0`
- ✅ Pas d'erreur
- ✅ Interface reste fonctionnelle

### Test 4: Connexion Lente

**Procédure**:
1. Activer la limitation de bande passante (Android Studio DevTools)
2. Ouvrir le Dashboard

**Résultat Attendu**:
- ✅ Indicateur de chargement visible pendant la requête
- ✅ Statistiques s'affichent une fois la réponse reçue
- ✅ Pas de blocage de l'interface

---

## 📊 Validation des Données

### Vérification Backend vs Frontend

Pour chaque statistique, vérifier que les nombres correspondent:

| Statistique | Backend (API) | Frontend (UI) | Status |
|-------------|---------------|---------------|--------|
| **Total Patientes** | 45 | 45 | ✅ |
| **Suivis En Cours** | 33 | 33 | ✅ |
| **Suivis Terminés** | 12 | 12 | ✅ |
| **Rappels Actifs** | 8 | 8 | ✅ |
| **Alertes Actives** | 3 | 3 | ✅ |

### Requête SQL de Vérification

Connectez-vous à la base de données PostgreSQL et exécutez:

```sql
-- Total Patientes assignées au médecin
SELECT COUNT(*) 
FROM patiente 
WHERE professionnel_sante_assigne_id = 1; -- ID du médecin

-- Suivis en cours (Grossesses EN_COURS)
SELECT COUNT(*) 
FROM grossesse g
INNER JOIN patiente p ON g.patiente_id = p.id
WHERE p.professionnel_sante_assigne_id = 1
  AND g.statut = 'EN_COURS';

-- Suivis terminés (Grossesses TERMINEE)
SELECT COUNT(*) 
FROM grossesse g
INNER JOIN patiente p ON g.patiente_id = p.id
WHERE p.professionnel_sante_assigne_id = 1
  AND g.statut = 'TERMINEE';

-- Rappels actifs (Statut ENVOYE)
SELECT COUNT(*) 
FROM rappel 
WHERE utilisateur_id = 1 -- ID du médecin
  AND statut = 'ENVOYE';

-- Alertes actives (Soumissions EN_ATTENTE)
SELECT COUNT(*) 
FROM dossier_medical_submission 
WHERE professionnel_sante_id = 1 -- ID du médecin
  AND status = 'EN_ATTENTE';
```

---

## 🐛 Dépannage

### Problème: "Aucune donnée disponible"

**Causes possibles**:
1. Token expiré
2. Médecin non trouvé dans la base de données
3. Erreur de parsing JSON

**Solutions**:
1. Se déconnecter et se reconnecter
2. Vérifier que le compte existe: `SELECT * FROM utilisateur WHERE telephone = '+22377777777';`
3. Vérifier les logs backend

### Problème: "Erreur de connexion au serveur"

**Causes possibles**:
1. Backend non démarré
2. Mauvaise URL configurée
3. Firewall bloquant la connexion

**Solutions**:
1. Démarrer le backend: `start-backend.bat`
2. Vérifier `api_config.dart`:
   - Émulateur Android: `http://10.0.2.2:8080`
   - iOS Simulator: `http://localhost:8080`
3. Désactiver le firewall ou autoriser le port 8080

### Problème: Nombres Incorrects

**Causes possibles**:
1. Cache des données
2. Transactions non commitées
3. Données de test incorrectes

**Solutions**:
1. Pull-to-refresh pour recharger
2. Vérifier les logs SQL dans le backend
3. Exécuter les requêtes SQL de vérification manuellement

---

## 📝 Checklist de Test Complet

### Backend

- [ ] Backend démarré sur `http://localhost:8080`
- [ ] Test endpoint: `curl http://localhost:8080/actuator/health`
- [ ] Test login: `POST /api/auth/login`
- [ ] Test dashboard: `GET /api/dashboard/medecin`
- [ ] Script PowerShell passé: `test-dashboard-integration.ps1`

### Frontend

- [ ] Application Flutter lancée sur émulateur
- [ ] Connexion réussie avec compte médecin
- [ ] Dashboard affiche 5 cartes
- [ ] Tous les nombres correspondent aux données backend
- [ ] Navigation "Patientes Suivies" fonctionne
- [ ] Navigation "Rappels" fonctionne
- [ ] Navigation "Alertes" fonctionne
- [ ] Pull-to-refresh fonctionne
- [ ] Pas d'erreur de linting
- [ ] Interface responsive

### Tests d'Intégration

- [ ] Test connexion lente
- [ ] Test backend indisponible
- [ ] Test token expiré
- [ ] Test médecin sans patientes
- [ ] Test déconnexion/reconnexion

---

## 🎯 Critères de Succès

L'intégration est considérée comme **réussie** si:

1. ✅ Le script PowerShell `test-dashboard-integration.ps1` passe tous les tests
2. ✅ Les 5 statistiques s'affichent correctement dans l'UI
3. ✅ Les nombres correspondent aux données backend
4. ✅ Les 3 navigations (Patientes, Rappels, Alertes) fonctionnent
5. ✅ Le pull-to-refresh recharge les données
6. ✅ Les messages d'erreur sont clairs et explicites
7. ✅ Aucune erreur de linting Flutter
8. ✅ Performance fluide (<2s pour charger le dashboard)

---

## 📸 Captures d'Écran Attendues

### Dashboard Chargé

```
┌───────────────────────────────────────────┐
│  Keneya Muso Logo        🔔 (vert) 👤    │
├───────────────────────────────────────────┤
│                                           │
│  Bienvenue Dr. Mamadou Koné              │
│  Comment allez-vous aujourd'hui?         │
│                                           │
│  ┌──────────┐  ┌──────────┐             │
│  │👥  45    │  │⏳  33    │             │
│  │Patientes │  │En cours  │             │
│  └──────────┘  └──────────┘             │
│                                           │
│  ┌──────────┐  ┌──────────┐             │
│  │✓   12    │  │🔔  8     │             │
│  │Terminés  │  │Rappels   │             │
│  └──────────┘  └──────────┘             │
│                                           │
│  ┌──────────────────────────┐            │
│  │⚠️           3             │            │
│  │Alertes dossiers          │            │
│  └──────────────────────────┘            │
│                                           │
├───────────────────────────────────────────┤
│  [Home] [Patientes] [Accomp.] [Profil]  │
└───────────────────────────────────────────┘
```

---

## 📅 Date de Test

**Date**: ________________

**Testeur**: ________________

**Version Backend**: ________________

**Version Flutter**: ________________

**Résultat Global**: ⬜ PASS  ⬜ FAIL

**Commentaires**:
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

---

**Dernière mise à jour**: 2025-01-16

