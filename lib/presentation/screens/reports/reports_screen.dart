// lib/presentation/screens/reports/reports_screen.dart
// Professional Reports Screen - Dynamic with Download Option

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lab_system/core/themes/app_theme.dart';
import 'package:lab_system/services/locator.dart';
import 'package:lab_system/data/repositories/base_booking_repository.dart';
import 'package:lab_system/data/models/booking_model.dart';

class ReportsScreen extends StatefulWidget {
  final String? bookingId;

  const ReportsScreen({super.key, this.bookingId});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final BaseBookingRepository _bookingRepository =
      locator<BaseBookingRepository>();

  List<BookingModel> _reports = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String _userId = 'user_001'; // TODO: Get from auth

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    await _fetchReports();
    setState(() => _isLoading = false);
  }

  Future<void> _refreshReports() async {
    setState(() => _isRefreshing = true);
    await _fetchReports();
    setState(() => _isRefreshing = false);
  }

  Future<void> _fetchReports() async {
    try {
      final allBookings = await _bookingRepository.getUserBookings(_userId);

      final reportsList = allBookings
          .where((booking) =>
              booking.status == BookingStatus.reportReady ||
              booking.status == BookingStatus.completed)
          .toList();

      setState(() {
        _reports = reportsList;
      });
    } catch (e) {
      debugPrint('Error loading reports: $e');
    }
  }

  void _downloadReport(BookingModel booking) {
    // TODO: Implement actual PDF download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading report for ${booking.test?.name}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'My Reports',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // If no previous screen (direct from bottom nav), go to home
              Navigator.pushReplacementNamed(context, '/');
            }
          },
        ),
        // REMOVED: actions (download all button)
      ),
      body: RefreshIndicator(
        onRefresh: _refreshReports,
        color: AppColors.primaryGreen,
        child: _isLoading
            ? _buildLoadingState()
            : _reports.isEmpty
                ? _buildEmptyState()
                : _buildReportsList(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryGreen),
          SizedBox(height: 16),
          Text(
            'Loading your reports...',
            style: TextStyle(color: AppColors.textGray),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryExtraLight,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.description_outlined,
              size: 50,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Reports Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your test reports will appear here when ready',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGray,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/tests');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Browse Tests'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final booking = _reports[index];
        return _buildReportCard(booking);
      },
    );
  }

  Widget _buildReportCard(BookingModel booking) {
    final reportDate =
        booking.reportReadyAt ?? booking.updatedAt ?? booking.createdAt;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      // REMOVED: InkWell - ab sirf container hai, clickable nahi
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // PDF Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primaryExtraLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.picture_as_pdf,
                size: 28,
                color: AppColors.error,
              ),
            ),
            const SizedBox(width: 14),
            // Report Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.test?.name ?? 'Diagnostic Report',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${booking.id}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textLightGray,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 10,
                        color: AppColors.textGray,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(reportDate),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textGray,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Ready',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Download Button (only clickable thing)
            GestureDetector(
              onTap: () => _downloadReport(booking),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.download,
                  color: AppColors.primaryGreen,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
