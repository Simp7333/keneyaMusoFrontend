# 📱 Configuration IP pour Téléphone Physique

## Guide complet pour connecter votre téléphone au backend

### 🎯 Objectif
Configurer l'adresse IP dans l'application Flutter pour que votre téléphone physique puisse se connecter au backend qui tourne sur votre ordinateur.

---

## 📍 Étape 1 : Trouver l'adresse IP de votre ordinateur

### Sur Windows :

**Méthode 1 : Via l'invite de commandes (CMD)**
1. Ouvrez `cmd` (Invite de commandes)
2. Tapez : `ipconfig`
3. Cherchez **"Adresse IPv4"** sous la section **"Carte réseau sans fil Wi-Fi"** ou **"Adaptateur Ethernet"**
4. Vous verrez quelque chose comme : `192.168.43.183` ou `192.168.1.10`

**Méthode 2 : Via PowerShell**
```powershell
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -like "*Wi-Fi*" -or $_.InterfaceAlias -like "*Ethernet*"} | Select-Object IPAddress, InterfaceAlias
```

### Sur Mac/Linux :
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

---

## 📍 Étape 2 : Vérifier que votre téléphone est sur le même réseau

✅ **Important :**
- Votre téléphone ET votre ordinateur doivent être connectés au **même réseau Wi-Fi**
- L'IP trouvée doit commencer par `192.168.x.x` ou `10.0.x.x` (réseau local)

---

## 📍 Étape 3 : Configurer l'IP dans l'application Flutter

Ouvrez le fichier : `lib/config/api_config.dart`

### Option A : Pour téléphone physique (recommandé)
```dart
// 📲 Pour appareil physique - Utilisez l'IP de votre ordinateur sur le réseau local
static const String baseUrl = 'http://192.168.43.183:8080'; // ← REMPLACEZ par VOTRE IP
```

### Option B : Pour émulateur Android
```dart
// 📱 Pour émulateur Android
static const String baseUrl = 'http://10.0.2.2:8080';
```

### Option C : Pour iOS simulator
```dart
// 🍎 Pour iOS simulator
static const String baseUrl = 'http://localhost:8080';
```

---

## 📍 Étape 4 : Démarrer le backend

Assurez-vous que votre backend Spring Boot est démarré sur le port 8080 :

```bash
# Dans le dossier KeneyaMusoBackend
./mvnw spring-boot:run
# ou
java -jar target/KeneyaMusoBackend.jar
```

Vérifiez que le backend écoute sur toutes les interfaces :
```properties
# Dans application.properties
server.address=0.0.0.0  # ← Permet les connexions externes
server.port=8080
```

---

## 📍 Étape 5 : Tester la connexion depuis le téléphone

1. **Depuis le navigateur du téléphone**, ouvrez :
   ```
   http://VOTRE_IP:8080/api-docs
   ```
   (Remplacez VOTRE_IP par l'IP trouvée à l'étape 1)

2. Si vous voyez la documentation Swagger, c'est que la connexion fonctionne ! ✅

---

## 🔧 Dépannage

### ❌ Problème : "Connection refused" ou "Timeout"

**Solutions :**

1. **Vérifier le firewall Windows :**
   ```powershell
   # Ouvrir le port 8080 dans le firewall
   New-NetFirewallRule -DisplayName "Backend Port 8080" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow
   ```

2. **Vérifier que le backend écoute bien sur toutes les interfaces :**
   - Dans `application.properties`, vérifiez : `server.address=0.0.0.0`

3. **Vérifier que le téléphone est sur le même réseau Wi-Fi**

4. **Vérifier que l'IP n'a pas changé :**
   - Les IP peuvent changer à chaque reconnexion Wi-Fi
   - Vérifiez l'IP avant chaque test

### ❌ Problème : "Network is unreachable"

- Vérifiez que votre téléphone a bien accès à Internet (Wi-Fi actif)
- Vérifiez que vous êtes sur le même réseau que l'ordinateur

### ❌ Problème : L'IP change à chaque fois

**Solution : Configurer une IP statique dans le routeur**
- Accédez à votre routeur (généralement `192.168.1.1`)
- Assignez une IP fixe à votre ordinateur via l'interface du routeur

---

## 📝 Exemple de configuration finale

```dart
/// Configuration de l'API backend
class ApiConfig {
  // 📲 Pour appareil physique - Utilisez l'IP de votre ordinateur
  static const String baseUrl = 'http://192.168.43.183:8080';
  
  // 📱 Pour émulateur Android (décommentez si besoin)
  // static const String baseUrl = 'http://10.0.2.2:8080';
  
  // 🍎 Pour iOS simulator (décommentez si besoin)
  // static const String baseUrl = 'http://localhost:8080';
  
  // ... reste du code ...
}
```

---

## 🚀 Après configuration

1. **Recompilez l'application Flutter :**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Testez une connexion simple :**
   - Connectez-vous dans l'application
   - Si ça fonctionne, c'est bon ! ✅

---

## 💡 Astuce : Script PowerShell pour trouver l'IP automatiquement

Créez un fichier `trouver-ip.ps1` :

```powershell
# Trouver l'adresse IP locale automatiquement
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
    $_.InterfaceAlias -like "*Wi-Fi*" -or 
    $_.InterfaceAlias -like "*Ethernet*"
}).IPAddress | Select-Object -First 1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Adresse IP de votre ordinateur :" -ForegroundColor Yellow
Write-Host "  $ip" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configurez dans api_config.dart :" -ForegroundColor Yellow
Write-Host "static const String baseUrl = 'http://$ip:8080';" -ForegroundColor Green
```

Exécutez-le avec :
```powershell
.\trouver-ip.ps1
```

---

## ✅ Checklist finale

- [ ] IP de l'ordinateur trouvée : `______________`
- [ ] Téléphone et ordinateur sur le même Wi-Fi
- [ ] Backend démarré sur port 8080
- [ ] `server.address=0.0.0.0` dans `application.properties`
- [ ] IP configurée dans `api_config.dart`
- [ ] Firewall ouvert pour le port 8080
- [ ] Test de connexion réussi depuis le navigateur du téléphone
- [ ] Application Flutter recompilée et testée

---

**Bonne configuration ! 🎉**

