import '../entities/product.dart';

/// Product repository contract — domain layer.
abstract class ProductRepository {
  Future<List<Product>> getProducts({int? page, int? limit, String? search});
  Future<Product> getProduct(String id);
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(String id);
}
