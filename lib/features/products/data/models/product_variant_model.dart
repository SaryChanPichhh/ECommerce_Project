import '../../domain/entities/product_variant.dart';

class ProductVariantOptionModel extends ProductVariantOption {
  const ProductVariantOptionModel({
    required super.name,
    required super.value,
  });

  factory ProductVariantOptionModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantOptionModel(
      name: json['name'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}

class ProductVariantModel extends ProductVariant {
  const ProductVariantModel({
    required super.id,
    required super.name,
    super.sku,
    required super.stockQuantity,
    super.status = 'active',
    required super.price,
    super.options = const [],
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List<dynamic>? ?? [];

    return ProductVariantModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      sku: json['sku'] as String?,
      stockQuantity: json['stock_quantity'] is num
          ? (json['stock_quantity'] as num).toInt()
          : int.tryParse(json['stock_quantity']?.toString() ?? '0') ?? 0,
      status: json['status'] as String? ?? 'active',
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      options: rawOptions
          .map((opt) =>
              ProductVariantOptionModel.fromJson(opt as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'stock_quantity': stockQuantity,
      'status': status,
      'price': price.toString(),
      'options': options
          .map((opt) => ProductVariantOptionModel(
                name: opt.name,
                value: opt.value,
              ).toJson())
          .toList(),
    };
  }

  factory ProductVariantModel.fromEntity(ProductVariant variant) {
    return ProductVariantModel(
      id: variant.id,
      name: variant.name,
      sku: variant.sku,
      stockQuantity: variant.stockQuantity,
      status: variant.status,
      price: variant.price,
      options: variant.options,
    );
  }
}
