// lib/presentation/screens/tests/test_list_screen.dart
// Professional Test List Screen with Search & Category Filter
// Clean UI, Smooth Animations, Professional UX

import 'package:flutter/material.dart';
import 'package:lab_system/core/routes/app_routes.dart';
import 'package:lab_system/core/themes/app_theme.dart';
import 'package:lab_system/services/locator.dart';
import 'package:lab_system/data/repositories/base_test_repository.dart';
import 'package:lab_system/data/models/test_model.dart';

class TestListScreen extends StatefulWidget {
  final String? initialCategory;

  const TestListScreen({super.key, this.initialCategory});

  @override
  State<TestListScreen> createState() => _TestListScreenState();
}

class _TestListScreenState extends State<TestListScreen> {
  final BaseTestRepository _testRepository = locator<BaseTestRepository>();

  List<TestModel> _allTests = [];
  List<TestModel> _filteredTests = [];
  bool _isLoading = true;

  // Search & Filter
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = '';

  // Categories (from your design)
  final List<String> _categories = [
    'All',
    'Blood Work',
    'Diabetes',
    'Renal',
    'Hepatic',
    'Cardiology',
  ];

  // Animation
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'All';
    _loadTests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTests() async {
    setState(() => _isLoading = true);
    try {
      final tests = await _testRepository.getTests();
      setState(() {
        _allTests = tests;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading tests: $e');
    }
  }

  void _applyFilters() {
    List<TestModel> filtered = _allTests;

    // Apply category filter
    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((test) => test.getCategoryDisplayName() == _selectedCategory)
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((test) =>
              test.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              test
                  .getCategoryDisplayName()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    setState(() {
      _filteredTests = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _applyFilters();
    });
  }

// Method update karo:
  void _navigateToTestDetail(TestModel test) {
    Navigator.pushNamed(
      context,
      AppRoutes.testDetail,
      arguments: test,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),

          // Category Filter
          _buildCategoryFilter(),

          const SizedBox(height: 8),

          // Results Count
          _buildResultsCount(),

          const SizedBox(height: 8),

          // Test List
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _filteredTests.isEmpty
                    ? _buildEmptyState()
                    : _buildTestList(),
          ),
        ],
      ),
    );
  }

  // ==================== APP BAR ====================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Diagnostic Tests',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 18),
        onPressed: () {
          // Check if we came from navigation or bottom nav
          if (Navigator.canPop(context)) {
            // If there's a previous screen, go back
            Navigator.pop(context);
          } else {
            // If no previous screen (direct from bottom nav), go to home
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        },
      ),
      actions: null,
    );
  }

  // ==================== SEARCH BAR ====================
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search tests...',
          hintStyle: const TextStyle(color: AppColors.textLightGray),
          prefixIcon:
              const Icon(Icons.search, size: 20, color: AppColors.textGray),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.primaryGreen, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // ==================== CATEGORY FILTER (Horizontal Scroll) ====================
  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => _onCategorySelected(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryGreen : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color:
                        isSelected ? Colors.transparent : AppColors.borderLight,
                  ),
                ),
                child: Center(
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==================== RESULTS COUNT ====================
  Widget _buildResultsCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_filteredTests.length} tests available',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textGray,
            ),
          ),
          if (_searchQuery.isNotEmpty || _selectedCategory != 'All')
            GestureDetector(
              onTap: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _selectedCategory = 'All';
                  _applyFilters();
                });
              },
              child: const Text(
                'Clear all',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==================== TEST LIST ====================
  Widget _buildTestList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredTests.length,
      itemBuilder: (context, index) {
        final test = _filteredTests[index];
        return _buildTestCard(test);
      },
    );
  }

  Widget _buildTestCard(TestModel test) {
    final categoryColor = _getCategoryColor(test.getCategoryDisplayName());

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToTestDetail(test),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Category Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: categoryColor['bg'],
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _getCategoryIcon(test.getCategoryDisplayName()),
                        color: categoryColor['color'],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Test Name & Category
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            test.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: categoryColor['bg'],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              test.getCategoryDisplayName(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: categoryColor['color'],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Price & Book Button
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rs. ${test.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _navigateToTestDetail(test),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            minimumSize: const Size(70, 32),
                          ),
                          child: const Text(
                            'Book',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Description (if available)
                if (test.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    test.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGray,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Preparation Instructions (if available)
                if (test.preparationInstructions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 12, color: AppColors.textLightGray),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          test.preparationInstructions,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textLightGray,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== LOADING STATE ====================
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryGreen),
          SizedBox(height: 16),
          Text(
            'Loading tests...',
            style: TextStyle(color: AppColors.textGray),
          ),
        ],
      ),
    );
  }

  // ==================== EMPTY STATE ====================
  // ==================== EMPTY STATE (FIXED - NO OVERFLOW) ====================
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - 200,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_off,
                    size: 50,
                    color: AppColors.textLightGray,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'No tests found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  _searchQuery.isNotEmpty
                      ? 'Try searching for something else'
                      : 'No tests available in this category',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textGray,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Clear Filters Button
                if (_searchQuery.isNotEmpty || _selectedCategory != 'All')
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                        _selectedCategory = 'All';
                        _applyFilters();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryGreen),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Clear Filters'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== FILTER DIALOG ====================
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Tests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sort by',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildFilterOption('Price: Low to High', () {}),
              _buildFilterOption('Price: High to Low', () {}),
              _buildFilterOption('Name: A to Z', () {}),
              const SizedBox(height: 16),
              const Text(
                'Price Range',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildFilterOption('Under Rs. 500', () {}),
              _buildFilterOption('Rs. 500 - Rs. 1000', () {}),
              _buildFilterOption('Above Rs. 1000', () {}),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      visualDensity: const VisualDensity(vertical: -2),
    );
  }

  // ==================== HELPER METHODS ====================
  Color _getCategoryColorForIcon(String category) {
    switch (category) {
      case 'Blood Work':
        return AppColors.bloodWorkColor;
      case 'Diabetes':
        return AppColors.diabetesColor;
      case 'Renal':
        return AppColors.renalColor;
      case 'Hepatic':
        return AppColors.hepaticColor;
      case 'Cardiology':
        return AppColors.cardioColor;
      default:
        return AppColors.primaryGreen;
    }
  }

  Map<String, Color> _getCategoryColor(String category) {
    switch (category) {
      case 'Blood Work':
        return {'bg': AppColors.bloodWorkBg, 'color': AppColors.bloodWorkColor};
      case 'Diabetes':
        return {'bg': AppColors.diabetesBg, 'color': AppColors.diabetesColor};
      case 'Renal':
        return {'bg': AppColors.renalBg, 'color': AppColors.renalColor};
      case 'Hepatic':
        return {'bg': AppColors.hepaticBg, 'color': AppColors.hepaticColor};
      case 'Cardiology':
        return {'bg': AppColors.cardioBg, 'color': AppColors.cardioColor};
      default:
        return {
          'bg': AppColors.primaryExtraLight,
          'color': AppColors.primaryGreen
        };
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Blood Work':
        return Icons.water_drop;
      case 'Diabetes':
        return Icons.analytics;
      case 'Renal':
        return Icons.shield;
      case 'Hepatic':
        return Icons.favorite;
      case 'Cardiology':
        return Icons.medical_services;
      default:
        return Icons.medical_services;
    }
  }
}
