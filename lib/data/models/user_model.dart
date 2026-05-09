// lib/data/models/user_model.dart
// User Model for Thal-Care App

class UserModel {
  final String id;
  final String phone;
  final String? name;
  final String? email;
  final String? sector;
  final String? address;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    this.sector,
    this.address,
    required this.createdAt,
    this.lastLogin,
  });

  // From JSON (API response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      sector: json['sector']?.toString(),
      address: json['address']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,
    );
  }

  // To JSON (for API request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'email': email,
      'sector': sector,
      'address': address,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  // Copy with updates
  UserModel copyWith({
    String? id,
    String? phone,
    String? name,
    String? email,
    String? sector,
    String? address,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      email: email ?? this.email,
      sector: sector ?? this.sector,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
