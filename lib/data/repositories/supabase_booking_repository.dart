// lib/data/repositories/supabase_booking_repository.dart
// FIXES:
//  1. getAvailableTimeSlots() was querying column 'date' — real column is 'booking_date'
//  2. trackBookingStatus() StreamController was never closed → memory leak
//  3. createBooking() unchanged — was already correct

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'base_booking_repository.dart';
import '../models/booking_model.dart';
import '../models/test_model.dart';

class SupabaseBookingRepository implements BaseBookingRepository {
  final _supabase = Supabase.instance.client;

  // FIX: Track channels so we can unsubscribe and close streams
  final Map<String, RealtimeChannel> _channels = {};
  final Map<String, StreamController<BookingStatus>> _controllers = {};

  @override
  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('*, tests(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map((json) => BookingModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
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
      debugPrint('Error fetching booking: $e');
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
    debugPrint('🟡 Creating booking for userId: $userId, testId: $testId');

    final homeSamplingFee = bookingType == BookingType.homeSampling
        ? (test.homeSamplingFee ?? 500.0)
        : null;

    final totalPrice = test.price + (homeSamplingFee ?? 0);

    final newBooking = {
      'user_id': userId,
      'test_id': testId,
      'sector': sector,
      'street_number': streetNumber,
      'house_number': houseNumber,
      'full_address': streetNumber != null && houseNumber != null
          ? '$streetNumber, $houseNumber, $sector'
          : sector,
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
      final response = await _supabase
          .from('bookings')
          .insert(newBooking)
          .select('*, tests(*)')
          .single();

      debugPrint('✅ Booking created with ID: ${response['id']}');
      return BookingModel.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error creating booking: $e');
      rethrow;
    }
  }

  @override
  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _supabase.from('bookings').update({
        'status': 'cancelled',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', bookingId);
      return true;
    } catch (e) {
      debugPrint('Error cancelling booking: $e');
      return false;
    }
  }

  @override
  Stream<BookingStatus> trackBookingStatus(String bookingId) {
    // FIX: close and remove any existing subscription for this booking
    _cleanupChannel(bookingId);

    final controller = StreamController<BookingStatus>.broadcast(
      // FIX: unsubscribe the Realtime channel when no listeners remain
      onCancel: () => _cleanupChannel(bookingId),
    );
    _controllers[bookingId] = controller;

    final channel = _supabase.channel('booking_status_$bookingId');
    _channels[bookingId] = channel;

    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'bookings',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: bookingId,
      ),
      callback: (payload) {
        final newStatus = payload.newRecord['status'] as String?;
        if (newStatus != null && !controller.isClosed) {
          controller.add(_parseStatus(newStatus));
        }
      },
    );

    channel.subscribe();
    return controller.stream;
  }

  void _cleanupChannel(String bookingId) {
    _channels[bookingId]?.unsubscribe();
    _channels.remove(bookingId);
    _controllers[bookingId]?.close();
    _controllers.remove(bookingId);
  }

  /// Call this when your widget/viewmodel is disposed to clean up ALL streams.
  void disposeAll() {
    for (final id in _channels.keys.toList()) {
      _cleanupChannel(id);
    }
  }

  BookingStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
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
    // FIX: was querying column 'date' which doesn't exist.
    // The correct column is 'booking_date'. We filter by the date portion.
    final dateStr = '${date.year.toString().padLeft(4, '0')}'
        '-${date.month.toString().padLeft(2, '0')}'
        '-${date.day.toString().padLeft(2, '0')}';

    try {
      final response = await _supabase
          .from('bookings')
          .select('time_slot')
          // Use gte/lt on booking_date to match the full day regardless of time
          .gte('booking_date', '${dateStr}T00:00:00')
          .lt('booking_date', '${dateStr}T23:59:59')
          .not('status', 'eq',
              'cancelled'); // don't block slots of cancelled bookings

      final bookedSlots = response.map((b) => b['time_slot'] as String).toSet();

      const allSlots = [
        '08:00 AM',
        '09:00 AM',
        '10:00 AM',
        '11:00 AM',
        '12:00 PM',
        '01:00 PM',
        '02:00 PM',
        '03:00 PM',
        '04:00 PM',
        '05:00 PM',
        '06:00 PM',
        '07:00 PM',
        '08:00 PM',
      ];

      return allSlots.where((slot) => !bookedSlots.contains(slot)).toList();
    } catch (e) {
      debugPrint('Error fetching time slots: $e');
      // Return all slots on error rather than breaking the UI
      return [
        '08:00 AM',
        '09:00 AM',
        '10:00 AM',
        '11:00 AM',
        '12:00 PM',
        '01:00 PM',
        '02:00 PM',
        '03:00 PM',
        '04:00 PM',
        '05:00 PM',
        '06:00 PM',
        '07:00 PM',
        '08:00 PM',
      ];
    }
  }
}
