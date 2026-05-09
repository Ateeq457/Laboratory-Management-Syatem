import 'package:flutter/material.dart';
import 'package:lab_system/error_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lab_system/services/locator.dart';
import 'package:lab_system/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // -----------------------------
    // 1. Dependency Injection Setup
    // -----------------------------
    setupLocator();

    // -----------------------------
    // 2. Supabase Initialization
    // -----------------------------
    await Supabase.initialize(
      url: 'YOUR_SUPABASE_URL',
      anonKey: 'YOUR_SUPABASE_ANON_KEY',
      debug: false,
    );

    // -----------------------------
    // 3. Run App
    // -----------------------------
    runApp(const MyApp());
  } catch (e) {
    debugPrint('App initialization error: $e');

    runApp(const ErrorApp());
  }
}
