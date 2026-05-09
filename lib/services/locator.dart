// lib/services/locator.dart
// Dependency Injection Container
// 🔥 IMPORTANT: If you change backend, ONLY edit this file!

import 'package:get_it/get_it.dart';

// Base Repositories (Abstract)
import '../data/repositories/base_test_repository.dart';
import '../data/repositories/base_booking_repository.dart';
import '../data/repositories/base_auth_repository.dart';
import '../data/repositories/base_report_repository.dart';

// JSON Implementations (Current)
// 👇 Agar aapko backend change karna hai to YAHI change karna hai
import '../data/repositories/json_test_repository.dart';
import '../data/repositories/json_booking_repository.dart';
import '../data/repositories/json_auth_repository.dart';
import '../data/repositories/json_report_repository.dart';

// For future API implementation (when ready):
// import '../data/repositories/api_test_repository.dart';
// import '../data/repositories/api_booking_repository.dart';
// import '../data/repositories/api_auth_repository.dart';
// import '../data/repositories/api_report_repository.dart';

final locator = GetIt.instance;

void setupLocator() {
  // ==================== REGISTER REPOSITORIES ====================

  // Test Repository
  locator.registerLazySingleton<BaseTestRepository>(
    () => JsonTestRepository(),
    // 🚀 For future API backend, change to:
    // () => ApiTestRepository(),
  );

  // Booking Repository
  locator.registerLazySingleton<BaseBookingRepository>(
    () => JsonBookingRepository(),
    // 🚀 For future API backend, change to:
    // () => ApiBookingRepository(),
  );

  // Auth Repository
  locator.registerLazySingleton<BaseAuthRepository>(
    () => JsonAuthRepository(),
    // 🚀 For future API backend, change to:
    // () => ApiAuthRepository(),
  );

  // Report Repository
  locator.registerLazySingleton<BaseReportRepository>(
    () => JsonReportRepository(),
    // 🚀 For future API backend, change to:
    // () => ApiReportRepository(),
  );

  print('✅ Service Locator initialized with JSON repositories');
}
