// lib/infrastructure/models/drug_model.dart
import '../../domain/entities/drug_entity.dart';

class DrugModel extends DrugEntity {
  const DrugModel({
    required super.id,
    required super.name,
    required super.activeIngredient,
    required super.category,
    required super.location,
    required super.price,
    required super.stock,
    super.expiryDate,
    super.matchPercentage,
    super.matchLevel,
    super.isAvailable = true,
  });

  factory DrugModel.fromJson(Map<String, dynamic> json) {
    final expiryStr = json['nearestExpiryDate'] ?? json['expiry_date'] ?? json['expiryDate'];
    DateTime? parsedExpiry;
    if (expiryStr != null) {
      parsedExpiry = DateTime.tryParse(expiryStr.toString());
    }

    final rawStock = json['totalQuantity'] ?? json['stock'] ?? json['quantity'] ?? 0;
    final parsedStock = rawStock is int ? rawStock : (int.tryParse(rawStock.toString()) ?? 0);

    final rawPrice = json['price'] ?? json['Price'] ?? 0.0;
    final parsedPrice = rawPrice is num ? rawPrice.toDouble() : (double.tryParse(rawPrice.toString()) ?? 0.0);

    return DrugModel(
      id: json['id'] ?? 0,
      name: (json['tradeName'] ?? json['name'] ?? json['TradeName'] ?? '').toString(),
      activeIngredient: (json['scientificName'] ?? json['active_ingredient'] ?? json['activeIngredient'] ?? json['ScientificName'] ?? '').toString(),
      category: (json['categoryName'] ?? json['category'] ?? json['CategoryName'] ?? 'قسم عام').toString(),
      location: (json['location'] ?? json['nearestBatchNumber'] ?? 'غير محدد').toString(),
      price: parsedPrice,
      stock: parsedStock,
      expiryDate: parsedExpiry,
      matchPercentage: json['match_percentage'] ?? json['matchPercentage'] ?? 90,
      matchLevel: (json['match_level'] ?? json['matchLevel'] ?? 'high').toString(),
      isAvailable: json['isAvailable'] ?? json['is_available'] ?? (parsedStock > 0),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tradeName': name,
    'name': name,
    'scientificName': activeIngredient,
    'active_ingredient': activeIngredient,
    'categoryName': category,
    'category': category,
    'location': location,
    'price': price,
    'stock': stock,
    'initialQuantity': stock,
    'expiryDate': expiryDate?.toIso8601String(),
    'expiry_date': expiryDate?.toIso8601String(),
    'match_percentage': matchPercentage,
    'match_level': matchLevel,
    'is_available': isAvailable,
  };
}
