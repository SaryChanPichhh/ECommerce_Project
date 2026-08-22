class ProductUpdateRequest {
  final String id;
  final String? name;
  final String? description;
  final double? price;
  final int? quantity;
  final String? category;
  final String? imageUrl;
  final bool? isActive;

  const ProductUpdateRequest({
    required this.id,
    this.name,
    this.description,
    this.price,
    this.quantity,
    this.category,
    this.imageUrl,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (description != null) map['description'] = description;
    if (price != null) map['price'] = price;
    if (quantity != null) map['quantity'] = quantity;
    if (category != null) map['category'] = category;
    if (imageUrl != null) map['image_url'] = imageUrl;
    if (isActive != null) map['is_active'] = isActive;
    return map;
  }
}
