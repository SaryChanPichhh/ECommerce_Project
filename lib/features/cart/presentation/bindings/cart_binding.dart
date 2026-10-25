import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../../orders/data/datasources/order_remote_datasource.dart';
import '../../../orders/data/repositories/order_repository_impl.dart';
import '../../../orders/domain/repositories/order_repository.dart';
import '../../data/datasources/cart_remote_datasource.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/add_to_cart.dart';
import '../../domain/usecases/get_cart.dart';
import '../../domain/usecases/get_checkout_preview.dart';
import '../../domain/usecases/remove_cart_item.dart';
import '../../domain/usecases/select_all_cart.dart';
import '../../domain/usecases/update_cart_item.dart';
import '../controllers/cart_controller.dart';

class CartBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CartRemoteDataSource>()) {
      Get.lazyPut<CartRemoteDataSource>(
        () => CartRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<CartRepositoryImpl>()) {
      Get.lazyPut<CartRepositoryImpl>(
        () => CartRepositoryImpl(
          remoteDataSource: Get.find<CartRemoteDataSource>(),
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<CartRepository>()) {
      Get.lazyPut<CartRepository>(
        () => Get.isRegistered<CartRepositoryImpl>()
            ? Get.find<CartRepositoryImpl>()
            : CartRepositoryImpl(
                remoteDataSource: Get.find<CartRemoteDataSource>(),
              ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<OrderRemoteDataSource>()) {
      Get.lazyPut<OrderRemoteDataSource>(
        () => OrderRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<OrderRepositoryImpl>()) {
      Get.lazyPut<OrderRepositoryImpl>(
        () => OrderRepositoryImpl(
          remoteDataSource: Get.find<OrderRemoteDataSource>(),
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<OrderRepository>()) {
      Get.lazyPut<OrderRepository>(
        () => Get.isRegistered<OrderRepositoryImpl>()
            ? Get.find<OrderRepositoryImpl>()
            : OrderRepositoryImpl(
                remoteDataSource: Get.find<OrderRemoteDataSource>(),
              ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<GetCartUseCase>()) {
      Get.lazyPut(
        () => GetCartUseCase(repository: Get.find<CartRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<AddToCartUseCase>()) {
      Get.lazyPut(
        () => AddToCartUseCase(repository: Get.find<CartRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<UpdateCartItemUseCase>()) {
      Get.lazyPut(
        () => UpdateCartItemUseCase(repository: Get.find<CartRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<RemoveCartItemUseCase>()) {
      Get.lazyPut(
        () => RemoveCartItemUseCase(repository: Get.find<CartRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<SelectAllCartUseCase>()) {
      Get.lazyPut(
        () => SelectAllCartUseCase(repository: Get.find<CartRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetCheckoutPreviewUseCase>()) {
      Get.lazyPut(
        () => GetCheckoutPreviewUseCase(repository: Get.find<CartRepository>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<CartController>()) {
      Get.lazyPut(
        () => CartController(
          getCartUseCase: Get.find<GetCartUseCase>(),
          addToCartUseCase: Get.find<AddToCartUseCase>(),
          updateCartItemUseCase: Get.find<UpdateCartItemUseCase>(),
          removeCartItemUseCase: Get.find<RemoveCartItemUseCase>(),
          selectAllCartUseCase: Get.find<SelectAllCartUseCase>(),
          getCheckoutPreviewUseCase: Get.find<GetCheckoutPreviewUseCase>(),
          cartRepository: Get.find<CartRepository>(),
          orderRepository: Get.find<OrderRepository>(),
        ),
        fenix: true,
      );
    }
  }
}
