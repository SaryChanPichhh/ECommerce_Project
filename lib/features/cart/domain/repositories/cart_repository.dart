import '../entities/address.dart';
import '../entities/cart.dart';

abstract class CartRepository {
  Future<Cart> getCart();
  Future<Cart> addToCart({
    required String productId,
    String? variantId,
    int quantity = 1,
    String? productName,
    double? unitPrice,
    String? productImageUrl,
    String? variantName,
  });
  Future<Cart> updateCartItem(
    String cartItemId, {
    int? quantity,
    bool? isSelected,
  });
  Future<void> removeCartItem(String cartItemId);
  Future<Cart> selectAll(bool selected);
  Future<CartTotals> getCheckoutPreview({String? shippingAddressId});
  Future<List<Address>> getAddresses();
  Future<Address> createAddress(Map<String, dynamic> data);
  Future<Address> setDefaultAddress(String addressId);
  Future<void> clearPurchasedItems();
}
