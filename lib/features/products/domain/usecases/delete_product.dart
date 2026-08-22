import '../repositories/product_repository.dart';

class DeleteProductUseCase {
  final ProductRepository _repository;

  DeleteProductUseCase({required ProductRepository repository})
      : _repository = repository;

  Future<void> call(String id) {
    return _repository.deleteProduct(id);
  }
}
