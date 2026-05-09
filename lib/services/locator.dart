// lib/services/locator.dart
// Dependency Injection Container
// 🔥 IMPORTANT: If you change backend, ONLY edit this file!

import 'package:get_it/get_it.dart';

// Base Repositories (Abstract)
import '../data/repositories/base_test_repository.dart';
import '../data/repositories/base_booking_repository.dart';
import '../data/repositories/base_auth_repository.dart';
import '../data/repositories/base_report_repository.dart';

// JSON Implementations (Mock Data)
// import '../data/repositories/json_test_repository.dart';
// import '../data/repositories/json_booking_repository.dart';
// import '../data/repositories/json_auth_repository.dart';
// import '../data/repositories/json_report_repository.dart';

// Supabase Implementations (Real Backend) ✅
import '../data/repositories/supabase_test_repository.dart';
import '../data/repositories/supabase_booking_repository.dart';
import '../data/repositories/supabase_auth_repository.dart';
import '../data/repositories/supabase_report_repository.dart';

final locator = GetIt.instance;

void setupLocator() {
  // ==================== REGISTER REPOSITORIES ====================

  // Test Repository - Using Supabase ✅
  locator.registerLazySingleton<BaseTestRepository>(
    () => SupabaseTestRepository(),
  );

  // Booking Repository - Using Supabase ✅
  locator.registerLazySingleton<BaseBookingRepository>(
    () => SupabaseBookingRepository(),
  );

  // Auth Repository - Using Supabase ✅
  locator.registerLazySingleton<BaseAuthRepository>(
    () => SupabaseAuthRepository(),
  );

  // Report Repository - Using Supabase ✅
  locator.registerLazySingleton<BaseReportRepository>(
    () => SupabaseReportRepository(),
  );

  print('✅ Service Locator initialized with Supabase repositories');
}
