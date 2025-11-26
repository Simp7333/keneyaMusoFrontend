# 📊 Intégration Dashboard - Guide Complet

## ✅ État de l'Intégration

L'intégration entre le frontend Flutter et le backend Spring Boot pour le dashboard professionnel est **COMPLÈTE ET FONCTIONNELLE**.

---

## 🔗 Architecture de l'Intégration

### Backend (Spring Boot)

#### 1. **Contrôleur** - `DashboardController.java`

```java
@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {
    
    @GetMapping("/medecin")
    public ResponseEntity<ApiResponse<DashboardStatsResponse>> getMedecinDashboardStats(
            Authentication authentication) {
        String telephone = authentication.getName();
        DashboardStatsResponse stats = dashboardService.getMedecinDashboardStats(telephone);
        return ResponseEntity.ok(ApiResponse.success("Statistiques récupérées avec succès", stats));
    }
}
```

**Endpoint**: `GET /api/dashboard/medecin`  
**Authentification**: Requiert Bearer Token JWT  
**Retour**: Objet `DashboardStatsResponse`

#### 2. **Service** - `DashboardService.java`

Calcule les statistiques en temps réel depuis la base de données :

```java
public DashboardStatsResponse getMedecinDashboardStats(String telephone) {
    // 1. Récupère le professionnel de santé connecté
    ProfessionnelSante professionnelSante = ...;
    
    // 2. Compte les patientes assignées
    long totalPatientes = patienteRepository.countByProfessionnelSanteId(...);
    
    // 3. Compte les grossesses terminées
    long suivisTermines = patienteRepository.countGrossessesTermineesByMedecinId(...);
    
    // 4. Compte les grossesses en cours
    long suivisEnCours = patienteRepository.countGrossessesEnCoursByMedecinId(...);
    
    // 5. Compte les rappels CPN/CPON/Vaccination non lus
    long rappelsActifs = rappelRepository.countByProfessionnelIdAndStatut(
        professionnelSante.getId(), 
        StatutRappel.ENVOYE
    );
    
    // 6. Compte les soumissions de dossiers en attente
    long alertesActives = submissionRepository.countByProfessionnelSanteIdAndStatus(
        professionnelSante.getId(), 
        SubmissionStatus.EN_ATTENTE
    );
    
    return DashboardStatsResponse.builder()
        .totalPatientes(totalPatientes)
        .suivisTermines(suivisTermines)
        .suivisEnCours(suivisEnCours)
        .rappelsActifs(rappelsActifs)
        .alertesActives(alertesActives)
        .build();
}
```

#### 3. **DTO de Réponse** - `DashboardStatsResponse.java`

```java
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardStatsResponse {
    private long totalPatientes;      // Nombre total de patientes assignées
    private long suivisTermines;      // Grossesses terminées
    private long suivisEnCours;       // Grossesses en cours
    private long rappelsActifs;       // Rappels CPN/CPON/Vaccination non lus
    private long alertesActives;      // Soumissions de dossiers en attente
}
```

---

### Frontend (Flutter)

#### 1. **Service** - `professionnel_sante_service.dart`

```dart
Future<ApiResponse<DashboardStatsResponse>> getDashboardStats() async {
    final token = prefs.getString('auth_token');
    
    final url = Uri.parse('${ApiConfig.baseUrl}/api/dashboard/medecin');
    
    final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
    );
    
    final stats = DashboardStatsResponse.fromJson(jsonResponse['data']);
    
    return ApiResponse<DashboardStatsResponse>(
        success: true,
        message: 'Statistiques récupérées avec succès',
        data: stats,
    );
}
```

#### 2. **Modèle** - `dashboard_stats_response.dart`

```dart
class DashboardStatsResponse {
  final int totalPatientes;
  final int suivisTermines;
  final int suivisEnCours;
  final int rappelsActifs;
  final int alertesActives;

  factory DashboardStatsResponse.fromJson(Map<String, dynamic> json) {
    // Conversion robuste pour gérer les types long du backend Java
    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return DashboardStatsResponse(
      totalPatientes: toInt(json['totalPatientes']),
      suivisTermines: toInt(json['suivisTermines']),
      suivisEnCours: toInt(json['suivisEnCours']),
      rappelsActifs: toInt(json['rappelsActifs']),
      alertesActives: toInt(json['alertesActives']),
    );
  }
}
```

#### 3. **Page** - `page_dashboard_pro.dart`

