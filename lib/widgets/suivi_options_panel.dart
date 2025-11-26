import 'package:flutter/material.dart';

class SuiviOptionsPanel extends StatefulWidget {
  const SuiviOptionsPanel({super.key});

  @override
  State<SuiviOptionsPanel> createState() => _SuiviOptionsPanelState();
}

class _SuiviOptionsPanelState extends State<SuiviOptionsPanel> {
  String _selectedSuivi = 'Suivi Postnatal';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSuiviOption(
            icon: Icons.pregnant_woman,
            title: 'Suivi Prénatal',
          ),
          const SizedBox(height: 16),
          _buildSuiviOption(
            icon: Icons.baby_changing_station,
            title: 'Suivi Postnatal',
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to the appropriate page
                },
                child: const Text('Enregistrer un suivi'),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSuiviOption({required IconData icon, required String title}) {
    final bool isSelected = _selectedSuivi == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSuivi = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFE91E63).withOpacity(0.9)
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected
                    ? const Color(0xFFE91E63).withOpacity(0.9)
                    : Colors.black),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.black : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
