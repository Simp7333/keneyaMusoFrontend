/// Configuration de l'API backend
class ApiConfig {
  // ⚙️ CONFIGURATION SIMPLE - Choisissez votre environnement :
  
  // 📱 Pour émulateur Android
  // static const String baseUrl = 'http://10.0.2.2:8080';
  
  // 🍎 Pour iOS simulator - Décommentez la ligne ci-dessous et commentez celle du dessus
  // static const String baseUrl = 'http://localhost:8080';
  
  // 📲 Pour appareil physique - Utilisez l'IP de votre ordinateur sur le réseau local
  static const String baseUrl = 'http://192.168.43.183:8080';
  
  // Endpoints d'authentification
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String logoutEndpoint = '/api/auth/logout';
  
  // Headers communs
  static Map<String, String> get headers => {
    'Content-Type': 'application/json; charset=UTF-8',
  };
  
  static Map<String, String> headersWithAuth(String token) => {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer $token',
  };
}

