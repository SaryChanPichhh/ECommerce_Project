import '../../domain/entities/cart.dart';

// ──────────────────────────────────────────────────────────
// Cart & Checkout Request Models (per lib/docs/order_process.md)
// ──────────────────────────────────────────────────────────

/// Step 2: `POST /api/v1/customer/cart/items/`
class AddToCartRequestModel {
  final String productId;
  final String? productVariantId;
  final int quantity;

  const AddToCartRequestModel({
    required this.productId,
    this.productVariantId,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        if (productVariantId != null && productVariantId!.isNotEmpty)
          'product_variant_id': productVariantId,
        'quantity': quantity,
      };
}

/// Step 3: `PATCH /api/v1/customer/cart/items/{cart_item_id}/`
class UpdateCartItemRequestModel {
  final int? quantity;
  final bool? isSelected;

  const UpdateCartItemRequestModel({
    this.quantity,
    this.isSelected,
  });

  Map<String, dynamic> toJson() => {
        'quantity': ?quantity,
        'is_selected': ?isSelected,
      };
}

/// Step 3: `POST /api/v1/customer/cart/select-all/`
class SelectAllCartRequestModel {
  final bool selected;

  const SelectAllCartRequestModel({required this.selected});

  Map<String, dynamic> toJson() => {'selected': selected};
}

/// Step 5: `POST /api/v1/customer/cart/checkout-preview/`
class CheckoutPreviewRequestModel {
  final String? shippingAddressId;

  const CheckoutPreviewRequestModel({this.shippingAddressId});

  bool get hasValidServerAddress =>
      shippingAddressId != null &&
      shippingAddressId!.isNotEmpty &&
      !shippingAddressId!.startsWith('addr-') &&
      !shippingAddressId!.startsWith('addr_');

  Map<String, dynamic> toJson() => {
        if (hasValidServerAddress) 'shipping_address_id': shippingAddressId,
      };
}

class CartModel extends Cart {
  const CartModel({
    required super.id,
    super.status,
    super.items,
    required super.totals,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List?)
            ?.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final totalsMap = json['totals'] is Map<String, dynamic>
        ? json['totals'] as Map<String, dynamic>
        : <String, dynamic>{};

    return CartModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      items: itemsList,
      totals: CartTotalsModel.fromJson(totalsMap, itemsList),
    );
  }
}

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.id,
    required super.productId,
    required super.productName,
    super.productImageUrl,
    super.variantId,
    super.variantName,
    super.quantity,
    required super.unitPrice,
    required super.lineTotal,
    super.isSelected,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    String pId = '';
    String pName = 'Product';
    String? pImg;

    if (json['product'] is Map) {
      final pMap = json['product'] as Map<String, dynamic>;
      pId = pMap['id']?.toString() ?? '';
      pName = pMap['name']?.toString() ?? 'Product';
      pImg = pMap['primary_image_url'] as String? ?? pMap['image_url'] as String?;
    } else {
      pId = json['product_id']?.toString() ?? '';
      pName = json['product_name'] as String? ?? 'Product';
      pImg = json['image_url'] as String?;
    }

    String? vId;
    String? vName;
    if (json['variant'] is Map) {
      final vMap = json['variant'] as Map<String, dynamic>;
      vId = vMap['id']?.toString();
      vName = vMap['name']?.toString();
    } else {
      vId = json['product_variant_id']?.toString();
      vName = json['variant_name']?.toString();
    }

    final rawPrice = json['unit_price_snapshot'] ?? json['unit_price'] ?? json['price'];
    double parsedUnitPrice = 0.0;
    if (rawPrice is num) {
      parsedUnitPrice = rawPrice.toDouble();
    } else if (rawPrice is String) {
      parsedUnitPrice = double.tryParse(rawPrice) ?? 0.0;
    }

    final qty = json['quantity'] as int? ?? 1;

    final rawTotal = json['line_total'] ?? json['total_price'];
    double parsedLineTotal = parsedUnitPrice * qty;
    if (rawTotal is num) {
      parsedLineTotal = rawTotal.toDouble();
    } else if (rawTotal is String) {
      parsedLineTotal = double.tryParse(rawTotal) ?? parsedLineTotal;
    }

    return CartItemModel(
      id: json['id']?.toString() ?? '',
      productId: pId,
      productName: pName,
      productImageUrl: pImg,
      variantId: vId,
      variantName: vName,
      quantity: qty,
      unitPrice: parsedUnitPrice,
      lineTotal: parsedLineTotal,
      isSelected: json['is_selected'] as bool? ?? true,
    );
  }
}

class CartTotalsModel extends CartTotals {
  const CartTotalsModel({
    super.selectedItemCount,
    super.subtotalAmount,
    super.shippingAmount,
    super.discountAmount,
    super.taxAmount,
    super.totalAmount,
    super.currency,
  });

  factory CartTotalsModel.fromJson(Map<String, dynamic> json, List<CartItem> fallbackItems) {
    double parse(dynamic val, [double def = 0.0]) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? def;
      return def;
    }

    final selectedCount = json['selected_item_count'] as int? ??
        fallbackItems.where((i) => i.isSelected).length;

    double subtotal = parse(json['subtotal_amount']);
    if (subtotal == 0.0 && fallbackItems.isNotEmpty) {
      subtotal = fallbackItems
          .where((i) => i.isSelected)
          .fold(0.0, (sum, i) => sum + i.lineTotal);
    }

    final shipping = parse(json['shipping_amount'], 0.0);
    final discount = parse(json['discount_amount']);
    final tax = parse(json['tax_amount']);
    final total = parse(json['total_amount'], subtotal + shipping - discount + tax);

    return CartTotalsModel(
      selectedItemCount: selectedCount,
      subtotalAmount: subtotal,
      shippingAmount: shipping,
      discountAmount: discount,
      taxAmount: tax,
      totalAmount: total,
      currency: json['currency']?.toString() ?? 'USD',
    );
  }
}
