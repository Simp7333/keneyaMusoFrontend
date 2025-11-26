import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/rappel.dart';
import '../services/dashboard_service.dart';
import '../pages/common/app_colors.dart';

/// Dialogue de confirmation pour un rappel de consultation
class ConfirmationRappelDialog extends StatefulWidget {
  final Rappel rappel;
  final VoidCallback? onConfirmed;
  final VoidCallback? onReprogrammed;

  const ConfirmationRappelDialog({
    super.key,
    required this.rappel,
    this.onConfirmed,
    this.onReprogrammed,
  });

  @override
  State<ConfirmationRappelDialog> createState() => _ConfirmationRappelDialogState();
}

class _ConfirmationRappelDialogState extends State<ConfirmationRappelDialog> {
  final DashboardService _dashboardService = DashboardService();
  bool _isProcessing = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Extraire la date prévue depuis le message si possible
    _extractDateFromMessage();
  }

  void _extractDateFromMessage() {
    // Le message contient généralement "le DD/MM/YYYY"
    final message = widget.rappel.message;
    final datePattern = RegExp(r'(\d{2}/\d{2}/\d{4})');
    final match = datePattern.firstMatch(message);
    if (match != null) {
      try {
        _selectedDate = DateFormat('dd/MM/yyyy').parse(match.group(1)!);
      } catch (e) {
        // Si le parsing échoue, utiliser la date d'aujourd'hui + 1 jour par défaut
        _selectedDate = DateTime.now().add(const Duration(days: 1));
      }
    } else {
      _selectedDate = DateTime.now().add(const Duration(days: 1));
    }
  }

  Future<void> _confirmerRappel() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final response = await _dashboardService.confirmerRappel(widget.rappel.id);

      if (!mounted) return;

      if (response.success) {
        if (widget.onConfirmed != null) {
          widget.onConfirmed!();
        }
        Navigator.of(context).pop(true); // true = confirmé
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consultation confirmée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Erreur lors de la confirmation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _reprogrammerRappel() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une date'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final response = await _dashboardService.reprogrammerRappel(widget.rappel.id, dateStr);

      if (!mounted) return;

      if (response.success) {
        if (widget.onReprogrammed != null) {
          widget.onReprogrammed!();
        }
        Navigator.of(context).pop(false); // false = reprogrammé
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Consultation reprogrammée au ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Erreur lors de la reprogrammation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: AppColors.primaryPink,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Confirmer votre consultation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.rappel.message,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            const Text(
              'Que souhaitez-vous faire ?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Bouton Confirmer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _confirmerRappel,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirmer la consultation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Section Reprogrammer
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Ou reprogrammer à une autre date :',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            // Sélecteur de date
            InkWell(
              onTap: _isProcessing ? null : () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate != null
                          ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                          : 'Sélectionner une date',
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectedDate != null ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    const Icon(Icons.calendar_today, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isProcessing ? null : _reprogrammerRappel,
                icon: const Icon(Icons.schedule),
                label: const Text('Reprogrammer'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryPink,
                  side: BorderSide(color: AppColors.primaryPink),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}

