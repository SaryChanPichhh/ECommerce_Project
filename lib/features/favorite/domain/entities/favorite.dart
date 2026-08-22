import '../../../products/domain/entities/product.dart';

class Favorite extends Product {
  final DateTime? favoritedAt;

  const Favorite({
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
    this.favoritedAt,
  });

  @override
  String toString() => 'Favorite(id: $id, name: $name, price: $price, favoritedAt: $favoritedAt)';
}
