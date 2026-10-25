import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class GetCheckoutPreviewUseCase {
  final CartRepository repository;
  GetCheckoutPreviewUseCase({required this.repository});

  Future<CartTotals> call({String? shippingAddressId}) =>
      repository.getCheckoutPreview(shippingAddressId: shippingAddressId);
}
