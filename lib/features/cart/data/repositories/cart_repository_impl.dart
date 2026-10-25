import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/address.dart';
import '../../domain/entities/cart.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_datasource.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource _remoteDataSource;

  CartRepositoryImpl({required CartRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Cart> getCart() async {
    try {
      return await _remoteDataSource.getCart();
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
  Future<Cart> addToCart({
    required String productId,
    String? variantId,
    int quantity = 1,
    String? productName,
    double? unitPrice,
    String? productImageUrl,
    String? variantName,
  }) async {
    try {
      return await _remoteDataSource.addToCart(
        productId: productId,
        variantId: variantId,
        quantity: quantity,
        productName: productName,
        unitPrice: unitPrice,
        productImageUrl: productImageUrl,
        variantName: variantName,
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
  Future<Cart> updateCartItem(
    String cartItemId, {
    int? quantity,
    bool? isSelected,
  }) async {
    try {
      return await _remoteDataSource.updateCartItem(
        cartItemId,
        quantity: quantity,
        isSelected: isSelected,
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
  Future<void> removeCartItem(String cartItemId) async {
    try {
      await _remoteDataSource.removeCartItem(cartItemId);
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
  Future<Cart> selectAll(bool selected) async {
    try {
      return await _remoteDataSource.selectAll(selected);
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
  Future<CartTotals> getCheckoutPreview({String? shippingAddressId}) async {
    try {
      return await _remoteDataSource.getCheckoutPreview(
        shippingAddressId: shippingAddressId,
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
  Future<List<Address>> getAddresses() async {
    try {
      return await _remoteDataSource.getAddresses();
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
  Future<Address> createAddress(Map<String, dynamic> data) async {
    try {
      return await _remoteDataSource.createAddress(data);
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
  Future<Address> setDefaultAddress(String addressId) async {
    try {
      return await _remoteDataSource.setDefaultAddress(addressId);
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
  Future<void> clearPurchasedItems() async {
    try {
      await _remoteDataSource.clearPurchasedItems();
    } catch (_) {}
  }
}
