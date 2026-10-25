import '../entities/product_variant.dart';
import '../repositories/product_repository.dart';

class GetProductVariantsUseCase {
  final ProductRepository _repository;

  GetProductVariantsUseCase({required ProductRepository repository})
      : _repository = repository;

  Future<List<ProductVariant>> call(String productId) {
    return _repository.getProductVariants(productId);
  }
}
