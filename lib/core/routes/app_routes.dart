// lib/core/routes/app_routes.dart

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
import 'package:lab_system/presentation/widgets/bottom_nav_bar.dart';
import 'package:lab_system/data/models/test_model.dart';
import 'package:lab_system/app.dart'; // ← Import MainScreen from app.dart

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
        return MaterialPageRoute(
          builder: (_) => const MainScreen(), // ← MainScreen with bottom nav
        );

      case testList:
        final args = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => TestListScreen(initialCategory: args),
        );

      case testDetail:
        final args = settings.arguments as TestModel;
        return MaterialPageRoute(
          builder: (_) => TestDetailScreen(test: args),
        );

      case orders:
        return MaterialPageRoute(
          builder: (_) => const BookingHistoryScreen(),
        );

      case reports:
        return MaterialPageRoute(
          builder: (_) => const ReportsScreen(),
        );

      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case otp:
        final args = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => OTPVerificationScreen(phoneNumber: args),
        );
      case nameInput:
        final args = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => NameInputScreen(phoneNumber: args),
        );
      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Route not found ❌'),
            ),
          ),
        );
    }
  }
}
