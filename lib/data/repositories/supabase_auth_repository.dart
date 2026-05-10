// lib/data/repositories/supabase_auth_repository.dart
// PRODUCTION-READY Auth Repository
// - Real OTP via Supabase Auth (production)
// - Mock OTP 123456 only in debug mode (development)

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'base_auth_repository.dart';
import '../models/user_model.dart';

class SupabaseAuthRepository implements BaseAuthRepository {
  final _supabase = Supabase.instance.client;
  static const String _keyUserId = 'current_user_id';

  // Secret mock OTP - only developer knows this
  // In production, this is disabled
  static const String _mockOTP = '123456';

  // Enable mock OTP in debug mode only
  bool get _isDebugMode => kDebugMode;

  @override
  Future<bool> sendOTP(String phoneNumber) async {
    try {
      if (_isDebugMode) {
        debugPrint('📱 [DEBUG] OTP sent to: $phoneNumber');
        debugPrint('🔑 [DEBUG] Mock OTP: $_mockOTP (for testing only)');
      }

      // In production, send real OTP via Supabase Auth
      if (!_isDebugMode) {
        await _supabase.auth.signInWithOtp(
          phone: phoneNumber,
        );
        debugPrint('📱 [PROD] Real OTP sent to: $phoneNumber');
      }

      return true;
    } catch (e) {
      debugPrint('❌ Error sending OTP: $e');
      return false;
    }
  }

  @override
  Future<UserModel?> verifyOTP(String phoneNumber, String otp) async {
    // DEVELOPMENT MODE: Accept mock OTP
    if (_isDebugMode && otp == _mockOTP) {
      debugPrint('✅ [DEBUG] Mock OTP accepted for: $phoneNumber');
      return await _authenticateUser(phoneNumber);
    }

    // PRODUCTION MODE: Verify real OTP via Supabase Auth
    if (!_isDebugMode) {
      try {
        final response = await _supabase.auth.verifyOTP(
          phone: phoneNumber,
          token: otp,
          type: OtpType.sms,
        );

        if (response.session != null) {
          debugPrint('✅ [PROD] Real OTP verified for: $phoneNumber');
          return await _authenticateUser(phoneNumber);
        }
      } catch (e) {
        debugPrint('❌ [PROD] OTP verification failed: $e');
        return null;
      }
    }

    // If we reach here, OTP is invalid
    debugPrint('❌ Invalid OTP provided');
    return null;
  }

  /// Common authentication logic for both dev and prod
  Future<UserModel?> _authenticateUser(String phoneNumber) async {
    try {
      // Check if user already exists
      UserModel? user = await _getUserByPhone(phoneNumber);

      if (user != null) {
        // Update last_login on every login
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
      debugPrint('❌ Error authenticating user: $e');
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

    // Also sign out from Supabase Auth if using real auth
    if (!_isDebugMode) {
      await _supabase.auth.signOut();
    }
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

    // Also check Supabase Auth session in production
    if (!_isDebugMode && userId != null) {
      final session = _supabase.auth.currentSession;
      return session != null;
    }

    return userId != null && userId.isNotEmpty;
  }
}
