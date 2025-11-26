# 🚨 Intégration Alertes - Documentation Complète

## ✅ État de l'Intégration

L'intégration de la page des alertes (soumissions de dossiers médicaux) est **COMPLÈTE ET FONCTIONNELLE**.

---

## 📋 Vue d'Ensemble

Les **alertes** dans Keneya Muso correspondent aux **soumissions de dossiers médicaux** que les patientes envoient et qui nécessitent la validation d'un médecin.

### Types d'Alertes

| Type | Description | Icône |
|------|-------------|-------|
| **CPN** | Formulaire Prénatal (Consultation Prénatale) | 🤰 `pregnant_woman` |
| **CPON** | Formulaire Postnatal (Consultation Postnatale) | 👶 `child_care` |

---

## 🔗 Architecture

### Backend (Spring Boot)

#### Controller: `DossierMedicalSubmissionController.java`

```java
@RestController
@RequestMapping("/api/dossiers/submissions")
public class DossierMedicalSubmissionController {
    
    // Récupère les alertes en attente pour le médecin connecté
    @GetMapping("/medecin")
    public ResponseEntity<ApiResponse<List<DossierSubmissionResponse>>> 
        getPendingForMedecin(Authentication authentication) {
        
        Long medecinId = submissionService.getMedecinIdFromTelephone(
            authentication.getName()
        );
        
        List<DossierSubmissionResponse> responses = 
            submissionService.mapToResponses(
                submissionService.getPendingSubmissionsForMedecin(medecinId)
            );
        
        return ResponseEntity.ok(
            ApiResponse.success("Soumissions en attente", responses)
        );
    }
    
    // Approuve une soumission
    @PostMapping("/{submissionId}/approve")
    public ResponseEntity<ApiResponse<String>> approveSubmission(...) {
        submissionService.approveSubmission(submissionId, medecinId, commentaire);
        return ResponseEntity.ok(ApiResponse.success("Soumission approuvée", null));
    }
    
    // Rejette une soumission
    @PostMapping("/{submissionId}/reject")
    public ResponseEntity<ApiResponse<String>> rejectSubmission(...) {
        submissionService.rejectSubmission(submissionId, medecinId, raison);
        return ResponseEntity.ok(ApiResponse.success("Soumission rejetée", null));
    }
}
```

#### Service: `DossierMedicalSubmissionService.java`

**Fonction principale**: `getPendingSubmissionsForMedecin(Long medecinId)`

```java
public List<DossierMedicalSubmission> getPendingSubmissionsForMedecin(Long medecinId) {
    // 1. Récupérer les soumissions assignées au médecin
    List<DossierMedicalSubmission> submissionsAssigned = 
        submissionRepository.findByProfessionnelSanteIdAndStatusInOrderByDateCreationDesc(
            medecinId,
            List.of(SubmissionStatus.EN_ATTENTE)
        );
    
    // 2. Récupérer TOUTES les soumissions sans médecin assigné (disponibles pour tous)
    List<DossierMedicalSubmission> submissionsUnassigned = 
        submissionRepository.findByProfessionnelSanteIsNullAndStatusOrderByDateCreationDesc(
            SubmissionStatus.EN_ATTENTE
        );
    
    // 3. Combiner et retourner
    submissionsUnassigned.addAll(submissionsAssigned);
    return submissionsUnassigned;
}
```

#### DTO: `DossierSubmissionResponse.java`

```java
@Data
@Builder
public class DossierSubmissionResponse {
    private Long id;
    private SubmissionType type;        // CPN, CPON
    private SubmissionStatus status;    // EN_ATTENTE, APPROUVEE, REJETEE
    private Long patienteId;
    private String patienteNom;
    private String patientePrenom;
    private String payload;             // JSON string
    private String commentaire;
    private LocalDateTime dateCreation;
}
```

---

### Frontend (Flutter)

#### 1. Service: `dossier_submission_service.dart`

