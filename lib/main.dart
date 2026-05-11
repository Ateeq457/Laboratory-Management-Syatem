// lib/main.dart
// ✅ PRODUCTION FIX: Initialize Firebase + Supabase BEFORE setupLocator()
// Root cause of crash: Repositories accessed Supabase.instance at constructor
// time (via GetIt lazy init) before Supabase.initialize() had completed.
// Fix: All async inits complete first, then DI container is configured.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lab_system/error_app.dart';
import 'package:lab_system/services/locator.dart';
import 'package:lab_system/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ─────────────────────────────────────────────────────────────
    // STEP 1 — Firebase (OTP Auth)
    // Must be first: firebase_auth depends on Firebase.initializeApp()
    // ─────────────────────────────────────────────────────────────
    await Firebase.initializeApp();

    // ─────────────────────────────────────────────────────────────
    // STEP 2 — Supabase (Database)
    // CRITICAL: Must complete before setupLocator() because every
    // Supabase*Repository calls Supabase.instance.client in its
    // constructor. If locator is set up first and a screen triggers
    // lazy creation before this line, you get the assertion crash:
    // "You must initialize the supabase instance before calling
    // Supabase.instance"
    // ─────────────────────────────────────────────────────────────
    await Supabase.initialize(
      url: 'https://xoxjukzbkzkskgnfjoye.supabase.co',
      anonKey: 'sb_publishable_i5w1EONe5IqPrPJMQSONqA_kZCNJm_p',
    );

    // ─────────────────────────────────────────────────────────────
    // STEP 3 — Dependency Injection
    // Now safe: both SDKs are fully ready, so repository constructors
    // that call Supabase.instance will not crash.
    // ─────────────────────────────────────────────────────────────
    setupLocator();

    // ─────────────────────────────────────────────────────────────
    // STEP 4 — Run App
    // ─────────────────────────────────────────────────────────────
    runApp(const MyApp());
  } catch (e, stack) {
    debugPrint('❌ App initialization error: $e');
    debugPrint(stack.toString());
    runApp(const ErrorApp());
  }
}
