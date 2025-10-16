import 'package:flutter/material.dart';

class CustomCalendar extends StatelessWidget {
  const CustomCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFCAD4).withOpacity(0.47),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Octobre 2025',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
                .map((day) => Text(day, style: const TextStyle(color: Colors.grey)))
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(31, (index) {
              int day = index + 1;
              if (day == 2) {
                return const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.medical_services_outlined,
                      color: Colors.white, size: 18),
                );
              }
              if (day == 17) {
                return const CircleAvatar(
                  backgroundColor: Colors.red,
                  child: Icon(Icons.medication_outlined,
                      color: Colors.white, size: 18),
                );
              }
              return Center(child: Text('$day'));
            }),
          ),
        ],
      ),
    );
  }
}
