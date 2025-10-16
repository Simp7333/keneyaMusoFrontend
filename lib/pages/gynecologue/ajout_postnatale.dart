import 'package:flutter/material.dart';
import 'package:keneya_muso/pages/common/app_colors.dart';

class AjoutPostnatalePage extends StatefulWidget {
  const AjoutPostnatalePage({super.key});

  @override
  State<AjoutPostnatalePage> createState() => _AjoutPostnatalePageState();
}

class _AjoutPostnatalePageState extends State<AjoutPostnatalePage> {
  final _formKey = GlobalKey<FormState>();

  // State variables for checkboxes
  final Map<String, bool> _symptomesSpecifiques = {
    'saignement': false,
    'engorgement': false,
    'fièvre': false,
    'douleurs': false,
    'Autre': false,
  };

  final Map<String, bool> _symptomesBebe = {
    'fièvre': false,
    'Vomissements': false,
    'diarrhée': false,
  };

  final Map<String, bool> _conseilsDemandes = {
    'Douleurs': false,
    'Allaitements': false,
    'Soins bébé': false,
    'Planification familiale': false,
    'Autre': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Formulaire de suivi postnatale',
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
              _buildTextField(label: 'Nom et prenom:'),
              _buildTextField(label: 'Téléphone:'),
              _buildTextField(label: 'Age:'),
              _buildTextField(label: 'Lieu:'),
              const SizedBox(height: 24),
              _buildCheckboxGroup(
                question: 'Problèmes ou symptômes spécifiques',
                options: _symptomesSpecifiques,
              ),
              _buildCheckboxGroup(
                question: 'Problèmes ou symptômes du bébé',
                options: _symptomesBebe,
              ),
              _buildCheckboxGroup(
                question: 'Type de conseil demandé',
                options: _conseilsDemandes,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Process data
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Enregistrer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  Widget _buildCheckboxGroup({
    required String question,
    required Map<String, bool> options,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: options.keys.map((option) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<String>(
                  value: option,
                  groupValue: options.entries.firstWhere((e) => e.value, orElse: () => const MapEntry('', false)).key,
                  onChanged: (value) {
                    setState(() {
                      options.updateAll((key, v) => options[key] = false);
                      options[value!] = true;
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
}

