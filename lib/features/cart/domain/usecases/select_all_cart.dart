import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class SelectAllCartUseCase {
  final CartRepository repository;
  SelectAllCartUseCase({required this.repository});

  Future<Cart> call(bool selected) => repository.selectAll(selected);
}
