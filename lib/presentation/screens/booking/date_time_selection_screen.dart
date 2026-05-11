// lib/presentation/screens/booking/date_time_selection_screen.dart
// FIX: Time slots only show future times for today's date

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
  final BaseBookingRepository _bookingRepo = locator<BaseBookingRepository>();

  DateTime? _selectedDate;
  String? _selectedTimeSlot;

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
    _selectedDate = DateTime.now();
    _fetchSlotsForDate(_selectedDate!);
  }

  Future<void> _fetchSlotsForDate(DateTime date) async {
    setState(() {
      _loadingSlots = true;
      _selectedTimeSlot = null;
    });

    try {
      // Get available slots from repository (not booked + not past time)
      final availableSlots = await _bookingRepo.getAvailableTimeSlots(date);

      // Filter by time if selected date is today
      final now = DateTime.now();
      final isToday = date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;

      List<String> finalSlots;

      if (isToday) {
        finalSlots = availableSlots.where((slot) {
          final slotHour = _getHourFromSlot(slot);
          final slotMinute = _getMinuteFromSlot(slot);

          // Only show future slots (30 minutes buffer)
          final totalSlotMinutes = slotHour * 60 + slotMinute;
          final totalCurrentMinutes = now.hour * 60 + now.minute + 30;

          return totalSlotMinutes > totalCurrentMinutes;
        }).toList();
      } else {
        finalSlots = availableSlots;
      }

      print('📅 Date: $date, isToday: $isToday');
      print('🕐 Available slots: ${finalSlots.length}');

      if (mounted) {
        setState(() {
          _availableSlots = finalSlots;
          _loadingSlots = false;
        });
      }
    } catch (e) {
      print('❌ Error fetching slots: $e');
      if (mounted) {
        setState(() {
          _availableSlots = [];
          _loadingSlots = false;
        });
      }
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  int _getHourFromSlot(String slot) {
    final parts = slot.split(' ');
    final time = parts[0];
    final period = parts[1];

    var hour = int.parse(time.split(':')[0]);
    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    return hour;
  }

  int _getMinuteFromSlot(String slot) {
    final parts = slot.split(' ');
    final time = parts[0];
    return int.parse(time.split(':')[1]);
  }

  String _getCurrentTimeFormatted() {
    final now = DateTime.now();
    return DateFormat('h:mm a').format(now);
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
    final isToday =
        _selectedDate != null && _isSameDay(_selectedDate!, DateTime.now());

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
                  _buildDatePicker(dates),
                  const SizedBox(height: 24),
                  _buildTimeSlots(isToday),
                  if (isToday &&
                      _selectedDate != null &&
                      _availableSlots.isEmpty &&
                      !_loadingSlots)
                    _buildNoSlotsWarning(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today,
                size: 20, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            const Text('Select Date',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final isSelected = _selectedDate != null &&
                  _formatDate(_selectedDate!) == _formatDate(date);
              final isToday = _formatDate(date) == _formatDate(DateTime.now());
              final isPastDate = date.isBefore(DateTime.now()) && !isToday;

              return GestureDetector(
                onTap: isPastDate
                    ? null
                    : () {
                        setState(() => _selectedDate = date);
                        _fetchSlotsForDate(date);
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : isPastDate
                            ? AppColors.backgroundLight
                            : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : isPastDate
                              ? AppColors.borderLight
                              : AppColors.borderLight,
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
                          color: isSelected
                              ? Colors.white
                              : isPastDate
                                  ? AppColors.textLightGray
                                  : AppColors.textGray,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd').format(date),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : isPastDate
                                  ? AppColors.textLightGray
                                  : AppColors.textDark,
                        ),
                      ),
                      if (isToday)
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : AppColors.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlots(bool isToday) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.access_time,
                size: 20, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            const Text('Select Time Slot',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            if (isToday && !_loadingSlots)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  'Available after ${_getCurrentTimeFormatted()}',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textLightGray),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _loadingSlots
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child:
                      CircularProgressIndicator(color: AppColors.primaryGreen),
                ),
              )
            : _availableSlots.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'No time slots available for this date',
                        style: TextStyle(color: AppColors.textGray),
                      ),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.0,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _availableSlots.length,
                    itemBuilder: (context, index) {
                      final slot = _availableSlots[index];
                      final isSelected = _selectedTimeSlot == slot;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedTimeSlot = slot),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryGreen
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Center(
                            child: Text(
                              slot,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textDark,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ],
    );
  }

  Widget _buildNoSlotsWarning() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'No time slots available for today. Please select another date.',
              style: TextStyle(fontSize: 12, color: AppColors.warning),
            ),
          ),
        ],
      ),
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
