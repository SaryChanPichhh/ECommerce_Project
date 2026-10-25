import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/order_remote_datasource.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/usecases/get_orders.dart';
import '../../domain/usecases/get_order.dart';
import '../controllers/order_controller.dart';

import '../../../orders/domain/repositories/order_repository.dart';

class OrderBinding extends Bindings {
  @override
  void dependencies() {
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
    if (!Get.isRegistered<GetOrdersUseCase>()) {
      Get.lazyPut(
        () => GetOrdersUseCase(repository: Get.find<OrderRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetOrderUseCase>()) {
      Get.lazyPut(
        () => GetOrderUseCase(repository: Get.find<OrderRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<OrderController>()) {
      Get.lazyPut(
        () => OrderController(
          getOrdersUseCase: Get.find<GetOrdersUseCase>(),
          orderRepository: Get.find<OrderRepository>(),
        ),
        fenix: true,
      );
    }
  }
}
