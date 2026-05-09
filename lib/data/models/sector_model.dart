// lib/data/models/sector_model.dart
// Sector Model for Khalabat Towns

class SectorModel {
  final String id;
  final String name;
  final String nameUrdu;
  final int sectorNumber; // 1-4
  final List<String> availableStreets;
  final bool isServiceAvailable;
  final double? homeSamplingFeeMultiplier;

  SectorModel({
    required this.id,
    required this.name,
    required this.nameUrdu,
    required this.sectorNumber,
    this.availableStreets = const [],
    this.isServiceAvailable = true,
    this.homeSamplingFeeMultiplier,
  });

  // Predefined sectors
  static List<SectorModel> getSectors() {
    return [
      SectorModel(
        id: 'sector_1',
        name: 'Khalabat Sector 1',
        nameUrdu: 'خلابت سیکٹر 1',
        sectorNumber: 1,
        availableStreets: ['Street 1', 'Street 2', 'Street 3', 'Street 4'],
        isServiceAvailable: true,
        homeSamplingFeeMultiplier: 1.0,
      ),
      SectorModel(
        id: 'sector_2',
        name: 'Khalabat Sector 2',
        nameUrdu: 'خلابت سیکٹر 2',
        sectorNumber: 2,
        availableStreets: ['Street 1', 'Street 2', 'Street 3', 'Street 5'],
        isServiceAvailable: true,
        homeSamplingFeeMultiplier: 1.0,
      ),
      SectorModel(
        id: 'sector_3',
        name: 'Khalabat Sector 3',
        nameUrdu: 'خلابت سیکٹر 3',
        sectorNumber: 3,
        availableStreets: ['Street 1', 'Street 2', 'Street 4', 'Street 6'],
        isServiceAvailable: true,
        homeSamplingFeeMultiplier: 1.2, // Slightly higher fee
      ),
      SectorModel(
        id: 'sector_4',
        name: 'Khalabat Sector 4',
        nameUrdu: 'خلابت سیکٹر 4',
        sectorNumber: 4,
        availableStreets: ['Street 1', 'Street 2', 'Street 3', 'Street 7'],
        isServiceAvailable: true,
        homeSamplingFeeMultiplier: 1.2,
      ),
    ];
  }

  // Get sector by number
  static SectorModel? getSectorByNumber(int number) {
    return getSectors().firstWhere(
      (sector) => sector.sectorNumber == number,
      orElse: () => getSectors().first,
    );
  }

  factory SectorModel.fromJson(Map<String, dynamic> json) {
    return SectorModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameUrdu: json['name_urdu']?.toString() ?? '',
      sectorNumber: json['sector_number'] ?? 0,
      availableStreets: json['available_streets'] != null
          ? List<String>.from(json['available_streets'])
          : [],
      isServiceAvailable: json['is_service_available'] ?? true,
      homeSamplingFeeMultiplier:
          json['home_sampling_fee_multiplier']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_urdu': nameUrdu,
      'sector_number': sectorNumber,
      'available_streets': availableStreets,
      'is_service_available': isServiceAvailable,
      'home_sampling_fee_multiplier': homeSamplingFeeMultiplier,
    };
  }
}