```dart
class DossierSubmissionService {
  /// Récupère les soumissions en attente
  Future<ApiResponse<List<DossierSubmissionResponse>>> getPendingSubmissions() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/dossiers/submissions/medecin');
    final response = await http.get(url, headers: ApiConfig.headersWithAuth(token));
    // Parse JSON et retourne la liste
  }

  /// Approuve une soumission
  Future<ApiResponse<String>> approveSubmission(int submissionId, {String? commentaire}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/dossiers/submissions/$submissionId/approve');
    final response = await http.post(url, headers: ..., body: ...);
  }

  /// Rejette une soumission
  Future<ApiResponse<String>> rejectSubmission(int submissionId, String raison) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/dossiers/submissions/$submissionId/reject');
    final response = await http.post(url, headers: ..., body: jsonEncode({'raison': raison}));
  }
}
```

#### 2. Modèle: `dossier_submission_response.dart`

```dart
class DossierSubmissionResponse {
  final int id;
  final String type;          // CPN, CPON
  final String status;        // EN_ATTENTE, APPROUVEE, REJETEE
  final int patienteId;
  final String patienteNom;
  final String patientePrenom;
  final String payload;       // JSON string
  final String? commentaire;
  final DateTime dateCreation;

  // Getters utiles
  String get titre {
    switch (type) {
      case 'CPN': return 'Formulaire Prénatal (CPN)';
      case 'CPON': return 'Formulaire Postnatal (CPON)';
      default: return 'Dossier Médical';
    }
  }

  String get nomComplet => '$patientePrenom $patienteNom';
  
  String get tempsEcoule {
    final difference = DateTime.now().difference(dateCreation);
    if (difference.inSeconds < 60) return '${difference.inSeconds}s';
    if (difference.inMinutes < 60) return '${difference.inMinutes}min';
    if (difference.inHours < 24) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}j';
    return '${(difference.inDays / 7).floor()}sem';
  }
}
```

#### 3. Page Liste: `page_alertes.dart`

**Fonctionnalités**:
- ✅ Affiche la liste des alertes en attente
- ✅ Pull-to-refresh pour recharger
- ✅ Loading state pendant le chargement
- ✅ Message d'erreur avec bouton Réessayer
- ✅ État vide avec message informatif
- ✅ Navigation vers la page de détail
- ✅ Rechargement automatique après traitement d'une alerte

**Interface**:
```
┌─────────────────────────────────────────┐
│  ← Alertes                              │
├─────────────────────────────────────────┤
│  Dossiers médicaux en attente de        │
│  validation                             │
│                                         │
│  ┌────────────────────────────────────┐│
│  │ 🤰 Formulaire Prénatal (CPN)      ││
│  │    Awa Diarra                     ││
│  │    Nouvelle soumission...         ││
│  │                       2h EN_ATTENTE││
│  └────────────────────────────────────┘│
│                                         │
│  ┌────────────────────────────────────┐│
│  │ 👶 Formulaire Postnatal (CPON)    ││
│  │    Fatou Keita                    ││
│  │    Nouvelle soumission...         ││
│  │                      1j EN_ATTENTE││
│  └────────────────────────────────────┘│
└─────────────────────────────────────────┘
```

#### 4. Page Détail: `page_detail_alerte.dart`

**Fonctionnalités**:
- ✅ Affiche les informations de la patiente
- ✅ Parse et affiche le payload JSON du formulaire
- ✅ Bouton "Approuver" (vert)
- ✅ Bouton "Rejeter" (rouge) avec dialog pour la raison
- ✅ Loading state pendant le traitement
- ✅ Messages de succès/erreur avec SnackBar
- ✅ Retour automatique à la liste après traitement