```dart
class _PageDashboardProState extends State<PageDashboardPro> {
  final ProfessionnelSanteService _service = ProfessionnelSanteService();
  DashboardStatsResponse? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _service.getDashboardStats();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.success && response.data != null) {
          _stats = response.data;
        } else {
          _errorMessage = response.message ?? 'Erreur lors du chargement';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadDashboardStats,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const WelcomeBanner(),
              StatsGrid(
                stats: _stats,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### 4. **Widget** - `stats_grid.dart`

Affiche les statistiques dans une grille de 3 lignes :

**Ligne 1** (2 colonnes) :
- **Patientes Suivies** (bleu) → Navigation vers `/pro-patientes`
- **Suivis en cours** (ambre)

**Ligne 2** (2 colonnes) :
- **Suivis terminés** (vert)
- **Rappels** (violet) → Navigation vers `/pro-notifications`

**Ligne 3** (pleine largeur) :
- **Alertes de dossiers** (rouge) → Navigation vers `/pro-alertes`

```dart
Widget build(BuildContext context) {
  if (isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  if (stats == null) {
    return const Center(child: Text('Aucune donnée disponible'));
  }

  return Column(
    children: [
      // Ligne 1: Patientes + Suivis en cours
      GridView.count(...),
      
      // Ligne 2: Suivis terminés + Rappels
      GridView.count(...),
      
      // Ligne 3: Alertes (pleine largeur)
      StatCard(...),
    ],
  );
}
```

---

## 🎨 Interface Utilisateur

### Disposition des Cartes

```
┌──────────────────────────┬──────────────────────────┐
│  👥 Patientes Suivies    │  ⏳ Suivis en cours      │
│      [Nombre]            │      [Nombre]            │
│  (Bleu - Cliquable)      │  (Ambre)                 │
└──────────────────────────┴──────────────────────────┘

┌──────────────────────────┬──────────────────────────┐
│  ✓ Suivis terminés       │  🔔 Rappels              │
│      [Nombre]            │      [Nombre]            │
│  (Vert)                  │  (Violet - Cliquable)    │
└──────────────────────────┴──────────────────────────┘

┌───────────────────────────────────────────────────────┐
│  ⚠️ Alertes de dossiers en attente                    │
│           [Nombre]                                    │
│      (Rouge - Cliquable)                              │
└───────────────────────────────────────────────────────┘
```

### Actions Interactives

| Carte | Action | Destination |
|-------|--------|-------------|
| **Patientes Suivies** | Tap | `/pro-patientes` - Liste des patientes |
| **Rappels** | Tap | `/pro-notifications` - Notifications CPN/CPON/Vaccination |
| **Alertes** | Tap | `/pro-alertes` - Dossiers médicaux en attente |

---

## 🔄 Flux de Données

```
┌─────────────────────┐
│  Page Dashboard     │
│  (initState)        │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ _loadDashboardStats │
│     (async)         │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────────────────┐
│ ProfessionnelSanteService       │
│ .getDashboardStats()            │
└──────────┬──────────────────────┘
           │
           ▼ HTTP GET + Bearer Token
┌──────────────────────────────────┐
│ Backend: /api/dashboard/medecin  │
└──────────┬───────────────────────┘
           │
           ▼
┌──────────────────────────┐
│ DashboardService         │
│ .getMedecinDashboardStats│
└──────────┬───────────────┘
           │
           ▼
┌────────────────────────────────────┐
│ Repositories (Queries SQL)         │
│ - PatienteRepository               │
│ - RappelRepository                 │
│ - DossierMedicalSubmissionRepo     │
└──────────┬─────────────────────────┘
           │
           ▼
┌─────────────────────────────┐
│ DashboardStatsResponse DTO  │
│ {                           │
│   totalPatientes: 45,       │
│   suivisTermines: 12,       │
│   suivisEnCours: 33,        │
│   rappelsActifs: 8,         │
│   alertesActives: 3         │
│ }                           │
└──────────┬──────────────────┘
           │
           ▼ JSON Response
┌──────────────────────────┐
│ Flutter: Parse JSON      │
│ DashboardStatsResponse   │
│   .fromJson()            │
└──────────┬───────────────┘
           │
           ▼
┌──────────────────────────┐
│ setState(() {            │
│   _stats = response.data;│
│   _isLoading = false;    │
│ })                       │
└──────────┬───────────────┘
           │
           ▼
┌──────────────────────────┐
│ StatsGrid Widget         │
│ (Affichage des cartes)   │
└──────────────────────────┘
```

---

## 🔐 Sécurité

### Authentification

- **JWT Bearer Token** requis pour tous les appels
- Token stocké dans `SharedPreferences` après login
- Token envoyé dans le header `Authorization: Bearer <token>`

### Backend Security

```java
@SecurityRequirement(name = "bearerAuth")
@GetMapping("/medecin")
public ResponseEntity<ApiResponse<DashboardStatsResponse>> getMedecinDashboardStats(
        Authentication authentication) {
    // Le téléphone est extrait automatiquement du token JWT
    String telephone = authentication.getName();
    // ...
}
```

### Frontend Security

```dart
Future<ApiResponse<DashboardStatsResponse>> getDashboardStats() async {
    final token = prefs.getString('auth_token');
    
    if (token == null) {
        return ApiResponse<DashboardStatsResponse>(
            success: false,
            message: 'Non authentifié. Veuillez vous connecter.',
        );
    }
    
    final response = await http.get(
        url,
        headers: ApiConfig.headersWithAuth(token),
    );
}
```

---

## 🛠️ Configuration

### Backend

**URL**: `http://localhost:8080`

**Endpoint**: `/api/dashboard/medecin`

**Méthode**: `GET`

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

### Frontend

**Configuration**: `lib/config/api_config.dart`

```dart
class ApiConfig {
  // Émulateur Android
  static const String baseUrl = 'http://10.0.2.2:8080';
  
  // iOS Simulator
  // static const String baseUrl = 'http://localhost:8080';
  
  // Appareil physique (remplacer par votre IP)
  // static const String baseUrl = 'http://192.168.1.10:8080';
}
```

---

## 📝 Exemple de Réponse API

### Requête

```http
GET /api/dashboard/medecin HTTP/1.1
Host: localhost:8080
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json
```

### Réponse Succès (200 OK)

```json
{
  "success": true,
  "message": "Statistiques récupérées avec succès",
  "data": {
    "totalPatientes": 45,
    "suivisTermines": 12,
    "suivisEnCours": 33,
    "rappelsActifs": 8,
    "alertesActives": 3
  }
}
```

### Réponse Erreur (401 Unauthorized)

```json
{
  "success": false,
  "message": "Token invalide ou expiré",
  "data": null
}
```

---

## 🧪 Test de l'Intégration

### 1. Démarrer le Backend

```bash
cd c:\Projects\KeneyaMusoBackend
start-backend.bat
```

### 2. Vérifier que le backend est actif

```bash
curl http://localhost:8080/actuator/health
```

### 3. Se connecter et obtenir un token

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "telephone": "+22377777777",
    "motDePasse": "medecin123"
  }'
