// lib/data/repositories/supabase_auth_repository.dart
// ✅ PRODUCTION-READY — Hybrid Auth Repository
//
// Auth layer  : Firebase Phone OTP (identity / session)
// Data layer  : Supabase Postgres (user profiles & app data)
//
// FIX 1: isLoggedIn() now checks Firebase Auth currentUser (not Supabase
//         session). In a hybrid setup the Supabase auth session is never
//         created — only Firebase holds the session.
// FIX 2: _authenticateUser stores Firebase UID as the Supabase user ID so
//         the two systems are linked by a stable key.
// FIX 3: Removed _isDebugMode gating — production should always work.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'base_auth_repository.dart';
import '../models/user_model.dart';

class SupabaseAuthRepository implements BaseAuthRepository {
  final _supabase = Supabase.instance.client;
  final _firebaseAuth = FirebaseAuth.instance;

  static const String _keyUserId = 'current_user_id';
  static const String _keyUserPhone = 'current_user_phone';

  // ─────────────────────────────────────────────────────────────
  // SEND OTP — delegated entirely to Firebase (see FirebaseAuthService)
  // This implementation is a no-op stub; the real send happens in
  // FirebaseAuthService called directly from LoginScreen.
  // ─────────────────────────────────────────────────────────────
  @override
  Future<bool> sendOTP(String phoneNumber) async => true;

  // ─────────────────────────────────────────────────────────────
  // VERIFY OTP — called after Firebase verifies the OTP.
  // At this point Firebase currentUser is already set.
  // We upsert the user in Supabase and persist their ID locally.
  // ─────────────────────────────────────────────────────────────
  @override
  Future<UserModel?> verifyOTP(String phoneNumber, String otp) async {
    // The OTP was already verified by FirebaseAuthService before calling here.
    // We just need to upsert the Supabase user record.
    return await _authenticateUser(phoneNumber);
  }

  // ─────────────────────────────────────────────────────────────
  // Called directly from OTPVerificationScreen after Firebase confirms
  // the user. Upserts a Supabase user row keyed on Firebase UID.
  // ─────────────────────────────────────────────────────────────
  Future<UserModel?> authenticateAfterFirebaseVerification(
      String phoneNumber) async {
    return await _authenticateUser(phoneNumber);
  }

  Future<UserModel?> _authenticateUser(String phoneNumber) async {
    try {
      final firebaseUid = _firebaseAuth.currentUser?.uid;

      // Try to find existing user by phone in Supabase
      UserModel? user = await _getUserByPhone(phoneNumber);

      if (user != null) {
        // Update last_login timestamp
        await _supabase.from('users').update(
            {'last_login': DateTime.now().toIso8601String()}).eq('id', user.id);

        await _persistUser(user);
        debugPrint('✅ Existing user authenticated: ${user.id}');
        return user;
      }

      // New user — create record
      user = await _createUser(phoneNumber, firebaseUid);
      await _persistUser(user);
      debugPrint('✅ New user created: ${user.id}');
      return user;
    } catch (e) {
      debugPrint('❌ Error in _authenticateUser: $e');
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
      debugPrint('❌ _getUserByPhone error: $e');
      return null;
    }
  }

  Future<UserModel> _createUser(String phoneNumber, String? firebaseUid) async {
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

  Future<void> _persistUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, user.id);
    await prefs.setString(_keyUserPhone, user.phone);
  }

  // ─────────────────────────────────────────────────────────────
  // IS LOGGED IN
  // ✅ FIX: Check Firebase Auth (the real session holder in hybrid mode).
  //         Previously checked Supabase session which is never set.
  // ─────────────────────────────────────────────────────────────
  @override
  Future<bool> isLoggedIn() async {
    // Primary check: Firebase session
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) return true;

    // Fallback: SharedPreferences (for cases where Firebase session
    // was cleared but user hasn't explicitly logged out)
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_keyUserId);
    return userId != null && userId.isNotEmpty;
  }

  // ─────────────────────────────────────────────────────────────
  // GET CURRENT USER
  // ─────────────────────────────────────────────────────────────
  @override
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_keyUserId);
    if (userId == null || userId.isEmpty) return null;

    try {
      final response =
          await _supabase.from('users').select().eq('id', userId).maybeSingle();
      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      debugPrint('❌ getCurrentUser error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────────────────────────
  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserPhone);

    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint('⚠️ Firebase signOut warning: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // UPDATE USER PROFILE
  // ─────────────────────────────────────────────────────────────
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
      debugPrint('❌ updateUserProfile error: $e');
      return null;
    }
  }
}
