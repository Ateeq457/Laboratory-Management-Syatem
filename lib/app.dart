// lib/app.dart

import 'package:flutter/material.dart';
import 'package:lab_system/core/themes/app_theme.dart';
import 'package:lab_system/core/routes/app_routes.dart';
import 'package:lab_system/presentation/screens/home/home_screen.dart';
import 'package:lab_system/presentation/screens/tests/test_list_screen.dart';
import 'package:lab_system/presentation/screens/history/booking_history_screen.dart';
import 'package:lab_system/presentation/screens/reports/reports_screen.dart';
import 'package:lab_system/presentation/screens/profile/profile_screen.dart';
import 'package:lab_system/presentation/widgets/bottom_nav_bar.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thal-Care Diagnostic',
      debugShowCheckedModeBanner: false,

      // Theme Support
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // ==================== ROUTING ====================
      initialRoute: AppRoutes.splash, // ← Splash screen pehle
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}

// ==================== MAIN SCREEN WITH BOTTOM NAVIGATION ====================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TestListScreen(),
    const BookingHistoryScreen(),
    const ReportsScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex == 0) {
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Exit App'),
          content: const Text('Are you sure you want to exit?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textGray),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Exit',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      );
      return shouldExit ?? false;
    } else {
      setState(() {
        _currentIndex = 0;
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
      ),
    );
  }
}
