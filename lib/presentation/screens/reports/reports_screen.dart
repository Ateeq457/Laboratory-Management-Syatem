// lib/presentation/screens/reports/reports_screen.dart
// Dynamic Reports Screen - Now using dedicated reports table

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lab_system/core/themes/app_theme.dart';
import 'package:lab_system/services/locator.dart';
import 'package:lab_system/data/repositories/base_auth_repository.dart';

class ReportsScreen extends StatefulWidget {
  final String? bookingId;

  const ReportsScreen({super.key, this.bookingId});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final BaseAuthRepository _authRepo = locator<BaseAuthRepository>();
  final _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final user = await _authRepo.getCurrentUser();
    setState(() {
      _userId = user?.id ?? '';
    });
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
    if (_userId.isEmpty) {
      print('⚠️ User ID is empty');
      return;
    }

    print('🟡 Fetching reports for userId: $_userId');

    try {
      // NO JOINS - JUST GET REPORTS
      final response = await _supabase
          .from('reports')
          .select('*')
          .eq('uploaded_by', _userId)
          .order('uploaded_at', ascending: false);

      print('✅ Got ${response.length} reports');
      print('📊 Response: $response');

      setState(() {
        _reports = response;
      });
    } catch (e) {
      print('❌ Error loading reports: $e');
    }
  }

  Future<void> _downloadReport(String fileUrl, String fileName) async {
    // TODO: Implement actual PDF download from Supabase storage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download started...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown date';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'Unknown date';
    }
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
              Navigator.pushReplacementNamed(context, '/');
            }
          },
        ),
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
        final report = _reports[index];
        return _buildReportCard(report);
      },
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    // Get test name from nested structure
    final booking = report['bookings'] as Map<String, dynamic>?;
    final tests = booking?['tests'] as Map<String, dynamic>?;
    final testName = tests?['name'] ?? 'Diagnostic Report';

    final fileUrl = report['file_url'] ?? '';
    final uploadedAt = report['uploaded_at'];
    final fileName = report['file_name'] ?? 'report.pdf';

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
                    testName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fileName,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textLightGray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                        _formatDate(uploadedAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Download Button
            GestureDetector(
              onTap: () => _downloadReport(fileUrl, fileName),
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
