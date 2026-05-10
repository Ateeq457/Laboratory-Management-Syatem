import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lab_system/error_app.dart';
import 'package:lab_system/services/locator.dart';
import 'package:lab_system/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // -----------------------------
    // 1. Dependency Injection
    // -----------------------------
    setupLocator();

    // -----------------------------
    // 2. Firebase Init (OTP Auth)
    // -----------------------------
    await Firebase.initializeApp();

    // -----------------------------
    // 3. Supabase Init (Database)
    // -----------------------------
    await Supabase.initialize(
      url: 'https://xoxjukzbkzkskgnfjoye.supabase.co',
      anonKey: 'sb_publishable_i5w1EONe5IqPrPJMQSONqA_kZCNJm_p',
    );

    // -----------------------------
    // 4. Run App
    // -----------------------------
    runApp(const MyApp());
  } catch (e) {
    debugPrint('App initialization error: $e');
    runApp(const ErrorApp());
  }
}
