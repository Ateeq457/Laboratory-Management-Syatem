// lib/main.dart
// PRODUCTION - Pure Supabase Auth

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lab_system/error_app.dart';
import 'package:lab_system/services/locator.dart';
import 'package:lab_system/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Supabase Initialization
    await Supabase.initialize(
      url: 'https://xoxjukzbkzkskgnfjoye.supabase.co',
      anonKey: 'sb_publishable_i5w1EONe5IqPrPJMQSONqA_kZCNJm_p',
    );

    // Dependency Injection
    setupLocator();

    // Run App
    runApp(const MyApp());
  } catch (e, stack) {
    debugPrint('❌ App initialization error: $e');
    debugPrint(stack.toString());
    runApp(const ErrorApp());
  }
}
