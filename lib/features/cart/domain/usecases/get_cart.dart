import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class GetCartUseCase {
  final CartRepository repository;
  GetCartUseCase({required this.repository});

  Future<Cart> call() => repository.getCart();
}
