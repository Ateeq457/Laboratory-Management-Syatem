// lib/data/repositories/json_booking_repository.dart
// JSON Implementation of Booking Repository

import 'dart:async';
import 'package:lab_system/services/json_service.dart';
import 'base_booking_repository.dart';
import '../models/booking_model.dart';
import '../models/test_model.dart';

class JsonBookingRepository implements BaseBookingRepository {
  final JsonService _jsonService = JsonService();

  @override
  Future<List<BookingModel>> getUserBookings(String userId) async {
    return await _jsonService.getUserBookings(userId);
  }

  @override
  Future<BookingModel?> getBookingById(String bookingId) async {
    return await _jsonService.getBookingById(bookingId);
  }

  @override
  Future<List<BookingModel>> getActiveBookings(String userId) async {
    return await _jsonService.getActiveBookings(userId);
  }

  @override
  Future<List<BookingModel>> getCompletedBookings(String userId) async {
    return await _jsonService.getCompletedBookings(userId);
  }

  @override
  Future<BookingModel> createBooking({
    required String userId,
    required String testId,
    required TestModel test,
    required String sector,
    String? streetNumber,
    String? houseNumber,
    required BookingType bookingType,
    required DateTime bookingDate,
    required String timeSlot,
    String? notes,
  }) async {
    final homeSamplingFee = bookingType == BookingType.homeSampling
        ? test.homeSamplingFee ?? 500
        : null;

    return await _jsonService.createBooking(
      userId: userId,
      testId: testId,
      sector: sector,
      streetNumber: streetNumber,
      houseNumber: houseNumber,
      bookingType: bookingType,
      bookingDate: bookingDate,
      timeSlot: timeSlot,
      basePrice: test.price,
      homeSamplingFee: homeSamplingFee,
      notes: notes,
    );
  }

  @override
  Future<bool> cancelBooking(String bookingId) async {
    // In JSON mock, we just return true
    // In real API, this would make a network call
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  @override
  Stream<BookingStatus> trackBookingStatus(String bookingId) async* {
    // Simulate real-time status updates
    await Future.delayed(const Duration(seconds: 1));
    yield BookingStatus.pending;

    await Future.delayed(const Duration(seconds: 3));
    yield BookingStatus.confirmed;

    // In real app, this would be from Supabase Realtime
  }

  @override
  Future<List<String>> getAvailableTimeSlots(DateTime date) async {
    // Mock time slots (8 AM to 8 PM)
    const allSlots = [
      '08:00 AM - 09:00 AM',
      '09:00 AM - 10:00 AM',
      '10:00 AM - 11:00 AM',
      '11:00 AM - 12:00 PM',
      '12:00 PM - 01:00 PM',
      '01:00 PM - 02:00 PM',
      '02:00 PM - 03:00 PM',
      '03:00 PM - 04:00 PM',
      '04:00 PM - 05:00 PM',
      '05:00 PM - 06:00 PM',
      '06:00 PM - 07:00 PM',
      '07:00 PM - 08:00 PM',
    ];

    // Simulate some slots being booked
    // In real app, check against database
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      return allSlots.take(8).toList(); // Limited slots on weekend
    }

    return allSlots;
  }
}
