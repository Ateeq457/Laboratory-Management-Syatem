// lib/presentation/screens/home/home_screen.dart
// Professional Home Screen - Clean & Minimal

import 'package:flutter/material.dart';
import 'package:lab_system/core/themes/app_theme.dart';
import 'package:lab_system/core/routes/app_routes.dart';
import 'package:lab_system/data/repositories/base_auth_repository.dart';
import 'package:lab_system/services/locator.dart';
import 'package:lab_system/data/repositories/base_test_repository.dart';
import 'package:lab_system/data/models/test_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BaseTestRepository _testRepository = locator<BaseTestRepository>();

  List<TestModel> _allTests = [];
  List<TestModel> _displayTests = [];
  bool _isLoading = true;
  bool _isError = false;
  String _userName = '';

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
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final authRepo = locator<BaseAuthRepository>();
    final user = await authRepo.getCurrentUser();
    setState(() {
      _userName = user?.name?.split(' ').first ?? 'Guest';
    });
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
        _displayTests = tests.take(5).toList();
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'All Available Tests',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      '${_allTests.length} tests available',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textGray),
                    ),
                  ),
                  const SizedBox(height: 16),
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

  void _navigateToTestList() {
    Navigator.pushNamed(context, AppRoutes.testList);
  }

  void _navigateToTestDetail(TestModel test) {
    Navigator.pushNamed(context, AppRoutes.testDetail, arguments: test);
  }

  void _navigateToOrders() {
    Navigator.pushNamed(context, AppRoutes.orders);
  }

  void _navigateToReports() {
    Navigator.pushNamed(context, AppRoutes.reports);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // Custom AppBar - UPDATED
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
              // Profile Avatar - REPLACED with icon
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.person_outline,
                      size: 18, color: AppColors.primaryGreen),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.profile);
                  },
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section - WITHOUT Location Selector
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

  // ==================== HERO SECTION (Updated - No Location) ====================
  // ==================== HERO SECTION (Updated - Welcome Banner Clickable) ====================
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
            Text(
              'Hello $_userName 👋',
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'Book your tests',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 4),
            const Text(
              'with ease',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryLight),
            ),
            const SizedBox(height: 20),

            // Quick Info Banner - CLICKABLE
            GestureDetector(
              onTap: _navigateToTestList,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      child: const Icon(Icons.medical_information,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome to Thal-Care',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_allTests.length}+ diagnostic tests available',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
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
                      child: const Icon(Icons.chevron_right,
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
        Navigator.pushNamed(
          context,
          AppRoutes.testList,
          arguments: category['name'],
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
}
