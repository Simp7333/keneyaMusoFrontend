# Intégration Backend - Authentification

## ✅ Étape 1 : Authentification Complétée

Cette étape intègre l'authentification (connexion et inscription) entre le frontend Flutter et le backend Spring Boot.

### 📦 Fichiers créés

#### Configuration
- **`lib/config/api_config.dart`** : Configuration de l'API (URL, endpoints, headers)

#### Modèles (Enums)
- **`lib/models/enums/role_utilisateur.dart`** : PATIENTE, MEDECIN, ADMINISTRATEUR
- **`lib/models/enums/specialite.dart`** : GYNECOLOGUE, PEDIATRE, GENERALISTE

#### DTOs (Data Transfer Objects)
- **`lib/models/dto/login_request.dart`** : Requête de connexion
- **`lib/models/dto/register_request.dart`** : Requête d'inscription
- **`lib/models/dto/jwt_auth_response.dart`** : Réponse d'authentification
- **`lib/models/dto/api_response.dart`** : Réponse générique de l'API

#### Services
- **`lib/services/auth_service.dart`** : Service d'authentification avec méthodes :
  - `login()` : Connexion
  - `register()` : Inscription
  - `logout()` : Déconnexion
  - `isLoggedIn()` : Vérification du statut de connexion
  - `getAuthToken()` : Récupération du token JWT
  - `getUserRole()` : Récupération du rôle utilisateur

### 📝 Fichiers modifiés

#### Pages Patientes
- **`lib/pages/patiente/page_connexion.dart`** :
  - Intégration API de connexion
  - Validation du rôle PATIENTE
  - Indicateur de chargement
  - Gestion des erreurs
  
- **`lib/pages/patiente/page_inscription.dart`** :
  - Intégration API d'inscription
  - Séparation automatique nom/prénom
  - Indicateur de chargement
  - Gestion des erreurs

#### Pages Professionnelles
- **`lib/pages/gynecologue/page_connexion_pro.dart`** :
  - Intégration API de connexion
  - Validation du rôle MEDECIN
  - Affichage/masquage du mot de passe
  - Indicateur de chargement
  
- **`lib/pages/gynecologue/page_inscription_pro.dart`** :
  - Intégration API d'inscription
  - Spécialité par défaut : GYNECOLOGUE
  - Indicateur de chargement
  - Gestion des erreurs

#### Dépendances
- **`pubspec.yaml`** : Ajout du package `http: ^1.1.0`

## 🔧 Configuration Backend

### URL du Backend
Par défaut dans `lib/config/api_config.dart` :
```dart
static const String baseUrl = 'http://10.0.2.2:8080'; // Émulateur Android
```

**À modifier selon votre environnement :**
- **Émulateur Android** : `http://10.0.2.2:8080`
- **iOS Simulator** : `http://localhost:8080`
- **Appareil physique** : `http://YOUR_LOCAL_IP:8080` (ex: `http://192.168.1.10:8080`)

### Endpoints utilisés
- **Login** : `POST /api/auth/login`
- **Register** : `POST /api/auth/register`
- **Logout** : `POST /api/auth/logout`

## 📊 Flux d'authentification

### Connexion Patiente
```
1. Saisie téléphone + mot de passe
2. Appel POST /api/auth/login
3. Validation rôle = PATIENTE
4. Sauvegarde token JWT + infos utilisateur
5. Vérification type de suivi (prenatal/postnatal)
6. Redirection vers dashboard approprié
```

### Inscription Patiente
```
1. Saisie nom, téléphone, mot de passe
2. Appel POST /api/auth/register avec role=PATIENTE
3. Sauvegarde token JWT + infos utilisateur
4. Redirection vers page de choix du type de suivi
```

### Connexion Professionnelle
```
1. Saisie téléphone + mot de passe
2. Appel POST /api/auth/login
3. Validation rôle = MEDECIN
4. Sauvegarde token JWT + infos utilisateur
5. Redirection vers dashboard professionnel
```

### Inscription Professionnelle
```
1. Saisie nom, téléphone, centre de santé, mot de passe
2. Appel POST /api/auth/register avec role=MEDECIN
3. Sauvegarde token JWT + infos utilisateur
4. Redirection vers dashboard professionnel
```

## 💾 Données sauvegardées localement (SharedPreferences)

Après une authentification réussie :
- `auth_token` : Token JWT
- `user_id` : ID de l'utilisateur
- `user_nom` : Nom
- `user_prenom` : Prénom
- `user_telephone` : Téléphone
- `user_role` : Rôle (PATIENTE/MEDECIN)
- `user_date_naissance` : Date de naissance (patientes uniquement)

## 🧪 Test de l'intégration

### Prérequis
1. Le backend doit être démarré sur le port 8080
2. Configurer l'URL correcte dans `api_config.dart`
3. Exécuter `flutter pub get` pour installer le package http

### Test Connexion
1. Créer un compte dans le backend (via API ou base de données)
2. Utiliser ces credentials dans l'app Flutter
3. Vérifier que le token est sauvegardé
4. Vérifier la redirection appropriée

### Test Inscription
1. Remplir le formulaire d'inscription
2. Vérifier que l'utilisateur est créé dans la base de données
3. Vérifier que le token est sauvegardé
4. Vérifier la redirection appropriée

## 🔍 Débogage

### Erreurs communes

**Erreur de connexion au serveur :**
- Vérifier que le backend est démarré
- Vérifier l'URL dans `api_config.dart`
- Sur appareil physique, vérifier que le téléphone et le PC sont sur le même réseau

**"Ce compte n'est pas un compte patiente/professionnel" :**
- Vérifier le rôle dans la base de données
- Utiliser la bonne page de connexion selon le rôle

**"Ce numéro de téléphone est déjà utilisé" :**
- Le compte existe déjà dans la base de données
- Utiliser la page de connexion au lieu de l'inscription

## 🚀 Prochaines étapes

- [ ] Intégration des dossiers médicaux
- [ ] Intégration des rendez-vous
- [ ] Intégration de la messagerie
- [ ] Intégration des notifications
- [ ] Upload d'images de profil
- [ ] Validation avancée des formulaires
- [ ] Gestion du rafraîchissement du token

