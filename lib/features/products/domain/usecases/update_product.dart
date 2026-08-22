import '../entities/product.dart';
import '../repositories/product_repository.dart';

class UpdateProductUseCase {
  final ProductRepository _repository;

  UpdateProductUseCase({required ProductRepository repository})
      : _repository = repository;

  Future<Product> call(Product product) {
    return _repository.updateProduct(product);
  }
}
