import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keneya_muso/services/profil_service.dart';
import 'dart:io';

class PageModifierProfil extends StatefulWidget {
  const PageModifierProfil({super.key});

  @override
  State<PageModifierProfil> createState() => _PageModifierProfilState();
}

class _PageModifierProfilState extends State<PageModifierProfil> {
  final ProfilService _profilService = ProfilService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = true;
  bool _isSaving = false;
  String _nom = '';
  String _prenom = '';

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

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profileData = await _profilService.getCurrentUserProfile();
      setState(() {
        _nom = profileData['nom'] ?? '';
        _prenom = profileData['prenom'] ?? '';
        _nameController.text = '$_prenom $_nom'.trim();
        _phoneController.text = profileData['telephone'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir le nom et prénom'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir le numéro de téléphone'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Séparer le nom et prénom
      final nameParts = _nameController.text.trim().split(' ');
      final nom = nameParts.isNotEmpty ? nameParts[0] : '';
      final prenom = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final response = await _profilService.updateProfile(
        nom: nom,
        prenom: prenom,
        telephone: _phoneController.text.trim(),
      );

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        // Retourner true pour indiquer que le profil a été modifié
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
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
          onPressed: _isSaving ? null : () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Modifier le profil',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Profile Picture with Initials
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
                        const SizedBox(height: 40),
                        // Name Field
                        _buildTextField('Nom et prénom', _nameController),
                        const SizedBox(height: 24),
                        // Phone Field
                        _buildTextField('Numéro de téléphone', _phoneController),
                      ],
                    ),
                  ),
                ),
                // Save Button at bottom
                Container(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E63).withOpacity(0.63),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Enregistrer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
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
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
