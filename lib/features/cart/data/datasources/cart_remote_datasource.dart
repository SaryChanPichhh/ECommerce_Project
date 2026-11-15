import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/address_model.dart';
import '../models/cart_model.dart';

abstract class CartRemoteDataSource {
  Future<CartModel> getCart();
  Future<CartModel> addToCart({
    required String productId,
    String? variantId,
    int quantity = 1,
    String? productName,
    double? unitPrice,
    String? productImageUrl,
    String? variantName,
  });
  Future<CartModel> updateCartItem(
    String cartItemId, {
    int? quantity,
    bool? isSelected,
  });
  Future<void> removeCartItem(String cartItemId);
  Future<CartModel> selectAll(bool selected);
  Future<CartTotalsModel> getCheckoutPreview({String? shippingAddressId});
  Future<List<AddressModel>> getAddresses();
  Future<AddressModel> createAddress(Map<String, dynamic> data);
  Future<AddressModel> setDefaultAddress(String addressId);
  Future<void> clearPurchasedItems();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final ApiClient _apiClient;

  CartRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  // Local fallback state for offline/guest browsing
  CartModel _mockCart = const CartModel(
    id: 'mock-cart-1',
    items: [
      CartItemModel(
        id: '1',
        productId: 'c928420c-7b0a-41e9-a352-fb59f237bf30',
        productName: 'Wireless Headphones',
        variantName: 'Red',
        quantity: 1,
        unitPrice: 120.0,
        lineTotal: 120.0,
        isSelected: true,
        productImageUrl: 'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb',
      ),
      CartItemModel(
        id: '2',
        productId: 'f51b9e28-7612-45e0-a75d-5cb95e1e1234',
        productName: 'Smart Watch',
        variantName: 'Black',
        quantity: 2,
        unitPrice: 250.0,
        lineTotal: 500.0,
        isSelected: false,
        productImageUrl: 'https://images.unsplash.com/photo-1551816230-ef5deaed4a26',
      ),
    ],
    totals: CartTotalsModel(
      selectedItemCount: 1,
      subtotalAmount: 120.0,
      shippingAmount: 15.0,
      totalAmount: 135.0,
    ),
  );

  final List<AddressModel> _mockAddresses = [
    const AddressModel(
      id: 'addr-1',
      label: 'Home',
      recipientName: 'Sarah Connor',
      phoneNumber: '+85599887766',
      addressLine1: '123 Russian Federation Blvd',
      city: 'Phnom Penh',
      state: 'Toul Kork',
      isDefault: true,
    ),
  ];

