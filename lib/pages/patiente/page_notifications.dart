import 'package:flutter/material.dart';

class PageNotifications extends StatelessWidget {
  const PageNotifications({super.key});

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
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader("Aujourd'hui"),
          const SizedBox(height: 16),
          _buildNotificationItem(
            imageUrl: 'assets/images/malmatou.jpg',
            title: 'Confirmation de suivi de dossier',
            subtitle:
                'Votre bébé grandit bien ! Pensez à boire beaucoup d\'eau et à bien vous reposer.',
            time: '2h',
          ),
          Divider(height: 32, color: Colors.grey.withOpacity(0.1)),
          _buildNotificationItem(
            imageUrl: 'assets/images/malmatou.jpg',
            title: 'Confirmation de suivi de dossier',
            subtitle:
                'Votre bébé grandit bien ! Pensez à boire beaucoup d\'eau et à bien vous reposer.',
            time: '2h',
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('Semaine'),
          const SizedBox(height: 16),
          _buildNotificationItem(
            imageUrl: 'assets/images/malmatou.jpg',
            title: 'Confirmation de suivi de dossier',
            subtitle:
                'Votre bébé grandit bien ! Pensez à boire beaucoup d\'eau et à bien vous reposer.',
            time: '2S',
          ),
          Divider(height: 32, color: Colors.grey.withOpacity(0.1)),
          _buildNotificationItem(
            imageUrl: 'assets/images/malmatou.jpg',
            title: 'Confirmation de suivi de dossier',
            subtitle:
                'Votre bébé grandit bien ! Pensez à boire beaucoup d\'eau et à bien vous reposer.',
            time: '2S',
          ),
          Divider(height: 32, color: Colors.grey.withOpacity(0.1)),
          _buildNotificationItem(
            imageUrl: 'assets/images/malmatou.jpg',
            title: 'Confirmation de suivi de dossier',
            subtitle:
                'Votre bébé grandit bien ! Pensez à boire beaucoup d\'eau et à bien vous reposer.',
            time: '2S',
          ),
          Divider(height: 32, color: Colors.grey.withOpacity(0.1)),
          _buildNotificationItem(
            imageUrl: 'assets/images/malmatou.jpg',
            title: 'Confirmation de suivi de dossier',
            subtitle:
                'Votre bébé grandit bien ! Pensez à boire beaucoup d\'eau et à bien vous reposer.',
            time: '2S',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildNotificationItem({
    required String imageUrl,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundImage: AssetImage(imageUrl),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Text(
          time,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
