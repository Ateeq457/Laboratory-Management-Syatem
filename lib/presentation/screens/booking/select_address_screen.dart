// lib/presentation/screens/booking/address_selection_screen.dart
// Professional Address Selection with Saved & Recent Addresses

import 'package:flutter/material.dart';
import 'package:lab_system/core/themes/app_theme.dart';
import 'package:lab_system/data/models/test_model.dart';
import 'package:lab_system/data/models/address_model.dart';
import 'package:lab_system/presentation/screens/booking/date_time_selection_screen.dart';
import 'package:lab_system/services/address_service.dart';

class AddressSelectionScreen extends StatefulWidget {
  final TestModel test;
  final String bookingType; // 'lab' or 'home'

  const AddressSelectionScreen({
    super.key,
    required this.test,
    required this.bookingType,
  });

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  final AddressService _addressService = AddressService();

  List<AddressModel> _savedAddresses = [];
  List<AddressModel> _recentAddresses = [];
  AddressModel? _selectedAddress;
  bool _isLoading = true;
  bool _isAddingNewAddress = false;

  // New address form controllers
  final TextEditingController _sectorController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();

  final List<String> _sectors = [
    'Khalabat Sector 1',
    'Khalabat Sector 2',
    'Khalabat Sector 3',
    'Khalabat Sector 4',
  ];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  @override
  void dispose() {
    _sectorController.dispose();
    _streetController.dispose();
    _houseController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);

    final saved = await _addressService.getSavedAddresses();
    final recent = await _addressService.getRecentAddresses();
    final defaultAddress = await _addressService.getDefaultAddress();

