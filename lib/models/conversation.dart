/// Modèle pour une conversation
class Conversation {
  final int id;
  final String titre;
  final bool active;
  final int nombreMessages;
  final DateTime? dateCreation;
  final DateTime? dateModification;
  final String? medecinNom;
  final String? medecinPrenom;
  final String? medecinImageUrl;
  final int? medecinId;

  Conversation({
    required this.id,
    required this.titre,
    required this.active,
    this.nombreMessages = 0,
    this.dateCreation,
    this.dateModification,
    this.medecinNom,
    this.medecinPrenom,
    this.medecinImageUrl,
    this.medecinId,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    // Extraire les informations du médecin depuis le titre ou les participants si disponibles
    String? medecinNom;
    String? medecinPrenom;
    int? medecinId;
    String? medecinImageUrl;
    
    // Le titre est au format "Chat: Prenom Nom ↔ Dr. Prenom Nom"
    // On peut extraire le nom du médecin depuis le titre
    final titre = json['titre'] as String? ?? '';
    if (titre.contains('↔')) {
      final parts = titre.split('↔');
      if (parts.length > 1) {
        final medecinPart = parts[1].trim();
        // Format: "Dr. Prenom Nom"
        if (medecinPart.startsWith('Dr.')) {
          final namePart = medecinPart.substring(3).trim();
          final nameParts = namePart.split(' ');
          if (nameParts.length >= 2) {
            medecinPrenom = nameParts[0];
            medecinNom = nameParts.sublist(1).join(' ');
          }
        }
      }
    }

    // Si les participants sont disponibles dans la réponse (même si @JsonIgnore, parfois ils sont inclus)
    if (json['participants'] != null) {
      final participants = json['participants'] as List<dynamic>?;
      if (participants != null) {
        for (var participant in participants) {
          final p = participant as Map<String, dynamic>;
          final role = p['role'] as String?;
          // Chercher le professionnel de santé (médecin)
          if (role != null && (role.contains('MEDECIN') || role.contains('PROFESSIONNEL'))) {
            medecinId = p['id'] as int?;
            medecinNom = p['nom'] as String?;
            medecinPrenom = p['prenom'] as String?;
            medecinImageUrl = p['imageUrl'] as String?;
            break;
          }
        }
      }
    }

    return Conversation(
      id: json['id'] as int? ?? (json['id'] as num?)?.toInt() ?? 0,
      titre: titre,
      active: json['active'] as bool? ?? true,
      nombreMessages: json['nombreMessages'] as int? ?? 
                      (json['messages'] != null ? (json['messages'] as List).length : 0),
      dateCreation: json['dateCreation'] != null 
          ? DateTime.parse(json['dateCreation'] as String)
          : null,
      dateModification: json['dateModification'] != null
          ? DateTime.parse(json['dateModification'] as String)
          : null,
      medecinNom: medecinNom,
      medecinPrenom: medecinPrenom,
      medecinImageUrl: medecinImageUrl ?? json['medecinImageUrl'] as String?,
      medecinId: medecinId,
    );
  }

  String get medecinFullName {
    if (medecinPrenom != null && medecinNom != null) {
      return '$medecinPrenom $medecinNom';
    }
    // Fallback: extraire depuis le titre
    final titre = this.titre;
    if (titre.contains('↔')) {
      final parts = titre.split('↔');
      if (parts.length > 1) {
        final medecinPart = parts[1].trim();
        if (medecinPart.startsWith('Dr.')) {
          return medecinPart.substring(3).trim();
        }
        return medecinPart;
      }
    }
    return 'Médecin';
  }
}

