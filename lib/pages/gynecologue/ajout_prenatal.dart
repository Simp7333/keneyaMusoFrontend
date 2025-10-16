import 'package:flutter/material.dart';
import 'package:keneya_muso/pages/common/app_colors.dart';
import 'package:intl/intl.dart';

class AjoutPrenatalPage extends StatefulWidget {
  const AjoutPrenatalPage({super.key});

  @override
  State<AjoutPrenatalPage> createState() => _AjoutPrenatalPageState();
}

class _AjoutPrenatalPageState extends State<AjoutPrenatalPage> {
  final _formKey = GlobalKey<FormState>();

  // State variables for radio buttons
  String? _complicationsGrossesse;
  String? _mouvementsBebe;
  String? _medicamentsVitamines;
  String? _maladiesChroniques;
  String? _vaccinVAT;
  String? _moustiquaire;
  String? _suiviAnterieur;

  // State variable for checkboxes
  final Map<String, bool> _symptomes = {
    'nausées fortes': false,
    'douleurs': false,
    'maux de tête': false,
    'gonflements': false,
    'saignements': false,
    'Autre': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Formulaire de suivi prenatal',
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
              _buildTextField(label: 'Age:'),
              _buildTextField(label: 'Téléphone:'),
              _buildTextField(label: 'Taille:'),
              _buildTextField(label: 'Poids:'),
              _buildDateField(label: 'Date de vos dernières règles/(ou) Nombre de mois:'),
              _buildDateField(label: 'Date du dernier contrôle ou échographie:'),
              _buildDropdownField(label: 'Groupe sanguin:', items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']),
              const SizedBox(height: 24),
              _buildRadioGroup(
                question: 'Avez-vous déjà eu des complications dans cette grossesse ?',
                options: ['Oui', 'Non'],
                groupValue: _complicationsGrossesse,
                onChanged: (value) => setState(() => _complicationsGrossesse = value),
              ),
              _buildRadioGroup(
                question: 'Sentez-vous régulièrement les mouvements du bébé ?',
                options: ['Oui', 'Non'],
                groupValue: _mouvementsBebe,
                onChanged: (value) => setState(() => _mouvementsBebe = value),
              ),
              _buildCheckboxGroup(
                question: 'Avez-vous des symptômes particuliers ?',
                options: _symptomes.keys.toList(),
                values: _symptomes,
              ),
              _buildRadioGroup(
                question: 'Prenez-vous actuellement des médicaments ou vitamines ?',
                options: ['Oui', 'Non'],
                groupValue: _medicamentsVitamines,
                onChanged: (value) => setState(() => _medicamentsVitamines = value),
              ),
              _buildRadioGroup(
                question: 'Avez-vous déjà eu des maladies comme l’hypertension, le diabète ou l’anémie ?',
                options: ['Oui', 'Non'],
                groupValue: _maladiesChroniques,
                onChanged: (value) => setState(() => _maladiesChroniques = value),
              ),
              _buildRadioGroup(
                question: 'Avez-vous reçu le vaccin antitétanique (VAT) ?',
                options: ['Oui', 'Non', 'Je ne sais pas'],
                groupValue: _vaccinVAT,
                onChanged: (value) => setState(() => _vaccinVAT = value),
              ),
              _buildRadioGroup(
                question: 'Dormez-vous sous une moustiquaire imprégnée ?',
                options: ['Oui', 'Non'],
                groupValue: _moustiquaire,
                onChanged: (value) => setState(() => _moustiquaire = value),
              ),
              _buildRadioGroup(
                question: 'Avez-vous déjà été suivie par une sage-femme ou un médecin ?',
                options: ['Oui', 'Non'],
                groupValue: _suiviAnterieur,
                onChanged: (value) => setState(() => _suiviAnterieur = value),
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
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
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
}
