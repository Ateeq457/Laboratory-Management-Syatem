// lib/presentation/screens/home/home_screen.dart
// Professional Home Screen with View All Bottom Sheet

import 'package:flutter/material.dart';
import 'package:lab_system/core/themes/app_theme.dart';
import 'package:lab_system/core/routes/app_routes.dart';
import 'package:lab_system/services/locator.dart';
import 'package:lab_system/data/repositories/base_test_repository.dart';
import 'package:lab_system/data/models/test_model.dart';
import 'package:lab_system/data/models/location_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BaseTestRepository _testRepository = locator<BaseTestRepository>();

  LocationModel? _selectedLocation;
  List<TestModel> _allTests = [];
  List<TestModel> _displayTests = [];
  bool _isLoading = true;
  bool _isError = false;

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Blood Work',
      'icon': Icons.water_drop,
      'color': AppColors.bloodWorkColor
    },
    {
      'name': 'Diabetes',
      'icon': Icons.analytics,
      'color': AppColors.diabetesColor
    },
    {'name': 'Renal', 'icon': Icons.shield, 'color': AppColors.renalColor},
    {
      'name': 'Hepatic',
      'icon': Icons.favorite,
      'color': AppColors.hepaticColor
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadTests();
    _loadSavedLocation();
  }

  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('selected_sector_id');
    if (savedId != null) {
      final sectors = LocationModel.getSectors();
      setState(() {
        _selectedLocation = sectors.firstWhere(
          (loc) => loc.id == savedId,
          orElse: () => sectors.first,
        );
      });
    } else {
      setState(() {
        _selectedLocation = LocationModel.getSectors().first;
      });
    }
  }

  Future<void> _saveLocation(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_sector_id', location.id);
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationPickerSheet(
        selectedLocation: _selectedLocation,
        onLocationSelected: (location) {
          setState(() {
            _selectedLocation = location;
          });
          _saveLocation(location);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _loadTests() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });
    try {
      final tests = await _testRepository.getTests();
      setState(() {
        _allTests = tests;
        _displayTests = tests.take(5).toList(); // Only show first 5
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
      });
      debugPrint('Error loading tests: $e');
    }
  }

  void _showAllTestsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Header
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'All Available Tests',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      '${_allTests.length} tests available',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textGray,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search Bar (Optional)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search tests...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.borderLight),
                        ),
                        filled: true,
                        fillColor: AppColors.backgroundLight,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tests List
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _allTests.length,
                      itemBuilder: (context, index) {
                        final test = _allTests[index];
                        return _buildAllTestItem(test);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAllTestItem(TestModel test) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          AppRoutes.testDetail,
          arguments: test,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryExtraLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.medical_services,
                  color: AppColors.primaryGreen, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    test.name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    test.getCategoryDisplayName(),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textGray),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rs. ${test.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen),
                ),
                const SizedBox(height: 4),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.testDetail,
                      arguments: test,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Book',
                      style: TextStyle(fontSize: 11, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTestDetail(TestModel test) {
    Navigator.pushNamed(
      context,
      AppRoutes.testDetail,
      arguments: test,
    );
  }

  void _navigateToOrders() {
    Navigator.pushNamed(context, AppRoutes.orders);
  }

  void _navigateToReports() {
    Navigator.pushNamed(context, AppRoutes.reports);
  }

  void _navigateToTestList() {
    Navigator.pushNamed(context, AppRoutes.testList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // Custom AppBar
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryGreen, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('T',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 8),
                RichText(
                  text: const TextSpan(
                    text: 'Thal',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark),
                    children: [
                      TextSpan(
                          text: '-Care',
                          style: TextStyle(color: AppColors.primaryGreen))
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none, size: 20),
                onPressed: () => _showNotificationsDialog(context),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.primaryGreen, AppColors.primaryMid]),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Center(
                    child: Text('AS',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12))),
              ),
              const SizedBox(width: 8),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section with Professional Location
                _buildHeroSection(),
                // Stats Strip
                _buildStatsStrip(),
                const SizedBox(height: 20),
                // Categories
                _buildCategoriesSection(),
                const SizedBox(height: 20),
                // All Tests Section
                _buildTestsSection(),
                const SizedBox(height: 20),
                // Quick Actions
                _buildQuickActions(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HERO SECTION ====================
  Widget _buildHeroSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryDark,
            AppColors.primaryMid,
            AppColors.primaryGreen
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hello 👋',
                style: TextStyle(fontSize: 13, color: Colors.white70)),
            const SizedBox(height: 4),
            const Text('Book your tests',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const SizedBox(height: 4),
            const Text('with ease',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryLight)),
            const SizedBox(height: 24),
            // Professional Location Card
            GestureDetector(
              onTap: _showLocationPicker,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.location_on,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedLocation?.name ?? 'Select Location',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _selectedLocation?.address ??
                                'Tap to change location',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.keyboard_arrow_down,
                          color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== STATS STRIP ====================
  Widget _buildStatsStrip() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _buildStatItem(Icons.access_time, '24/7 Service'),
          _buildStatItem(Icons.bolt, 'Fast Results'),
          _buildStatItem(Icons.home, 'Home Sampling'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: 18),
            const SizedBox(height: 4),
            Text(label,
                style:
                    const TextStyle(fontSize: 10, color: AppColors.textGray)),
          ],
        ),
      ),
    );
  }

  // ==================== CATEGORIES ====================
  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Categories',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children:
                _categories.map((cat) => _buildCategoryCard(cat)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () {
        // Navigate to test list with selected category
        Navigator.pushNamed(
          context,
          AppRoutes.testList,
          arguments: category['name'], // Pass category name as argument
        );
      },
      child: Container(
        width: 85,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.borderLight),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(category['icon'], color: category['color'], size: 28),
            const SizedBox(height: 6),
            Text(category['name'],
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // ==================== TESTS SECTION ====================
  Widget _buildTestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Available Tests',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              TextButton(
                onPressed: _showAllTestsBottomSheet,
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Row(
                  children: [
                    Text('View All',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.primaryGreen)),
                    Icon(Icons.chevron_right,
                        size: 14, color: AppColors.primaryGreen),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _isLoading
            ? _buildLoadingState()
            : _isError
                ? _buildErrorState()
                : _displayTests.isEmpty
                    ? _buildEmptyState()
                    : _buildTestsList(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: AppColors.primaryGreen),
            SizedBox(height: 12),
            Text('Loading tests...',
                style: TextStyle(fontSize: 12, color: AppColors.textGray)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            const Text('Failed to load tests',
                style: TextStyle(fontSize: 14, color: AppColors.textGray)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadTests,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.medical_services_outlined,
                size: 48, color: AppColors.textLightGray),
            SizedBox(height: 12),
            Text('No tests available',
                style: TextStyle(fontSize: 14, color: AppColors.textGray)),
          ],
        ),
      ),
    );
  }

  Widget _buildTestsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _displayTests.length,
      itemBuilder: (context, index) => _buildTestCard(_displayTests[index]),
    );
  }

  Widget _buildTestCard(TestModel test) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryExtraLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.medical_services,
                color: AppColors.primaryGreen, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(test.name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(test.getCategoryDisplayName(),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textGray)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Rs. ${test.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen)),
              const SizedBox(height: 2),
              ElevatedButton(
                onPressed: () => _navigateToTestDetail(test),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Book',
                    style: TextStyle(fontSize: 11, color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== QUICK ACTIONS ====================
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _navigateToOrders,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.textDark,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.assignment, color: Colors.white, size: 22),
                    const SizedBox(height: 10),
                    const Text('My Orders',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    const Text('Track bookings',
                        style: TextStyle(color: Colors.white70, fontSize: 10)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _navigateToReports,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.diabetesBg,
                  border: Border.all(color: AppColors.borderLight),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.description,
                        color: AppColors.diabetesColor, size: 22),
                    const SizedBox(height: 10),
                    const Text('Reports',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    const Text('View & download',
                        style:
                            TextStyle(fontSize: 10, color: AppColors.textGray)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Notifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('No new notifications',
                style: TextStyle(color: AppColors.textGray)),
          ],
        ),
      ),
    );
  }
}

