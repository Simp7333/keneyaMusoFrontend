import 'package:flutter/material.dart';
import 'package:keneya_muso/pages/common/app_colors.dart';
import 'package:intl/intl.dart';

class AjoutEnfantPage extends StatefulWidget {
  const AjoutEnfantPage({super.key});

  @override
  State<AjoutEnfantPage> createState() => _AjoutEnfantPageState();
}

class _AjoutEnfantPageState extends State<AjoutEnfantPage> {
  final _formKey = GlobalKey<FormState>();

  // State variables for radio buttons
  String? _sexe;
  String? _allaitementMaternel;
  String? _complicationsNaissance;
  String? _vaccinationsFaites;
  String? _developpementNormal;
  String? _problemesSante;

  // State variable for checkboxes
  final Map<String, bool> _symptomes = {
    'fièvre': false,
    'diarrhée': false,
    'vomissements': false,
    'difficultés respiratoires': false,
    'perte d\'appétit': false,
    'irritabilité': false,
    'Autre': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Formulaire d\'ajout d\'enfant',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Text(
            'Veuillez remplir correctement ce formulaire',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(label: 'Nom de l\'enfant:'),
              _buildTextField(label: 'Prénom de l\'enfant:'),
              _buildTextField(label: 'Nom de la mère:'),
              _buildTextField(label: 'Téléphone de la mère:'),
              _buildDateField(label: 'Date de naissance:'),
              _buildDropdownField(label: 'Sexe:', items: ['Masculin', 'Féminin']),
              _buildTextField(label: 'Poids de naissance (kg):'),
              _buildTextField(label: 'Taille de naissance (cm):'),
              const SizedBox(height: 24),
              _buildRadioGroup(
                question: 'Sexe de l\'enfant ?',
                options: ['Masculin', 'Féminin'],
                groupValue: _sexe,
                onChanged: (value) => setState(() => _sexe = value),
              ),
              _buildRadioGroup(
                question: 'L\'enfant est-il allaité au sein ?',
                options: ['Oui', 'Non', 'Mixte (sein + lait artificiel)'],
                groupValue: _allaitementMaternel,
                onChanged: (value) => setState(() => _allaitementMaternel = value),
              ),
              _buildRadioGroup(
                question: 'Y a-t-il eu des complications à la naissance ?',
                options: ['Oui', 'Non'],
                groupValue: _complicationsNaissance,
                onChanged: (value) => setState(() => _complicationsNaissance = value),
              ),
              _buildCheckboxGroup(
                question: 'L\'enfant présente-t-il des symptômes particuliers ?',
                options: _symptomes.keys.toList(),
                values: _symptomes,
              ),
              _buildRadioGroup(
                question: 'Avez-vous fait les vaccinations de base (BCG, DTaP) ?',
                options: ['Oui', 'Non', 'Partiellement'],
                groupValue: _vaccinationsFaites,
                onChanged: (value) => setState(() => _vaccinationsFaites = value),
              ),
              _buildRadioGroup(
                question: 'Le développement de l\'enfant est-il normal ?',
                options: ['Oui', 'Non', 'À surveiller'],
                groupValue: _developpementNormal,
                onChanged: (value) => setState(() => _developpementNormal = value),
              ),
              _buildRadioGroup(
                question: 'L\'enfant a-t-il des problèmes de santé particuliers ?',
                options: ['Oui', 'Non'],
                groupValue: _problemesSante,
                onChanged: (value) => setState(() => _problemesSante = value),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Process data
                      _showSuccessDialog();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: AppColors.primaryPink,
                  ),
                  child: const Text('Enregistrer l\'enfant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryPink),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({required String label}) {
    final controller = TextEditingController();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
          );
          if (pickedDate != null) {
            String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
            controller.text = formattedDate;
          }
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryPink),
          ),
          suffixIcon: Icon(Icons.calendar_today, color: AppColors.primaryPink),
        ),
      ),
    );
  }

  Widget _buildDropdownField({required String label, required List<String> items}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryPink),
          ),
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (_) {},
      ),
    );
  }

  Widget _buildRadioGroup({
    required String question,
    required List<String> options,
    required String? groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 8),
          Row(
            children: options.map((option) => Expanded(
              child: RadioListTile<String>(
                title: Text(option, style: const TextStyle(fontSize: 14)),
                value: option,
                groupValue: groupValue,
                onChanged: onChanged,
                activeColor: AppColors.primaryPink,
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCheckboxGroup({
    required String question,
    required List<String> options,
    required Map<String, bool> values,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 0.0,
            runSpacing: 0.0,
            children: options.map((option) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: values[option],
                  onChanged: (value) {
                    setState(() {
                      values[option] = value!;
                    });
                  },
                  activeColor: AppColors.primaryPink,
                ),
                Text(option, style: const TextStyle(fontSize: 14)),
              ],
            )).toList(),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Succès'),
          content: const Text('L\'enfant a été ajouté avec succès !'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la dialog
                Navigator.of(context).pop(); // Retourner à la page précédente
              },
              child: Text(
                'OK',
                style: TextStyle(color: AppColors.primaryPink),
              ),
            ),
          ],
        );
      },
    );
  }
}
