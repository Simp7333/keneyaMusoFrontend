import 'package:flutter/material.dart';

class PageOrdonnance extends StatefulWidget {
  const PageOrdonnance({super.key});

  @override
  State<PageOrdonnance> createState() => _PageOrdonnanceState();
}

class _PageOrdonnanceState extends State<PageOrdonnance> {
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
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildPrescriptionTable(),
            const SizedBox(height: 32),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        Text('Republique du Mali', style: TextStyle(fontSize: 12)),
        Text('Un peuple - un but - une fois', style: TextStyle(fontSize: 12)),
        SizedBox(height: 8),
        Divider(thickness: 0.5),
        SizedBox(height: 8),
        Text('MINISTERE DE LA SANTE ET DU DEVELOPPEMENT SOCIAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        SizedBox(height: 8),
        Divider(thickness: 0.5),
        SizedBox(height: 8),
        Text('Region de sikasso-district sanitaire de sadiola', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
        Text('CENTRE DE SANTE COMMUNAUTAIRE(CSCOM) DE NIENA', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Text('Adresse: Quartier centre, commune de niena, cercle de kadiola', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
        SizedBox(height: 8),
        Text('Tel: (+223 93836382)', style: TextStyle(fontSize: 12)),
        SizedBox(height: 8),
        Divider(thickness: 0.5),
      ],
    );
  }

  Widget _buildPrescriptionTable() {
    return Table(
      border: TableBorder.all(color: Colors.black),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(2),
      },
      children: [
        _buildTableHeader(),
        ...List.generate(10, (index) => _buildTableRow()),
      ],
    );
  }

  TableRow _buildTableHeader() {
    return const TableRow(
      children: [
        Padding(padding: EdgeInsets.all(8.0), child: Text('Médicaments', style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.all(8.0), child: Text('Posologie', style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.all(8.0), child: Text('Durée', style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.all(8.0), child: Text('Observation', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
    );
  }

  TableRow _buildTableRow() {
    return TableRow(
      children: List.generate(4, (index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: TextField(
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
        ),
      )),
    );
  }

  Widget _buildFooter() {
    return const Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Medecin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Eunice tika'),
                  Text('Sage femme diplomée d\'etat'),
                  Text('N° d\'immatriculation : SF-0178-2024'),
                ],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Patiente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 8),
                  Text('COULIBALY Mariam'),
                  Text('Village de Finkolo-'),
                  Text('Ganadougou'),
                  Text('67 10 88 90'),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 48),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Signature / Cachet :', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('12/08/2025'),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
