import 'package:flutter/material.dart';
import 'package:keneya_muso/routes.dart';
import '../../services/professionnel_sante_service.dart';
import '../../models/dto/dashboard_stats_response.dart';
import '../../widgets/pro_bottom_nav_bar.dart';
import '../../widgets/stats_grid.dart';
import '../../widgets/welcome_banner.dart';

class PageDashboardPro extends StatefulWidget {
  const PageDashboardPro({super.key});

  @override
  State<PageDashboardPro> createState() => _PageDashboardProState();
}

class _PageDashboardProState extends State<PageDashboardPro> {
  int _selectedIndex = 0;
  final ProfessionnelSanteService _service = ProfessionnelSanteService();
  DashboardStatsResponse? _stats;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _service.getDashboardStats();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.success && response.data != null) {
          _stats = response.data;
          // Debug: afficher les valeurs
          print('📊 Dashboard Stats:');
          print('  Total Patientes: ${_stats!.totalPatientes}');
          print('  Suivis Terminés: ${_stats!.suivisTermines}');
          print('  Suivis En Cours: ${_stats!.suivisEnCours}');
          print('  Rappels Actifs: ${_stats!.rappelsActifs}');
          print('  Alertes Actives: ${_stats!.alertesActives}');
        } else {
          _errorMessage = response.message ?? 'Erreur lors du chargement des statistiques';
        }
      });
    }
  }

  void _onNavBarItemTapped(int index) {
    if (_selectedIndex == index) return;

    switch (index) {
      case 0:
        // Already on this page, do nothing.
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.proPatientes);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.proAccompagnements);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.proSettings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo/logoknya.png',
              height: 80,
              fit: BoxFit.contain,
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none,
                    color: Colors.black, size: 30),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.proNotifications);
                },
              ),
              // Badge de notification dynamique (alertes + rappels)
              if (_stats != null && (_stats!.alertesActives > 0 || _stats!.rappelsActifs > 0))
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '${(_stats!.alertesActives + _stats!.rappelsActifs)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.proProfile);
            },
            child: const CircleAvatar(
              backgroundColor: Colors.black,
              radius: 20,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WelcomeBanner(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _errorMessage != null
                    ? Column(
                        children: [
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _loadDashboardStats,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Réessayer'),
                          ),
                        ],
                      )
                    : StatsGrid(
                        stats: _stats,
                        isLoading: _isLoading,
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ProBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavBarItemTapped,
      ),
    );
  }
}
