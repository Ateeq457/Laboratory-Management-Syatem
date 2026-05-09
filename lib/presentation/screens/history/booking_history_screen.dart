// lib/presentation/screens/history/booking_history_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lab_system/core/themes/app_theme.dart';
import 'package:lab_system/data/repositories/base_auth_repository.dart';
import 'package:lab_system/presentation/screens/history/booking_detail_screen.dart';
import 'package:lab_system/services/locator.dart';
import 'package:lab_system/data/repositories/base_booking_repository.dart';
import 'package:lab_system/data/models/booking_model.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  final BaseBookingRepository _bookingRepository =
      locator<BaseBookingRepository>();
  final BaseAuthRepository _authRepo = locator<BaseAuthRepository>();

  List<BookingModel> _bookings = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String _userId = '';

  final Set<BookingStatus> _cancellableStatuses = {
    BookingStatus.pending,
    BookingStatus.confirmed,
  };

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<void> _loadUserId() async {
    final user = await _authRepo.getCurrentUser();
    if (user == null || user.id.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }
    setState(() => _userId = user.id);
    _loadBookings();
  }

  // ── Data fetching ─────────────────────────────────────────────────────────

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    await _fetchBookings();
    setState(() => _isLoading = false);
  }

  Future<void> _refreshBookings() async {
    setState(() => _isRefreshing = true);
    await _fetchBookings();
    setState(() => _isRefreshing = false);
  }

  Future<void> _fetchBookings() async {
    if (_userId.isEmpty) {
      setState(() => _bookings = []);
      return;
    }
    try {
      final bookings = await _bookingRepository.getUserBookings(_userId);
      setState(() => _bookings = bookings);
    } catch (e) {
      debugPrint('Error loading bookings: $e');
    }
  }

  // ── Cancel logic ──────────────────────────────────────────────────────────

  bool _canCancel(BookingStatus status) =>
      _cancellableStatuses.contains(status);

  String _getCancelReason(BookingStatus status) {
    switch (status) {
      case BookingStatus.sampleCollected:
        return 'Sample already collected, cannot cancel';
      case BookingStatus.processing:
        return 'Test is being processed, cannot cancel';
      case BookingStatus.reportReady:
        return 'Report is ready, please contact support';
      case BookingStatus.completed:
        return 'Booking already completed';
      case BookingStatus.cancelled:
        return 'Booking already cancelled';
      default:
        return '';
    }
  }

  Future<void> _cancelBooking(BookingModel booking) async {
    if (!_canCancel(booking.status)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_getCancelReason(booking.status)),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel '
              '${booking.test?.name ?? 'this test'}?',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.error),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cancellation is only allowed for pending/confirmed bookings',
                      style: TextStyle(fontSize: 12, color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, Keep It',
                style: TextStyle(color: AppColors.textGray)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Cancel',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isRefreshing = true);
    final success = await _bookingRepository.cancelBooking(booking.id);

    if (success) {
      setState(() {
        final index = _bookings.indexWhere((b) => b.id == booking.id);
        if (index != -1) {
          _bookings[index] = booking.copyWith(status: BookingStatus.cancelled);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Booking cancelled successfully'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to cancel booking. Please try again.'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 3),
        ));
      }
    }

    setState(() => _isRefreshing = false);
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _navigateToTestList() => Navigator.pushNamed(context, '/tests');

  void _downloadReport(BookingModel booking) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Download started...'),
      duration: Duration(seconds: 2),
    ));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatDate(DateTime date) => DateFormat('MMM dd, yyyy').format(date);

  Map<String, dynamic> _getStatusConfig(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return {
          'label': 'Pending',
          'color': AppColors.warning,
          'bgColor': AppColors.warning.withOpacity(0.1),
          'icon': Icons.access_time,
          'progress': 0,
        };
      case BookingStatus.confirmed:
        return {
          'label': 'Confirmed',
          'color': AppColors.info,
          'bgColor': AppColors.info.withOpacity(0.1),
          'icon': Icons.check_circle_outline,
          'progress': 20,
        };
      case BookingStatus.sampleCollected:
        return {
          'label': 'Sample Collected',
          'color': AppColors.secondaryBlue,
          'bgColor': AppColors.secondaryBlue.withOpacity(0.1),
          'icon': Icons.inbox,
          'progress': 40,
        };
      case BookingStatus.processing:
        return {
          'label': 'Processing',
          'color': AppColors.secondaryPurple,
          'bgColor': AppColors.secondaryPurple.withOpacity(0.1),
          'icon': Icons.science,
          'progress': 60,
        };
      case BookingStatus.reportReady:
        return {
          'label': 'Report Ready',
          'color': AppColors.success,
          'bgColor': AppColors.success.withOpacity(0.1),
          'icon': Icons.description,
          'progress': 90,
        };
      case BookingStatus.completed:
        return {
          'label': 'Completed',
          'color': AppColors.primaryGreen,
          'bgColor': AppColors.primaryExtraLight,
          'icon': Icons.done_all,
          'progress': 100,
        };
      case BookingStatus.cancelled:
        return {
          'label': 'Cancelled',
          'color': AppColors.error,
          'bgColor': AppColors.error.withOpacity(0.1),
          'icon': Icons.cancel,
          'progress': 0,
        };
      default:
        return {
          'label': 'Pending',
          'color': AppColors.warning,
          'bgColor': AppColors.warning.withOpacity(0.1),
          'icon': Icons.access_time,
          'progress': 0,
        };
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'My Orders',
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
        onRefresh: _refreshBookings,
        color: AppColors.primaryGreen,
        child: _isLoading
            ? _buildLoadingState()
            : _bookings.isEmpty
                ? _buildEmptyState()
                : _buildBookingsList(),
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
          Text('Loading your bookings...',
              style: TextStyle(color: AppColors.textGray)),
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
            child: const Icon(Icons.history,
                size: 50, color: AppColors.primaryGreen),
          ),
          const SizedBox(height: 24),
          const Text('No Bookings Yet',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
          const SizedBox(height: 8),
          const Text('Book your first diagnostic test',
              style: TextStyle(fontSize: 14, color: AppColors.textGray)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _navigateToTestList,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Browse Tests'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _bookings.length,
      itemBuilder: (context, index) => _buildBookingCard(_bookings[index]),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    final statusConfig = _getStatusConfig(booking.status);
    final isActive = booking.status != BookingStatus.completed &&
        booking.status != BookingStatus.cancelled;
    final isCancellable = _canCancel(booking.status);
    final canShowReport = booking.status == BookingStatus.reportReady;
    final progress = statusConfig['progress'] as int;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BookingDetailScreen(booking: booking)),
      ),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.test?.name ?? 'Diagnostic Test',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark),
                        ),
                        const SizedBox(height: 4),
                        Text('ID: ${booking.id}',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textLightGray)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusConfig['bgColor'],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusConfig['icon'],
                            size: 14, color: statusConfig['color']),
                        const SizedBox(width: 4),
                        Text(statusConfig['label'],
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: statusConfig['color'])),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(
                height: 0, thickness: 0.5, color: AppColors.borderLight),

            // Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow('Date & Time',
                      '${_formatDate(booking.bookingDate)} • ${booking.timeSlot}'),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                      'Service Type',
                      booking.bookingType == BookingType.homeSampling
                          ? 'Home Sampling'
                          : 'Lab Visit'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Location', booking.sector),
                ],
              ),
            ),

            // Progress bar
            if (isActive)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Order Progress',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.textGray)),
                        Text('$progress%',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGreen)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: AppColors.borderLight,
                        color: AppColors.primaryGreen,
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  if (booking.status == BookingStatus.reportReady ||
                      booking.status == BookingStatus.completed)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _downloadReport(booking),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Download Report',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  if (isCancellable &&
                      !canShowReport &&
                      booking.status != BookingStatus.cancelled)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _cancelBooking(booking),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Cancel Booking',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.error)),
                      ),
                    ),
                  if (booking.status == BookingStatus.cancelled)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _navigateToTestList,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryGreen),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Book Again',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.primaryGreen)),
                      ),
                    ),
                ],
              ),
            ),

            // Non-cancellable reason banner
            if (!isCancellable &&
                isActive &&
                !canShowReport &&
                booking.status != BookingStatus.cancelled)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 14, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_getCancelReason(booking.status),
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.warning)),
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: AppColors.textGray)),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark)),
      ],
    );
  }
}
