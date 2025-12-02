import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/dto/dossier_submission_response.dart';
import '../../services/dossier_submission_service.dart';
import '../../utils/message_helper.dart';

class PageDetailAlerte extends StatefulWidget {
  final DossierSubmissionResponse submission;

  const PageDetailAlerte({super.key, required this.submission});

  @override
  State<PageDetailAlerte> createState() => _PageDetailAlerteState();
}

class _PageDetailAlerteState extends State<PageDetailAlerte> {
  final DossierSubmissionService _service = DossierSubmissionService();
  bool _isProcessing = false;

  Future<void> _approuver() async {
    setState(() => _isProcessing = true);

    final response = await _service.approveSubmission(widget.submission.id);

    if (mounted) {
      setState(() => _isProcessing = false);

      if (response.success) {
        await MessageHelper.showApiResponse(
          context: context,
          response: response,
          successTitle: 'Soumission approuvée',
          onSuccess: () {
            Navigator.pop(context, true); // true = recharger la liste
          },
        );
      } else {
        await MessageHelper.showApiResponse(
          context: context,
          response: response,
          errorTitle: 'Erreur',
        );
      }
    }
  }

  Future<void> _rejeter() async {
    final raison = await showDialog<String>(
      context: context,
      builder: (context) => _RaisonDialog(),
    );

    if (raison == null || raison.isEmpty) return;

    setState(() => _isProcessing = true);

    final response = await _service.rejectSubmission(widget.submission.id, raison);

    if (mounted) {
      setState(() => _isProcessing = false);

      if (response.success) {
        await MessageHelper.showWarning(
          context: context,
          message: response.message ?? 'Soumission rejetée',
          title: 'Soumission rejetée',
          onPressed: () {
            Navigator.pop(context, true); // true = recharger la liste
          },
        );
      } else {
        await MessageHelper.showApiResponse(
          context: context,
          response: response,
          errorTitle: 'Erreur',
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    // Parse le payload JSON
    Map<String, dynamic>? formData;
    try {
      formData = jsonDecode(widget.submission.payload);
    } catch (e) {
      formData = null;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.submission.titre,
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFCDD2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: widget.submission.type == 'CPN'
                            ? const Color(0xFFE3F2FD)
                            : const Color(0xFFFEEBEE),
                        child: Icon(
                          widget.submission.type == 'CPN'
                              ? Icons.pregnant_woman
                              : Icons.child_care,
                          color: widget.submission.type == 'CPN'
                              ? const Color(0xFF1976D2)
                              : const Color(0xFFD32F2F),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.submission.nomComplet,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Soumis il y a ${widget.submission.tempsEcoule}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Données du formulaire
            if (formData != null) ...[
              const Text(
                'Données du formulaire',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _getFilteredFormData(formData).entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              _formatFieldName(entry.key),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: Text(
                              entry.value?.toString() ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Boutons d'action
            if (_isProcessing)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _approuver,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Approuver'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF66BB6A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _rejeter,
                      icon: const Icon(Icons.cancel),
                      label: const Text('Rejeter'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD32F2F),
                        side: const BorderSide(color: Color(0xFFD32F2F)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Filtre les données du formulaire selon le type de soumission
  /// Pour CPN, ne garde que le "message" et masque les champs techniques
  Map<String, dynamic> _getFilteredFormData(Map<String, dynamic> formData) {
    if (widget.submission.type == 'CPN') {
      // Pour CPN, ne garder que le message
      final filteredData = <String, dynamic>{};
      if (formData.containsKey('message')) {
        filteredData['message'] = formData['message'];
      }
      return filteredData;
    } else {
      // Pour CPON, afficher tous les champs
      return formData;
    }
  }

  String _formatFieldName(String key) {
    // Convertir camelCase en texte lisible
    return key
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
        )
        .replaceFirst(key[0], key[0].toUpperCase())
        .trim();
  }
}

// Dialog pour demander la raison du rejet
class _RaisonDialog extends StatefulWidget {
  @override
  State<_RaisonDialog> createState() => _RaisonDialogState();
}

class _RaisonDialogState extends State<_RaisonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Raison du rejet'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Indiquez la raison du rejet...',
          border: OutlineInputBorder(),
        ),
        maxLines: 4,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F),
            foregroundColor: Colors.white,
          ),
          child: const Text('Rejeter'),
        ),
      ],
    );
  }
}