// ==================== LOCATION PICKER SHEET ====================

class LocationPickerSheet extends StatefulWidget {
  final LocationModel? selectedLocation;
  final Function(LocationModel) onLocationSelected;

  const LocationPickerSheet({
    super.key,
    this.selectedLocation,
    required this.onLocationSelected,
  });

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  String _searchQuery = '';
  List<LocationModel> _filteredLocations = [];

  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();

  final FocusNode _houseFocus = FocusNode();
  final FocusNode _streetFocus = FocusNode();
  final FocusNode _landmarkFocus = FocusNode();

  String? _selectedSector;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _filteredLocations = LocationModel.getSectors();
    _selectedSector = LocationModel.getSectors().first.id;
  }

  @override
  void dispose() {
    _houseController.dispose();
    _streetController.dispose();
    _landmarkController.dispose();
    _houseFocus.dispose();
    _streetFocus.dispose();
    _landmarkFocus.dispose();
    super.dispose();
  }

  void _filterLocations(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredLocations = LocationModel.getSectors();
      } else {
        _filteredLocations = LocationModel.getSectors()
            .where((loc) =>
                loc.name.toLowerCase().contains(query.toLowerCase()) ||
                loc.address.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _saveManualAddress() {
    _houseFocus.unfocus();
    _streetFocus.unfocus();
    _landmarkFocus.unfocus();

    if (_selectedSector == null) {
      _showSnackBar('Please select a sector');
      return;
    }

    final house = _houseController.text.trim();
    final street = _streetController.text.trim();

    if (house.isEmpty || street.isEmpty) {
      _showSnackBar('Please enter house and street number');
      return;
    }

    final sector = LocationModel.getSectors().firstWhere(
      (s) => s.id == _selectedSector,
    );

    final landmark = _landmarkController.text.trim();
    final fullAddress = landmark.isNotEmpty
        ? 'House $house, Street $street, ${sector.name}, Near $landmark'
        : 'House $house, Street $street, ${sector.name}';

    final customLocation = LocationModel(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: sector.name,
      address: fullAddress,
      isSaved: true,
      isCustom: true,
    );

    widget.onLocationSelected(customLocation);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _closeKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: _closeKeyboard,
      behavior: HitTestBehavior.translucent,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: keyboardHeight),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Select Location',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          _buildTabButton('Sector', 0),
                          _buildTabButton('Manual', 1),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _selectedTab == 1
                      ? 'Enter your complete address manually'
                      : 'Choose your sector for home sampling',
                  style:
                      const TextStyle(fontSize: 13, color: AppColors.textGray),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _selectedTab == 1
                    ? _buildManualAddressForm()
                    : _buildSectorList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int tabIndex) {
    final isActive = _selectedTab == tabIndex;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedTab = tabIndex);
        _closeKeyboard();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textGray,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSectorList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: TextField(
              onChanged: _filterLocations,
              decoration: InputDecoration(
                hintText: 'Search sector...',
                prefixIcon: const Icon(Icons.search,
                    size: 20, color: AppColors.textGray),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredLocations.length,
            itemBuilder: (context, index) {
              final location = _filteredLocations[index];
              final isSelected = widget.selectedLocation?.id == location.id;
              return GestureDetector(
                onTap: () => widget.onLocationSelected(location),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppColors.primaryExtraLight : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : AppColors.borderLight,
                      width: isSelected ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryGreen.withOpacity(0.1)
                              : AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.location_on,
                            color: isSelected
                                ? AppColors.primaryGreen
                                : AppColors.textGray,
                            size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(location.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: isSelected
                                        ? AppColors.primaryGreen
                                        : AppColors.textDark)),
                            const SizedBox(height: 2),
                            Text(location.address,
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.textGray)),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle,
                            color: AppColors.primaryGreen, size: 22),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildManualAddressForm() {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Sector *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              border: Border.all(color: AppColors.borderLight),
              borderRadius: BorderRadius.circular(14),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSector,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.textGray),
                items: LocationModel.getSectors().map((sector) {
                  return DropdownMenuItem(
                      value: sector.id, child: Text(sector.name));
                }).toList(),
                onChanged: (value) => setState(() => _selectedSector = value),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('House / Flat Number *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _houseController,
            focusNode: _houseFocus,
            decoration: InputDecoration(
              hintText: 'e.g., 123, A-45',
              prefixIcon:
                  const Icon(Icons.home, size: 20, color: AppColors.textGray),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.borderLight)),
              focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: AppColors.primaryGreen, width: 1.5)),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Street / Road Name *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _streetController,
            focusNode: _streetFocus,
            decoration: InputDecoration(
              hintText: 'e.g., Main Street, Street 5',
              prefixIcon:
                  const Icon(Icons.route, size: 20, color: AppColors.textGray),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.borderLight)),
              focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: AppColors.primaryGreen, width: 1.5)),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Landmark (Optional)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _landmarkController,
            focusNode: _landmarkFocus,
            decoration: InputDecoration(
              hintText: 'e.g., Near City Hospital',
              prefixIcon: const Icon(Icons.location_city,
                  size: 20, color: AppColors.textGray),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.borderLight)),
              focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: AppColors.primaryGreen, width: 1.5)),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveManualAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Save Address',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
