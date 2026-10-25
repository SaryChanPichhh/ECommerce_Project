import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class UpdateCartItemUseCase {
  final CartRepository repository;
  UpdateCartItemUseCase({required this.repository});

  Future<Cart> call(
    String cartItemId, {
    int? quantity,
    bool? isSelected,
  }) {
    return repository.updateCartItem(
      cartItemId,
      quantity: quantity,
      isSelected: isSelected,
    );
  }
}
