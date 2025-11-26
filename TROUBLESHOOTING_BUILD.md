# 🔧 Guide de Dépannage - Erreurs de Build

## Problème Résolu: Erreur de Compilation Flutter

### ❌ Erreur Rencontrée
```
/C:/flutter/packages/flutter/lib/src/widgets/framework.dart:7004:1: Error: Expected ';' after this.
o    }
^
Error: The getter 'o' isn't defined for the type 'SingleChildRenderObjectElement'.
Target kernel_snapshot_program failed: Exception
```

### ✅ Solution Appliquée

Cette erreur était causée par un cache de build corrompu dans Flutter.

**Étapes de résolution:**

1. **Nettoyage du cache Flutter**
   ```bash
   C:\flutter\bin\flutter.bat clean
   ```

2. **Récupération des dépendances**
   ```bash
   C:\flutter\bin\flutter.bat pub get
   ```

3. **Import inutile supprimé**
   - Fichier: `lib/widgets/custom_calendar.dart`
   - Suppression de: `import 'package:keneya_muso/pages/common/app_colors.dart';`

## 🚀 Comment Lancer l'Application

### Méthode 1: Script Batch (Recommandé)
```bash
cd C:\Projects\Keneya_muso
run_debug.bat
```

Ce script fait automatiquement:
1. Nettoyage du cache (`flutter clean`)
2. Récupération des dépendances (`flutter pub get`)
3. Lancement de l'app (`flutter run`)

### Méthode 2: Commandes Manuelles
```bash
cd C:\Projects\Keneya_muso
C:\flutter\bin\flutter.bat clean
C:\flutter\bin\flutter.bat pub get
C:\flutter\bin\flutter.bat run
```

### Méthode 3: Depuis PowerShell
```powershell
cd C:\Projects\Keneya_muso
C:\flutter\bin\flutter.bat run
```

## 🐛 Autres Erreurs Courantes

### 1. LocaleDataException
**Erreur:**
```
LocaleDataException: Locale data has not been initialized
```

**Solution:** Déjà corrigée dans `custom_calendar.dart` et `page_tableau_bord.dart`
- Utilisation de formatage manuel au lieu de `DateFormat` avec locale

### 2. Multiple Heroes Error
**Erreur:**
```
There are multiple heroes that share the same tag
```

**Solution:** Déjà corrigée dans `page_tableau_bord.dart`
- Ajout de `heroTag` unique pour chaque `FloatingActionButton`

### 3. Analyzer Issues (Info/Warnings)
Les 212 issues trouvées par l'analyzer sont principalement:
- ✅ **deprecated_member_use** : `withOpacity()` est déprécié (non critique)
- ✅ **avoid_print** : Utilisation de `print()` pour debug (non critique)
- ✅ **unused_import** : Import inutile supprimé
- ✅ **dead_code** : Code jamais exécuté (non critique pour le build)

**Ces warnings n'empêchent PAS la compilation.**

## 📋 Checklist de Dépannage

Avant de lancer l'app, vérifiez:

- [ ] Le backend est démarré sur `http://10.0.2.2:8080` (pour émulateur)
- [ ] L'émulateur Android est lancé
- [ ] Le cache Flutter est nettoyé (`flutter clean`)
- [ ] Les dépendances sont à jour (`flutter pub get`)
- [ ] Aucune erreur critique dans `flutter analyze`

## 🔍 Vérification de l'Environnement

### Vérifier Flutter
```bash
C:\flutter\bin\flutter.bat doctor
```

**Résultat attendu:**
```
[√] Flutter (Channel stable, 3.35.3)
[√] Android toolchain
[√] Android Studio
[√] Connected device
```

### Vérifier les Erreurs Critiques
```bash
C:\flutter\bin\flutter.bat analyze
```

**Résultat attendu:**
- Seulement des `info` et `warning`
- Pas d'`error`

## 🛠️ Commandes Utiles

### Nettoyage Complet
```bash
# Supprimer tous les fichiers de build
C:\flutter\bin\flutter.bat clean

# Supprimer le dossier .dart_tool (si problème persiste)
rmdir /s /q .dart_tool
rmdir /s /q build

# Récupérer les dépendances
C:\flutter\bin\flutter.bat pub get
```

### Lancement avec Logs Détaillés
```bash
C:\flutter\bin\flutter.bat run --verbose
```

### Build Debug APK
```bash
C:\flutter\bin\flutter.bat build apk --debug
```

### Voir les Devices Connectés
```bash
C:\flutter\bin\flutter.bat devices
```

## 📱 Configuration de l'Émulateur

Si l'émulateur ne démarre pas:

1. **Lancer Android Studio**
2. **Ouvrir AVD Manager** (Tools > Device Manager)
3. **Créer/Lancer un émulateur** (Pixel 4 ou plus récent recommandé)

Ou via ligne de commande:
```bash
# Lister les émulateurs
emulator -list-avds

# Lancer un émulateur
emulator -avd <nom_emulateur>
```

## 🔗 Backend

### Vérifier que le Backend est Actif
```bash
curl http://10.0.2.2:8080/api/auth/login
```

Ou ouvrir dans le navigateur:
```
http://localhost:8080/swagger-ui.html
```

### Démarrer le Backend
```bash
cd C:\Projects\KeneyaMusoBackend
start-backend.bat
```

## 📝 Logs et Debug

### Voir les Logs en Temps Réel
```bash
C:\flutter\bin\flutter.bat logs
```

### Clear les Logs
```bash
C:\flutter\bin\flutter.bat logs --clear
```

## ⚠️ Problèmes Connus

### Android SDK avec Espaces dans le Chemin
**Message:**
```
Android SDK location currently contains spaces
```

**Impact:** Peut causer des problèmes avec NDK
**Solution:** Déplacer le SDK vers un chemin sans espaces (optionnel)

### Device Non Autorisé
**Message:**
```
Device 6e2b20fa is not authorized
```

**Solution:**
1. Débloquer le téléphone/émulateur
2. Accepter le dialogue d'autorisation USB debugging
3. Relancer `flutter run`

## 🎯 En Cas de Problème Persistant

1. **Redémarrer l'IDE** (VS Code/Android Studio)
2. **Redémarrer l'émulateur**
3. **Nettoyage complet:**
   ```bash
   C:\flutter\bin\flutter.bat clean
   C:\flutter\bin\flutter.bat pub cache repair
   C:\flutter\bin\flutter.bat pub get
   ```
4. **Réinstaller Flutter** (dernier recours)

## 📞 Support

Si l'erreur persiste, vérifiez:
- `BUGFIX_LOCALE_HERO.md` - Correctifs récents
- `INTEGRATION_DASHBOARD_PATIENTE.md` - Guide d'intégration
- `README.md` - Instructions générales

---

✨ **L'application devrait maintenant compiler et se lancer sans erreur !** ✨