    setState(() {
      _savedAddresses = List<AddressModel>.from(saved);
      _recentAddresses = List<AddressModel>.from(recent);
      _selectedAddress =
          defaultAddress ?? (saved.isNotEmpty ? saved.first : null);
      _isLoading = false;
    });
  }

  void _selectAddress(AddressModel address) {
    setState(() {
      _selectedAddress = address;
    });
    _addressService.updateLastUsed(address.id);
  }

  void _saveNewAddress() async {
    final sector = _sectorController.text.trim();
    final street = _streetController.text.trim();
    final house = _houseController.text.trim();

    if (sector.isEmpty || street.isEmpty || house.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final landmark = _landmarkController.text.trim();
    final fullAddress = landmark.isNotEmpty
        ? '$sector, Street $street, House $house, Near $landmark'
        : '$sector, Street $street, House $house';

    final newAddress = AddressModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sector: sector,
      streetNumber: street,
      houseNumber: house,
      landmark: landmark.isNotEmpty ? landmark : null,
      fullAddress: fullAddress,
      isSaved: true,
      isDefault: _savedAddresses.isEmpty,
      lastUsed: DateTime.now(),
    );

    await _addressService.saveAddress(newAddress);
    if (_savedAddresses.isEmpty) {
      await _addressService.setDefaultAddress(newAddress.id);
    }

    setState(() {
      _isAddingNewAddress = false;
    });

    _clearForm();
    await _loadAddresses();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address saved successfully!')),
    );
  }

  void _clearForm() {
    _sectorController.clear();
    _streetController.clear();
    _houseController.clear();
    _landmarkController.clear();
  }

  void _proceedToNext() {
    if (widget.bookingType == 'lab') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DateTimeSelectionScreen(
            test: widget.test,
            bookingType: widget.bookingType,
            address: null,
          ),
        ),
      );
    } else if (_selectedAddress != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DateTimeSelectionScreen(
            test: widget.test,
            bookingType: widget.bookingType,
            address: _selectedAddress,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or add an address')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Address Details',
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service Type Summary
                        _buildServiceSummary(),

                        const SizedBox(height: 20),

                        // Lab Address (if lab visit)
                        if (widget.bookingType == 'lab') ...[
                          _buildLabAddressCard(),
                          const SizedBox(height: 20),
                        ],

                        // Saved Addresses Section
                        if (widget.bookingType == 'home' &&
                            _savedAddresses.isNotEmpty) ...[
                          _buildSavedAddressesSection(),
                          const SizedBox(height: 20),
                        ],

                        // Recent Addresses Section
                        if (widget.bookingType == 'home' &&
                            _recentAddresses.isNotEmpty &&
                            _savedAddresses.isNotEmpty) ...[
                          _buildRecentAddressesSection(),
                          const SizedBox(height: 20),
                        ],

                        // Add New Address Button
                        if (widget.bookingType == 'home' &&
                            !_isAddingNewAddress)
                          _buildAddNewAddressButton(),

                        // Add New Address Form
                        if (_isAddingNewAddress) _buildNewAddressForm(),
                      ],
                    ),
                  ),
          ),

          // Continue Button
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildServiceSummary() {
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
          const Text(
            'Service Type',
            style: TextStyle(fontSize: 12, color: AppColors.textGray),
          ),
          const SizedBox(height: 4),
          Text(
            widget.bookingType == 'lab' ? 'Lab Visit' : 'Home Sampling',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.test.name,
            style: const TextStyle(fontSize: 13, color: AppColors.textGray),
          ),
        ],
      ),
    );
  }

  Widget _buildLabAddressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryExtraLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_on, color: AppColors.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lab Address',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Main Road, Khalabat Sector 1',
                  style: TextStyle(fontSize: 12, color: AppColors.textGray),
                ),
                Text(
                  'Near City Hospital',
                  style:
                      TextStyle(fontSize: 11, color: AppColors.textLightGray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedAddressesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Saved Addresses',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _savedAddresses.length,
          itemBuilder: (context, index) {
            final address = _savedAddresses[index];
            final isSelected = _selectedAddress?.id == address.id;
            return _buildAddressCard(address, isSelected,
                showDefaultBadge: true);
          },
        ),
      ],
    );
  }

  Widget _buildRecentAddressesSection() {
    // Filter out addresses that are already in saved addresses
    final recentNotSaved = _recentAddresses
        .where(
            (recent) => !_savedAddresses.any((saved) => saved.id == recent.id))
        .toList();

    if (recentNotSaved.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Addresses',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentNotSaved.length,
          itemBuilder: (context, index) {
            final address = recentNotSaved[index];
            final isSelected = _selectedAddress?.id == address.id;
            return _buildAddressCard(address, isSelected,
                showDefaultBadge: false);
          },
        ),
      ],
    );
  }

  Widget _buildAddressCard(AddressModel address, bool isSelected,
      {required bool showDefaultBadge}) {
    return GestureDetector(
      onTap: () => _selectAddress(address),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryExtraLight : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Location Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGreen.withOpacity(0.1)
                    : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.location_on,
                color: isSelected ? AppColors.primaryGreen : AppColors.textGray,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Address Text (Expanded to take available space)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.fullAddress,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primaryGreen
                          : AppColors.textDark,
                    ),
                    maxLines: 2, // ← Added: Limit to 2 lines
                    overflow:
                        TextOverflow.ellipsis, // ← Added: Show ... if too long
                  ),
                  // Default Badge - Moved below address
                  if (showDefaultBadge && address.isDefault) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryExtraLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Default',
                        style: TextStyle(
                            fontSize: 9, color: AppColors.primaryGreen),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Check Icon (only if selected)
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: AppColors.primaryGreen, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewAddressButton() {
    return GestureDetector(
      onTap: () => setState(() => _isAddingNewAddress = true),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.borderLight, style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            const Text(
              'Add New Address',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewAddressForm() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add New Address',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => setState(() => _isAddingNewAddress = false),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sector Dropdown
          const Text('Sector *',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sectorController.text.isEmpty
                    ? null
                    : _sectorController.text,
                hint: const Text('Select sector'),
                isExpanded: true,
                items: _sectors.map((s) {
                  return DropdownMenuItem(value: s, child: Text(s));
                }).toList(),
                onChanged: (value) =>
                    setState(() => _sectorController.text = value ?? ''),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Street Number
          const Text('Street Number *',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: _streetController,
            decoration: InputDecoration(
              hintText: 'e.g., 5',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),

          const SizedBox(height: 12),

          // House Number
          const Text('House Number *',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: _houseController,
            decoration: InputDecoration(
              hintText: 'e.g., 123',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),

          const SizedBox(height: 12),

          // Landmark (Optional)
          const Text('Landmark (Optional)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: _landmarkController,
            decoration: InputDecoration(
              hintText: 'e.g., Near City Hospital',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _isAddingNewAddress = false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveNewAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Address'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
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
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _proceedToNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Continue to Date Selection',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
