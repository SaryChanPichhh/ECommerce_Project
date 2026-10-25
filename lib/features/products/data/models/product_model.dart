import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';
import 'product_variant_model.dart';

class ProductModel extends Product {
  const ProductModel({
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
    super.variants,
    super.createdAt,
    super.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Parse price: backend provides base_price (e.g. "45.00") or price (num/string)
    double parsedPrice = 0.0;
    final rawPrice = json['base_price'] ?? json['price'];
    if (rawPrice is num) {
      parsedPrice = rawPrice.toDouble();
    } else if (rawPrice is String) {
      parsedPrice = double.tryParse(rawPrice) ?? 0.0;
    }

    // Parse compareAtPrice
    double? parsedComparePrice;
    final rawComparePrice = json['compare_at_price'];
    if (rawComparePrice is num) {
      parsedComparePrice = rawComparePrice.toDouble();
    } else if (rawComparePrice is String) {
      parsedComparePrice = double.tryParse(rawComparePrice);
    }

    // Parse category name and id
    String? categoryName;
    String? catId;
    if (json['category'] is Map) {
      categoryName = json['category']['name']?.toString();
      catId = json['category']['id']?.toString();
    } else if (json['category'] != null) {
      categoryName = json['category'].toString();
    }
    if (json['category_id'] != null) {
      catId = json['category_id']?.toString();
    }

    // Parse store id
    String? strId;
    if (json['store'] is Map) {
      strId = json['store']['id']?.toString();
    } else if (json['store_id'] != null) {
      strId = json['store_id']?.toString();
    }

    // Parse primary image
    final primaryImg = json['primary_image_url'] as String? ??
        json['image_url'] as String? ??
        json['image'] as String?;

    // Parse status / active
    final status = json['status']?.toString();
    final bool active = status != null ? status == 'active' : (json['is_active'] as bool? ?? true);

    // Parse rating average
    double ratingAvg = 0.0;
    final rawRating = json['rating_average'] ?? json['rating'];
    if (rawRating is num) {
      ratingAvg = rawRating.toDouble();
    } else if (rawRating is String) {
      ratingAvg = double.tryParse(rawRating) ?? 0.0;
    }

    // Parse variants
    final List<ProductVariant> parsedVariants = <ProductVariant>[];
    if (json['variants'] is List) {
      for (final item in json['variants'] as List) {
        if (item is Map) {
          parsedVariants.add(
            ProductVariantModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    // Parse quantity:
    // Note: GET /api/v1/public/products/ (product list summary) does not include
    // root `quantity`/`stock_quantity` or embedded `variants` (stock lives on
    // `/api/v1/public/products/{id}/variants/`, and variant-less products are not
    // stock-tracked per order_process.md).
    int parsedQuantity = 0;
    final rawQuantity = json['quantity'] ?? json['stock_quantity'];
    final hasExplicitQuantity =
        (json.containsKey('quantity') && json['quantity'] != null) ||
        (json.containsKey('stock_quantity') && json['stock_quantity'] != null);

    if (rawQuantity is num) {
      parsedQuantity = rawQuantity.toInt();
    } else if (rawQuantity is String) {
      parsedQuantity = int.tryParse(rawQuantity) ?? 0;
    }

    if (!hasExplicitQuantity && parsedVariants.isNotEmpty) {
      parsedQuantity = parsedVariants.fold<int>(
        0,
        (int sum, ProductVariant v) => sum + v.stockQuantity,
      );
    } else if (!hasExplicitQuantity && parsedVariants.isEmpty) {
      final isExplicitlyOutOfStock =
          json['in_stock'] == false || status == 'out_of_stock';
      if (active && !isExplicitlyOutOfStock) {
        parsedQuantity = 10;
      }
    }

    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      price: parsedPrice,
      compareAtPrice: parsedComparePrice,
      quantity: parsedQuantity,
      category: categoryName,
      categoryId: catId,
      storeId: strId,
      imageUrl: primaryImg,
      isActive: active,
      isFavorite: json['is_favorite'] as bool? ?? false,
      ratingAverage: ratingAvg,
      ratingCount: json['rating_count'] as int? ?? 0,
      soldCount: json['sold_count'] as int? ?? 0,
      variants: parsedVariants,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (slug != null) 'slug': slug,
      'description': description,
      'price': price,
      'base_price': price.toStringAsFixed(2),
      if (compareAtPrice != null) 'compare_at_price': compareAtPrice,
      'quantity': quantity,
      'stock_quantity': quantity,
      'category': category,
      if (categoryId != null) 'category_id': categoryId,
      if (storeId != null) 'store_id': storeId,
      'primary_image_url': imageUrl,
      'image_url': imageUrl,
      'is_active': isActive,
      'status': isActive ? 'active' : 'inactive',
      'is_favorite': isFavorite,
      'rating_average': ratingAverage,
      'rating_count': ratingCount,
      'sold_count': soldCount,
      if (variants.isNotEmpty)
        'variants': variants
            .map((v) => ProductVariantModel.fromEntity(v).toJson())
            .toList(),
    };
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      slug: product.slug,
      description: product.description,
      price: product.price,
      compareAtPrice: product.compareAtPrice,
      quantity: product.quantity,
      category: product.category,
      categoryId: product.categoryId,
      storeId: product.storeId,
      imageUrl: product.imageUrl,
      isActive: product.isActive,
      isFavorite: product.isFavorite,
      ratingAverage: product.ratingAverage,
      ratingCount: product.ratingCount,
      soldCount: product.soldCount,
      variants: product.variants,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }
}
