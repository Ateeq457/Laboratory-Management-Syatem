// lib/core/routes/app_routes.dart
// ✅ Updated: OTP route now passes userName (Map args) alongside phoneNumber

import 'package:flutter/material.dart';
import 'package:lab_system/presentation/screens/auth/login_screen.dart';
import 'package:lab_system/presentation/screens/auth/name_input_screen.dart';
import 'package:lab_system/presentation/screens/auth/otp_verification_screen.dart';
import 'package:lab_system/presentation/screens/auth/splash_screen.dart';
import 'package:lab_system/presentation/screens/reports/reports_screen.dart';
import 'package:lab_system/presentation/screens/tests/test_list_screen.dart';
import 'package:lab_system/presentation/screens/tests/test_detail_screen.dart';
import 'package:lab_system/presentation/screens/history/booking_history_screen.dart';
import 'package:lab_system/presentation/screens/profile/profile_screen.dart';
import 'package:lab_system/data/models/test_model.dart';
import 'package:lab_system/app.dart';

class AppRoutes {
  static const String home = '/';
  static const String testList = '/tests';
  static const String testDetail = '/test-detail';
  static const String orders = '/orders';
  static const String reports = '/reports';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String nameInput = '/name-input';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return _route(const MainScreen());

      case testList:
        return _route(TestListScreen(
          initialCategory: settings.arguments as String?,
        ));

      case testDetail:
        return _route(TestDetailScreen(test: settings.arguments as TestModel));

      case orders:
        return _route(const BookingHistoryScreen());

      case reports:
        return _route(const ReportsScreen());

      case splash:
        return _route(const SplashScreen());

      case login:
        return _route(const LoginScreen());

      // OTP route: arguments is a Map<String, String>
      // { 'phone': '+923001234567', 'name': 'Ahmed Raza' }
      case otp:
        final args = settings.arguments as Map<String, String>;
        return _route(OTPVerificationScreen(
          phoneNumber: args['phone']!,
          userName: args['name'] ?? '',
        ));

      case nameInput:
        return _route(NameInputScreen(
          phoneNumber: settings.arguments as String,
        ));

      case profile:
        return _route(const ProfileScreen());

      default:
        return _route(
          const Scaffold(
            body: Center(child: Text('Route not found ❌')),
          ),
        );
    }
  }

  static MaterialPageRoute _route(Widget page) =>
      MaterialPageRoute(builder: (_) => page);
}