```

### 4. Tester l'endpoint dashboard

```bash
curl -X GET http://localhost:8080/api/dashboard/medecin \
  -H "Authorization: Bearer <VOTRE_TOKEN>"
```

### 5. Lancer l'application Flutter

```bash
cd c:\Projects\Keneya_muso
flutter run
```

---

## 🐛 Dépannage

### Problème 1: "Aucune donnée disponible"

**Cause**: Token expiré ou invalide

**Solution**:
1. Se déconnecter de l'app
2. Se reconnecter pour obtenir un nouveau token

### Problème 2: "Erreur de connexion au serveur"

**Cause**: Backend non démarré ou mauvaise URL

**Solution**:
1. Vérifier que le backend est actif: `http://localhost:8080/actuator/health`
2. Vérifier l'URL dans `api_config.dart`:
   - Émulateur Android: `http://10.0.2.2:8080`
   - iOS Simulator: `http://localhost:8080`

### Problème 3: Données incorrectes

**Cause**: Problème de parsing JSON

**Solution**: La fonction `toInt()` dans `DashboardStatsResponse.fromJson()` gère automatiquement les conversions `long` → `int`.

---

## ✅ Points Clés de l'Intégration

1. ✅ **Endpoint Backend** : `/api/dashboard/medecin` (GET)
2. ✅ **Service Backend** : `DashboardService.getMedecinDashboardStats()`
3. ✅ **DTO Backend** : `DashboardStatsResponse` avec 5 champs
4. ✅ **Service Frontend** : `ProfessionnelSanteService.getDashboardStats()`
5. ✅ **Modèle Frontend** : `DashboardStatsResponse` avec conversion robuste
6. ✅ **Page Flutter** : `PageDashboardPro` avec RefreshIndicator
7. ✅ **Widget Flutter** : `StatsGrid` avec layout 3 lignes
8. ✅ **Authentification** : JWT Bearer Token
9. ✅ **Gestion d'erreur** : Messages d'erreur + bouton Réessayer
10. ✅ **Pull to Refresh** : Rechargement des données

---

## 🎯 Prochaines Étapes

1. **Page Notifications** : Afficher les rappels CPN/CPON/Vaccination
2. **Page Alertes** : Afficher les dossiers médicaux en attente
3. **Filtre Patientes** : Par type de suivi (PRENATAL, POSTNATAL, ENFANTS)
4. **Graphiques** : Évolution des statistiques dans le temps
5. **Notifications Push** : Intégration Firebase Cloud Messaging

---

## 📚 Fichiers Concernés

### Backend
- `DashboardController.java` - Contrôleur REST
- `DashboardService.java` - Logique métier
- `DashboardStatsResponse.java` - DTO de réponse
- `PatienteRepository.java` - Requêtes SQL patientes
- `RappelRepository.java` - Requêtes SQL rappels
- `DossierMedicalSubmissionRepository.java` - Requêtes SQL soumissions

### Frontend
- `page_dashboard_pro.dart` - Page principale
- `stats_grid.dart` - Widget grille de statistiques
- `stat_card.dart` - Widget carte individuelle
- `professionnel_sante_service.dart` - Service HTTP
- `dashboard_stats_response.dart` - Modèle de données
- `api_config.dart` - Configuration API

---

## 🎉 Conclusion

L'intégration du dashboard est **complète et fonctionnelle**. Toutes les statistiques sont calculées en temps réel depuis la base de données et affichées dans une interface moderne et intuitive avec des actions de navigation.

**Date de dernière mise à jour**: 2025-01-16


