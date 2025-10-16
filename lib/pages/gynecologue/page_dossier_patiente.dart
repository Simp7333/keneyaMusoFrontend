import 'package:flutter/material.dart';
import 'package:keneya_muso/pages/common/app_colors.dart';
import 'package:keneya_muso/pages/gynecologue/page_carnet_sante.dart';
import 'package:keneya_muso/pages/gynecologue/page_discussion.dart';
import 'package:keneya_muso/pages/gynecologue/page_ordonnance.dart';

class PageDossierPatiente extends StatelessWidget {
  const PageDossierPatiente({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PageOrdonnance()),
            );
          },
          child: CircleAvatar(
            backgroundColor: Colors.green[300],
            child: const Icon(Icons.assignment, color: Colors.white),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PageCarnetSante()),
            );
          },
          child: CircleAvatar(
            backgroundColor: Colors.blue[300],
            child: const Icon(Icons.edit, color: Colors.white),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPatientHeader(),
          const SizedBox(height: 24),
          _buildInfoRow('Nom et prenom:', 'Awa diarra'),
          _buildInfoRow('Age:', '25 ans'),
          _buildInfoRow('Téléphone:', '90 11 05 65'),
          _buildInfoRow('Taille:', '1m76'),
          _buildInfoRow('Poids:', '76kg'),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _buildInfoRow('Date de vos dernières règles/(ou) Nombre de mois:', '2mois'),
          _buildInfoRow('Date du dernier contrôle ou échographie:', '2/11/2025'),
          _buildInfoRow('Groupe sanguin:', 'O+'),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _buildRadioQuestion('Avez-vous déjà eu des complications dans cette grossesse ?'),
          _buildRadioQuestion('Sentez-vous régulièrement les mouvements du bébé ?'),
          _buildCheckboxQuestion('Avez-vous des symptômes particuliers ?', ['nausées fortes', 'douleurs', 'gonflements', 'saignements', 'maux de tête', 'Autre']),
          _buildRadioQuestion('Prenez-vous actuellement des médicaments ou vitamines ?'),
          _buildRadioQuestion('Avez-vous déjà eu des maladies comme l\'hypertension, le diabète ou l\'anémie ?'),
          _buildRadioQuestion('Avez-vous reçu le vaccin antitétanique (VAT) ?', options: ['Oui', 'Non', 'Je ne sais pas']),
          _buildRadioQuestion('Dormez-vous sous une moustiquaire imprégnée ?'),
          _buildRadioQuestion('Avez-vous déjà été suivie par une sage-femme ou un médecin ?'),
          const SizedBox(height: 80), // To make space for the FAB
        ],
      ),
    );
  }

  Widget _buildPatientHeader() {
    return Center(
      child: CircleAvatar(
        radius: 50,
        backgroundColor: AppColors.primaryPink.withOpacity(0.1),
        child: Image.asset('assets/images/D1.jpg', height: 80),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.black54))),
          const SizedBox(width: 16),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRadioQuestion(String question, {List<String> options = const ['Oui', 'Non']}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontWeight: FontWeight.w600)),
          Wrap(
            spacing: 0.0,
            runSpacing: 0.0,
            children: options.map((option) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio(value: option, groupValue: 'TODO', onChanged: (v) {}),
                Text(option),
              ],
            )).toList(),
          ),
        ],
      ),
    );
  }

    Widget _buildCheckboxQuestion(String question, List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontWeight: FontWeight.w600)),
          Wrap(
            spacing: 8.0,
            children: options.map((option) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio(value: option, groupValue: 'TODO', onChanged: (v) {}),
                Text(option),
              ],
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, '/ordonnance');
      },
      child: const Icon(Icons.add),
    );
  }
}
