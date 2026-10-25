import '../../domain/entities/favorite.dart';

class FavoriteModel extends Favorite {
  const FavoriteModel({
    required super.id,
    required super.name,
    super.description,
    required super.price,
    super.quantity,
    super.category,
    super.imageUrl,
    super.isActive,
    super.createdAt,
    super.updatedAt,
    super.favoritedAt,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    // If favorite item wraps the product under 'product' key
    final Map<String, dynamic> pMap =
        json['product'] is Map<String, dynamic> ? json['product'] as Map<String, dynamic> : json;

    double parsedPrice = 0.0;
    final rawPrice = pMap['base_price'] ?? pMap['price'] ?? json['price'];
    if (rawPrice is num) {
      parsedPrice = rawPrice.toDouble();
    } else if (rawPrice is String) {
      parsedPrice = double.tryParse(rawPrice) ?? 0.0;
    }

    String? categoryName;
    if (pMap['category'] is Map) {
      categoryName = pMap['category']['name']?.toString();
    } else if (pMap['category'] != null) {
      categoryName = pMap['category'].toString();
    }

    final imageUrl = pMap['primary_image_url'] as String? ??
        pMap['image_url'] as String? ??
        pMap['image'] as String? ??
        json['image_url'] as String?;

    return FavoriteModel(
      id: (pMap['id'] ?? json['product_id'] ?? json['id'])?.toString() ?? '',
      name: (pMap['name'] ?? json['name']) as String? ?? '',
      description: (pMap['description'] ?? json['description']) as String?,
      price: parsedPrice,
      quantity: (pMap['quantity'] ?? json['quantity']) as int? ?? 0,
      category: categoryName,
      imageUrl: imageUrl,
      isActive: pMap['status'] == 'active' || (pMap['is_active'] as bool? ?? true),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      favoritedAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'category': category,
      'image_url': imageUrl,
      'is_active': isActive,
      if (favoritedAt != null) 'favorited_at': favoritedAt?.toIso8601String(),
    };
  }

  factory FavoriteModel.fromEntity(Favorite favorite) {
    return FavoriteModel(
      id: favorite.id,
      name: favorite.name,
      description: favorite.description,
      price: favorite.price,
      quantity: favorite.quantity,
      category: favorite.category,
      imageUrl: favorite.imageUrl,
      isActive: favorite.isActive,
      createdAt: favorite.createdAt,
      updatedAt: favorite.updatedAt,
      favoritedAt: favorite.favoritedAt,
    );
  }
}
