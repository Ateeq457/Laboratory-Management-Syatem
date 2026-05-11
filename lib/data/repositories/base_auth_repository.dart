// lib/data/repositories/base_auth_repository.dart
// Abstract Repository for Authentication

import '../models/user_model.dart';

abstract class BaseAuthRepository {
  // Email/Password Sign Up
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
  });

  // Email/Password Sign In
  Future<UserModel?> signIn({
    required String email,
    required String password,
  });

  // Sign Out
  Future<void> signOut();

  // Get current logged in user
  Future<UserModel?> getCurrentUser();

  // Update user profile
  Future<UserModel?> updateUserProfile({
    String? name,
    String? email,
    String? phone,
    String? sector,
    String? address,
  });

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email);

  // Check if user is logged in
  Future<bool> isLoggedIn();

  // Get auth state stream
  Stream<AuthUserState?> get authStateChanges;

  // Resend email verification
  Future<bool> resendEmailVerification();

  // Check if email is verified
  Future<bool> isEmailVerified();

  // Refresh user session (get latest data)
  Future<UserModel?> refreshUser();
}

// Auth state model - FIXED with const constructor
class AuthUserState {
  final String? userId;
  final String? email;
  final bool isEmailVerified;
  final bool isLoading;

  const AuthUserState({
    // ← const added
    this.userId,
    this.email,
    this.isEmailVerified = false,
    this.isLoading = false,
  });

  AuthUserState copyWith({
    String? userId,
    String? email,
    bool? isEmailVerified,
    bool? isLoading,
  }) {
    return AuthUserState(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isAuthenticated => userId != null && userId!.isNotEmpty;
}
