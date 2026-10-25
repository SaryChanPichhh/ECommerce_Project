class ProductVariantOption {
  final String name;
  final String value;

  const ProductVariantOption({
    required this.name,
    required this.value,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductVariantOption &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          value == other.value;

  @override
  int get hashCode => Object.hash(name, value);
}

class ProductVariant {
  final String id;
  final String name;
  final String? sku;
  final int stockQuantity;
  final String status;
  final double price;
  final List<ProductVariantOption> options;

  const ProductVariant({
    required this.id,
    required this.name,
    this.sku,
    required this.stockQuantity,
    this.status = 'active',
    required this.price,
    this.options = const [],
  });

  bool get isInStock => stockQuantity > 0 && status == 'active';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductVariant &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
