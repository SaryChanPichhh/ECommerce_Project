class ProductCreateRequest {
  final String name;
  final String? description;
  final double price;
  final int quantity;
  final String? category;
  final String? imageUrl;

  const ProductCreateRequest({
    required this.name,
    this.description,
    required this.price,
    this.quantity = 0,
    this.category,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'category': category,
      'image_url': imageUrl,
    };
  }
}
