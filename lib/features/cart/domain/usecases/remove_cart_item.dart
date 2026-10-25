import '../repositories/cart_repository.dart';

class RemoveCartItemUseCase {
  final CartRepository repository;
  RemoveCartItemUseCase({required this.repository});

  Future<void> call(String cartItemId) => repository.removeCartItem(cartItemId);
}
