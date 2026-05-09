// lib/data/repositories/supabase_booking_repository.dart
// Supabase Implementation of Booking Repository

import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'base_booking_repository.dart';
import '../models/booking_model.dart';
import '../models/test_model.dart';

class SupabaseBookingRepository implements BaseBookingRepository {
  final _supabase = Supabase.instance.client;
  RealtimeChannel? _channel;

  @override
  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      // Remove hardcoded 'user_001' and use actual UUID
      final response = await _supabase
          .from('bookings')
          .select('*, tests(*)')
          .eq('user_id', userId) // userId should be actual UUID
          .order('created_at', ascending: false);

      return response.map((json) => BookingModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  @override
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('*, tests(*)')
          .eq('id', bookingId)
          .single();

      return BookingModel.fromJson(response);
    } catch (e) {
      print('Error fetching booking: $e');
      return null;
    }
  }

  @override
  Future<List<BookingModel>> getActiveBookings(String userId) async {
    final bookings = await getUserBookings(userId);
    return bookings
        .where((b) =>
            b.status != BookingStatus.completed &&
            b.status != BookingStatus.cancelled)
        .toList();
  }

  @override
  Future<List<BookingModel>> getCompletedBookings(String userId) async {
    final bookings = await getUserBookings(userId);
    return bookings.where((b) => b.status == BookingStatus.completed).toList();
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
    print('🟡 Creating booking for userId: $userId');
    print('🟡 TestId: $testId');

    final homeSamplingFee = bookingType == BookingType.homeSampling
        ? test.homeSamplingFee ?? 500
        : null;

    final totalPrice = test.price + (homeSamplingFee ?? 0);

    final newBooking = {
      'user_id': userId,
      'test_id': testId,
      'sector': sector,
      'street_number': streetNumber,
      'house_number': houseNumber,
      'full_address': '$streetNumber, $houseNumber, $sector',
      'booking_type': bookingType == BookingType.homeSampling ? 'home' : 'lab',
      'booking_date': bookingDate.toIso8601String(),
      'time_slot': timeSlot,
      'status': 'pending',
      'base_price': test.price,
      'home_sampling_fee': homeSamplingFee,
      'total_price': totalPrice,
      'notes': notes,
      'created_at': DateTime.now().toIso8601String(),
    };

    try {
      final response =
          await _supabase.from('bookings').insert(newBooking).select().single();

      print('✅ Booking created with ID: ${response['id']}');
      return BookingModel.fromJson(response);
    } catch (e) {
      print('❌ Error creating booking: $e');
      rethrow;
    }
  }

  @override
  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _supabase
          .from('bookings')
          .update({'status': 'cancelled'}).eq('id', bookingId);
      return true;
    } catch (e) {
      print('Error cancelling booking: $e');
      return false;
    }
  }

  @override
  Stream<BookingStatus> trackBookingStatus(String bookingId) {
    // Create a broadcast stream controller
    final controller = StreamController<BookingStatus>.broadcast();

    // Subscribe to changes on the bookings table
    _channel = _supabase.channel('booking_status_$bookingId');

    _channel!.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'bookings',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: bookingId,
      ),
      callback: (payload) {
        final newStatus = payload.newRecord['status'] as String;
        final status = _parseStatus(newStatus);
        if (!controller.isClosed) {
          controller.add(status);
        }
      },
    );

    _channel!.subscribe();

    // Return the stream and clean up on cancel
    return controller.stream;
  }

  BookingStatus _parseStatus(String status) {
    switch (status) {
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

  @override
  Future<List<String>> getAvailableTimeSlots(DateTime date) async {
    // Get booked slots for this date
    final dateStr = date.toIso8601String().split('T').first;
    final response = await _supabase
        .from('bookings')
        .select('time_slot')
        .eq('date', dateStr);

    final bookedSlots = response.map((b) => b['time_slot'] as String).toSet();

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

    return allSlots.where((slot) => !bookedSlots.contains(slot)).toList();
  }
}
