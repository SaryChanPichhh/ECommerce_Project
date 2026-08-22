import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductUseCase {
  final ProductRepository _repository;

  GetProductUseCase({required ProductRepository repository})
      : _repository = repository;

  Future<Product> call(String id) {
    return _repository.getProduct(id);
  }
}
