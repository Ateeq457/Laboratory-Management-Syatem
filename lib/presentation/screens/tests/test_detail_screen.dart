// lib/presentation/screens/tests/test_detail_screen.dart
// Professional Test Detail Screen
// Shows complete test information with Book Now button

import 'package:flutter/material.dart';
import 'package:lab_system/core/themes/app_theme.dart';
import 'package:lab_system/data/models/test_model.dart';
import 'package:lab_system/presentation/screens/booking/select_service_type_screen.dart';

class TestDetailScreen extends StatefulWidget {
  final TestModel test;

  const TestDetailScreen({
    super.key,
    required this.test,
  });

  @override
  State<TestDetailScreen> createState() => _TestDetailScreenState();
}

class _TestDetailScreenState extends State<TestDetailScreen> {
  bool _isLoading = false;

  void _proceedToBooking() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceSelectionScreen(test: widget.test),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor =
        _getCategoryColor(widget.test.getCategoryDisplayName());

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            // Ye already hai:
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 18),
              onPressed: () => Navigator.pop(context), // Route se wapas aayega
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryDark,
                      AppColors.primaryMid,
                      AppColors.primaryGreen,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Category Chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.test.getCategoryDisplayName(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Test Name
                        Text(
                          widget.test.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        // Price
                        Row(
                          children: [
                            const Text(
                              'Rs. ',
                              style: TextStyle(
                                color: AppColors.primaryLight,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              widget.test.price.toStringAsFixed(0),
                              style: const TextStyle(
                                color: AppColors.primaryLight,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description Section
                  _buildInfoCard(
                    title: 'Description',
                    icon: Icons.description_outlined,
                    children: [
                      Text(
                        widget.test.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textDark,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Parameters Section
                  if (widget.test.parameters.isNotEmpty)
                    _buildInfoCard(
                      title: 'Parameters Covered',
                      icon: Icons.list_alt,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.test.parameters.map((param) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryExtraLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                param,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // Preparation Section
                  if (widget.test.preparationInstructions.isNotEmpty)
                    _buildInfoCard(
                      title: 'Preparation Required',
                      icon: Icons.access_time,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 16,
                              color: AppColors.primaryGreen,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.test.preparationInstructions,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // Report Time Section
                  _buildInfoCard(
                    title: 'Report Delivery',
                    icon: Icons.schedule,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.timer,
                            size: 16,
                            color: AppColors.primaryGreen,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.test.reportTime,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.home,
                            size: 16,
                            color: AppColors.primaryGreen,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Home sampling available',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Fasting Required Section
                  if (widget.test.fastingRequired != null)
                    _buildInfoCard(
                      title: 'Fasting Required',
                      icon: Icons.restaurant,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              size: 16,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.test.fastingRequired!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                  const SizedBox(height: 100), // Space for fixed button
                ],
              ),
            ),
          ),
        ],
      ),

      // Fixed Bottom Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Price Column
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Total Price',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textGray,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rs. ${widget.test.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    if (widget.test.homeSamplingFee != null)
                      Text(
                        '+ Rs.${widget.test.homeSamplingFee!.toStringAsFixed(0)} for home sampling',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textLightGray,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Book Button
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _proceedToBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Book This Test',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
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
          'color': AppColors.primaryGreen,
        };
    }
  }
}