**Interface**:
```
┌─────────────────────────────────────────┐
│  ← Formulaire Prénatal (CPN)           │
├─────────────────────────────────────────┤
│  ┌────────────────────────────────────┐│
│  │ 🤰 Awa Diarra                     ││
│  │    Soumis il y a 2h               ││
│  └────────────────────────────────────┘│
│                                         │
│  Données du formulaire                  │
│  ┌────────────────────────────────────┐│
│  │ Taille:           1.65 m           ││
│  │ Poids:            65 kg            ││
│  │ Dernier Contrôle: 2024-12-01       ││
│  │ Date Dernières Règles: 2024-10-15  ││
│  │ Nombre Mois Grossesse: 2           ││
│  │ ...                                ││
│  └────────────────────────────────────┘│
│                                         │
│  ┌──────────────┐  ┌──────────────────┐│
│  │ ✓ Approuver  │  │ ✗ Rejeter        ││
│  └──────────────┘  └──────────────────┘│
└─────────────────────────────────────────┘
```

---

## 🔄 Flux de Données

```
┌──────────────────────────────────────────────────────────────┐
│                   FLUX LISTE DES ALERTES                     │
└──────────────────────────────────────────────────────────────┘

PageAlertes (initState)
    │
    ▼
_loadAlertes()
    │
    ▼
DossierSubmissionService.getPendingSubmissions()
    │
    ▼ HTTP GET + Bearer Token
/api/dossiers/submissions/medecin
    │
    ▼
DossierMedicalSubmissionService.getPendingSubmissionsForMedecin()
    │
    ├─> submissionRepository.findByProfessionnelSanteIdAndStatusInOrderByDateCreationDesc()
    │   (Soumissions assignées au médecin)
    │
    └─> submissionRepository.findByProfessionnelSanteIsNullAndStatusOrderByDateCreationDesc()
        (Soumissions non assignées - disponibles pour tous)
    │
    ▼
List<DossierSubmissionResponse>
    │
    ▼ JSON Response
Flutter: Parse JSON
    │
    ▼
setState(() {
  _alertes = response.data;
  _isLoading = false;
})
    │
    ▼
ListView.builder (affiche les alertes)
```

```
┌──────────────────────────────────────────────────────────────┐
│                 FLUX TRAITEMENT D'UNE ALERTE                 │
└──────────────────────────────────────────────────────────────┘

User tap sur alerte
    │
    ▼
Navigation vers PageDetailAlerte
    │
    ├─> User clique "Approuver"
    │       │
    │       ▼
    │   DossierSubmissionService.approveSubmission(id)
    │       │
    │       ▼ HTTP POST + Bearer Token
    │   /api/dossiers/submissions/{id}/approve
    │       │
    │       ▼
    │   DossierMedicalSubmissionService.approveSubmission()
    │       │
    │       ├─> Assigner le médecin à la patiente (si non assigné)
    │       ├─> Traiter le formulaire (CPN ou CPON)
    │       ├─> Mettre à jour le statut: APPROUVEE
    │       └─> Envoyer une notification à la patiente
    │       │
    │       ▼
    │   SnackBar: "Soumission approuvée"
    │       │
    │       ▼
    │   Navigator.pop(context, true)
    │
    └─> User clique "Rejeter"
            │
            ▼
        Dialog: "Indiquez la raison..."
            │
            ▼
        DossierSubmissionService.rejectSubmission(id, raison)
            │
            ▼ HTTP POST + Bearer Token
        /api/dossiers/submissions/{id}/reject
            │
            ▼
        DossierMedicalSubmissionService.rejectSubmission()
            │
            ├─> Mettre à jour le statut: REJETEE
            ├─> Enregistrer la raison
            └─> Envoyer une notification à la patiente
            │
            ▼
        SnackBar: "Soumission rejetée"
            │
            ▼
        Navigator.pop(context, true)
    │
    ▼
PageAlertes recharge automatiquement (_loadAlertes)
```

---

## 📝 Endpoints API

### 1. GET /api/dossiers/submissions/medecin

