import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class AddToCartUseCase {
  final CartRepository repository;
  AddToCartUseCase({required this.repository});

  Future<Cart> call({
    required String productId,
    String? variantId,
    int quantity = 1,
    String? productName,
    double? unitPrice,
    String? productImageUrl,
    String? variantName,
  }) {
    return repository.addToCart(
      productId: productId,
      variantId: variantId,
      quantity: quantity,
      productName: productName,
      unitPrice: unitPrice,
      productImageUrl: productImageUrl,
      variantName: variantName,
    );
  }
}
