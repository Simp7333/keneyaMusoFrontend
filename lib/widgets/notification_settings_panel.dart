import 'package:flutter/material.dart';

class NotificationSettingsPanel extends StatefulWidget {
  const NotificationSettingsPanel({super.key});

  @override
  State<NotificationSettingsPanel> createState() =>
      _NotificationSettingsPanelState();
}

class _NotificationSettingsPanelState extends State<NotificationSettingsPanel> {
  bool _remindersEnabled = true;
  bool _soundEnabled = true;
  bool _showNotificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Notifications',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          _buildSettingsRow('Rappels', _remindersEnabled, (value) {
            setState(() {
              _remindersEnabled = value;
            });
          }),
          const SizedBox(height: 16),
          _buildSettingsRow('Son', _soundEnabled, (value) {
            setState(() {
              _soundEnabled = value;
            });
          }),
          const SizedBox(height: 16),
          _buildSettingsRow('Afficher les notifications', _showNotificationsEnabled,
              (value) {
            setState(() {
              _showNotificationsEnabled = value;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildSettingsRow(
      String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFFE91E63).withOpacity(0.63),
            activeColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
