import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl({required ProductRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<Product>> getProducts({int? page, int? limit, String? search, String? category}) async {
    try {
      return await _remoteDataSource.getProducts(
        page: page,
        limit: limit,
        search: search,
        category: category,
      );
    } on NetworkException {
      throw const NetworkFailure();
    } on UnauthorizedException {
      throw const UnauthorizedFailure();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<Product> getProduct(String id) async {
    try {
      return await _remoteDataSource.getProduct(id);
    } on NotFoundException {
      throw const NotFoundFailure(message: 'Product not found');
    } on NetworkException {
      throw const NetworkFailure();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<List<ProductVariant>> getProductVariants(String productId) async {
    try {
      final list = await _remoteDataSource.getProductVariants(productId);
      return List<ProductVariant>.from(list);
    } on NetworkException {
      throw const NetworkFailure();
    } on UnauthorizedException {
      throw const UnauthorizedFailure();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<Product> createProduct(Product product) async {
    try {
      final model = ProductModel.fromEntity(product);
      return await _remoteDataSource.createProduct(model.toJson());
    } on ValidationException catch (e) {
      throw ValidationFailure(message: e.message, errors: e.errors);
    } on NetworkException {
      throw const NetworkFailure();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    try {
      final model = ProductModel.fromEntity(product);
      return await _remoteDataSource.updateProduct(product.id, model.toJson());
    } on NotFoundException {
      throw const NotFoundFailure(message: 'Product not found');
    } on ValidationException catch (e) {
      throw ValidationFailure(message: e.message, errors: e.errors);
    } on NetworkException {
      throw const NetworkFailure();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await _remoteDataSource.deleteProduct(id);
    } on NotFoundException {
      throw const NotFoundFailure(message: 'Product not found');
    } on NetworkException {
      throw const NetworkFailure();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }
}
