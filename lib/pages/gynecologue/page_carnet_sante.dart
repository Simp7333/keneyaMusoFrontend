import 'package:flutter/material.dart';
import 'package:keneya_muso/pages/common/app_colors.dart';

class PageCarnetSante extends StatefulWidget {
  const PageCarnetSante({super.key});

  @override
  State<PageCarnetSante> createState() => _PageCarnetSanteState();
}

class _PageCarnetSanteState extends State<PageCarnetSante> {
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildPeriodicExamsTable(),
            const SizedBox(height: 16),
            _buildSectionTitle('Soins curatifs'),
            _buildInputLine(),
            _buildInputLine(),
            _buildInputLine(),
            _buildInputLine(),
            const SizedBox(height: 16),
            _buildSectionTitle('Examens du 9ème Mois'),
            _buildSubSectionTitle('ETAT GENERAL'),
            _buildCheckboxSection('Etat des conjonctives', ['Colorées', 'Pales', 'Jaunes']),
            _buildLabeledInputLine(label: 'Poids actuel:'),
            _buildLabeledInputLine(label: 'Gain de poids depuis début de grossesse:'),
            _buildTrippleInputRow(),
            const SizedBox(height: 16),
            _buildSubSectionTitle('EXAMEN OBSTETRICAL'),
            _buildLabeledInputLine(label: 'INSPECTION PALPATION'),
            _buildLabeledInputLine(label: 'TV'),
            _buildLabeledInputLine(label: 'Etat du col'),
            _buildLabeledInputLine(label: 'Presentation'),
            _buildLabeledInputLine(label: 'Etat du bassin:   Atteinte du promontoire'),
            _buildLabeledInputLine(label: 'Oui en cm'),
            _buildLabeledInputLine(label: 'Non'),
            const SizedBox(height: 16),
            _buildLabeledInputLine(label: 'Recommandations en prévision de l\'accouchement'),
            _buildInputLine(),
            _buildInputLine(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Soumettre'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text('Republique du Mali', style: TextStyle(fontSize: 12)),
          const Text('Un peuple - un but - une fois', style: TextStyle(fontSize: 12)),
          const Divider(height: 20),
          const Text('MINISTERE DE LA SANTE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          const Text('DIRECTION NATIONALE DE SANTE', style: TextStyle(fontSize: 12)),
          const Text('DIVISION DE LA SANTE DE LA REPRODUCTION', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.grey[200],
            child: const Text('CARNET de SANTE de la MERE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodicExamsTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: Text('Examens périodiques', style: TextStyle(fontWeight: FontWeight.bold))),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            border: TableBorder.all(color: Colors.grey),
            defaultColumnWidth: const IntrinsicColumnWidth(),
            children: [
              const TableRow(children: [
                Padding(padding: EdgeInsets.all(8.0), child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8.0), child: Text('Age Grossesse', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8.0), child: Text('Poids', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8.0), child: Text('T.A', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8.0), child: Text('H.U', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8.0), child: Text('M.F', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8.0), child: Text('BDC', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8.0), child: Text('OEdème', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8.0), child: Text('Alb.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8.0), child: Text('Etat CoL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8.0), child: Text('T.V', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8.0), child: Text('Observations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8.0), child: Text('R.V.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              ]),
              ...List.generate(4, (index) => TableRow(children: List.generate(13, (i) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: TextField(decoration: InputDecoration(border: InputBorder.none)),
              )))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

    Widget _buildSubSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
    );
  }

  Widget _buildInputLine() {
    return TextField(
      decoration: InputDecoration(
        border: const UnderlineInputBorder(
          borderSide: BorderSide(style: BorderStyle.solid, color: Colors.grey),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(style: BorderStyle.solid, color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(style: BorderStyle.solid, color: AppColors.primaryPink.withOpacity(0.63)),
        ),
      ),
    );
  }

  Widget _buildLabeledInputLine({required String label}) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(child: _buildInputLine()),
      ],
    );
  }
  
  Widget _buildTrippleInputRow() {
    return Row(
      children: [
        const Text('T.A:'),
        const SizedBox(width: 4),
        Expanded(child: _buildInputLine()),
        const SizedBox(width: 16),
        const Text('OEdème:'),
        const SizedBox(width: 4),
        Expanded(child: _buildInputLine()),
        const SizedBox(width: 16),
        const Text('Albumine:'),
        const SizedBox(width: 4),
        Expanded(child: _buildInputLine()),
      ],
    );
  }

  Widget _buildCheckboxSection(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: options.map((option) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(value: false, onChanged: (v) {}),
              Text(option),
            ],
          )).toList(),
        ),
      ],
    );
  }
}
