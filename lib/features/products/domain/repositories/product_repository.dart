import '../entities/product.dart';
import '../entities/product_variant.dart';

/// Product repository contract — domain layer.
abstract class ProductRepository {
  Future<List<Product>> getProducts({
    int? page,
    int? limit,
    String? search,
    String? category,
  });
  Future<Product> getProduct(String id);
  Future<List<ProductVariant>> getProductVariants(String productId);
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(String id);
}
