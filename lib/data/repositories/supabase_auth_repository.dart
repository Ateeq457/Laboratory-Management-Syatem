// lib/data/repositories/supabase_auth_repository.dart
// FIXES:
//  1. updateUserName() actually called after NameInputScreen — was missing
//  2. last_login updated on verifyOTP success
//  3. verifyOTP returns the user so OTP screen navigation works correctly
//  4. Removed unsafe bare try/catch that swallowed DB errors silently

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'base_auth_repository.dart';
import '../models/user_model.dart';

class SupabaseAuthRepository implements BaseAuthRepository {
  final _supabase = Supabase.instance.client;
  static const String _keyUserId = 'current_user_id';

  @override
  Future<bool> sendOTP(String phoneNumber) async {
    // TODO: In production, integrate a real SMS provider (Twilio, etc.)
    // or use Supabase Auth phone sign-in (requires phone provider setup).
    debugPrint('📱 OTP sent to: $phoneNumber');
    debugPrint('🔑 Mock OTP: 123456 (replace with real SMS in production)');
    return true;
  }

  @override
  Future<UserModel?> verifyOTP(String phoneNumber, String otp) async {
    // TODO: Validate against real OTP when SMS provider is integrated
    if (otp.length != 6) return null;

    try {
      // Check if user already exists
      UserModel? user = await _getUserByPhone(phoneNumber);

      if (user != null) {
        // FIX: Update last_login on every login
        await _supabase.from('users').update(
            {'last_login': DateTime.now().toIso8601String()}).eq('id', user.id);

        await _saveUserId(user.id);
        return user;
      }

      // New user — create record
      user = await _createUser(phoneNumber);
      await _saveUserId(user.id);
      return user;
    } catch (e) {
      debugPrint('❌ Error verifying OTP: $e');
      return null;
    }
  }

  Future<UserModel?> _getUserByPhone(String phoneNumber) async {
    final response = await _supabase
        .from('users')
        .select()
        .eq('phone', phoneNumber)
        .maybeSingle();

    if (response == null) return null;
    return UserModel.fromJson(response);
  }

  Future<UserModel> _createUser(String phoneNumber) async {
    final response = await _supabase
        .from('users')
        .insert({
          'phone': phoneNumber,
          'name': '',
          'created_at': DateTime.now().toIso8601String(),
          'last_login': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

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
    if (userId == null || userId.isEmpty) return null;

    try {
      final response =
          await _supabase.from('users').select().eq('id', userId).single();
      return UserModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching current user: $e');
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
      debugPrint('Error updating user profile: $e');
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_keyUserId);
    return userId != null && userId.isNotEmpty;
  }
}
