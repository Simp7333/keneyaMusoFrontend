# 📱 Guide d'utilisation du Message Popup stylisé

## 🎨 Présentation

Le système de popup stylisé remplace les `SnackBar` standards par des popups modernes et cohérents dans toute l'application. Les popups sont disponibles avec différents types (succès, erreur, avertissement, information).

## 📦 Fichiers

- **`lib/widgets/message_popup.dart`** : Widget de popup stylisé
- **`lib/utils/message_helper.dart`** : Fonctions helper pour faciliter l'utilisation

## 🚀 Utilisation rapide

### 1. Import

```dart
import 'package:keneya_muso/utils/message_helper.dart';
```

### 2. Affichage d'un message de succès

```dart
await MessageHelper.showSuccess(
  context: context,
  message: 'Opération réussie avec succès !',
  title: 'Succès',
);
```

### 3. Affichage d'une erreur

```dart
await MessageHelper.showError(
  context: context,
  message: 'Une erreur est survenue lors de l\'opération',
  title: 'Erreur',
);
```

### 4. Affichage d'un avertissement

```dart
await MessageHelper.showWarning(
  context: context,
  message: 'Attention, cette action est irréversible',
  title: 'Avertissement',
);
```

### 5. Affichage d'une information

```dart
await MessageHelper.showInfo(
  context: context,
  message: 'Vos données ont été sauvegardées',
  title: 'Information',
);
```

### 6. Utilisation avec une ApiResponse

Le plus pratique : afficher automatiquement un message selon le résultat d'une API :

```dart
final response = await _service.someApiCall();

if (mounted) {
  await MessageHelper.showApiResponse(
    context: context,
    response: response,
    successTitle: 'Opération réussie',
    errorTitle: 'Erreur',
    onSuccess: () {
      // Action à effectuer en cas de succès (optionnel)
      Navigator.pop(context);
    },
  );
}
```

## 🔄 Remplacement des SnackBar

### Avant (SnackBar)

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Message de succès'),
    backgroundColor: Colors.green,
  ),
);
```

### Après (MessagePopup)

```dart
await MessageHelper.showSuccess(
  context: context,
  message: 'Message de succès',
);
```

## 📝 Exemples complets

### Exemple 1 : Sauvegarde réussie avec action

```dart
Future<void> _saveData() async {
  setState(() => _isSaving = true);
  
  final response = await _service.saveData(data);
  
  if (mounted) {
    setState(() => _isSaving = false);
    
    await MessageHelper.showApiResponse(
      context: context,
      response: response,
      successTitle: 'Sauvegarde réussie',
      onSuccess: () {
        Navigator.pop(context, true); // Retour avec succès
      },
    );
  }
}
```

### Exemple 2 : Gestion d'erreur avec action

```dart
try {
  final response = await _service.performAction();
  
  if (mounted) {
    if (response.success) {
      await MessageHelper.showSuccess(
        context: context,
        message: response.message ?? 'Action réussie',
      );
    } else {
      await MessageHelper.showError(
        context: context,
        message: response.message ?? 'Une erreur est survenue',
        onPressed: () {
          // Action personnalisée en cas d'erreur
        },
      );
    }
  }
} catch (e) {
  if (mounted) {
    await MessageHelper.showError(
      context: context,
      message: 'Erreur: $e',
    );
  }
}
```

### Exemple 3 : Avertissement avec confirmation

```dart
Future<void> _deleteItem() async {
  final confirmed = await MessageHelper.showWarning(
    context: context,
    message: 'Êtes-vous sûr de vouloir supprimer cet élément ?',
    title: 'Confirmation',
    buttonText: 'Supprimer',
  );
  
  // Le popup se ferme automatiquement, mais vous pouvez ajouter une logique
}
```

## 🎨 Personnalisation

### Utilisation directe du widget

Si vous avez besoin de plus de contrôle, vous pouvez utiliser directement le widget :

```dart
await MessagePopup.show(
  context: context,
  title: 'Titre personnalisé',
  message: 'Message personnalisé',
  type: MessageType.success, // ou error, warning, info
  buttonText: 'Fermer',
  onPressed: () {
    // Action personnalisée
    Navigator.of(context).pop();
  },
);
```

## 🔧 Types de messages

- **`MessageType.success`** : Message de succès (vert)
- **`MessageType.error`** : Message d'erreur (rouge)
- **`MessageType.warning`** : Message d'avertissement (orange)
- **`MessageType.info`** : Message d'information (bleu)

## ✨ Avantages

1. **Design cohérent** : Tous les messages ont le même style
2. **Expérience utilisateur améliorée** : Popups plus visibles que les SnackBar
3. **Facilité d'utilisation** : Fonctions helper simples
4. **Flexibilité** : Support de différents types de messages
5. **Actions personnalisées** : Possibilité d'ajouter des callbacks

## 📚 Migration depuis SnackBar

Pour migrer votre code existant :

1. Remplacer les imports si nécessaire
2. Remplacer `ScaffoldMessenger.of(context).showSnackBar()` par `MessageHelper.show...()`
3. Utiliser `await` car les popups sont asynchrones
4. Utiliser `onSuccess`/`onPressed` pour les actions après fermeture

## 💡 Bonnes pratiques

- ✅ Utiliser `MessageHelper.showApiResponse()` pour les réponses API
- ✅ Vérifier `mounted` avant d'afficher un popup
- ✅ Utiliser des titres clairs et des messages descriptifs
- ✅ Ajouter des actions dans `onSuccess`/`onPressed` si nécessaire
- ❌ Ne pas afficher plusieurs popups en même temps
- ❌ Ne pas oublier le `await` pour les popups asynchrones

