import '../entities/product.dart';
import '../repositories/product_repository.dart';

class CreateProductUseCase {
  final ProductRepository _repository;

  CreateProductUseCase({required ProductRepository repository})
      : _repository = repository;

  Future<Product> call(Product product) {
    return _repository.createProduct(product);
  }
}
