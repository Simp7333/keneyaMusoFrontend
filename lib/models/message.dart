/// Modèle pour les messages de chat
class Message {
  final int id;
  final String type; // TEXTE, IMAGE, AUDIO, DOCUMENT
  final String contenu;
  final String? fileUrl;
  final int conversationId;
  final int expediteurId;
  final String? expediteurNom;
  final String? expediteurPrenom;
  final String? expediteurTelephone;
  final bool lu;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.type,
    required this.contenu,
    this.fileUrl,
    required this.conversationId,
    required this.expediteurId,
    this.expediteurNom,
    this.expediteurPrenom,
    this.expediteurTelephone,
    required this.lu,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      type: json['type'] as String? ?? 'TEXTE',
      contenu: json['contenu'] as String? ?? '',
      fileUrl: json['fileUrl'] as String?,
      conversationId: json['conversationId'] as int,
      expediteurId: json['expediteurId'] as int,
      expediteurNom: json['expediteurNom'] as String?,
      expediteurPrenom: json['expediteurPrenom'] as String?,
      expediteurTelephone: json['expediteurTelephone'] as String?,
      lu: json['lu'] as bool? ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  String get expediteurFullName {
    if (expediteurPrenom != null && expediteurNom != null) {
      return '$expediteurPrenom $expediteurNom';
    }
    return expediteurNom ?? expediteurPrenom ?? 'Utilisateur';
  }

  bool get isTexte => type == 'TEXTE';
  bool get isImage => type == 'IMAGE';
  bool get isAudio => type == 'AUDIO';
  bool get isDocument => type == 'DOCUMENT';
}

