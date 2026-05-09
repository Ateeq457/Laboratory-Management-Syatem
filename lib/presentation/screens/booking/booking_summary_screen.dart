// lib/presentation/screens/booking/booking_summary_screen.dart
// Professional Booking Summary Screen

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lab_system/core/themes/app_theme.dart';
import 'package:lab_system/data/models/test_model.dart';
import 'package:lab_system/data/models/address_model.dart';
import 'package:lab_system/presentation/screens/booking/booking_success_screen.dart';

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

  double get _basePrice => widget.test.price;
  double get _homeSamplingFee =>
      widget.bookingType == 'home' ? (widget.test.homeSamplingFee ?? 500) : 0;
  double get _totalPrice => _basePrice + _homeSamplingFee;

  String get _formattedDate {
    return DateFormat('EEEE, MMMM dd, yyyy').format(widget.selectedDate);
  }

  Future<void> _confirmBooking() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Generate a dummy booking ID
    final bookingId = 'THAL-${DateTime.now().millisecondsSinceEpoch}';

    setState(() => _isLoading = false);

    // Navigate to success screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BookingSuccessScreen(
          bookingId: bookingId,
          testName: widget.test.name,
          bookingType: widget.bookingType,
        ),
      ),
    );
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
                  // Test Details Card
                  _buildTestDetailsCard(),

                  const SizedBox(height: 16),

                  // Service & Location Card
                  _buildServiceDetailsCard(),

                  const SizedBox(height: 16),

                  // Date & Time Card
                  _buildDateTimeCard(),

                  const SizedBox(height: 16),

                  // Price Breakdown Card
                  _buildPriceBreakdownCard(),

                  const SizedBox(height: 16),

                  // Payment Info Card
                  _buildPaymentInfoCard(),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // Confirm Button
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
                    color: _getCategoryColor(
                        widget.test.getCategoryDisplayName())['bg'],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.test.getCategoryDisplayName(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: _getCategoryColor(
                          widget.test.getCategoryDisplayName())['color'],
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
            // Price Column
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
            // Confirm Button
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

  Map<String, Color> _getCategoryColor(String category) {
    switch (category) {
      case 'Blood Work':
        return {'bg': AppColors.bloodWorkBg, 'color': AppColors.bloodWorkColor};
      case 'Diabetes':
        return {'bg': AppColors.diabetesBg, 'color': AppColors.diabetesColor};
      case 'Renal':
        return {'bg': AppColors.renalBg, 'color': AppColors.renalColor};
      case 'Hepatic':
        return {'bg': AppColors.hepaticBg, 'color': AppColors.hepaticColor};
      default:
        return {
          'bg': AppColors.primaryExtraLight,
          'color': AppColors.primaryGreen
        };
    }
  }
}
