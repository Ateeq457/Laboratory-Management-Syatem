// lib/data/models/test_model.dart
// Test / Diagnostic Service Model

enum TestCategory { bloodWork, diabetes, renal, hepatic, cardiology, other }

class TestModel {
  final String id;
  final String name;
  final String nameUrdu; // For local language support
  final TestCategory category;
  final double price;
  final double? homeSamplingFee;
  final String description;
  final String preparationInstructions;
  final String reportTime; // e.g., "6-8 hours"
  final bool isPopular;
  final bool isFeatured;
  final String? imageUrl;
  final List<String> parameters; // e.g., ["Hemoglobin", "RBC", "WBC"]
  final String? fastingRequired; // e.g., "8-10 hours fasting"
  final int orderCount; // For popularity sorting

  TestModel({
    required this.id,
    required this.name,
    required this.nameUrdu,
    required this.category,
    required this.price,
    this.homeSamplingFee,
    required this.description,
    required this.preparationInstructions,
    required this.reportTime,
    this.isPopular = false,
    this.isFeatured = false,
    this.imageUrl,
    this.parameters = const [],
    this.fastingRequired,
    this.orderCount = 0,
  });

  // From JSON
  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameUrdu: json['name_urdu']?.toString() ?? '',
      category: _parseCategory(json['category']?.toString() ?? ''),
      price: (json['price'] ?? 0).toDouble(),
      homeSamplingFee: json['home_sampling_fee']?.toDouble(),
      description: json['description']?.toString() ?? '',
      preparationInstructions:
          json['preparation_instructions']?.toString() ?? '',
      reportTime: json['report_time']?.toString() ?? '24 hours',
      isPopular: json['is_popular'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      imageUrl: json['image_url']?.toString(),
      parameters: json['parameters'] != null
          ? List<String>.from(json['parameters'])
          : [],
      fastingRequired: json['fasting_required']?.toString(),
      orderCount: json['order_count'] ?? 0,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_urdu': nameUrdu,
      'category': _categoryToString(category),
      'price': price,
      'home_sampling_fee': homeSamplingFee,
      'description': description,
      'preparation_instructions': preparationInstructions,
      'report_time': reportTime,
      'is_popular': isPopular,
      'is_featured': isFeatured,
      'image_url': imageUrl,
      'parameters': parameters,
      'fasting_required': fastingRequired,
      'order_count': orderCount,
    };
  }

  // Helper: Get total price with home sampling
  double getTotalPrice({bool isHomeSampling = false}) {
    if (isHomeSampling && homeSamplingFee != null) {
      return price + homeSamplingFee!;
    }
    return price;
  }

  // Helper: Get category display name
  String getCategoryDisplayName() {
    switch (category) {
      case TestCategory.bloodWork:
        return 'Blood Work';
      case TestCategory.diabetes:
        return 'Diabetes';
      case TestCategory.renal:
        return 'Renal';
      case TestCategory.hepatic:
        return 'Hepatic';
      case TestCategory.cardiology:
        return 'Cardiology';
      default:
        return 'Other';
    }
  }

  // Helper: Get category color
  String getCategoryColorHex() {
    switch (category) {
      case TestCategory.bloodWork:
        return '#fef2f2'; // Light red bg
      case TestCategory.diabetes:
        return '#eff6ff'; // Light blue bg
      case TestCategory.renal:
        return '#f0fdf4'; // Light green bg
      case TestCategory.hepatic:
        return '#fffbeb'; // Light yellow bg
      case TestCategory.cardiology:
        return '#fdf4ff'; // Light purple bg
      default:
        return '#f8fafc';
    }
  }

  static TestCategory _parseCategory(String value) {
    final lower = value.toLowerCase().trim();
    switch (lower) {
      case 'bloodwork':
      case 'blood_work':
      case 'blood work': // ← Space ke saath
        return TestCategory.bloodWork;
      case 'diabetes':
        return TestCategory.diabetes;
      case 'renal':
        return TestCategory.renal;
      case 'hepatic':
        return TestCategory.hepatic;
      case 'cardiology':
        return TestCategory.cardiology;
      default:
        print('⚠️ Unknown category from DB: $value');
        return TestCategory.other;
    }
  }

  static String _categoryToString(TestCategory category) {
    switch (category) {
      case TestCategory.bloodWork:
        return 'Blood Work'; // ← Space ke saath, database mein match karega
      case TestCategory.diabetes:
        return 'Diabetes';
      case TestCategory.renal:
        return 'Renal';
      case TestCategory.hepatic:
        return 'Hepatic';
      case TestCategory.cardiology:
        return 'Cardiology';
      default:
        return 'Other';
    }
  }
}
