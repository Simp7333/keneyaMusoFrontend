# 🧪 Test de l'authentification - Guide Simple

## ✅ Étape 1 : Démarrer le backend

Ouvrez un terminal et lancez :

```bash
cd C:\Projects\KeneyaMusoBackend
C:\flutter\bin\flutter.bat pub get
mvn spring-boot:run
```

**Attendez que vous voyiez** :
```
Started KeneyaMusoApplication in X.XXX seconds
```

## ✅ Étape 2 : Vérifier la configuration

### Pour émulateur Android (déjà configuré ✓)
Le fichier `lib/config/api_config.dart` utilise déjà :
```dart
static const String baseUrl = 'http://10.0.2.2:8080';
```

### Pour appareil physique
1. Trouvez votre IP : `ipconfig` dans cmd
2. Modifiez `lib/config/api_config.dart` :
```dart
static const String baseUrl = 'http://VOTRE_IP:8080';
```

## ✅ Étape 3 : Lancer l'application Flutter

```bash
cd C:\Projects\Keneya_muso
C:\flutter\bin\flutter.bat run
```

## 🧪 Étape 4 : Tester l'inscription

### Test Patiente :
1. Cliquez sur "S'inscrire" depuis la page d'accueil
2. Remplissez :
   - **Nom et Prénom** : Fatoumata Diawara
   - **Téléphone** : 90110565 (ou tout numéro)
   - **Mot de passe** : test123
3. Cliquez sur "Inscription"
4. **Résultat attendu** :
   - Message : "Inscription réussie ! Bienvenue Diawara"
   - Redirection vers choix du type de suivi

### Test Professionnel :
1. Allez sur la page de connexion pro
2. Cliquez sur "S'inscrire"
3. Remplissez :
   - **Nom et Prénom** : Dr Mamadou Keita
   - **Téléphone** : 77001122 (ou tout numéro)
   - **Centre de santé** : CSCOM Bamako
   - **Mot de passe** : test123
4. Cliquez sur "S'inscrire"
5. **Résultat attendu** :
   - Message : "Inscription réussie ! Bienvenue Dr. Mamadou"
   - Redirection vers dashboard professionnel

## 🧪 Étape 5 : Tester la connexion

### Test Patiente :
1. Utilisez les credentials créés ci-dessus
2. Cliquez sur "Se connecter"
3. **Résultat attendu** :
   - Message : "Connexion réussie ! Bienvenue Diawara"
   - Redirection vers tableau de bord

### Test Professionnel :
1. Utilisez les credentials créés ci-dessus
2. Cliquez sur "Se connecter"
3. **Résultat attendu** :
   - Message : "Connexion réussie ! Bienvenue Dr. Mamadou"
   - Redirection vers dashboard pro

## 🔍 Dépannage

### ❌ "Erreur de connexion au serveur"
- Vérifiez que le backend est bien démarré
- Vérifiez l'URL dans `api_config.dart`
- Testez l'URL dans le navigateur : `http://10.0.2.2:8080` ou `http://localhost:8080`

### ❌ "Ce numéro de téléphone est déjà utilisé"
- Normal si vous testez deux fois avec le même numéro
- Utilisez la connexion au lieu de l'inscription
- Ou changez le numéro de téléphone

### ❌ "Ce compte n'est pas un compte patiente"
- Vous essayez de vous connecter avec un compte médecin sur la page patiente
- Utilisez la page de connexion appropriée

## 📊 Vérification dans le backend

Après inscription, vérifiez dans les logs du backend :
```
[date] INFO  c.k.service.AuthService - Utilisateur créé: Fatoumata Diawara
```

Ou consultez la base de données H2 :
- URL : `http://localhost:8080/h2-console`
- JDBC URL : `jdbc:h2:mem:keneyamuso`
- User : `sa`
- Password : (vide)

Requête SQL :
```sql
SELECT * FROM utilisateur;
```

## ✅ Points de vérification

- [ ] Backend démarré avec succès
- [ ] URL configurée correctement
- [ ] Inscription patiente fonctionne
- [ ] Inscription professionnelle fonctionne
- [ ] Connexion patiente fonctionne
- [ ] Connexion professionnelle fonctionne
- [ ] Token sauvegardé localement
- [ ] Redirection appropriée selon le rôle

---

🎉 **L'intégration est simple : 3 fichiers principaux**
1. `config/api_config.dart` - Configuration
2. `services/auth_service.dart` - Logique d'authentification
3. `models/dto/*` - Correspondance avec le backend

C'est tout ! Le reste est géré automatiquement. 🚀

