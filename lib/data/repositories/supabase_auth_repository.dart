// lib/data/repositories/supabase_auth_repository.dart
// PRODUCTION-READY - Pure Supabase Email/Password Auth

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'base_auth_repository.dart';
import '../models/user_model.dart';

class SupabaseAuthRepository implements BaseAuthRepository {
  final _supabase = Supabase.instance.client;
  static const String _keyUserId = 'current_user_id';
  static const String _keyUserEmail = 'current_user_email';

  @override
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      debugPrint('📝 Signing up: $email');

      final response = await _supabase.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password,
        data: {'name': name},
      );

      if (response.user == null) {
        debugPrint('❌ Sign up failed: No user returned');
        return null;
      }

      final userId = response.user!.id;

      // Insert into public.users table
      await _supabase.from('users').insert({
        'id': userId,
        'email': email.trim().toLowerCase(),
        'name': name,
        'created_at': DateTime.now().toIso8601String(),
        'last_login': DateTime.now().toIso8601String(),
      });

      await _persistUser(userId, email);

      debugPrint('✅ User signed up: $userId');

      return UserModel(
        id: userId,
        phone: email,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );
    } on AuthException catch (e) {
      debugPrint('❌ Sign up error: ${e.message}');

      // Convert to user-friendly error message
      final message = e.message.toLowerCase();
      if (message.contains('rate limit') || message.contains('too many')) {
        throw Exception('Too many attempts. Please wait 5 minutes.');
      } else if (message.contains('already registered')) {
        throw Exception('Email already registered. Please login.');
      } else if (message.contains('password')) {
        throw Exception('Password must be at least 6 characters.');
      } else {
        throw Exception('Sign up failed. Please try again.');
      }
    } catch (e) {
      debugPrint('❌ Sign up error: $e');
      throw Exception(
          'Something went wrong. Please check your internet connection.');
    }
  }

  @override
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 Signing in: $email');

      final response = await _supabase.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      if (response.user == null) {
        debugPrint('❌ Sign in failed: No user returned');
        return null;
      }

      final userId = response.user!.id;
      final userEmail = response.user!.email ?? email;

      await _supabase.from('users').upsert({
        'id': userId,
        'email': userEmail,
        'last_login': DateTime.now().toIso8601String(),
      });

      await _persistUser(userId, userEmail);

      final user = await _getUserById(userId);
      debugPrint('✅ User signed in: $userId');
      return user;
    } on AuthException catch (e) {
      debugPrint('❌ Sign in error: ${e.message}');

      final message = e.message.toLowerCase();
      if (message.contains('invalid login credentials')) {
        throw Exception('Invalid email or password.');
      } else if (message.contains('rate limit')) {
        throw Exception('Too many attempts. Please wait 5 minutes.');
      } else if (message.contains('email not confirmed')) {
        throw Exception('Please verify your email first. Check your inbox.');
      } else {
        throw Exception('Sign in failed. Please try again.');
      }
    } catch (e) {
      debugPrint('❌ Sign in error: $e');
      throw Exception('Something went wrong. Please try again.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUserEmail);
      debugPrint('✅ User signed out');
    } catch (e) {
      debugPrint('⚠️ Sign out error: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        final user = await _getUserById(session.user.id);
        if (user != null) {
          await _persistUser(session.user.id, session.user.email ?? '');
          return user;
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_keyUserId);
      if (userId != null && userId.isNotEmpty) {
        return await _getUserById(userId);
      }

      return null;
    } catch (e) {
      debugPrint('❌ getCurrentUser error: $e');
      return null;
    }
  }

  @override
  Future<UserModel?> refreshUser() async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) return null;
    return await _getUserById(currentUser.id);
  }

  Future<UserModel?> _getUserById(String userId) async {
    try {
      final response =
          await _supabase.from('users').select().eq('id', userId).maybeSingle();

      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      debugPrint('❌ _getUserById error: $e');
      return null;
    }
  }

  Future<void> _persistUser(String userId, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUserEmail, email);
  }

  @override
  Future<UserModel?> updateUserProfile({
    String? name,
    String? email,
    String? phone,
    String? sector,
    String? address,
  }) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) return null;

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (email != null) updates['email'] = email;
    if (phone != null) updates['phone'] = phone;
    if (sector != null) updates['sector'] = sector;
    if (address != null) updates['address'] = address;
    updates['updated_at'] = DateTime.now().toIso8601String();

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

  @override
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email.trim().toLowerCase());
      debugPrint('✅ Password reset email sent to: $email');

      // Add a small delay to prevent rapid-fire requests
      await Future.delayed(const Duration(seconds: 2));

      return true;
    } on AuthException catch (e) {
      debugPrint('❌ sendPasswordResetEmail error: ${e.message}');

      final message = e.message.toLowerCase();

      // Rate limit handling with user-friendly message
      if (message.contains('rate limit') ||
          message.contains('too many') ||
          message.contains('over_email_send_rate_limit')) {
        throw Exception(
            'Too many reset attempts. Please wait 15-20 minutes before trying again.');
      } else if (message.contains('user not found') ||
          message.contains('invalid email')) {
        throw Exception('No account found with this email address.');
      } else if (message.contains('invalid')) {
        throw Exception('Invalid email address. Please check and try again.');
      } else {
        throw Exception('Unable to send reset email. Please try again later.');
      }
    } catch (e) {
      debugPrint('❌ sendPasswordResetEmail error: $e');
      throw Exception(
          'Network error. Please check your connection and try again.');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final session = _supabase.auth.currentSession;
    if (session != null) return true;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_keyUserId);
    return userId != null && userId.isNotEmpty;
  }

  @override
  Stream<AuthUserState?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map((event) {
      if (event.session != null) {
        return AuthUserState(
          userId: event.session!.user.id,
          email: event.session!.user.email,
          isEmailVerified: event.session!.user.emailConfirmedAt != null,
        );
      }
      return const AuthUserState();
    });
  }

  @override
  Future<bool> resendEmailVerification() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // Note: Supabase doesn't have direct resend method
      // User can request via settings or sign up again
      debugPrint('⚠️ Email verification resend - user should check email');
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isEmailVerified() async {
    final user = _supabase.auth.currentUser;
    return user?.emailConfirmedAt != null;
  }
}
