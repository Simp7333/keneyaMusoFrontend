import 'package:flutter/material.dart';
import '../models/consultation_postnatale.dart';
import '../models/vaccination.dart';
import '../models/rappel.dart';

/// Calendrier postnatale dynamique avec intégration backend
/// Affiche les CPoN (consultations postnatales), vaccinations et prises de médicaments
class CalendarPostnatale extends StatefulWidget {
  final List<ConsultationPostnatale> consultations;
  final List<Vaccination> vaccinations;
  final List<Rappel> rappels; // Pour les prises de médicaments
  
  const CalendarPostnatale({
    super.key,
    this.consultations = const [],
    this.vaccinations = const [],
    this.rappels = const [],
  });

  @override
  State<CalendarPostnatale> createState() => _CalendarPostnataleState();
}

class _CalendarPostnataleState extends State<CalendarPostnatale> {
  DateTime _currentMonth = DateTime.now();
  
  void _changeMonth(int delta) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + delta,
        1,
      );
    });
  }
  
  /// Regroupe tous les événements par jour
  Map<int, List<_EventMarker>> _groupEventsByDay() {
    Map<int, List<_EventMarker>> grouped = {};
    
    // Ajouter les consultations postnatales (CPoN)
    for (var consultation in widget.consultations) {
      try {
        DateTime date = DateTime.parse(consultation.datePrevue);
        
        if (date.year == _currentMonth.year && 
            date.month == _currentMonth.month) {
          if (!grouped.containsKey(date.day)) {
            grouped[date.day] = [];
          }
          grouped[date.day]!.add(_EventMarker(
            type: _EventType.consultation,
            title: consultation.typeLabel,
            color: Colors.blue,
            icon: Icons.medical_services_outlined,
            subtitle: consultation.notesMere ?? 'Consultation postnatale',
            statut: consultation.statut,
          ));
        }
      } catch (e) {
        print('❌ Erreur parsing date CPoN: $e');
      }
    }
    
    // Ajouter les vaccinations
    for (var vaccination in widget.vaccinations) {
      try {
        DateTime date = DateTime.parse(vaccination.dateAffichage);
        
        if (date.year == _currentMonth.year && 
            date.month == _currentMonth.month) {
          if (!grouped.containsKey(date.day)) {
            grouped[date.day] = [];
          }
          grouped[date.day]!.add(_EventMarker(
            type: _EventType.vaccination,
            title: vaccination.nomVaccin,
            color: Colors.green,
            icon: Icons.vaccines_outlined,
            subtitle: vaccination.notes ?? 'Vaccination',
            statut: vaccination.statut,
          ));
        }
      } catch (e) {
        print('❌ Erreur parsing date vaccination: $e');
      }
    }
    
    // Ajouter tous les rappels (consultations, vaccinations, médicaments, conseils personnalisés)
    for (var rappel in widget.rappels) {
      try {
        DateTime date = DateTime.parse(rappel.displayDate);
        
        if (date.year == _currentMonth.year && 
            date.month == _currentMonth.month) {
          if (!grouped.containsKey(date.day)) {
            grouped[date.day] = [];
          }
          
          // Déterminer la couleur et l'icône selon le type de rappel
          Color rappelColor = Colors.grey;
          IconData rappelIcon = Icons.notifications_outlined;
          
          switch (rappel.type) {
            case 'RAPPEL_CONSULTATION':
              rappelColor = Colors.blue;
              rappelIcon = Icons.medical_services_outlined;
              break;
            case 'RAPPEL_VACCINATION':
              rappelColor = Colors.red;
              rappelIcon = Icons.medication_outlined;
              break;
            case 'CONSEIL':
              rappelColor = Colors.orange;
              rappelIcon = Icons.lightbulb_outline;
              break;
            case 'AUTRE':
            default:
              rappelColor = Colors.purple;
              rappelIcon = Icons.event_note;
              break;
          }
          
          grouped[date.day]!.add(_EventMarker(
            type: _EventType.medicament,
            title: rappel.titre,
            color: rappelColor,
            icon: rappelIcon,
            subtitle: rappel.message,
            statut: rappel.statut,
          ));
        }
      } catch (e) {
        print('❌ Erreur parsing date rappel: $e');
      }
    }
    
    return grouped;
  }

  /// Affiche les détails des événements d'un jour donné
  void _showDayEvents(BuildContext context, int day, List<_EventMarker> events) {
    final monthNames = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    final dateStr = '$day ${monthNames[_currentMonth.month - 1]} ${_currentMonth.year}';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // En-tête
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFCAD4).withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Événements du jour',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              dateStr,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                
                // Liste des événements
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return _buildEventCard(event);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Construit une carte pour un événement dans le popup
  Widget _buildEventCard(_EventMarker event) {
    String statutLabel = '';
    Color statutColor = Colors.grey;

    // Déterminer le label et la couleur du statut
    if (event.statut != null) {
      switch (event.statut) {
        case 'A_VENIR':
        case 'A_FAIRE':
        case 'NON_LUE':
        case 'ENVOYE':
          statutLabel = 'À venir';
          statutColor = Colors.orange;
          break;
        case 'REALISEE':
        case 'FAIT':
        case 'LUE':
          statutLabel = 'Réalisé';
          statutColor = Colors.green;
          break;
        case 'MANQUEE':
        case 'MANQUE':
          statutLabel = 'Manqué';
          statutColor = Colors.red;
          break;
        default:
          statutLabel = event.statut!;
          statutColor = Colors.grey;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: event.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: event.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(event.icon, color: event.color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (event.statut != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statutColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statutLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statutColor,
                    ),
                  ),
                ),
            ],
          ),
          if (event.subtitle != null && event.subtitle!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              event.subtitle!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final weekdayOfFirst = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday
    
    // Formater le mois sans locale
    final monthNames = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    final monthName = '${monthNames[_currentMonth.month - 1]} ${_currentMonth.year}';
    final eventsByDay = _groupEventsByDay();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFCAD4).withOpacity(0.47),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // En-tête avec navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 16),
                onPressed: () => _changeMonth(-1),
              ),
              Text(
                monthName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Jours de la semaine
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
                .map((day) => Text(day, style: const TextStyle(color: Colors.grey)))
                .toList(),
          ),
          const SizedBox(height: 8),
          
          // Grille du calendrier
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(weekdayOfFirst - 1 + daysInMonth, (index) {
              // Jours vides avant le premier du mois
              if (index < weekdayOfFirst - 1) {
                return const SizedBox.shrink();
              }
              
              int day = index - weekdayOfFirst + 2;
              List<_EventMarker>? dayEvents = eventsByDay[day];
              
              // Afficher avec icône si des événements existent
              if (dayEvents != null && dayEvents.isNotEmpty) {
                // Prioriser l'affichage: CPoN > Vaccination > Médicament
                _EventMarker primaryEvent = dayEvents.first;
                for (var event in dayEvents) {
                  if (event.type == _EventType.consultation) {
                    primaryEvent = event;
                    break;
                  } else if (event.type == _EventType.vaccination && 
                             primaryEvent.type != _EventType.consultation) {
                    primaryEvent = event;
                  }
                }
                
                return GestureDetector(
                  onTap: () => _showDayEvents(context, day, dayEvents),
                  child: Stack(
                    children: [
                      Center(
                        child: CircleAvatar(
                          backgroundColor: primaryEvent.color,
                          radius: 18,
                          child: Icon(
                            primaryEvent.icon,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      // Badge si plusieurs événements
                      if (dayEvents.length > 1)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${dayEvents.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }
              
              return Center(child: Text('$day'));
            }),
          ),
          const SizedBox(height: 16),
          
          // Légende
          const Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _LegendItem(
                color: Colors.blue,
                label: 'CPoN',
              ),
              _LegendItem(
                color: Colors.green,
                label: 'Vaccination',
              ),
              _LegendItem(
                color: Colors.red,
                label: 'Médicament',
              ),
              _LegendItem(
                color: Colors.orange,
                label: 'Conseil',
              ),
              _LegendItem(
                color: Colors.purple,
                label: 'Rappel',
              ),
            ],
          )
        ],
      ),
    );
  }
}

/// Types d'événements affichés dans le calendrier
enum _EventType {
  consultation,
  vaccination,
  medicament,
}

/// Marqueur d'événement pour le calendrier
class _EventMarker {
  final _EventType type;
  final String title;
  final Color color;
  final IconData icon;
  final String? subtitle;
  final String? statut;
  
  _EventMarker({
    required this.type,
    required this.title,
    required this.color,
    required this.icon,
    this.subtitle,
    this.statut,
  });
}

/// Widget de légende
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  
  const _LegendItem({
    required this.color,
    required this.label,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, color: color, size: 10),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
