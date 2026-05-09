// lib/data/repositories/supabase_test_repository.dart
// Supabase Implementation of Test Repository

import 'package:supabase_flutter/supabase_flutter.dart';
import 'base_test_repository.dart';
import '../models/test_model.dart';

class SupabaseTestRepository implements BaseTestRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<TestModel>> getTests() async {
    try {
      print('🔵 Fetching tests from Supabase...');
      final response = await _supabase.from('tests').select('*');
      print('✅ Got ${response.length} tests');
      return response.map((json) => TestModel.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error fetching tests: $e');
      return [];
    }
  }

  @override
  Future<List<TestModel>> getFeaturedTests() async {
    final tests = await getTests();
    return tests.where((t) => t.isFeatured).toList();
  }

  @override
  Future<List<TestModel>> getPopularTests() async {
    final tests = await getTests();
    return tests.where((t) => t.isPopular).toList();
  }

  @override
  Future<List<TestModel>> getTestsByCategory(String category) async {
    final tests = await getTests();
    return tests.where((t) => t.getCategoryDisplayName() == category).toList();
  }

  @override
  Future<TestModel?> getTestById(String id) async {
    final tests = await getTests();
    try {
      return tests.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<TestModel>> searchTests(String query) async {
    final tests = await getTests();
    if (query.isEmpty) return tests;
    return tests
        .where((t) =>
            t.name.toLowerCase().contains(query.toLowerCase()) ||
            t
                .getCategoryDisplayName()
                .toLowerCase()
                .contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<List<String>> getCategories() async {
    final tests = await getTests();
    final categories = tests.map((t) => t.getCategoryDisplayName()).toSet();
    return categories.toList();
  }
}
