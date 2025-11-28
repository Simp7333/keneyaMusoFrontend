import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/consultation_prenatale.dart';
import '../models/consultation_postnatale.dart';
import '../models/vaccination.dart';
import '../services/consultation_service.dart';
import '../services/vaccination_service.dart';
import '../pages/common/app_colors.dart';

/// Dialogue de confirmation pour une consultation ou vaccination avec date dépassée
class ConfirmationDateDepasseeDialog extends StatefulWidget {
  final dynamic item; // ConsultationPrenatale, ConsultationPostnatale ou Vaccination
  final String type; // 'cpn', 'cpon', 'vaccination'
  final VoidCallback? onConfirmed;
  final VoidCallback? onReprogrammed;

  const ConfirmationDateDepasseeDialog({
    super.key,
    required this.item,
    required this.type,
    this.onConfirmed,
    this.onReprogrammed,
  });

  @override
  State<ConfirmationDateDepasseeDialog> createState() =>
      _ConfirmationDateDepasseeDialogState();
}

class _ConfirmationDateDepasseeDialogState
    extends State<ConfirmationDateDepasseeDialog> {
  final ConsultationService _consultationService = ConsultationService();
  final VaccinationService _vaccinationService = VaccinationService();
  bool _isProcessing = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Initialiser avec la date prévue actuelle
    _selectedDate = _getDatePrevue();
  }

  DateTime? _getDatePrevue() {
    try {
      if (widget.type == 'cpn') {
        return DateTime.parse((widget.item as ConsultationPrenatale).datePrevue);
      } else if (widget.type == 'cpon') {
        return DateTime.parse((widget.item as ConsultationPostnatale).datePrevue);
      } else if (widget.type == 'vaccination') {
        return DateTime.parse((widget.item as Vaccination).datePrevue);
      }
    } catch (e) {
      print('❌ Erreur parsing date: $e');
    }
    return DateTime.now().add(const Duration(days: 1));
  }

  String _getTitre() {
    if (widget.type == 'cpn') {
      return 'Consultation prénatale (CPN)';
    } else if (widget.type == 'cpon') {
      final cpon = widget.item as ConsultationPostnatale;
      return cpon.typeLabel;
    } else if (widget.type == 'vaccination') {
      final vacc = widget.item as Vaccination;
      return 'Vaccination: ${vacc.nomVaccin}';
    }
    return 'Consultation';
  }

  String _getDatePrevueFormatee() {
    final date = _getDatePrevue();
    if (date != null) {
      return DateFormat('dd/MM/yyyy').format(date);
    }
    return 'Date inconnue';
  }

  Future<void> _confirmer() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      bool success = false;
      String message = '';

      if (widget.type == 'cpn') {
        final cpn = widget.item as ConsultationPrenatale;
        final response = await _consultationService.confirmerConsultationPrenatale(
          cpn,
          DateFormat('yyyy-MM-dd').format(DateTime.now()),
        );
        success = response.success;
        message = response.message;
      } else if (widget.type == 'cpon') {
        final cpon = widget.item as ConsultationPostnatale;
        final response = await _consultationService.confirmerConsultationPostnatale(
          cpon,
          DateFormat('yyyy-MM-dd').format(DateTime.now()),
        );
        success = response.success;
        message = response.message;
      } else if (widget.type == 'vaccination') {
        final vacc = widget.item as Vaccination;
        final response = await _vaccinationService.confirmerVaccination(
          vacc,
          DateFormat('yyyy-MM-dd').format(DateTime.now()),
        );
        success = response.success;
        message = response.message;
      }

      if (!mounted) return;

      if (success) {
        if (widget.onConfirmed != null) {
          widget.onConfirmed!();
        }
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.isNotEmpty ? message : 'Confirmé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.isNotEmpty ? message : 'Erreur lors de la confirmation'),
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

  Future<void> _reprogrammer() async {
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
      bool success = false;
      String message = '';
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);

      if (widget.type == 'cpn') {
        final cpn = widget.item as ConsultationPrenatale;
        final response = await _consultationService.reprogrammerConsultationPrenatale(
          cpn,
          dateStr,
        );
        success = response.success;
        message = response.message;
      } else if (widget.type == 'cpon') {
        final cpon = widget.item as ConsultationPostnatale;
        final response = await _consultationService.reprogrammerConsultationPostnatale(
          cpon,
          dateStr,
        );
        success = response.success;
        message = response.message;
      } else if (widget.type == 'vaccination') {
        final vacc = widget.item as Vaccination;
        final response = await _vaccinationService.reprogrammerVaccination(
          vacc,
          dateStr,
        );
        success = response.success;
        message = response.message;
      }

      if (!mounted) return;

      if (success) {
        if (widget.onReprogrammed != null) {
          widget.onReprogrammed!();
        }
        Navigator.of(context).pop(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message.isNotEmpty
                  ? message
                  : 'Reprogrammé au ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.isNotEmpty ? message : 'Erreur lors de la reprogrammation'),
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
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Date dépassée',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              'La date prévue pour votre ${_getTitre()} était le ${_getDatePrevueFormatee()}.',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'Cette date est maintenant dépassée. Que souhaitez-vous faire ?',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            const Text(
              'Options disponibles :',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Bouton Confirmer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _confirmer,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirmer (marquer comme fait)'),
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
                onPressed: _isProcessing ? null : _reprogrammer,
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

