// lib/infrastructure/models/profile_model.dart
import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.name,
    required super.role,
    required super.pharmacyName,
    required super.licenseNumber,
    required super.phone,
    required super.expiredDrugsCount,
    required super.totalAlternatives,
    super.avatarUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      pharmacyName: json['pharmacy_name'] ?? json['pharmacyName'] ?? '',
      licenseNumber: json['license_number'] ?? json['licenseNumber'] ?? '',
      phone: json['phone'] ?? '',
      expiredDrugsCount: json['expired_drugs_count'] ?? json['expiredDrugsCount'] ?? 0,
      totalAlternatives: json['total_alternatives'] ?? json['totalAlternatives'] ?? 0,
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
    );
  }

  static const ProfileModel mock = ProfileModel(
    id: 1,
    name: 'د. محمد عبدالله',
    role: 'صيدلي مرخص',
    pharmacyName: 'صيدلية الشفاء الحديثة',
    licenseNumber: 'LIC-2024-9981-AR',
    phone: '777777777',
    expiredDrugsCount: 1,
    totalAlternatives: 420,
  );
}
