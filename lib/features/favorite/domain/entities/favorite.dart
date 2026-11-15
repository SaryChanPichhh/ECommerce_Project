import '../../../products/domain/entities/product.dart';
import '../../../products/domain/entities/product_variant.dart';

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
    super.storeName,
    super.storeLogoUrl,
    super.imageUrl,
    super.images,
    super.tags,
    super.isActive,
    super.isFavorite,
    super.ratingAverage,
    super.ratingCount,
    super.soldCount,
    super.variants,
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
    String? storeName,
    String? storeLogoUrl,
    String? imageUrl,
    List<String>? images,
    List<String>? tags,
    bool? isActive,
    bool? isFavorite,
    double? ratingAverage,
    int? ratingCount,
    int? soldCount,
    List<ProductVariant>? variants,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? favoritedAt,
  }) => Favorite(
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
    storeName: storeName ?? this.storeName,
    storeLogoUrl: storeLogoUrl ?? this.storeLogoUrl,
    imageUrl: imageUrl ?? this.imageUrl,
    images: images ?? this.images,
    tags: tags ?? this.tags,
    isActive: isActive ?? this.isActive,
    isFavorite: isFavorite ?? this.isFavorite,
    ratingAverage: ratingAverage ?? this.ratingAverage,
    ratingCount: ratingCount ?? this.ratingCount,
    soldCount: soldCount ?? this.soldCount,
    variants: variants ?? this.variants,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    favoritedAt: favoritedAt ?? this.favoritedAt,
  );

  @override
  String toString() =>
      'Favorite(id: $id, name: $name, price: $price, favoritedAt: $favoritedAt)';
}
