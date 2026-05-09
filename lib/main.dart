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
    // 2. Supabase Initialization (UPDATED WITH YOUR CREDENTIALS)
    // -----------------------------
    await Supabase.initialize(
      url: 'https://xoxjukzbkzkskgnfjoye.supabase.co',
      anonKey: 'sb_publishable_i5w1EONe5IqPrPJMQSONqA_kZCNJm_p',
      debug: true,
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
