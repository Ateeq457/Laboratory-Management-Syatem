// lib/data/models/address_model.dart

class AddressModel {
  final String id;
  final String sector;
  final String streetNumber;
  final String houseNumber;
  final String? landmark;
  final String fullAddress;
  final bool isSaved;
  final bool isDefault;
  final DateTime lastUsed;

  AddressModel({
    required this.id,
    required this.sector,
    required this.streetNumber,
    required this.houseNumber,
    this.landmark,
    required this.fullAddress,
    required this.isSaved,
    this.isDefault = false,
    required this.lastUsed,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString() ?? '',
      sector: json['sector']?.toString() ?? '',
      streetNumber: json['street_number']?.toString() ?? '',
      houseNumber: json['house_number']?.toString() ?? '',
      landmark: json['landmark']?.toString(),
      fullAddress: json['full_address']?.toString() ?? '',
      isSaved: json['is_saved'] ?? false,
      isDefault: json['is_default'] ?? false,
      lastUsed: json['last_used'] != null
          ? DateTime.parse(json['last_used'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sector': sector,
      'street_number': streetNumber,
      'house_number': houseNumber,
      'landmark': landmark,
      'full_address': fullAddress,
      'is_saved': isSaved,
      'is_default': isDefault,
      'last_used': lastUsed.toIso8601String(),
    };
  }

  AddressModel copyWith({
    String? id,
    String? sector,
    String? streetNumber,
    String? houseNumber,
    String? landmark,
    String? fullAddress,
    bool? isSaved,
    bool? isDefault,
    DateTime? lastUsed,
  }) {
    return AddressModel(
      id: id ?? this.id,
      sector: sector ?? this.sector,
      streetNumber: streetNumber ?? this.streetNumber,
      houseNumber: houseNumber ?? this.houseNumber,
      landmark: landmark ?? this.landmark,
      fullAddress: fullAddress ?? this.fullAddress,
      isSaved: isSaved ?? this.isSaved,
      isDefault: isDefault ?? this.isDefault,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }
}
