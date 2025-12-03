# 📁 Dossier Audio - Application Keneya Muso

## 📍 Fichiers audio requis

Placez vos fichiers audio dans ce dossier avec les noms suivants :

### 1. Tableau de Bord
**`tableau_bord_voix.aac`** (ou `.mp3`, `.m4a`, etc.)
- Utilisé dans : `page_tableau_bord.dart`
- Bouton de lecture vocale dans le tableau de bord prénatal

### 2. Page Type de Suivi
**`type_suivi_voix.aac`** (ou `.mp3`, `.m4a`, etc.)
- Utilisé dans : `type_suivi_page.dart`
- Bouton de lecture vocale en haut à droite de la page de sélection du type de suivi

## 📝 Instructions

1. **Noms des fichiers** : 
   - `tableau_bord_voix.aac` pour le tableau de bord
   - `type_suivi_voix.aac` pour la page de type de suivi

2. **Format** : Les fichiers peuvent être au format AAC, MP3, M4A, ou tout autre format supporté par `just_audio`

3. **Emplacement** : Tous les fichiers doivent être placés dans `assets/audio/`

## 🔧 Modification des noms de fichiers

### Pour le tableau de bord
Modifiez la constante `audioPath` dans :
```
Keneya_muso/lib/pages/patiente/prenatale/page_tableau_bord.dart
```
Ligne à modifier (environ ligne 454) :
```dart
const audioPath = 'assets/audio/votre_nom_fichier.aac';
```

### Pour la page type de suivi
Modifiez la constante `audioPath` dans :
```
Keneya_muso/lib/pages/patiente/type_suivi_page.dart
```
Ligne à modifier (environ ligne 250) :
```dart
const audioPath = 'assets/audio/votre_nom_fichier.aac';
```

## ✅ Vérification

Après avoir ajouté les fichiers audio :
1. Exécutez `flutter pub get` pour mettre à jour les assets
2. Redémarrez l'application
3. Les boutons de lecture vocale devraient maintenant jouer vos fichiers audio

## 📍 Emplacement des boutons

- **Tableau de bord** : Bouton flottant en bas à gauche (avec les autres boutons FAB)
- **Type de suivi** : Bouton flottant en haut à droite de la page

