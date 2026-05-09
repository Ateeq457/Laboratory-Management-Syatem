// lib/services/json_service.dart
// JSON Service - Reads mock data from assets
// This can be replaced with API calls later without changing UI

import 'dart:convert';
import 'package:flutter/services.dart';

// Models
import '../data/models/test_model.dart';
import '../data/models/booking_model.dart';
import '../data/models/sector_model.dart';
import '../data/models/user_model.dart';
import '../data/models/report_model.dart';

class JsonService {
  static final JsonService _instance = JsonService._internal();
  factory JsonService() => _instance;
  JsonService._internal();

  // ==================== TESTS ====================

  Future<List<TestModel>> getTests() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/json/tests.json',
      );
      final Map<String, dynamic> data = json.decode(response);
      final List<dynamic> testsJson = data['tests'];
      return testsJson.map((json) => TestModel.fromJson(json)).toList();
    } catch (e) {
      print('Error loading tests: $e');
      return [];
    }
  }

  Future<List<TestModel>> getFeaturedTests() async {
    final tests = await getTests();
    return tests.where((test) => test.isFeatured).toList();
  }

  Future<List<TestModel>> getPopularTests() async {
    final tests = await getTests();
    return tests.where((test) => test.isPopular).toList();
  }

  Future<List<TestModel>> getTestsByCategory(String category) async {
    final tests = await getTests();
    return tests
        .where(
          (test) =>
              test.getCategoryDisplayName().toLowerCase() ==
              category.toLowerCase(),
        )
        .toList();
  }

  Future<TestModel?> getTestById(String id) async {
    final tests = await getTests();
    try {
      return tests.firstWhere((test) => test.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<TestModel>> searchTests(String query) async {
    final tests = await getTests();
    if (query.isEmpty) return tests;
    return tests
        .where(
          (test) =>
              test.name.toLowerCase().contains(query.toLowerCase()) ||
              test.nameUrdu.contains(query) ||
              test.getCategoryDisplayName().toLowerCase().contains(
                query.toLowerCase(),
              ),
        )
        .toList();
  }

  // ==================== BOOKINGS ====================

  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final String response = await rootBundle.loadString(
        'assets/json/bookings.json',
      );
      final Map<String, dynamic> data = json.decode(response);
      final List<dynamic> bookingsJson = data['bookings'];
      final allBookings = bookingsJson
          .map((json) => BookingModel.fromJson(json))
          .toList();

      // Filter by user (for now, return all since we have one user)
      // In real API, this would be filtered on backend
      return allBookings;
    } catch (e) {
      print('Error loading bookings: $e');
      return [];
    }
  }

  Future<BookingModel?> getBookingById(String bookingId) async {
    final bookings = await getUserBookings('');
    try {
      return bookings.firstWhere((booking) => booking.id == bookingId);
    } catch (e) {
      return null;
    }
  }

  Future<List<BookingModel>> getActiveBookings(String userId) async {
    final bookings = await getUserBookings(userId);
    return bookings
        .where(
          (booking) =>
              booking.status != BookingStatus.completed &&
              booking.status != BookingStatus.cancelled,
        )
        .toList();
  }

  Future<List<BookingModel>> getCompletedBookings(String userId) async {
    final bookings = await getUserBookings(userId);
    return bookings
        .where(
          (booking) =>
              booking.status == BookingStatus.completed ||
              (booking.status == BookingStatus.reportReady &&
                  booking.isReportViewed),
        )
        .toList();
  }

  // ==================== SECTORS ====================

  Future<List<SectorModel>> getSectors() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/json/sectors.json',
      );
      final Map<String, dynamic> data = json.decode(response);
      final List<dynamic> sectorsJson = data['sectors'];
      return sectorsJson.map((json) => SectorModel.fromJson(json)).toList();
    } catch (e) {
      print('Error loading sectors: $e');
      return SectorModel.getSectors(); // Fallback to hardcoded
    }
  }

  Future<SectorModel?> getSectorById(String id) async {
    final sectors = await getSectors();
    try {
      return sectors.firstWhere((sector) => sector.id == id);
    } catch (e) {
      return null;
    }
  }

  // ==================== USERS ====================

  Future<UserModel?> getUser(String userId) async {
    try {
      final String response = await rootBundle.loadString(
        'assets/json/users.json',
      );
      final Map<String, dynamic> data = json.decode(response);
      final List<dynamic> usersJson = data['users'];
      final users = usersJson.map((json) => UserModel.fromJson(json)).toList();

      try {
        return users.firstWhere((user) => user.id == userId);
      } catch (e) {
        return users.isNotEmpty ? users.first : null;
      }
    } catch (e) {
      print('Error loading users: $e');
      return null;
    }
  }

  // ==================== REPORTS ====================

  Future<List<ReportModel>> getUserReports(String userId) async {
    // Get completed bookings with reports
    final bookings = await getUserBookings(userId);
    final reports = <ReportModel>[];

    for (final booking in bookings) {
      if (booking.isReportAvailable && booking.reportUrl != null) {
        reports.add(
          ReportModel(
            id: 'report_${booking.id}',
            bookingId: booking.id,
            testName: booking.test?.name ?? 'Test Report',
            reportUrl: booking.reportUrl!,
            generatedAt: booking.reportReadyAt ?? booking.createdAt,
            fileSize: 250,
            isSigned: true,
            signedBy: 'Dr. Pathologist, Thal-Care Lab',
          ),
        );
      }
    }

    return reports;
  }

  // ==================== CREATE BOOKING (Mock) ====================

  Future<BookingModel> createBooking({
    required String userId,
    required String testId,
    required String sector,
    String? streetNumber,
    String? houseNumber,
    required BookingType bookingType,
    required DateTime bookingDate,
    required String timeSlot,
    required double basePrice,
    double? homeSamplingFee,
    String? notes,
  }) async {
    // Calculate total price
    final totalPrice = basePrice + (homeSamplingFee ?? 0);

    // Create new booking
    final newBooking = BookingModel(
      id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      testId: testId,
      sector: sector,
      streetNumber: streetNumber,
      houseNumber: houseNumber,
      fullAddress: '$streetNumber, $houseNumber, $sector',
      bookingType: bookingType,
      bookingDate: bookingDate,
      timeSlot: timeSlot,
      status: BookingStatus.pending,
      basePrice: basePrice,
      homeSamplingFee: homeSamplingFee,
      totalPrice: totalPrice,
      createdAt: DateTime.now(),
      notes: notes,
    );

    // In real app, this would be saved to backend
    // For now, just return the created booking
    return newBooking;
  }
}
