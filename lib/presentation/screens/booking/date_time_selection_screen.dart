// lib/presentation/screens/booking/date_time_selection_screen.dart
// FIX: _bookedSlots are no longer a hardcoded 2024 Set.
//      Slots are fetched live from Supabase via BaseBookingRepository.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lab_system/core/themes/app_theme.dart';
import 'package:lab_system/data/models/address_model.dart';
import 'package:lab_system/data/models/test_model.dart';
import 'package:lab_system/data/repositories/base_booking_repository.dart';
import 'package:lab_system/presentation/screens/booking/booking_summary_screen.dart';
import 'package:lab_system/services/locator.dart';

class DateTimeSelectionScreen extends StatefulWidget {
  final TestModel test;
  final String bookingType;
  final AddressModel? address;

  const DateTimeSelectionScreen({
    super.key,
    required this.test,
    required this.bookingType,
    this.address,
  });

  @override
  State<DateTimeSelectionScreen> createState() =>
      _DateTimeSelectionScreenState();
}

class _DateTimeSelectionScreenState extends State<DateTimeSelectionScreen> {
  // FIX: injected from locator, not hardcoded
  final BaseBookingRepository _bookingRepo = locator<BaseBookingRepository>();

  DateTime? _selectedDate;
  String? _selectedTimeSlot;

  // FIX: fetched from Supabase per selected date
  List<String> _availableSlots = [];
  bool _loadingSlots = false;

  final List<String> _allSlots = const [
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

  @override
  void initState() {
    super.initState();
    // Pre-select today so the user sees slots immediately
    _selectedDate = DateTime.now();
    _fetchSlotsForDate(_selectedDate!);
  }

  /// FIX: replaces the hardcoded _bookedSlots Set
  Future<void> _fetchSlotsForDate(DateTime date) async {
    setState(() {
      _loadingSlots = true;
      _selectedTimeSlot = null; // clear previous selection on date change
    });

    try {
      final available = await _bookingRepo.getAvailableTimeSlots(date);
      if (mounted) {
        setState(() {
          _availableSlots = available;
          _loadingSlots = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _availableSlots = List.from(_allSlots); // fallback: show all
          _loadingSlots = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  String _formatDisplayDate(DateTime date) =>
      DateFormat('EEE, MMM dd').format(date);

  List<DateTime> _getNext7Days() {
    final today = DateTime.now();
    return List.generate(7, (i) => today.add(Duration(days: i)));
  }

  void _proceedToSummary() {
    if (_selectedDate == null || _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time slot')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingSummaryScreen(
          test: widget.test,
          bookingType: widget.bookingType,
          address: widget.address,
          selectedDate: _selectedDate!,
          selectedTimeSlot: _selectedTimeSlot!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dates = _getNext7Days();
    final totalPrice = widget.bookingType == 'home'
        ? widget.test.price + (widget.test.homeSamplingFee ?? 500)
        : widget.test.price;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Select Date & Time',
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
                  _buildBookingSummaryCard(totalPrice),
                  const SizedBox(height: 24),

                  // Date Selection
                  const Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 20, color: AppColors.primaryGreen),
                      SizedBox(width: 8),
                      Text('Select Date',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDatePicker(dates),
                  const SizedBox(height: 24),

                  // Time Selection
                  const Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 20, color: AppColors.primaryGreen),
                      SizedBox(width: 8),
                      Text('Select Time Slot',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // FIX: Show loader while fetching slots, not hardcoded data
                  _loadingSlots
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(
                                color: AppColors.primaryGreen),
                          ),
                        )
                      : _buildTimeSlots(),

                  if (_selectedDate != null && _selectedTimeSlot != null) ...[
                    const SizedBox(height: 16),
                    _buildSelectedInfoCard(),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildBottomButton(totalPrice),
        ],
      ),
    );
  }

  Widget _buildBookingSummaryCard(double totalPrice) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryExtraLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Booking Summary',
              style: TextStyle(fontSize: 12, color: AppColors.textGray)),
          const SizedBox(height: 8),
          Text(widget.test.name,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text(widget.bookingType == 'lab' ? 'Lab Visit' : 'Home Sampling',
              style: const TextStyle(fontSize: 13, color: AppColors.textGray)),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              Text('Rs. ${totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(List<DateTime> dates) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = _selectedDate != null &&
              _formatDate(_selectedDate!) == _formatDate(date);
          final isToday = _formatDate(date) == _formatDate(DateTime.now());

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = date);
              _fetchSlotsForDate(date);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreen : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color:
                      isSelected ? Colors.transparent : AppColors.borderLight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd').format(date),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  if (isToday)
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Colors.white : AppColors.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlots() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _allSlots.length,
      itemBuilder: (context, index) {
        final slot = _allSlots[index];
        // FIX: availability from live Supabase data, not 2024 hardcode
        final isAvailable = _availableSlots.contains(slot);
        final isSelected = _selectedTimeSlot == slot;

        return GestureDetector(
          onTap: isAvailable
              ? () => setState(() => _selectedTimeSlot = slot)
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryGreen
                  : !isAvailable
                      ? AppColors.backgroundLight
                      : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    slot,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : !isAvailable
                              ? AppColors.textLightGray
                              : AppColors.textDark,
                    ),
                  ),
                  if (!isAvailable)
                    const Text(
                      'Booked',
                      style: TextStyle(
                          fontSize: 9, color: AppColors.textLightGray),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedInfoCard() {
    return Container(
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
            child: const Icon(Icons.check,
                color: AppColors.primaryGreen, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Selected: ${_formatDisplayDate(_selectedDate!)} at $_selectedTimeSlot',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(double totalPrice) {
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
                  const Text('Total Amount',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.textGray)),
                  const SizedBox(height: 2),
                  Text(
                    'Rs. ${totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
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
                onPressed: _proceedToSummary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Continue to Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
