// lib/data/models/booking_model.dart
// Booking Model for Thal-Care App

import 'package:lab_system/data/models/test_model.dart';

enum BookingStatus {
  pending, // Just booked
  confirmed, // Payment received / confirmed
  sampleCollected, // Sample collected from home/lab
  processing, // Lab processing
  reportReady, // Report generated
  completed, // User viewed report
  cancelled, // Booking cancelled
}

enum BookingType { labVisit, homeSampling }

class BookingModel {
  final String id;
  final String userId;
  final String testId;
  final TestModel? test; // Populated when needed

  // Location Details
  final String sector; // Sector 1-4
  final String? streetNumber;
  final String? houseNumber;
  final String? fullAddress;

  // Booking Details
  final BookingType bookingType;
  final DateTime bookingDate;
  final String timeSlot; // e.g., "09:00 AM - 10:00 AM"
  final BookingStatus status;

  // Pricing
  final double basePrice;
  final double? homeSamplingFee;
  final double totalPrice;

  // Tracking
  final DateTime createdAt;
  DateTime? updatedAt;
  DateTime? sampleCollectedAt;
  DateTime? reportReadyAt;

  // Additional Info
  final String? notes;
  final String? prescriptionUrl;

  // Report
  final String? reportUrl;
  final bool isReportViewed;

  BookingModel({
    required this.id,
    required this.userId,
    required this.testId,
    this.test,
    required this.sector,
    this.streetNumber,
    this.houseNumber,
    this.fullAddress,
    required this.bookingType,
    required this.bookingDate,
    required this.timeSlot,
    required this.status,
    required this.basePrice,
    this.homeSamplingFee,
    required this.totalPrice,
    required this.createdAt,
    this.updatedAt,
    this.sampleCollectedAt,
    this.reportReadyAt,
    this.notes,
    this.prescriptionUrl,
    this.reportUrl,
    this.isReportViewed = false,
  });

  // From JSON
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      testId: json['test_id']?.toString() ?? '',
      test: json['test'] != null ? TestModel.fromJson(json['test']) : null,
      sector: json['sector']?.toString() ?? '',
      streetNumber: json['street_number']?.toString(),
      houseNumber: json['house_number']?.toString(),
      fullAddress: json['full_address']?.toString(),
      bookingType: json['booking_type'] == 'home'
          ? BookingType.homeSampling
          : BookingType.labVisit,
      bookingDate: json['booking_date'] != null
          ? DateTime.parse(json['booking_date'])
          : DateTime.now(),
      timeSlot: json['time_slot']?.toString() ?? '',
      status: _parseStatus(json['status']?.toString() ?? 'pending'),
      basePrice: (json['base_price'] ?? 0).toDouble(),
      homeSamplingFee: json['home_sampling_fee']?.toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      sampleCollectedAt: json['sample_collected_at'] != null
          ? DateTime.parse(json['sample_collected_at'])
          : null,
      reportReadyAt: json['report_ready_at'] != null
          ? DateTime.parse(json['report_ready_at'])
          : null,
      notes: json['notes']?.toString(),
      prescriptionUrl: json['prescription_url']?.toString(),
      reportUrl: json['report_url']?.toString(),
      isReportViewed: json['is_report_viewed'] ?? false,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'test_id': testId,
      'sector': sector,
      'street_number': streetNumber,
      'house_number': houseNumber,
      'full_address': fullAddress,
      'booking_type': bookingType == BookingType.homeSampling ? 'home' : 'lab',
      'booking_date': bookingDate.toIso8601String(),
      'time_slot': timeSlot,
      'status': _statusToString(status),
      'base_price': basePrice,
      'home_sampling_fee': homeSamplingFee,
      'total_price': totalPrice,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'sample_collected_at': sampleCollectedAt?.toIso8601String(),
      'report_ready_at': reportReadyAt?.toIso8601String(),
      'notes': notes,
      'prescription_url': prescriptionUrl,
      'report_url': reportUrl,
      'is_report_viewed': isReportViewed,
    };
  }

  // ==================== COPYWITH METHOD (ADDED) ====================
  BookingModel copyWith({
    String? id,
    String? userId,
    String? testId,
    TestModel? test,
    String? sector,
    String? streetNumber,
    String? houseNumber,
    String? fullAddress,
    BookingType? bookingType,
    DateTime? bookingDate,
    String? timeSlot,
    BookingStatus? status,
    double? basePrice,
    double? homeSamplingFee,
    double? totalPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? sampleCollectedAt,
    DateTime? reportReadyAt,
    String? notes,
    String? prescriptionUrl,
    String? reportUrl,
    bool? isReportViewed,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      testId: testId ?? this.testId,
      test: test ?? this.test,
      sector: sector ?? this.sector,
      streetNumber: streetNumber ?? this.streetNumber,
      houseNumber: houseNumber ?? this.houseNumber,
      fullAddress: fullAddress ?? this.fullAddress,
      bookingType: bookingType ?? this.bookingType,
      bookingDate: bookingDate ?? this.bookingDate,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      basePrice: basePrice ?? this.basePrice,
      homeSamplingFee: homeSamplingFee ?? this.homeSamplingFee,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sampleCollectedAt: sampleCollectedAt ?? this.sampleCollectedAt,
      reportReadyAt: reportReadyAt ?? this.reportReadyAt,
      notes: notes ?? this.notes,
      prescriptionUrl: prescriptionUrl ?? this.prescriptionUrl,
      reportUrl: reportUrl ?? this.reportUrl,
      isReportViewed: isReportViewed ?? this.isReportViewed,
    );
  }

  // Get status display name (for UI)
  String getStatusDisplayName() {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.sampleCollected:
        return 'Sample Collected';
      case BookingStatus.processing:
        return 'Processing';
      case BookingStatus.reportReady:
        return 'Report Ready';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  // Get status color
  String getStatusColorHex() {
    switch (status) {
      case BookingStatus.pending:
        return '#f59e0b'; // Amber
      case BookingStatus.confirmed:
        return '#3b82f6'; // Blue
      case BookingStatus.sampleCollected:
        return '#8b5cf6'; // Purple
      case BookingStatus.processing:
        return '#06b6d4'; // Cyan
      case BookingStatus.reportReady:
        return '#10b981'; // Green
      case BookingStatus.completed:
        return '#059669'; // Dark Green
      case BookingStatus.cancelled:
        return '#ef4444'; // Red
    }
  }

  // Check if report is available
  bool get isReportAvailable {
    return reportUrl != null && reportUrl!.isNotEmpty;
  }

  static BookingStatus _parseStatus(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'sample_collected':
        return BookingStatus.sampleCollected;
      case 'processing':
        return BookingStatus.processing;
      case 'report_ready':
        return BookingStatus.reportReady;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }

  static String _statusToString(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.sampleCollected:
        return 'sample_collected';
      case BookingStatus.processing:
        return 'processing';
      case BookingStatus.reportReady:
        return 'report_ready';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.cancelled:
        return 'cancelled';
    }
  }
}
