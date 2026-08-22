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
    return FavoriteModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] as int? ?? 0,
      category: json['category'] as String?,
      imageUrl: json['image_url'] as String? ?? json['image'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      favoritedAt: json['favorited_at'] != null
          ? DateTime.tryParse(json['favorited_at'] as String)
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
