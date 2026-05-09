// lib/presentation/screens/booking/booking_summary_screen.dart
// FIX: _confirmBooking() now calls SupabaseBookingRepository.createBooking()
// instead of using a fake Future.delayed + hardcoded ID.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lab_system/core/themes/app_theme.dart';
import 'package:lab_system/data/models/address_model.dart';
import 'package:lab_system/data/models/booking_model.dart';
import 'package:lab_system/data/models/test_model.dart';
import 'package:lab_system/data/repositories/base_auth_repository.dart';
import 'package:lab_system/data/repositories/base_booking_repository.dart';
import 'package:lab_system/presentation/screens/booking/booking_success_screen.dart';
import 'package:lab_system/services/locator.dart';

class BookingSummaryScreen extends StatefulWidget {
  final TestModel test;
  final String bookingType;
  final AddressModel? address;
  final DateTime selectedDate;
  final String selectedTimeSlot;

  const BookingSummaryScreen({
    super.key,
    required this.test,
    required this.bookingType,
    this.address,
    required this.selectedDate,
    required this.selectedTimeSlot,
  });

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  // FIX: injected from locator — same pattern used everywhere else in the app
  final BaseBookingRepository _bookingRepo = locator<BaseBookingRepository>();
  final BaseAuthRepository _authRepo = locator<BaseAuthRepository>();

  double get _basePrice => widget.test.price;
  double get _homeSamplingFee =>
      widget.bookingType == 'home' ? (widget.test.homeSamplingFee ?? 500) : 0;
  double get _totalPrice => _basePrice + _homeSamplingFee;

  String get _formattedDate =>
      DateFormat('EEEE, MMMM dd, yyyy').format(widget.selectedDate);

  // ─────────────────────────────────────────────────────────────────────────
  // FIX: The actual Supabase insert now happens here.
  // Before: Future.delayed(1s) + fake ID. Now: real DB call.
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _confirmBooking() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Get the currently logged-in user
      final user = await _authRepo.getCurrentUser();
      if (user == null || user.id.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'You must be logged in to book a test.';
        });
        return;
      }

      // 2. Map UI types to domain types
      final bookingType = widget.bookingType == 'home'
          ? BookingType.homeSampling
          : BookingType.labVisit;

      // 3. Call the Supabase repository — this is what was missing
      final booking = await _bookingRepo.createBooking(
        userId: user.id,
        testId: widget.test.id,
        test: widget.test,
        sector: widget.address?.sector ?? 'Lab Visit',
        streetNumber: widget.address?.streetNumber,
        houseNumber: widget.address?.houseNumber,
        bookingType: bookingType,
        bookingDate: widget.selectedDate,
        timeSlot: widget.selectedTimeSlot,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      // 4. Navigate to success with the real booking ID from Supabase
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookingSuccessScreen(
            bookingId: booking.id,
            testName: widget.test.name,
            bookingType: widget.bookingType,
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Booking failed: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Failed to confirm booking. Please check your connection and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Booking Summary',
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTestDetailsCard(),
                  const SizedBox(height: 16),
                  _buildServiceDetailsCard(),
                  const SizedBox(height: 16),
                  _buildDateTimeCard(),
                  const SizedBox(height: 16),
                  _buildPriceBreakdownCard(),
                  const SizedBox(height: 16),
                  _buildPaymentInfoCard(),
                  // FIX: Show error message if booking fails
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: AppColors.error.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              size: 18, color: AppColors.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          _buildConfirmButton(),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryExtraLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.medical_services,
              size: 24,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Test',
                  style: TextStyle(fontSize: 12, color: AppColors.textGray),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.test.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryExtraLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.test.getCategoryDisplayName(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryGreen,
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

  Widget _buildServiceDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, size: 20, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              const Text(
                'Service & Location',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.bookingType == 'lab'
                      ? AppColors.primaryExtraLight
                      : AppColors.diabetesBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.bookingType == 'lab' ? Icons.business : Icons.home,
                  size: 16,
                  color: widget.bookingType == 'lab'
                      ? AppColors.primaryGreen
                      : AppColors.diabetesColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.bookingType == 'lab'
                          ? 'Lab Visit'
                          : 'Home Sampling',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (widget.bookingType == 'lab')
                      const Text(
                        'Visit our lab for sample collection',
                        style:
                            TextStyle(fontSize: 11, color: AppColors.textGray),
                      )
                    else if (widget.address != null)
                      Text(
                        widget.address!.fullAddress,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textGray),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today,
                  size: 20, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              const Text(
                'Date & Time',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_month,
                    size: 16, color: AppColors.primaryGreen),
              ),
              const SizedBox(width: 12),
              Text(
                _formattedDate,
                style: const TextStyle(fontSize: 14, color: AppColors.textDark),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.access_time,
                    size: 16, color: AppColors.primaryGreen),
              ),
              const SizedBox(width: 12),
              Text(
                widget.selectedTimeSlot,
                style: const TextStyle(fontSize: 14, color: AppColors.textDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdownCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt, size: 20, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              const Text(
                'Payment Summary',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPriceRow('Test Price', 'Rs. ${_basePrice.toStringAsFixed(0)}'),
          if (widget.bookingType == 'home')
            _buildPriceRow('Home Sampling Fee',
                'Rs. ${_homeSamplingFee.toStringAsFixed(0)}'),
          const Divider(height: 24, thickness: 1),
          _buildPriceRow(
            'Total Amount',
            'Rs. ${_totalPrice.toStringAsFixed(0)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: isTotal ? AppColors.textDark : AppColors.textGray,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? AppColors.primaryGreen : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryExtraLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                const Icon(Icons.info, size: 18, color: AppColors.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Payment will be collected ${widget.bookingType == 'lab' ? 'at the lab' : 'during home sampling'}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(fontSize: 12, color: AppColors.textGray),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rs. ${_totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Confirm Booking',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
