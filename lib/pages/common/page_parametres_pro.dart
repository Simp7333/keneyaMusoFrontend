import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:keneya_muso/routes.dart';
import 'package:keneya_muso/widgets/pro_bottom_nav_bar.dart';
import 'package:keneya_muso/widgets/bottom_nav_bar.dart';
import 'package:keneya_muso/widgets/notification_settings_panel.dart';
import 'package:keneya_muso/services/auth_service.dart';
import 'package:keneya_muso/services/profil_service.dart';
import 'package:keneya_muso/models/enums/role_utilisateur.dart';

class PageParametresPro extends StatefulWidget {
  final bool isPatiente;
  
  const PageParametresPro({super.key, this.isPatiente = false});

  @override
  State<PageParametresPro> createState() => _PageParametresProState();
}

class _PageParametresProState extends State<PageParametresPro> {
  int _bottomNavIndex = 3;
  final AuthService _authService = AuthService();
  final ProfilService _profilService = ProfilService();
  
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _profilService.getCurrentUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToDashboard() async {
    if (!widget.isPatiente) {
      Navigator.pushReplacementNamed(context, AppRoutes.proDashboard);
      return;
    }

    // Pour les patientes, vérifier le type de suivi
    final prefs = await SharedPreferences.getInstance();
    final suiviType = prefs.getString('suiviType') ?? 'prenatal';
    
    if (suiviType == 'prenatal') {
      Navigator.pushReplacementNamed(context, AppRoutes.patienteDashboard);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.patienteDashboardPostnatal);
    }
  }

  void _onNavBarItemTapped(int index) {
    if (_bottomNavIndex == index) return;
    
    if (widget.isPatiente) {
      // Navigation pour les patientes
      switch (index) {
        case 0:
          _navigateToDashboard();
          break;
        case 1:
          Navigator.pushReplacementNamed(context, AppRoutes.patienteContent);
          break;
        case 2:
          Navigator.pushReplacementNamed(context, AppRoutes.patientePersonnel);
          break;
        case 3:
          // Already on this page
          break;
      }
    } else {
      // Navigation pour les professionnels
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, AppRoutes.proDashboard);
          break;
        case 1:
          Navigator.pushReplacementNamed(context, AppRoutes.proPatientes);
          break;
        case 2:
          Navigator.pushReplacementNamed(context, AppRoutes.proAccompagnements);
          break;
        case 3:
          // Already on this page
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            _navigateToDashboard();
          },
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Paramètres',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE91E63).withOpacity(0.63),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildProfileCard(),
              const SizedBox(height: 24),
              _buildNotificationsTile(),
              const SizedBox(height: 16),
              _buildLogoutTile(),
                    const Spacer(),
                    _buildDeleteButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: widget.isPatiente 
        ? BottomNavBar(
            selectedIndex: _bottomNavIndex,
            onItemTapped: _onNavBarItemTapped,
          )
        : ProBottomNavBar(
            selectedIndex: _bottomNavIndex,
            onItemSelected: _onNavBarItemTapped,
          ),
    );
  }

  Widget _buildProfileCard() {
    final nom = _userProfile?['nom'] ?? '';
    final prenom = _userProfile?['prenom'] ?? '';
    final fullName = '$prenom $nom'.trim();
    final roleString = _userProfile?['role'] ?? '';
    
    // Générer les initiales
    String initials = '';
    if (prenom.isNotEmpty) {
      initials += prenom[0].toUpperCase();
    }
    if (nom.isNotEmpty) {
      initials += nom[0].toUpperCase();
    }
    if (initials.isEmpty) {
      initials = 'U'; // User par défaut
    }
    
    String roleDisplay = '';
    try {
      final role = RoleUtilisateur.fromJson(roleString);
      switch (role) {
        case RoleUtilisateur.PATIENTE:
          roleDisplay = 'Patiente';
          break;
        case RoleUtilisateur.MEDECIN:
          roleDisplay = 'Médecin';
          break;
        case RoleUtilisateur.ADMINISTRATEUR:
          roleDisplay = 'Administrateur';
          break;
      }
    } catch (e) {
      roleDisplay = roleString;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: const Color(0xFFE91E63).withOpacity(0.63),
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName.isNotEmpty ? fullName : 'Utilisateur',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  roleDisplay.isNotEmpty ? roleDisplay : 'Rôle non défini',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Naviguer vers la page de profil appropriée
              final route = widget.isPatiente 
                  ? AppRoutes.patienteProfile 
                  : AppRoutes.proProfile;
              Navigator.pushNamed(
                context,
                route,
              ).then((_) {
                // Rafraîchir les données après modification
                _loadUserProfile();
              });
            },
            icon: Icon(Icons.edit_outlined, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: const Icon(Icons.notifications_outlined, color: Colors.black),
        title: const Text('Notifications'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showNotificationSettings(context);
        },
      ),
    );
  }

  Widget _buildLogoutTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: _isLoggingOut
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.logout, color: Colors.black),
        title: const Text('Déconnexion'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: _isLoggingOut
            ? null
            : () {
                _showLogoutConfirmation();
              },
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleLogout();
              },
              child: const Text(
                'Déconnexion',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      // Appeler le service de déconnexion pour nettoyer le token
      await _authService.logout();

      if (!mounted) return;

      // Naviguer vers la page de connexion appropriée
      if (widget.isPatiente) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.proLogin,
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoggingOut = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la déconnexion: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          _showDeleteAccountConfirmation();
        },
        style: TextButton.styleFrom(
          backgroundColor: Colors.grey[200],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          'Supprimer mon compte',
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      ),
    );
  }

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Supprimer mon compte',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            '⚠️ Cette action est irréversible.\n\n'
            'Toutes vos données seront définitivement supprimées :\n'
            '• Votre profil\n'
            '• Vos consultations\n'
            '• Vos messages\n'
            '• Toutes vos informations\n\n'
            'Êtes-vous absolument sûr de vouloir continuer ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleDeleteAccount();
              },
              child: const Text(
                'Supprimer définitivement',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleDeleteAccount() async {
    // Afficher un dialogue de confirmation supplémentaire
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Dernière confirmation',
            style: TextStyle(color: Colors.red),
          ),
          content: const Text(
            'Cette action ne peut pas être annulée. Voulez-vous vraiment supprimer votre compte ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Non, annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Oui, supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final response = await _profilService.deleteAccount();

      if (!mounted) return;

      Navigator.of(context).pop(); // Fermer l'indicateur de chargement

      if (response.success) {
        // Naviguer vers la page de connexion appropriée
        if (widget.isPatiente) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.proLogin,
            (route) => false,
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Votre compte a été supprimé avec succès'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Erreur lors de la suppression du compte'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      Navigator.of(context).pop(); // Fermer l'indicateur de chargement

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationSettingsPanel(),
    );
  }
}
