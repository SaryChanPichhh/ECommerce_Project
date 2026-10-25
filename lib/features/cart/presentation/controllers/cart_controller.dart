import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/user_session.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/helpers.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/repositories/order_repository.dart';
import '../../../orders/presentation/controllers/order_controller.dart';
import '../../domain/entities/address.dart';
import '../../domain/entities/cart.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/add_to_cart.dart';
import '../../domain/usecases/get_cart.dart';
import '../../domain/usecases/get_checkout_preview.dart';
import '../../domain/usecases/remove_cart_item.dart';
import '../../domain/usecases/select_all_cart.dart';
import '../../domain/usecases/update_cart_item.dart';

class CartController extends GetxController {
  final GetCartUseCase _getCartUseCase;
  final AddToCartUseCase _addToCartUseCase;
  final UpdateCartItemUseCase _updateCartItemUseCase;
  final RemoveCartItemUseCase _removeCartItemUseCase;
  final SelectAllCartUseCase _selectAllCartUseCase;
  final GetCheckoutPreviewUseCase _getCheckoutPreviewUseCase;
  final CartRepository _cartRepository;
  final OrderRepository _orderRepository;

  CartController({
    required GetCartUseCase getCartUseCase,
    required AddToCartUseCase addToCartUseCase,
    required UpdateCartItemUseCase updateCartItemUseCase,
    required RemoveCartItemUseCase removeCartItemUseCase,
    required SelectAllCartUseCase selectAllCartUseCase,
    required GetCheckoutPreviewUseCase getCheckoutPreviewUseCase,
    required CartRepository cartRepository,
    required OrderRepository orderRepository,
  })  : _getCartUseCase = getCartUseCase,
        _addToCartUseCase = addToCartUseCase,
        _updateCartItemUseCase = updateCartItemUseCase,
        _removeCartItemUseCase = removeCartItemUseCase,
        _selectAllCartUseCase = selectAllCartUseCase,
        _getCheckoutPreviewUseCase = getCheckoutPreviewUseCase,
        _cartRepository = cartRepository,
        _orderRepository = orderRepository;

  final Rxn<Cart> cart = Rxn<Cart>();
  final RxBool isLoading = false.obs;
  final RxBool isCheckingOut = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isLoggedIn = false.obs;

  // Addresses
  final RxList<Address> addresses = <Address>[].obs;
  final Rxn<Address> selectedAddress = Rxn<Address>();

  /// Check if the user is currently authenticated with a valid session token.
  bool get isAuthenticated => checkAuth();

  bool checkAuth() {
    bool authed = false;
    if (UserSession.instance.isAuthenticated) {
      authed = true;
    } else if (Get.isRegistered<LocalStorage>()) {
      authed = Get.find<LocalStorage>().isAuthenticated();
    }
    isLoggedIn.value = authed;
    return authed;
  }

  @override
  void onInit() {
    super.onInit();
    checkAuth();
    loadCart();
    loadAddresses();
  }

  /// Clears in-memory cart and address states on logout or account switch.
  void clearState() {
    isLoggedIn.value = false;
    cart.value = null;
    addresses.clear();
    selectedAddress.value = null;
    errorMessage.value = '';
    isLoading.value = false;
    isCheckingOut.value = false;
  }

  /// Reloads cart and address data for newly logged in user.
  Future<void> reload() async {
    clearState();
    checkAuth();
    await Future.wait([
      loadCart(),
      loadAddresses(),
    ]);
  }

  Future<void> loadCart() async {
    if (!isAuthenticated) {
      cart.value = null;
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _getCartUseCase();
      cart.value = result;
    } on UnauthorizedFailure {
      cart.value = null;
    } on Failure catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Failed to load cart';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAddresses() async {
    if (!isAuthenticated) {
      addresses.clear();
      selectedAddress.value = null;
      return;
    }
    try {
      final list = await _cartRepository.getAddresses();
      addresses.assignAll(list);
      if (list.isNotEmpty && selectedAddress.value == null) {
        selectedAddress.value = list.firstWhere(
          (a) => a.isDefault,
          orElse: () => list.first,
        );
      }
    } catch (_) {}
  }

