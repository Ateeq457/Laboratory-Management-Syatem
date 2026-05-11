// lib/data/repositories/firebase_auth_service.dart
// ✅ FIX: Singleton pattern so _verificationId persists across screens.
//
// ROOT CAUSE of "verifyOTP called before sendOTP":
//   LoginScreen did:   FirebaseAuthService()  → instance A, _verificationId set ✅
//   OTPScreen did:     FirebaseAuthService()  → instance B, _verificationId = null ❌
//
// With singleton: every `FirebaseAuthService()` call returns the SAME instance,
// so _verificationId set in LoginScreen is available in OTPScreen.

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthService {
  // ─── Singleton ────────────────────────────────────────────
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();
  // ──────────────────────────────────────────────────────────

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;

  // ─── SEND OTP ─────────────────────────────────────────────
  Future<bool> sendOTP(String phone) async {
    final formatted = _formatPhone(phone);
    debugPrint('📱 Sending OTP to: $formatted');

    final completer = Completer<bool>();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: formatted,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);
            debugPrint('✅ Firebase: Auto-verification completed');
          } catch (e) {
            debugPrint('❌ Firebase: Auto sign-in failed: $e');
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          debugPrint('✅ Firebase: codeSent — _verificationId saved');
          if (!completer.isCompleted) completer.complete(true);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('❌ Firebase verificationFailed → ${e.code}: ${e.message}');
          if (!completer.isCompleted) completer.complete(false);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          debugPrint('⏱ Firebase: timeout — _verificationId saved');
          if (!completer.isCompleted) completer.complete(true);
        },
      );

      return await completer.future;
    } catch (e) {
      debugPrint('❌ Firebase sendOTP exception: $e');
      return false;
    }
  }

  // ─── VERIFY OTP ───────────────────────────────────────────
  Future<User?> verifyOTP(String smsCode) async {
    if (_verificationId == null) {
      debugPrint(
          '❌ _verificationId is null — sendOTP was not called or failed');
      return null;
    }
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      final result = await _auth.signInWithCredential(credential);
      debugPrint('✅ Firebase OTP verified. UID: ${result.user?.uid}');
      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ verifyOTP FirebaseAuthException → ${e.code}: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('❌ verifyOTP exception: $e');
      return null;
    }
  }

  // ─── RESEND OTP ───────────────────────────────────────────
  Future<bool> resendOTP(String phone) async => sendOTP(phone);

  // ─── HELPERS ──────────────────────────────────────────────
  String _formatPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-()]'), '');
    if (cleaned.startsWith('+')) return cleaned;
    if (cleaned.startsWith('92')) return '+$cleaned';
    if (cleaned.startsWith('0')) return '+92${cleaned.substring(1)}';
    return '+92$cleaned';
  }

  User? get currentUser => _auth.currentUser;
  Future<void> signOut() async => _auth.signOut();
}
