import 'package:flutter/material.dart';
import 'package:keneya_muso/pages/common/page_modifier_profil.dart';
import 'package:keneya_muso/services/profil_service.dart';

class PageProfil extends StatefulWidget {
  const PageProfil({super.key});

  @override
  State<PageProfil> createState() => _PageProfilState();
}

class _PageProfilState extends State<PageProfil> {
  final ProfilService _profilService = ProfilService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _nom = '';
  String _prenom = '';

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profileData = await _profilService.getCurrentUserProfile();
      setState(() {
        _nom = profileData['nom'] ?? '';
        _prenom = profileData['prenom'] ?? '';
        _nameController.text = '$_prenom $_nom'.trim().isEmpty 
            ? 'Non renseigné' 
            : '$_prenom $_nom'.trim();
        _phoneController.text = profileData['telephone'] ?? 'Non renseigné';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _nameController.text = 'Erreur de chargement';
        _phoneController.text = '';
        _isLoading = false;
      });
    }
  }
  
  String _getInitials() {
    String initials = '';
    if (_prenom.isNotEmpty) {
      initials += _prenom[0].toUpperCase();
    }
    if (_nom.isNotEmpty) {
      initials += _nom[0].toUpperCase();
    }
    if (initials.isEmpty) {
      initials = 'U';
    }
    return initials;
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
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Profil',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfileData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: const Color(0xFFE91E63).withOpacity(0.63),
                      child: Text(
                        _getInitials(),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PageModifierProfil()),
                        );
                        // Rafraîchir les données si le profil a été modifié
                        if (result == true) {
                          _loadProfileData();
                        }
                      },
                      child: const Text(
                        'Modifier',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildTextField('Nom et prénom', _nameController, enabled: false),
                    const SizedBox(height: 24),
                    _buildTextField('Numéro de téléphone', _phoneController, enabled: false),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: enabled ? Colors.grey[100] : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
