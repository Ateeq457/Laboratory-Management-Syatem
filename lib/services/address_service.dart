// lib/services/address_service.dart
// Manages saved addresses with SharedPreferences

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/address_model.dart';

class AddressService {
  static const String _addressesKey = 'saved_addresses';
  static const String _defaultAddressIdKey = 'default_address_id';

  Future<List<AddressModel>> getSavedAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? addressesJson = prefs.getString(_addressesKey);

    if (addressesJson == null) return [];

    final List<dynamic> decoded = json.decode(addressesJson);
    return decoded.map((item) => AddressModel.fromJson(item)).toList();
  }

  Future<void> saveAddress(AddressModel address) async {
    final List<AddressModel> addresses =
        await getSavedAddresses(); // Fixed type
    final existingIndex = addresses.indexWhere((a) => a.id == address.id);

    List<AddressModel> updatedAddresses;
    if (existingIndex != -1) {
      updatedAddresses = List<AddressModel>.from(addresses); // Fixed
      updatedAddresses[existingIndex] = address;
    } else {
      updatedAddresses = [address, ...addresses];
    }

    // Keep only last 10 addresses
    if (updatedAddresses.length > 10) {
      updatedAddresses = updatedAddresses.sublist(0, 10);
    }

    await _saveAddressesList(updatedAddresses);
  }

  Future<void> deleteAddress(String addressId) async {
    final List<AddressModel> addresses =
        await getSavedAddresses(); // Fixed type
    final filtered = addresses.where((a) => a.id != addressId).toList();
    await _saveAddressesList(filtered);
  }

  Future<void> setDefaultAddress(String addressId) async {
    final List<AddressModel> addresses =
        await getSavedAddresses(); // Fixed type
    final List<AddressModel> updatedAddresses = addresses.map((address) {
      return address.copyWith(isDefault: address.id == addressId);
    }).toList();

    await _saveAddressesList(updatedAddresses);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultAddressIdKey, addressId);
  }

  Future<AddressModel?> getDefaultAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final defaultId = prefs.getString(_defaultAddressIdKey);

    if (defaultId == null) return null;

    final List<AddressModel> addresses =
        await getSavedAddresses(); // Fixed type
    try {
      return addresses.firstWhere((a) => a.id == defaultId);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateLastUsed(String addressId) async {
    final List<AddressModel> addresses =
        await getSavedAddresses(); // Fixed type
    final index = addresses.indexWhere((a) => a.id == addressId);

    if (index != -1) {
      final updated = addresses[index].copyWith(lastUsed: DateTime.now());
      final List<AddressModel> updatedAddresses =
          List<AddressModel>.from(addresses); // Fixed
      updatedAddresses[index] = updated;
      await _saveAddressesList(updatedAddresses);
    }
  }

  Future<List<AddressModel>> getRecentAddresses() async {
    final List<AddressModel> addresses =
        await getSavedAddresses(); // Fixed type
    final List<AddressModel> sorted =
        List<AddressModel>.from(addresses) // Fixed
          ..sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
    return sorted.length > 5 ? sorted.sublist(0, 5) : sorted; // Fixed .take()
  }

  Future<void> _saveAddressesList(List<AddressModel> addresses) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(addresses.map((a) => a.toJson()).toList());
    await prefs.setString(_addressesKey, encoded);
  }
}
