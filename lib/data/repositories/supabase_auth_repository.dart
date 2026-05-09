// lib/data/repositories/supabase_auth_repository.dart
// Supabase Implementation of Auth Repository

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'base_auth_repository.dart';
import '../models/user_model.dart';

class SupabaseAuthRepository implements BaseAuthRepository {
  final _supabase = Supabase.instance.client;
  static const String _keyUserId = 'current_user_id';

  @override
  Future<bool> sendOTP(String phoneNumber) async {
    try {
      // For demo, just return true
      // In production with actual SMS, use Supabase Auth
      print('📱 OTP sent to: $phoneNumber');
      print('🔑 Mock OTP: 123456');
      return true;
    } catch (e) {
      print('Error sending OTP: $e');
      return false;
    }
  }

  @override
  Future<UserModel?> verifyOTP(String phoneNumber, String otp) async {
    try {
      // For demo, accept any 6-digit OTP
      if (otp.length == 6) {
        // Check if user exists
        final existingUser = await _getUserByPhone(phoneNumber);

        if (existingUser != null) {
          await _saveUserId(existingUser.id);
          return existingUser;
        }

        // Create new user
        final newUser = await _createUser(phoneNumber);
        await _saveUserId(newUser.id);
        return newUser;
      }
      return null;
    } catch (e) {
      print('Error verifying OTP: $e');
      return null;
    }
  }

  Future<UserModel?> _getUserByPhone(String phoneNumber) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('phone', phoneNumber)
          .maybeSingle();

      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<UserModel> _createUser(String phoneNumber) async {
    final newUser = {
      'phone': phoneNumber,
      'name': '',
      'created_at': DateTime.now().toIso8601String(),
    };

    final response =
        await _supabase.from('users').insert(newUser).select().single();

    return UserModel.fromJson(response);
  }

  Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_keyUserId);

    if (userId == null) return null;

    try {
      final response =
          await _supabase.from('users').select().eq('id', userId).single();

      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
  }

  @override
  Future<UserModel?> updateUserProfile({
    String? name,
    String? email,
    String? sector,
    String? address,
  }) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) return null;

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (email != null) updates['email'] = email;
    if (sector != null) updates['sector'] = sector;
    if (address != null) updates['address'] = address;

    if (updates.isEmpty) return currentUser;

    try {
      final response = await _supabase
          .from('users')
          .update(updates)
          .eq('id', currentUser.id)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error updating user: $e');
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyUserId);
  }
}
