// lib/data/repositories/base_booking_repository.dart
// Abstract Repository for Bookings

import '../models/booking_model.dart';
import '../models/test_model.dart';

abstract class BaseBookingRepository {
  // Get all bookings for a user
  Future<List<BookingModel>> getUserBookings(String userId);

  // Get single booking by ID
  Future<BookingModel?> getBookingById(String bookingId);

  // Get active bookings (pending, confirmed, processing, etc.)
  Future<List<BookingModel>> getActiveBookings(String userId);

  // Get completed bookings
  Future<List<BookingModel>> getCompletedBookings(String userId);

  // Create new booking
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
  });

  // Cancel booking
  Future<bool> cancelBooking(String bookingId);

  // Track booking status (realtime)
  Stream<BookingStatus> trackBookingStatus(String bookingId);

  // Get available time slots for a date
  Future<List<String>> getAvailableTimeSlots(DateTime date);
}
