// lib/core/routes/app_routes.dart

import 'package:flutter/material.dart';
import 'package:lab_system/presentation/screens/home/home_screen.dart';
import 'package:lab_system/presentation/screens/reports/reports_screen.dart';
import 'package:lab_system/presentation/screens/tests/test_list_screen.dart';
import 'package:lab_system/presentation/screens/tests/test_detail_screen.dart';
import 'package:lab_system/presentation/screens/history/booking_history_screen.dart';
import 'package:lab_system/data/models/test_model.dart';

class AppRoutes {
  // Route names
  static const String home = '/';
  static const String testList = '/tests';
  static const String testDetail = '/test-detail';
  static const String orders = '/orders';
  static const String reports = '/reports';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      case testList:
        // Get category name from arguments (optional)
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
