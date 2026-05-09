// lib/data/repositories/json_test_repository.dart
// JSON Implementation of Test Repository
// Current: Uses JSON files
// Future: Can be replaced with API implementation

import 'package:lab_system/services/json_service.dart';
import 'base_test_repository.dart';
import '../models/test_model.dart';

class JsonTestRepository implements BaseTestRepository {
  final JsonService _jsonService = JsonService();

  @override
  Future<List<TestModel>> getTests() async {
    return await _jsonService.getTests();
  }

  @override
  Future<List<TestModel>> getFeaturedTests() async {
    return await _jsonService.getFeaturedTests();
  }

  @override
  Future<List<TestModel>> getPopularTests() async {
    return await _jsonService.getPopularTests();
  }

  @override
  Future<List<TestModel>> getTestsByCategory(String category) async {
    return await _jsonService.getTestsByCategory(category);
  }

  @override
  Future<TestModel?> getTestById(String id) async {
    return await _jsonService.getTestById(id);
  }

  @override
  Future<List<TestModel>> searchTests(String query) async {
    return await _jsonService.searchTests(query);
  }

  @override
  Future<List<String>> getCategories() async {
    final tests = await getTests();
    final categories =
        tests.map((test) => test.getCategoryDisplayName()).toSet();
    return categories.toList();
  }
}
