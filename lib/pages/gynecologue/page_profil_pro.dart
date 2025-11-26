import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../services/professionnel_sante_service.dart';
import '../../models/professionnel_sante.dart';

class PageProfilPro extends StatefulWidget {
  const PageProfilPro({super.key});

  @override
  State<PageProfilPro> createState() => _PageProfilProState();
}

class _PageProfilProState extends State<PageProfilPro> {
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _phoneController;
  late TextEditingController _specialtyController;
  late TextEditingController _locationController;
  File? _image;
  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  ProfessionnelSante? _professionnel;

  final ImagePicker _picker = ImagePicker();
  final ProfessionnelSanteService _service = ProfessionnelSanteService();

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController();
    _prenomController = TextEditingController();
    _phoneController = TextEditingController();
    _specialtyController = TextEditingController();
    _locationController = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _phoneController.dispose();
    _specialtyController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _service.getCurrentProfessionnelProfile();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.success && response.data != null) {
          _professionnel = response.data;
          _nomController.text = _professionnel!.nom;
          _prenomController.text = _professionnel!.prenom;
          _phoneController.text = _professionnel!.telephone;
          _specialtyController.text = _professionnel!.specialite;
          _locationController.text = _professionnel!.centreSante ?? _professionnel!.adresse ?? '';
        } else {
          _errorMessage = response.message ?? 'Erreur lors du chargement du profil';
        }
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final response = await _service.updateProfessionnelProfile(
      nom: _nomController.text.trim(),
      prenom: _prenomController.text.trim(),
      telephone: _phoneController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isSaving = false;
        if (response.success) {
          _isEditing = false;
          _professionnel = response.data;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil mis à jour avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          _errorMessage = response.message ?? 'Erreur lors de la sauvegarde';
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null && _professionnel == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadProfile,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildProfilePicture(),
                      const SizedBox(height: 32),
                      if (_errorMessage != null && _professionnel != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      _buildInfoField(
                        label: 'Nom',
                        controller: _nomController,
                        isEditing: _isEditing,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoField(
                        label: 'Prénom',
                        controller: _prenomController,
                        isEditing: _isEditing,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoField(
                        label: 'Téléphone',
                        controller: _phoneController,
                        isEditing: _isEditing,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoField(
                        label: 'Spécialité',
                        controller: _specialtyController,
                        isEditing: false, // La spécialité n'est pas modifiable
                      ),
                      const SizedBox(height: 16),
                      _buildInfoField(
                        label: 'Localisation',
                        controller: _locationController,
                        isEditing: _isEditing,
                      ),
                      if (_isEditing) const SizedBox(height: 40),
                      if (_isEditing) _buildSaveButton(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfilePicture() {
    return Column(
      children: [
        GestureDetector(
          onTap: _isEditing ? _pickImage : null,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 70,
                backgroundColor: Colors.grey.shade100,
                backgroundImage: _image != null ? FileImage(_image!) : const AssetImage('assets/images/docP.png') as ImageProvider,
              ),
              if (_isEditing)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.black, size: 20),
                ),
            ],
          ),
        ),
        if (!_isEditing) const SizedBox(height: 12),
        if (!_isEditing)
          TextButton(
            onPressed: _toggleEditing,
            child: const Text(
              'Modifier',
              style: TextStyle(color: Colors.green, fontSize: 16),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: isEditing,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.green, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE91E63).withOpacity(0.63),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Enregistrer',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
      ),
    );
  }
}
