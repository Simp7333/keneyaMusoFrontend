import 'package:flutter/material.dart';
import '../../models/dto/patiente_list_dto.dart';
import '../../services/professionnel_sante_service.dart';
import '../../pages/patiente/prenatale/dossier_cpn_page.dart';
import '../../pages/patiente/postnatale/dossier_post_page.dart';
import '../../routes.dart';
import '../../widgets/pro_bottom_nav_bar.dart';
import '../common/app_colors.dart';

class PagePatientes extends StatefulWidget {
  const PagePatientes({super.key});

  @override
  State<PagePatientes> createState() => _PagePatientesState();
}

class _PagePatientesState extends State<PagePatientes> {
  int _selectedTabIndex = 0;
  int _bottomNavIndex = 1; // 'Patientes' is the second item

  final ProfessionnelSanteService _service = ProfessionnelSanteService();
  List<PatienteListDto> _prenatalPatients = [];
  List<PatienteListDto> _postnatalPatients = [];
  List<PatienteListDto> _filteredPatients = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _loadPatientes();
    _searchController.addListener(_filterPatients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Charger les patientes prénatales
    final prenatalesResponse = await _service.getMedecinPatientes(typeSuivi: 'PRENATAL');
    
    // Charger les patientes postnatales
    final postnatalesResponse = await _service.getMedecinPatientes(typeSuivi: 'POSTNATAL');

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (prenatalesResponse.success && prenatalesResponse.data != null) {
          _prenatalPatients = prenatalesResponse.data!;
        } else if (!prenatalesResponse.success) {
          _errorMessage = prenatalesResponse.message;
        }

        if (postnatalesResponse.success && postnatalesResponse.data != null) {
          _postnatalPatients = postnatalesResponse.data!;
        } else if (!postnatalesResponse.success && _errorMessage == null) {
          _errorMessage = postnatalesResponse.message;
        }

        _updateFilteredPatients();
      });
    }
  }

  void _updateFilteredPatients() {
    final patientsToShow = _selectedTabIndex == 0 ? _prenatalPatients : _postnatalPatients;
    final searchQuery = _searchController.text.toLowerCase().trim();

    if (searchQuery.isEmpty) {
      _filteredPatients = patientsToShow;
    } else {
      _filteredPatients = patientsToShow.where((patient) {
        final fullName = patient.fullName.toLowerCase();
        final phone = patient.telephone.toLowerCase();
        return fullName.contains(searchQuery) || phone.contains(searchQuery);
      }).toList();
    }
  }

  void _filterPatients() {
    setState(() {
      _updateFilteredPatients();
    });
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
      _updateFilteredPatients();
    });
  }

  void _onNavBarItemTapped(int index) {
    if (_bottomNavIndex == index) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.proDashboard);
        break;
      case 1:
        // Already on this page
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Patientes',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPink.withOpacity(0.63),
                ),
              ),
              const SizedBox(height: 16),
              _buildTabs(),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null && _filteredPatients.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _loadPatientes,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Réessayer'),
                                ),
                              ],
                            ),
                          )
                        : _filteredPatients.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.people_outline,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _selectedTabIndex == 0
                                          ? 'Aucune patiente prénatale'
                                          : 'Aucune patiente postnatale',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadPatientes,
                                child: ListView.builder(
                                  itemCount: _filteredPatients.length,
                                  itemBuilder: (context, index) {
                                    final patiente = _filteredPatients[index];
                                    Widget destinationPage;
                                    switch (_selectedTabIndex) {
                                      case 0:
                                        // Prénatale - afficher le dossier CPN de la patiente sélectionnée
                                        destinationPage = DossierCpnPage(patienteId: patiente.id);
                                        break;
                                      case 1:
                                        // Postnatale - afficher le dossier Post de la patiente sélectionnée
                                        destinationPage = DossierPostPage(patienteId: patiente.id);
                                        break;
                                      default:
                                        destinationPage = DossierCpnPage(patienteId: patiente.id);
                                    }
                                    return _buildPatienteListItem(patiente, destinationPage);
                                  },
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ProBottomNavBar(
        selectedIndex: _bottomNavIndex,
        onItemSelected: _onNavBarItemTapped,
      ),
    );
  }

  Widget _buildPatienteListItem(PatienteListDto patiente, Widget destinationPage) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationPage),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFFEEDEE3),
              child: Text(
                patiente.prenom.isNotEmpty ? patiente.prenom[0].toUpperCase() : 'P',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE91E63),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patiente.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(patiente.age, style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text(patiente.telephone, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _onTabChanged(0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0 ? AppColors.primaryPink.withOpacity(0.63) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    'Prenatale',
                    style: TextStyle(
                      color: _selectedTabIndex == 0 ? Colors.white : AppColors.primaryPink.withOpacity(0.63),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _onTabChanged(1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1 ? AppColors.primaryPink.withOpacity(0.63) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    'Postnatale',
                    style: TextStyle(
                      color: _selectedTabIndex == 1 ? Colors.white : AppColors.primaryPink.withOpacity(0.63),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Rechercher par nom ou téléphone...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}