**Description**: Récupère les soumissions en attente pour le médecin connecté

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Réponse (200 OK)**:
```json
{
  "success": true,
  "message": "Soumissions en attente",
  "data": [
    {
      "id": 1,
      "type": "CPN",
      "status": "EN_ATTENTE",
      "patienteId": 5,
      "patienteNom": "Diarra",
      "patientePrenom": "Awa",
      "payload": "{\"taille\":1.65,\"poids\":65,\"dernierControle\":\"2024-12-01\",\"dateDernieresRegles\":\"2024-10-15\",\"nombreMoisGrossesse\":2,\"groupeSanguin\":\"O+\",\"complications\":false,\"mouvementsBebeReguliers\":true,\"symptomes\":[],\"prendMedicamentsOuVitamines\":false,\"aEuMaladies\":false}",
      "commentaire": null,
      "dateCreation": "2025-01-16T10:30:00"
    },
    {
      "id": 2,
      "type": "CPON",
      "status": "EN_ATTENTE",
      "patienteId": 8,
      "patienteNom": "Keita",
      "patientePrenom": "Fatou",
      "payload": "{\"accouchementType\":\"VAGINAL\",\"nombreEnfants\":1,\"sentiment\":\"BIEN\",\"saignements\":false,\"consultation\":\"OUI\",\"sexeBebe\":\"FEMININ\",\"alimentation\":\"ALLAITEMENT\"}",
      "commentaire": null,
      "dateCreation": "2025-01-15T14:20:00"
    }
  ]
}
```

### 2. POST /api/dossiers/submissions/{id}/approve

**Description**: Approuve une soumission

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Body (optionnel)**:
```json
{
  "commentaire": "Dossier complet et conforme"
}
```

**Réponse (200 OK)**:
```json
{
  "success": true,
  "message": "Soumission approuvée",
  "data": null
}
```

### 3. POST /api/dossiers/submissions/{id}/reject

**Description**: Rejette une soumission

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Body**:
```json
{
  "raison": "Informations médicales incomplètes. Veuillez renseigner le groupe sanguin et les antécédents médicaux."
}
```

**Réponse (200 OK)**:
```json
{
  "success": true,
  "message": "Soumission rejetée",
  "data": null
}
```

---

## 🎨 Interface Utilisateur

### États de l'Interface

#### 1. Loading
```
┌─────────────────────────────────┐
│  Alertes                        │
│  Dossiers médicaux en attente   │
│                                 │
│          ⏳ Loading...          │
│                                 │
└─────────────────────────────────┘
```

#### 2. Liste avec alertes
```
┌─────────────────────────────────┐
│  Alertes                        │
│  Dossiers médicaux en attente   │
│                                 │
│  🤰 Formulaire Prénatal (CPN)  │
│     Awa Diarra                  │
│     Nouvelle soumission...      │
│                    2h EN_ATTENTE│
│  ─────────────────────────────  │
│  👶 Formulaire Postnatal (CPON)│
│     Fatou Keita                 │
│     Nouvelle soumission...      │
│                   1j EN_ATTENTE│
└─────────────────────────────────┘
```

#### 3. État vide
```
┌─────────────────────────────────┐
│  Alertes                        │
│  Dossiers médicaux en attente   │
│                                 │
│         🔔                      │
│  Aucune alerte en attente       │
│  Les nouvelles soumissions      │
│  apparaîtront ici               │
│                                 │
└─────────────────────────────────┘
```

#### 4. Erreur
```
┌─────────────────────────────────┐
│  Alertes                        │
│  Dossiers médicaux en attente   │
│                                 │
│         ⚠️                      │
│  Erreur de connexion au serveur│
│                                 │
│      [🔄 Réessayer]             │
└─────────────────────────────────┘
```

---

## 🧪 Tests

### Test Manuel - Liste des Alertes

1. **Démarrer le backend**:
   ```bash
   cd c:\Projects\KeneyaMusoBackend
   start-backend.bat
   ```