  @override
  Future<CartModel> getCart() async {
    try {
      final response = await _apiClient.get(ApiConstants.customerCart);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final cartData = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data;
        final model = CartModel.fromJson(cartData);
        _mockCart = model;
        return model;
      }
      return _mockCart;
    } on UnauthorizedException {
      rethrow;
    } catch (_) {
      return _mockCart;
    }
  }

  @override
  Future<CartModel> addToCart({
    required String productId,
    String? variantId,
    int quantity = 1,
    String? productName,
    double? unitPrice,
    String? productImageUrl,
    String? variantName,
  }) async {
    try {
      final request = AddToCartRequestModel(
        productId: productId,
        productVariantId: variantId,
        quantity: quantity,
      );
      final response = await _apiClient.post(
        ApiConstants.customerCartItems,
        data: request.toJson(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final cartData = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data;
        final model = CartModel.fromJson(cartData);
        _mockCart = model;
        return model;
      }
      return _mockCart;
    } on UnauthorizedException {
      rethrow;
    } on AppException {
      rethrow;
    } catch (_) {
      // Mock update
      final updatedItems = List<CartItemModel>.from(_mockCart.items.cast<CartItemModel>());
      final existingIndex = updatedItems.indexWhere((i) => i.productId == productId);
      final price = unitPrice ?? 45.0;
      final name = productName ?? 'Product Item';

      if (existingIndex >= 0) {
        final old = updatedItems[existingIndex];
        final newQty = old.quantity + quantity;
        final itemPrice = old.unitPrice > 0 ? old.unitPrice : price;
        updatedItems[existingIndex] = CartItemModel(
          id: old.id,
          productId: old.productId,
          productName: old.productName != 'Product Item' ? old.productName : name,
          productImageUrl: old.productImageUrl ?? productImageUrl,
          variantId: old.variantId ?? variantId,
          variantName: old.variantName ?? variantName,
          quantity: newQty,
          unitPrice: itemPrice,
          lineTotal: itemPrice * newQty,
          isSelected: old.isSelected,
        );
      } else {
        updatedItems.add(
          CartItemModel(
            id: 'c_${DateTime.now().millisecondsSinceEpoch}',
            productId: productId,
            productName: name,
            productImageUrl: productImageUrl,
            variantId: variantId,
            variantName: variantName,
            quantity: quantity,
            unitPrice: price,
            lineTotal: price * quantity,
            isSelected: true,
          ),
        );
      }
      _mockCart = CartModel(
        id: _mockCart.id,
        items: updatedItems,
        totals: CartTotalsModel.fromJson({}, updatedItems),
      );
      return _mockCart;
    }
  }

  @override
  Future<CartModel> updateCartItem(
    String cartItemId, {
    int? quantity,
    bool? isSelected,
  }) async {
    try {
      final request = UpdateCartItemRequestModel(
        quantity: quantity,
        isSelected: isSelected,
      );
      final response = await _apiClient.patch(
        ApiConstants.customerCartItemDetail(cartItemId),
        data: request.toJson(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final cartData = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data;
        final model = CartModel.fromJson(cartData);
        _mockCart = model;
        return model;
      }
      return _mockCart;
    } on UnauthorizedException {
      rethrow;
    } catch (_) {
      final updatedItems = _mockCart.items.map((i) {
        if (i.id == cartItemId) {
          final newQty = quantity ?? i.quantity;
          return CartItemModel(
            id: i.id,
            productId: i.productId,
            productName: i.productName,
            productImageUrl: i.productImageUrl,
            variantId: i.variantId,
            variantName: i.variantName,
            quantity: newQty,
            unitPrice: i.unitPrice,
            lineTotal: i.unitPrice * newQty,
            isSelected: isSelected ?? i.isSelected,
          );
        }
        return i as CartItemModel;
      }).toList();

      _mockCart = CartModel(
        id: _mockCart.id,
        items: updatedItems,
        totals: CartTotalsModel.fromJson({}, updatedItems),
      );
      return _mockCart;
    }
  }

  @override
  Future<void> removeCartItem(String cartItemId) async {
    if (!cartItemId.startsWith('c_') && cartItemId != '1' && cartItemId != '2') {
      try {
        await _apiClient.delete(ApiConstants.customerCartItemDetail(cartItemId));
      } on UnauthorizedException {
        rethrow;
      } catch (_) {}
    }
    final updatedItems = _mockCart.items
        .where((i) => i.id != cartItemId)
        .cast<CartItemModel>()
        .toList();
    _mockCart = CartModel(
      id: _mockCart.id,
      items: updatedItems,
      totals: CartTotalsModel.fromJson({}, updatedItems),
    );
  }

  @override
  Future<CartModel> selectAll(bool selected) async {
    try {
      final request = SelectAllCartRequestModel(selected: selected);
      final response = await _apiClient.post(
        ApiConstants.customerCartSelectAll,
        data: request.toJson(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final cartData = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data;
        final model = CartModel.fromJson(cartData);
        _mockCart = model;
        return model;
      }
      return _mockCart;
    } on UnauthorizedException {
      rethrow;
    } catch (_) {
      final updatedItems = _mockCart.items.map((i) {
        return CartItemModel(
          id: i.id,
          productId: i.productId,
          productName: i.productName,
          productImageUrl: i.productImageUrl,
          variantId: i.variantId,
          variantName: i.variantName,
          quantity: i.quantity,
          unitPrice: i.unitPrice,
          lineTotal: i.lineTotal,
          isSelected: selected,
        );
      }).toList();

      _mockCart = CartModel(
        id: _mockCart.id,
        items: updatedItems,
        totals: CartTotalsModel.fromJson({}, updatedItems),
      );
      return _mockCart;
    }
  }

  @override
  Future<CartTotalsModel> getCheckoutPreview({String? shippingAddressId}) async {
    try {
      final request = CheckoutPreviewRequestModel(
        shippingAddressId: shippingAddressId,
      );
      final response = await _apiClient.post(
        ApiConstants.customerCartCheckoutPreview,
        data: request.toJson(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final totalsData = data['data']?['totals'] is Map<String, dynamic>
            ? data['data']['totals'] as Map<String, dynamic>
            : (data['data'] is Map<String, dynamic>
                ? data['data'] as Map<String, dynamic>
                : <String, dynamic>{});
        return CartTotalsModel.fromJson(totalsData, _mockCart.items);
      }
      return _mockCart.totals as CartTotalsModel;
    } on UnauthorizedException {
      rethrow;
    } catch (_) {
      return _mockCart.totals as CartTotalsModel;
    }
  }

  @override
  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await _apiClient.get(ApiConstants.customerAddresses);
      final data = response.data;
      List<dynamic> items;
      if (data is Map<String, dynamic>) {
        items = data['data'] as List<dynamic>? ?? [];
      } else if (data is List) {
        items = data;
      } else {
        items = [];
      }
      final parsed = items.map((e) => AddressModel.fromJson(e as Map<String, dynamic>)).toList();
      if (parsed.isNotEmpty) return parsed;
      return _mockAddresses;
    } on UnauthorizedException {
      rethrow;
    } catch (_) {
      return _mockAddresses;
    }
  }

  @override
  Future<AddressModel> createAddress(Map<String, dynamic> data) async {
    try {
      final sanitized = Map<String, dynamic>.from(data);
      if (sanitized['latitude'] is num) {
        sanitized['latitude'] = double.parse(
          (sanitized['latitude'] as num).toDouble().toStringAsFixed(6),
        );
      }
      if (sanitized['longitude'] is num) {
        sanitized['longitude'] = double.parse(
          (sanitized['longitude'] as num).toDouble().toStringAsFixed(6),
        );
      }

      final response = await _apiClient.post(
        ApiConstants.customerAddresses,
        data: sanitized,
      );
      final resData = response.data;
      final aData = resData is Map<String, dynamic> && resData.containsKey('data')
          ? resData['data'] as Map<String, dynamic>
          : resData as Map<String, dynamic>;
      final model = AddressModel.fromJson(aData);
      _mockAddresses.add(model);
      return model;
    } on UnauthorizedException {
      rethrow;
    } catch (_) {
      final model = AddressModel.fromJson({
        'id': 'addr_${DateTime.now().millisecondsSinceEpoch}',
        ...data,
      });
      _mockAddresses.add(model);
      return model;
    }
  }

  @override
  Future<AddressModel> setDefaultAddress(String addressId) async {
    try {
      final response = await _apiClient.post(ApiConstants.customerAddressDefault(addressId));
      final resData = response.data;
      final aData = resData is Map<String, dynamic> && resData.containsKey('data')
          ? resData['data'] as Map<String, dynamic>
          : resData as Map<String, dynamic>;
      return AddressModel.fromJson(aData);
    } on UnauthorizedException {
      rethrow;
    } catch (_) {
      return _mockAddresses.firstWhere((a) => a.id == addressId, orElse: () => _mockAddresses.first);
    }
  }

  @override
  Future<void> clearPurchasedItems() async {
    final remainingItems = _mockCart.items
        .where((i) => !i.isSelected)
        .cast<CartItemModel>()
        .toList();
    _mockCart = CartModel(
      id: _mockCart.id,
      items: remainingItems,
      totals: CartTotalsModel.fromJson({}, remainingItems),
    );
  }
}
