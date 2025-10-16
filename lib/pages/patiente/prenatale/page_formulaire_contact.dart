import 'package:flutter/material.dart';

class PageFormulaireContact extends StatefulWidget {
  final String sageFemmeName;

  const PageFormulaireContact({
    super.key,
    required this.sageFemmeName,
  });

  @override
  State<PageFormulaireContact> createState() => _PageFormulaireContactState();
}

class _PageFormulaireContactState extends State<PageFormulaireContact> {
  // Controllers pour les champs texte
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _tailleController = TextEditingController();
  final TextEditingController _poidsController = TextEditingController();
  final TextEditingController _dernierControleController =
      TextEditingController();

  // Variables pour les boutons radio et checkboxes
  String? _complications;
  String? _mouvementsBebe;
  final List<String> _symptomes = [];
  String? _medicaments;
  String? _maladies;

  // Variables pour les dropdowns
  String? _derniereRegles;
  String? _groupeSanguin;

  @override
  void dispose() {
    _nomController.dispose();
    _ageController.dispose();
    _telephoneController.dispose();
    _tailleController.dispose();
    _poidsController.dispose();
    _dernierControleController.dispose();
    super.dispose();
  }

  void _onSymptomChanged(String value) {
    setState(() {
      if (_symptomes.contains(value)) {
        _symptomes.remove(value);
      } else {
        _symptomes.add(value);
      }
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Align(
              alignment: Alignment.center,
              child: Text(
                'Formulaire de contact sage-femme',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Veuillez remplir correctement ce formulaire',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildTextField('Nom et prenom:', _nomController),
            _buildTextField('Age:', _ageController),
            _buildTextField('Téléphone:', _telephoneController),
            _buildTextField('Taille:', _tailleController),
            _buildTextField('Poids:', _poidsController),
            _buildDropdownField(
              'Date de vos dernières règles/(ou) Nombre de mois:',
              ['1 mois', '2 mois', '3 mois', '4 mois', '5 mois', '6 mois', '7 mois', '8 mois', '9 mois'],
              _derniereRegles,
              (value) => setState(() => _derniereRegles = value),
            ),
            _buildTextField(
                'Date du dernier contrôle ou échographie:', _dernierControleController),
            _buildDropdownField(
              'Groupe sanguin:',
              ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
              _groupeSanguin,
              (value) => setState(() => _groupeSanguin = value),
            ),
            const SizedBox(height: 16),
            _buildRadioQuestion(
              'Avez-vous déjà eu des complications dans cette grossesse ?',
              ['Oui', 'Non'],
              _complications,
              (value) => setState(() => _complications = value),
            ),
            _buildRadioQuestion(
              'Sentez-vous régulièrement les mouvements du bébé ?',
              ['Oui', 'Non'],
              _mouvementsBebe,
              (value) => setState(() => _mouvementsBebe = value),
            ),
            _buildCheckboxQuestion(
              'Avez-vous des symptômes particuliers ?',
              ['nausées fortes', 'douleurs', 'maux de tête', 'gonflements', 'saignements', 'Autre'],
              _symptomes,
              _onSymptomChanged,
            ),
            _buildRadioQuestion(
              'Prenez-vous actuellement des médicaments ou vitamines ?',
              ['Oui', 'Non'],
              _medicaments,
              (value) => setState(() => _medicaments = value),
            ),
            _buildRadioQuestion(
              'Avez-vous déjà eu des maladies comme l\'hypertension, le diabète ou l\'anémie ?',
              ['Oui', 'Non'],
              _maladies,
              (value) => setState(() => _maladies = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[700]),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[700]),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxQuestion(
    String question,
    List<String> options,
    List<String> selectedValues,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: options.map((option) {
              return _buildRadioOption(
                option,
                selectedValues.contains(option) ? option : null,
                (value) {
                  onChanged(option);
                },
                isCheckbox: true,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioQuestion(
    String question,
    List<String> options,
    String? selectedValue,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: options.map((option) {
              return Padding(
                padding: const EdgeInsets.only(right: 24.0),
                child: _buildRadioOption(option, selectedValue, onChanged),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String value, String? selectedValue,
      Function(String?) onChanged,
      {bool isCheckbox = false}) {
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selectedValue == value
                  ? const Color(0xFFE91E63).withOpacity(0.61)
                  : Colors.transparent,
              border: Border.all(color: Colors.grey[400]!),
            ),
          ),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }
}






