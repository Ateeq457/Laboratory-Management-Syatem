// lib/data/repositories/base_test_repository.dart
// Abstract Repository - Defines WHAT to do (not HOW)

import '../models/test_model.dart';

abstract class BaseTestRepository {
  // Get all tests
  Future<List<TestModel>> getTests();

  // Get featured tests (home page)
  Future<List<TestModel>> getFeaturedTests();

  // Get popular tests
  Future<List<TestModel>> getPopularTests();

  // Get tests by category
  Future<List<TestModel>> getTestsByCategory(String category);

  // Get single test by ID
  Future<TestModel?> getTestById(String id);

  // Search tests
  Future<List<TestModel>> searchTests(String query);

  // Get all categories
  Future<List<String>> getCategories();
}
