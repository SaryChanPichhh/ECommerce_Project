import '../../../products/domain/entities/product.dart';

class Favorite extends Product {
  final DateTime? favoritedAt;

  const Favorite({
    required super.id,
    required super.name,
    super.slug,
    super.description,
    required super.price,
    super.compareAtPrice,
    super.quantity,
    super.category,
    super.categoryId,
    super.storeId,
    super.imageUrl,
    super.isActive,
    super.isFavorite,
    super.ratingAverage,
    super.ratingCount,
    super.soldCount,
    super.createdAt,
    super.updatedAt,
    this.favoritedAt,
  });

  @override
  Favorite copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    double? price,
    double? compareAtPrice,
    int? quantity,
    String? category,
    String? categoryId,
    String? storeId,
    String? imageUrl,
    bool? isActive,
    bool? isFavorite,
    double? ratingAverage,
    int? ratingCount,
    int? soldCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? favoritedAt,
  }) {
    return Favorite(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      price: price ?? this.price,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      storeId: storeId ?? this.storeId,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      isFavorite: isFavorite ?? this.isFavorite,
      ratingAverage: ratingAverage ?? this.ratingAverage,
      ratingCount: ratingCount ?? this.ratingCount,
      soldCount: soldCount ?? this.soldCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      favoritedAt: favoritedAt ?? this.favoritedAt,
    );
  }

  @override
  String toString() => 'Favorite(id: $id, name: $name, price: $price, favoritedAt: $favoritedAt)';
}
