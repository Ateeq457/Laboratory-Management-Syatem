// lib/services/address_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/address_model.dart';

class AddressService {
  final _supabase = Supabase.instance.client;
  static const String _defaultAddressIdKey = 'default_address_id';

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('current_user_id');
  }

  Future<List<AddressModel>> getSavedAddresses() async {
    final userId = await _getUserId();
    if (userId == null) return [];

    try {
      final response = await _supabase
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .eq('is_saved', true)
          .order('is_default', ascending: false)
          .order('last_used', ascending: false);

      return response.map((json) => AddressModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching addresses: $e');
      return [];
    }
  }

  Future<void> saveAddress(AddressModel address) async {
    final userId = await _getUserId();
    if (userId == null) return;

    try {
      await _supabase.from('addresses').insert({
        'user_id': userId,
        'sector': address.sector,
        'street_number': address.streetNumber,
        'house_number': address.houseNumber,
        'landmark': address.landmark,
        'full_address': address.fullAddress,
        'is_saved': true,
        'is_default': address.isDefault,
        'last_used': DateTime.now().toIso8601String(),
        // ❌ 'id' bilkul mat dalo — Supabase khud banayega
      });
    } catch (e) {
      print('Error saving address: $e');
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      await _supabase.from('addresses').delete().eq('id', addressId);
    } catch (e) {
      print('Error deleting address: $e');
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    final userId = await _getUserId();
    if (userId == null) return;

    try {
      // Pehle sab ka default false karo
      await _supabase
          .from('addresses')
          .update({'is_default': false}).eq('user_id', userId);

      // Phir selected ko true karo
      await _supabase
          .from('addresses')
          .update({'is_default': true}).eq('id', addressId);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_defaultAddressIdKey, addressId);
    } catch (e) {
      print('Error setting default address: $e');
    }
  }

  Future<AddressModel?> getDefaultAddress() async {
    final userId = await _getUserId();
    if (userId == null) return null;

    try {
      final response = await _supabase
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .eq('is_default', true)
          .maybeSingle();

      if (response == null) return null;
      return AddressModel.fromJson(response);
    } catch (e) {
      print('Error fetching default address: $e');
      return null;
    }
  }

  Future<void> updateLastUsed(String addressId) async {
    try {
      await _supabase.from('addresses').update(
          {'last_used': DateTime.now().toIso8601String()}).eq('id', addressId);
    } catch (e) {
      print('Error updating last used: $e');
    }
  }

  Future<List<AddressModel>> getRecentAddresses() async {
    final userId = await _getUserId();
    if (userId == null) return [];

    try {
      final response = await _supabase
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .order('last_used', ascending: false)
          .limit(5);

      return response.map((json) => AddressModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching recent addresses: $e');
      return [];
    }
  }
}
