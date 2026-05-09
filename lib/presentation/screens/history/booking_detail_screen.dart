// lib/presentation/screens/history/booking_detail_screen.dart
// Professional Booking Detail Screen

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lab_system/core/themes/app_theme.dart';
import 'package:lab_system/data/models/booking_model.dart';

class BookingDetailScreen extends StatefulWidget {
  final BookingModel booking;

  const BookingDetailScreen({
    super.key,
    required this.booking,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _downloadReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download started...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, MMMM dd, yyyy').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  Map<String, dynamic> _getStatusConfig(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return {
          'label': 'Pending',
          'color': AppColors.warning,
          'bgColor': AppColors.warning.withOpacity(0.1),
          'icon': Icons.access_time,
          'progress': 0,
          'description': 'Your booking is pending confirmation',
        };
      case BookingStatus.confirmed:
        return {
          'label': 'Confirmed',
          'color': AppColors.info,
          'bgColor': AppColors.info.withOpacity(0.1),
          'icon': Icons.check_circle_outline,
          'progress': 25,
          'description': 'Your booking has been confirmed',
        };
      case BookingStatus.sampleCollected:
        return {
          'label': 'Sample Collected',
          'color': AppColors.secondaryBlue,
          'bgColor': AppColors.secondaryBlue.withOpacity(0.1),
          'icon': Icons.inbox,
          'progress': 50,
          'description': 'Your sample has been collected',
        };
      case BookingStatus.processing:
        return {
          'label': 'Processing',
          'color': AppColors.secondaryPurple,
          'bgColor': AppColors.secondaryPurple.withOpacity(0.1),
          'icon': Icons.science,
          'progress': 75,
          'description': 'Your sample is being processed',
        };
      case BookingStatus.reportReady:
        return {
          'label': 'Report Ready',
          'color': AppColors.success,
          'bgColor': AppColors.success.withOpacity(0.1),
          'icon': Icons.description,
          'progress': 90,
          'description': 'Your report is ready to download',
        };
      case BookingStatus.completed:
        return {
          'label': 'Completed',
          'color': AppColors.primaryGreen,
          'bgColor': AppColors.primaryExtraLight,
          'icon': Icons.done_all,
          'progress': 100,
          'description': 'Booking completed successfully',
        };
      case BookingStatus.cancelled:
        return {
          'label': 'Cancelled',
          'color': AppColors.error,
          'bgColor': AppColors.error.withOpacity(0.1),
          'icon': Icons.cancel,
          'progress': 0,
          'description': 'This booking has been cancelled',
        };
      default:
        return {
          'label': 'Pending',
          'color': AppColors.warning,
          'bgColor': AppColors.warning.withOpacity(0.1),
          'icon': Icons.access_time,
          'progress': 0,
          'description': 'Your booking is pending confirmation',
        };
    }
  }

  List<Map<String, dynamic>> _getTimelineSteps(BookingStatus currentStatus) {
    final List<Map<String, dynamic>> allSteps = [
      {
        'status': BookingStatus.pending,
        'title': 'Booking Created',
        'icon': Icons.event_available
      },
      {
        'status': BookingStatus.confirmed,
        'title': 'Confirmed',
        'icon': Icons.check_circle
      },
      {
        'status': BookingStatus.sampleCollected,
        'title': 'Sample Collected',
        'icon': Icons.inbox
      },
      {
        'status': BookingStatus.processing,
        'title': 'Processing',
        'icon': Icons.science
      },
      {
        'status': BookingStatus.reportReady,
        'title': 'Report Ready',
        'icon': Icons.description
      },
    ];

    final currentIndex =
        allSteps.indexWhere((step) => step['status'] == currentStatus);

    return allSteps.asMap().entries.map((entry) {
      final index = entry.key;
      final step = entry.value;
      final isCompleted = index <= currentIndex;
      final isCurrent = index == currentIndex;

      // Fix: Explicitly cast step['status'] to BookingStatus
      final stepStatus = step['status'] as BookingStatus;

      return {
        'title': step['title'],
        'icon': step['icon'],
        'isCompleted': isCompleted,
        'isCurrent': isCurrent,
        'dateTime': _getStepDateTime(currentStatus, stepStatus),
      };
    }).toList();
  }

  String? _getStepDateTime(
      BookingStatus currentStatus, BookingStatus stepStatus) {
    if (stepStatus == currentStatus) {
      return 'In Progress';
    }
    if (stepStatus == BookingStatus.pending) {
      return _formatDate(widget.booking.createdAt);
    }
    if (stepStatus == BookingStatus.sampleCollected &&
        widget.booking.sampleCollectedAt != null) {
      return _formatDate(widget.booking.sampleCollectedAt!);
    }
    if (stepStatus == BookingStatus.reportReady &&
        widget.booking.reportReadyAt != null) {
      return _formatDate(widget.booking.reportReadyAt!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final statusConfig = _getStatusConfig(widget.booking.status);
    final progress = statusConfig['progress'] as int;
    final isReportReady = widget.booking.status == BookingStatus.reportReady;
    final isCancelled = widget.booking.status == BookingStatus.cancelled;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Booking Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              _buildStatusCard(statusConfig, progress, isCancelled),

              const SizedBox(height: 20),

              // Booking Info Card
              _buildBookingInfoCard(),

              const SizedBox(height: 20),

              // Test Details Card
              _buildTestDetailsCard(),

              const SizedBox(height: 20),

              // Timeline Card
              _buildTimelineCard(),

              const SizedBox(height: 20),

              // Action Button
              if (widget.booking.status == BookingStatus.reportReady ||
                  widget.booking.status == BookingStatus.completed)
                _buildDownloadButton(),
              if (isCancelled) _buildBookAgainButton(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(
      Map<String, dynamic> statusConfig, int progress, bool isCancelled) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCancelled
              ? [
                  AppColors.error.withOpacity(0.9),
                  AppColors.error.withOpacity(0.7)
                ]
              : [AppColors.primaryGreen, AppColors.primaryMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isCancelled
                ? AppColors.error.withOpacity(0.3)
                : AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  statusConfig['icon'],
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Status',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusConfig['label'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isCancelled) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                Text(
                  '$progress%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: Colors.white.withOpacity(0.3),
                color: Colors.white,
                minHeight: 6,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    statusConfig['description'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              const Text(
                'Booking Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildInfoRow('Booking ID', widget.booking.id),
          const SizedBox(height: 12),
          _buildInfoRow('Booking Date', _formatDate(widget.booking.createdAt)),
          const SizedBox(height: 12),
          _buildInfoRow('Booking Time', _formatTime(widget.booking.createdAt)),
        ],
      ),
    );
  }

  Widget _buildTestDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Icon(Icons.medical_services,
                  size: 20, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              const Text(
                'Test Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildInfoRow(
              'Test Name', widget.booking.test?.name ?? 'Diagnostic Test'),
          const SizedBox(height: 12),
          _buildInfoRow(
              'Service Type',
              widget.booking.bookingType == BookingType.homeSampling
                  ? 'Home Sampling'
                  : 'Lab Visit'),
          const SizedBox(height: 12),
          if (widget.booking.bookingType == BookingType.homeSampling &&
              widget.booking.fullAddress != null)
            _buildInfoRow('Address', widget.booking.fullAddress!,
                multiLine: true),
          _buildInfoRow('Date & Time',
              '${_formatDate(widget.booking.bookingDate)} • ${widget.booking.timeSlot}'),
          const SizedBox(height: 12),
          _buildInfoRow('Sector', widget.booking.sector),
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
    final steps = _getTimelineSteps(widget.booking.status);
    final isCancelled = widget.booking.status == BookingStatus.cancelled;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Icon(Icons.timeline, size: 20, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              const Text(
                'Booking Timeline',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Divider(height: 24),
          if (isCancelled)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.cancel, size: 18, color: AppColors.error),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This booking has been cancelled',
                      style: TextStyle(fontSize: 13, color: AppColors.error),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: steps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;
                final isLast = index == steps.length - 1;

                return _buildTimelineStep(
                  title: step['title'],
                  icon: step['icon'],
                  isCompleted: step['isCompleted'],
                  isCurrent: step['isCurrent'],
                  dateTime: step['dateTime'],
                  isLast: isLast,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required IconData icon,
    required bool isCompleted,
    required bool isCurrent,
    String? dateTime,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.primaryGreen
                    : AppColors.backgroundLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? AppColors.primaryGreen
                      : AppColors.borderLight,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 16,
                color: isCompleted ? Colors.white : AppColors.textLightGray,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: isCompleted
                    ? AppColors.primaryGreen
                    : AppColors.borderLight,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    color:
                        isCompleted ? AppColors.textDark : AppColors.textGray,
                  ),
                ),
                if (dateTime != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    dateTime,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textLightGray,
                    ),
                  ),
                ],
                if (isCurrent)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Current',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool multiLine = false}) {
    return Row(
      crossAxisAlignment:
          multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textGray,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
            maxLines: multiLine ? 3 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _downloadReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download, size: 20),
            SizedBox(width: 8),
            Text(
              'Download Report',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookAgainButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/tests');
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primaryGreen),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh, size: 20, color: AppColors.primaryGreen),
            SizedBox(width: 8),
            Text(
              'Book Again',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen),
            ),
          ],
        ),
      ),
    );
  }
}
