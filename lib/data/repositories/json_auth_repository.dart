// lib/data/repositories/json_auth_repository.dart
// JSON Implementation of Auth Repository

import 'package:shared_preferences/shared_preferences.dart';
import 'package:lab_system/services/json_service.dart';
import 'base_auth_repository.dart';
import '../models/user_model.dart';

class JsonAuthRepository implements BaseAuthRepository {
  final JsonService _jsonService = JsonService();
  static const String _keyUserId = 'current_user_id';

  @override
  Future<bool> sendOTP(String phoneNumber) async {
    // Mock OTP sending
    await Future.delayed(const Duration(seconds: 1));
    print('📱 OTP sent to: $phoneNumber');
    print('🔑 Mock OTP: 123456');
    return true;
  }

  @override
  Future<UserModel?> verifyOTP(String phoneNumber, String otp) async {
    // Mock OTP verification
    await Future.delayed(const Duration(seconds: 1));

    // Accept any OTP in mock mode (for testing)
    if (otp == '123456' || otp.length == 6) {
      // Get or create user
      final users = await _getAllUsers();
      var user = users.firstWhere(
        (u) => u.phone == phoneNumber,
        orElse: () => _createMockUser(phoneNumber),
      );

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserId, user.id);

      return user;
    }

    return null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_keyUserId);

    if (userId == null) return null;

    return await _jsonService.getUser(userId);
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

    final updatedUser = currentUser.copyWith(
      name: name ?? currentUser.name,
      email: email ?? currentUser.email,
      sector: sector ?? currentUser.sector,
      address: address ?? currentUser.address,
    );

    // In mock, just return updated user
    // In real app, save to backend
    return updatedUser;
  }

  @override
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyUserId);
  }

  // ==================== Helper Methods ====================

  Future<List<UserModel>> _getAllUsers() async {
    final user = await _jsonService.getUser('user_001');
    return user != null ? [user] : [];
  }

  UserModel _createMockUser(String phoneNumber) {
    return UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      phone: phoneNumber,
      name: 'User',
      createdAt: DateTime.now(),
    );
  }
}