  Future<bool> addToCart({
    required String productId,
    String? variantId,
    int quantity = 1,
    String? productName,
    double? unitPrice,
    String? productImageUrl,
    String? variantName,
  }) async {
    if (!isAuthenticated) {
      final shouldLogin = await Helpers.showConfirmDialog(
        title: 'login_required'.tr,
        message: 'login_to_add_cart'.tr,
        confirmText: 'login'.tr,
        cancelText: 'cancel'.tr,
      );
      if (shouldLogin) {
        Get.toNamed(AppRoutes.login);
      }
      return false;
    }

    try {
      final updated = await _addToCartUseCase(
        productId: productId,
        variantId: variantId,
        quantity: quantity,
        productName: productName,
        unitPrice: unitPrice,
        productImageUrl: productImageUrl,
        variantName: variantName,
      );
      cart.value = updated;
      Helpers.showSuccess(
        productName != null ? '$productName added to cart' : 'Added to cart',
      );
      return true;
    } on UnauthorizedFailure {
      final shouldLogin = await Helpers.showConfirmDialog(
        title: 'login_required'.tr,
        message: 'login_to_add_cart'.tr,
        confirmText: 'login'.tr,
        cancelText: 'cancel'.tr,
      );
      if (shouldLogin) {
        Get.toNamed(AppRoutes.login);
      }
      return false;
    } on Failure catch (e) {
      Helpers.showError(e.message);
      return false;
    } catch (_) {
      Helpers.showError('Failed to add to cart');
      return false;
    }
  }

  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeItem(cartItemId);
      return;
    }
    try {
      final updated = await _updateCartItemUseCase(
        cartItemId,
        quantity: newQuantity,
      );
      cart.value = updated;
    } on Failure catch (e) {
      Helpers.showError(e.message);
    }
  }

  Future<void> toggleItemSelection(String cartItemId, bool isSelected) async {
    try {
      final updated = await _updateCartItemUseCase(
        cartItemId,
        isSelected: isSelected,
      );
      cart.value = updated;
    } on Failure catch (e) {
      Helpers.showError(e.message);
    }
  }

  Future<void> toggleSelectAll(bool selectAll) async {
    try {
      final updated = await _selectAllCartUseCase(selectAll);
      cart.value = updated;
    } on Failure catch (e) {
      Helpers.showError(e.message);
    }
  }

  Future<void> removeItem(String cartItemId) async {
    try {
      await _removeCartItemUseCase(cartItemId);
      await loadCart();
      Helpers.showSuccess('Item removed');
    } on Failure catch (e) {
      Helpers.showError(e.message);
    }
  }

  Future<void> refreshCheckoutPreview() async {
    try {
      final totals = await _getCheckoutPreviewUseCase(
        shippingAddressId: selectedAddress.value?.id,
      );
      if (cart.value != null) {
        cart.value = Cart(
          id: cart.value!.id,
          status: cart.value!.status,
          items: cart.value!.items,
          totals: totals,
        );
      }
    } catch (_) {}
  }

  void selectAddress(Address address) {
    selectedAddress.value = address;
    refreshCheckoutPreview();
  }

  Future<void> saveAddress({
    required String name,
    required String address,
    String? phone,
    double? latitude,
    double? longitude,
  }) async {
    final roundedLat = latitude != null
        ? double.parse(latitude.toStringAsFixed(6))
        : null;
    final roundedLng = longitude != null
        ? double.parse(longitude.toStringAsFixed(6))
        : null;

    try {
      final hasRealAddresses = addresses.any(
        (a) => !a.id.startsWith('addr-') && !a.id.startsWith('addr_'),
      );
      final newAddr = await _cartRepository.createAddress({
        'label': name,
        'recipient_name': name,
        'address_line_1': address,
        'phone_number': phone ?? '+85512345678',
        'city': 'Phnom Penh',
        'country_code': 'KH',
        'latitude': ?roundedLat,
        'longitude': ?roundedLng,
        'is_default': !hasRealAddresses,
      });
      addresses.add(newAddr);
      selectedAddress.value = newAddr;
      Helpers.showSuccess('Address updated');
    } catch (_) {
      final fallbackAddr = Address(
        id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
        label: name,
        recipientName: name,
        addressLine1: address,
        phoneNumber: phone ?? '+85512345678',
        city: 'Phnom Penh',
        latitude: roundedLat,
        longitude: roundedLng,
      );
      addresses.add(fallbackAddr);
      selectedAddress.value = fallbackAddr;
    }
  }

  Future<bool> checkout() async {
    if (!isAuthenticated) {
      final shouldLogin = await Helpers.showConfirmDialog(
        title: 'login_required'.tr,
        message: 'login_to_view_cart'.tr,
        confirmText: 'login'.tr,
        cancelText: 'cancel'.tr,
      );
      if (shouldLogin) {
        Get.toNamed(AppRoutes.login);
      }
      return false;
    }

    if (cart.value == null || !cart.value!.hasSelectedItems) {
      Helpers.showError('Please select at least one item to checkout');
      return false;
    }
    if (selectedAddress.value == null && addresses.isEmpty) {
      Helpers.showError('Please select a delivery address');
      return false;
    }

    isCheckingOut.value = true;
    try {
      Address currentAddr = selectedAddress.value ?? addresses.first;

      // If the selected address is a local mock placeholder (e.g. 'addr-1' or 'addr_...'),
      // persist it on the backend first so the order receives a valid shipping_address_id.
      if (currentAddr.id.startsWith('addr-') ||
          currentAddr.id.startsWith('addr_')) {
        try {
          final createdAddr = await _cartRepository.createAddress({
            'label': currentAddr.label ?? currentAddr.recipientName,
            'recipient_name': currentAddr.recipientName.isNotEmpty
                ? currentAddr.recipientName
                : 'Customer',
            'address_line_1': currentAddr.addressLine1.isNotEmpty
                ? currentAddr.addressLine1
                : '123 Russian Federation Blvd',
            'phone_number': currentAddr.phoneNumber.isNotEmpty
                ? currentAddr.phoneNumber
                : '+85512345678',
            'city': currentAddr.city.isNotEmpty
                ? currentAddr.city
                : 'Phnom Penh',
            'country_code': currentAddr.countryCode.isNotEmpty
                ? currentAddr.countryCode
                : 'KH',
            if (currentAddr.latitude != null)
              'latitude': double.parse(
                currentAddr.latitude!.toStringAsFixed(6),
              ),
            if (currentAddr.longitude != null)
              'longitude': double.parse(
                currentAddr.longitude!.toStringAsFixed(6),
              ),
            'is_default': true,
          });
          currentAddr = createdAddr;
          selectedAddress.value = createdAddr;
        } catch (_) {}
      }

      // Ensure selected items exist on the server cart if any were added locally
      final selectedCartItems =
          cart.value!.items.where((i) => i.isSelected).toList();
      final hasMockCartItems = cart.value!.id.startsWith('mock-') ||
          selectedCartItems.any(
            (i) => i.id == '1' || i.id == '2' || i.id.startsWith('c_'),
          );
      if (hasMockCartItems) {
        for (final item in selectedCartItems) {
          if (item.id == '1' || item.id == '2' || item.id.startsWith('c_')) {
            try {
              final syncedCart = await _addToCartUseCase(
                productId: item.productId,
                variantId: item.variantId,
                quantity: item.quantity,
                productName: item.productName,
                unitPrice: item.unitPrice,
                productImageUrl: item.productImageUrl,
                variantName: item.variantName,
              );
              cart.value = syncedCart;
            } catch (_) {}
          }
        }
      }

      final addressId = currentAddr.id;
      final fallbackOrderItems = selectedCartItems
          .map((i) => OrderItem(
                id: i.id,
                productId: i.productId,
                productVariantId: i.variantId,
                productName: i.productName,
                variantName: i.variantName,
                productImageUrl: i.productImageUrl,
                quantity: i.quantity,
                unitPrice: i.unitPrice,
                totalPrice: i.lineTotal,
              ))
          .toList();
      final total = cart.value!.totals.totalAmount;
      final cartId = cart.value!.id;
      final idempotencyKey =
          'checkout-${DateTime.now().microsecondsSinceEpoch}-$cartId';

      // Step 6: Place order(s) (creates one pending order per store)
      final createdOrders = await _orderRepository.createOrder(
        cartId: cartId,
        shippingAddressId: addressId,
        idempotencyKey: idempotencyKey,
        fallbackItems: fallbackOrderItems,
        fallbackTotal: total,
      );

      // Step 8 & 9: Complete payment for all orders created in this checkout batch
      // (automatically transitions orders from 'pending' -> 'confirmed')
      if (createdOrders.isNotEmpty) {
        final orderIds = createdOrders
            .map((o) => o.id)
            .where((id) => id.isNotEmpty)
            .toSet()
            .toList();
        if (orderIds.isNotEmpty) {
          try {
            await _orderRepository.payOrders(
              orderIds: orderIds,
              idempotencyKey:
                  'pay-${DateTime.now().microsecondsSinceEpoch}-$cartId',
            );
          } catch (_) {
            // If payment call fails transiently, orders remain in 'pending' state
            // and can be paid from the Orders screen.
          }
        }
      }

      // Clear purchased items from cart (also remove from server cart if fallback order was used due to server 500)
      if (createdOrders.any((o) => o.id.startsWith('ORD-'))) {
        for (final item in selectedCartItems) {
          try {
            await _removeCartItemUseCase(item.id);
          } catch (_) {}
        }
      }
      await _cartRepository.clearPurchasedItems();
      await loadCart();

      // Refresh order controller if active
      if (Get.isRegistered<OrderController>()) {
        Get.find<OrderController>().fetchOrders();
      }

      Helpers.showSuccess('Order placed successfully!');
      return true;
    } on Failure catch (e) {
      Helpers.showError(e.message);
      return false;
    } catch (e) {
      Helpers.showError('Failed to place order');
      return false;
    } finally {
      isCheckingOut.value = false;
    }
  }
}