2. **Créer des soumissions de test** (depuis Postman ou l'app patiente):
   ```bash
   POST http://localhost:8080/api/dossiers/submissions
   Authorization: Bearer <TOKEN_PATIENTE>
   Body: {
     "type": "CPN",
     "data": {
       "taille": 1.65,
       "poids": 65,
       ...
     }
   }
   ```

3. **Lancer l'app Flutter**:
   ```bash
   cd c:\Projects\Keneya_muso
   flutter run
   ```

4. **Se connecter en tant que médecin**:
   - Téléphone: `+22377777777`
   - Mot de passe: `medecin123`

5. **Naviguer vers les alertes**:
   - Dashboard → Cliquer sur la carte "Alertes" (rouge)

6. **Vérifier l'affichage**:
   - ✅ Liste des alertes chargée
   - ✅ Icônes correctes (🤰 CPN, 👶 CPON)
   - ✅ Noms des patientes affichés
   - ✅ Temps écoulé correct
   - ✅ Badge "EN ATTENTE"

### Test Manuel - Détail et Traitement

1. **Cliquer sur une alerte**:
   - Ouvre la page de détail

2. **Vérifier l'affichage**:
   - ✅ Informations patiente
   - ✅ Données du formulaire parsées
   - ✅ Boutons "Approuver" et "Rejeter"

3. **Tester l'approbation**:
   - Cliquer sur "Approuver"
   - ✅ SnackBar vert: "Soumission approuvée"
   - ✅ Retour à la liste
   - ✅ L'alerte disparaît de la liste

4. **Tester le rejet**:
   - Cliquer sur une autre alerte
   - Cliquer sur "Rejeter"
   - ✅ Dialog s'affiche
   - Saisir une raison
   - ✅ SnackBar orange: "Soumission rejetée"
   - ✅ Retour à la liste
   - ✅ L'alerte disparaît de la liste

5. **Tester le pull-to-refresh**:
   - Tirer la liste vers le bas
   - ✅ Indicateur de chargement
   - ✅ Liste rechargée

---

## ✅ Checklist d'Intégration

### Backend
- [x] `DossierMedicalSubmissionController.java` - Endpoints REST
- [x] `DossierMedicalSubmissionService.java` - Logique métier
- [x] `DossierSubmissionResponse.java` - DTO de réponse
- [x] Endpoint GET `/medecin` - Liste des alertes
- [x] Endpoint POST `/{id}/approve` - Approuver
- [x] Endpoint POST `/{id}/reject` - Rejeter
- [x] Authentification JWT
- [x] Gestion des soumissions non assignées

### Frontend
- [x] `dossier_submission_service.dart` - Service HTTP
- [x] `dossier_submission_response.dart` - Modèle
- [x] `page_alertes.dart` - Liste des alertes
- [x] `page_detail_alerte.dart` - Détail et traitement
- [x] Loading states
- [x] Error handling
- [x] Pull-to-refresh
- [x] Navigation
- [x] Dialog de rejet
- [x] SnackBar de confirmation

---

## 🐛 Dépannage

### Problème: Liste vide alors que des alertes existent

**Causes possibles**:
1. Médecin non authentifié
2. Alertes déjà traitées
3. Problème de filtre (status != EN_ATTENTE)

**Solutions**:
1. Vérifier le token JWT
2. Créer de nouvelles soumissions
3. Vérifier les logs backend

### Problème: Erreur lors de l'approbation

**Causes possibles**:
1. Soumission déjà traitée
2. Médecin non autorisé
3. Payload JSON invalide

**Solutions**:
1. Recharger la liste
2. Vérifier les permissions
3. Vérifier les logs backend

---

## 🎉 Conclusion

✅ **L'intégration des alertes est COMPLÈTE et FONCTIONNELLE**

- Liste des alertes en temps réel
- Traitement (approbation/rejet) opérationnel
- Interface moderne et intuitive
- Gestion d'erreurs robuste
- Pull-to-refresh fonctionnel

**Date**: 2025-01-16  
**Version**: 1.0.0  
**Status**: ✅ PRODUCTION READY


