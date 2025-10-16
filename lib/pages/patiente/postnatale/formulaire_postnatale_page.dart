import 'package:flutter/material.dart';
import 'package:keneya_muso/routes.dart';

class FormulairePostnatalePage extends StatefulWidget {
  const FormulairePostnatalePage({super.key});

  @override
  State<FormulairePostnatalePage> createState() =>
      _FormulairePostnatalePageState();
}

class _FormulairePostnatalePageState extends State<FormulairePostnatalePage> {
  final _dateController = TextEditingController();

  // State for checkboxes
  Map<String, bool> accouchementType = {'Normal': false, 'Césarienne': false};
  Map<String, bool> nombreEnfants = {
    '1er': false,
    '2e': false,
    '3e': false,
    'Plus': false
  };
  Map<String, bool> sentiment = {
    'Bien': false,
    'Fatiguée': false,
    'Douleurs': false,
    'Fièvre': false
  };
  Map<String, bool> saignements = {'Oui': false, 'Non': false};
  Map<String, bool> consultation = {
    'Non': false,
    'Oui,CPON1': false,
    'Oui,CPON2': false,
    'Oui,CPON3': false,
    'Oui,CPON4': false
  };
  Map<String, bool> sexeBebe = {'Fille': false, 'Garçon': false};
  Map<String, bool> alimentation = {'Allaitement': false, 'Biberon': false};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Image.asset(
              'assets/images/postnat.jpg',
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.45,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: 16,
            right: 16,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, -5),
                  )
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Formulaire postnatal',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('1. Informations sur la maman'),
                    const SizedBox(height: 16),
                    _buildDateInput(),
                    const SizedBox(height: 16),
                    _buildCheckboxGroup('Type d\'accouchement', accouchementType),
                    const SizedBox(height: 16),
                    _buildCheckboxGroup('Nombre d\'enfants', nombreEnfants),
                    const SizedBox(height: 16),
                    _buildCheckboxGroup(
                        'Comment vous sentez-vous actuellement ?', sentiment),
                    const SizedBox(height: 16),
                    _buildCheckboxGroup(
                        'Avez-vous encore des saignements ou douleurs ?',
                        saignements),
                    const SizedBox(height: 16),
                    _buildCheckboxGroup(
                        'Avez-vous déjà fait une consultation postnatale ?',
                        consultation),
                    const SizedBox(height: 24),
                    _buildSectionTitle('2. Informations sur le bébé'),
                    const SizedBox(height: 16),
                    _buildCheckboxGroup('Sexe du bébé', sexeBebe),
                    const SizedBox(height: 16),
                    _buildCheckboxGroup('Mode d\'alimentation', alimentation),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.patienteDashboardPostnatal,
                          );
                        },
                        child: const Text(
                          'Enregistrer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  Widget _buildDateInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date d\'accouchement:',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        TextField(
          controller: _dateController,
          decoration: const InputDecoration(
            hintText: ' ',
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE91E63)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxGroup(String question, Map<String, bool> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10.0,
          runSpacing: 0.0,
          children: options.keys.map((String key) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: options[key],
                  onChanged: (bool? value) {
                    setState(() {
                      options[key] = value!;
                    });
                  },
                  activeColor: const Color(0xFFE91E63).withOpacity(0.9),
                ),
                Text(key),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
