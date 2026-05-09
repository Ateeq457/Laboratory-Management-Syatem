// lib/data/repositories/base_auth_repository.dart
// Abstract Repository for Authentication

import '../models/user_model.dart';

abstract class BaseAuthRepository {
  // Send OTP to phone number
  Future<bool> sendOTP(String phoneNumber);

  // Verify OTP and login
  Future<UserModel?> verifyOTP(String phoneNumber, String otp);

  // Get current logged in user
  Future<UserModel?> getCurrentUser();

  // Logout user
  Future<void> logout();

  // Update user profile
  Future<UserModel?> updateUserProfile({
    String? name,
    String? email,
    String? sector,
    String? address,
  });

  // Check if user is logged in
  Future<bool> isLoggedIn();
}
