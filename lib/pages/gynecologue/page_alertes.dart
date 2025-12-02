import 'package:flutter/material.dart';
import 'package:keneya_muso/pages/gynecologue/page_detail_alerte.dart';
import '../../services/dossier_submission_service.dart';
import '../../models/dto/dossier_submission_response.dart';

class PageAlertes extends StatefulWidget {
  const PageAlertes({super.key});

  @override
  State<PageAlertes> createState() => _PageAlertesState();
}

class _PageAlertesState extends State<PageAlertes> {
  final DossierSubmissionService _service = DossierSubmissionService();
  List<DossierSubmissionResponse> _alertes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAlertes();
  }

  Future<void> _loadAlertes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    print('🔄 Chargement des alertes...');
    final response = await _service.getPendingSubmissions();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.success && response.data != null) {
          _alertes = response.data!;
          print('✅ ${_alertes.length} alerte(s) chargée(s)');
          for (var alerte in _alertes) {
            print('  - ${alerte.titre} - ${alerte.nomComplet}');
          }
        } else {
          _errorMessage = response.message ?? 'Erreur lors du chargement des alertes';
          print('❌ Erreur: $_errorMessage');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAlertes,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Alertes',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD32F2F),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Dossiers médicaux en attente de validation',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFD32F2F),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFD32F2F),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadAlertes,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_alertes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune alerte en attente',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Les nouvelles soumissions apparaîtront ici',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _alertes.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PageDetailAlerte(
                  submission: _alertes[index],
                ),
              ),
            );
            // Si la soumission a été traitée, recharger la liste
            if (result == true) {
              _loadAlertes();
            }
          },
          child: _buildAlerteItem(_alertes[index]),
        );
      },
    );
  }

  Widget _buildAlerteItem(DossierSubmissionResponse alerte) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF5F5F5), width: 1.0),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: alerte.type == 'CPN' 
                ? const Color(0xFFE3F2FD) 
                : const Color(0xFFFEEBEE),
            child: Icon(
              alerte.type == 'CPN' 
                  ? Icons.pregnant_woman 
                  : Icons.child_care,
              color: alerte.type == 'CPN'
                  ? const Color(0xFF1976D2)
                  : const Color(0xFFD32F2F),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alerte.titre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alerte.nomComplet,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Text(
                  alerte.message,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                alerte.tempsEcoule,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEEBEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'EN ATTENTE',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFFD32F2F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
