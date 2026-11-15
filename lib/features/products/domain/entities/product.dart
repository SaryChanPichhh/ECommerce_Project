import 'product_variant.dart';

/// Product entity — pure Dart, no framework dependencies.
class Product {
  final String id;
  final String name;
  final String? slug;
  final String? description;
  final double price;
  final double? compareAtPrice;
  final int quantity;
  final String? category;
  final String? categoryId;
  final String? storeId;
  final String? storeName;
  final String? storeLogoUrl;
  final String? imageUrl;
  final List<String> images;
  final List<String> tags;
  final bool isActive;
  final bool isFavorite;
  final double ratingAverage;
  final int ratingCount;
  final int soldCount;
  final List<ProductVariant> variants;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    required this.price,
    this.compareAtPrice,
    this.quantity = 0,
    this.category,
    this.categoryId,
    this.storeId,
    this.storeName,
    this.storeLogoUrl,
    this.imageUrl,
    this.images = const [],
    this.tags = const [],
    this.isActive = true,
    this.isFavorite = false,
    this.ratingAverage = 0.0,
    this.ratingCount = 0,
    this.soldCount = 0,
    this.variants = const [],
    this.createdAt,
    this.updatedAt,
  });

  Product copyWith({
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
  }) {
    return Product(
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
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Product(id: $id, name: $name, price: $price)';
}
