import 'package:flutter/material.dart';
import 'package:keneya_muso/pages/common/app_colors.dart';

class PageDiscussion extends StatelessWidget {
  const PageDiscussion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildDateSeparator('Jeu. 11 sept.'),
                _buildMessageBubble(context, 'Bonjour Mme diallo comment allez vous aujourdhui', '12:03', isMe: true),
                _buildMessageBubble(context, 'Bonjour docteur Bien et vous', '12:03', isMe: false),
                _buildMessageBubble(context, 'Votre prochaine rendez-vous est le mardi 10 novembre', '12:03', isMe: true),
                _buildMessageBubble(context, 'Insha\'Allah', '12:03', isMe: false),
                _buildImageMessage('assets/images/D2.jpg', '12:03', isMe: true),
                _buildAudioMessage('1:05', '12:03', isMe: true),
              ],
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryPink.withOpacity(0.63),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Row(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage('assets/images/D1.jpg'),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Awa diarra', style: TextStyle(color: Colors.white, fontSize: 16)),
              Text('En ligne', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(String date) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, String text, String time, {required bool isMe}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryPink.withOpacity(0.63) : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(0),
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(child: Text(text, style: TextStyle(color: isMe ? Colors.white : Colors.black))),
            const SizedBox(width: 8),
            Text(time, style: TextStyle(color: isMe ? Colors.white70 : Colors.black54, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildImageMessage(String imageUrl, String time, {required bool isMe}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: const BoxConstraints(maxWidth: 250),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(imageUrl),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 8),
              child: Text(time, style: const TextStyle(color: Colors.black54, fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioMessage(String duration, String time, {required bool isMe}) {
    // Placeholder for audio wave form
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 250,
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryPink.withOpacity(0.63) : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(0),
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(20),
          ),
        ),
        child: Row(
          children: [
            if (isMe)
              const CircleAvatar(
                  radius: 15,
                  backgroundImage: AssetImage('assets/images/D1.jpg')),
            const SizedBox(width: 8),
            Icon(Icons.play_arrow, color: isMe ? Colors.white : Colors.black),
            const SizedBox(width: 8),
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  _buildWaveform(isMe),
                  Positioned(
                    left: 20,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isMe ? Colors.white : Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(duration, style: TextStyle(color: isMe ? Colors.white70 : Colors.black54, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveform(bool isMe) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(
        30,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 1),
          width: 2,
          height: (index % 5 + 1) * 4.0,
          decoration: BoxDecoration(
            color: isMe ? Colors.white54 : Colors.grey[600],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      color: Colors.grey[100],
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Votre message...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.mic, color: AppColors.primaryPink),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt, color: AppColors.primaryPink),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
