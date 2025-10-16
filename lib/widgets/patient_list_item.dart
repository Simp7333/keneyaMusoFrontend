import 'package:flutter/material.dart';
import 'package:keneya_muso/models/patient.dart';
import 'package:keneya_muso/pages/gynecologue/page_dossier_patiente.dart';

class PatientListItem extends StatelessWidget {
  final Patient patient;
  const PatientListItem({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PageDossierPatiente()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFFEEDEE3),
              child: Image.asset(patient.imageUrl, height: 40),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(patient.age, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 4),
                Text(patient.phone, style: const TextStyle(color: Colors.black54)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
