// lib/domain/entities/drug_entity.dart

class DrugEntity {
  final int id;
  final String name;
  final String activeIngredient;
  final String category;
  final String location;
  final double price;
  final int stock;
  final DateTime? expiryDate;
  final int? matchPercentage;
  final String? matchLevel; // 'high' | 'medium' | 'low'
  final bool isAvailable;

  const DrugEntity({
    required this.id,
    required this.name,
    required this.activeIngredient,
    required this.category,
    required this.location,
    required this.price,
    required this.stock,
    this.expiryDate,
    this.matchPercentage,
    this.matchLevel,
    this.isAvailable = true,
  });

  String get expiryFormatted {
    if (expiryDate == null) return 'غير محدد';
    return '${expiryDate!.month.toString().padLeft(2, '0')}/${expiryDate!.year}';
  }

  String get stockStatus {
    if (stock <= 0) return 'غير متوفر';
    if (stock < 5) return 'متوفر - كمية قليلة';
    return 'متوفر';
  }

  String get expiryStatus {
    if (expiryDate == null) return 'ممتازة';
    final now = DateTime.now();
    final diff = expiryDate!.difference(now).inDays;
    if (diff < 0) return 'منتهية';
    if (diff < 90) return 'قاربت على الانتهاء';
    if (diff < 180) return 'متوسطة';
    return 'ممتازة';
  }
}
