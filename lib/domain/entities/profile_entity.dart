// lib/domain/entities/profile_entity.dart

class ProfileEntity {
  final int id;
  final String name;
  final String role;
  final String pharmacyName;
  final String licenseNumber;
  final String phone;
  final int expiredDrugsCount;
  final int totalAlternatives;
  final String? avatarUrl;

  const ProfileEntity({
    required this.id,
    required this.name,
    required this.role,
    required this.pharmacyName,
    required this.licenseNumber,
    required this.phone,
    required this.expiredDrugsCount,
    required this.totalAlternatives,
    this.avatarUrl,
  });

  static const ProfileEntity mock = ProfileEntity(
    id: 1,
    name: 'د. أحمد عبد الرحمن',
    role: 'مالك الصيدلية وإداري المخزون',
    pharmacyName: 'صيدلية الشفاء الحديثة',
    licenseNumber: 'PH-99281-A',
    phone: '+966 50 123 4567',
    expiredDrugsCount: 1,
    totalAlternatives: 420,
  );
}
