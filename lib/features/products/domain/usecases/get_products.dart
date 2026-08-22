import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository _repository;

  GetProductsUseCase({required ProductRepository repository})
      : _repository = repository;

  Future<List<Product>> call({int? page, int? limit, String? search}) {
    return _repository.getProducts(page: page, limit: limit, search: search);
  }
}
