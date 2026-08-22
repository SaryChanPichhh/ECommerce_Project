import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/order_remote_datasource.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/usecases/get_orders.dart';
import '../../domain/usecases/get_order.dart';
import '../controllers/order_controller.dart';

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderRemoteDataSource>(() => OrderRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()));
    Get.lazyPut(() => OrderRepositoryImpl(remoteDataSource: Get.find<OrderRemoteDataSource>()));
    Get.lazyPut(() => GetOrdersUseCase(repository: Get.find<OrderRepositoryImpl>()));
    Get.lazyPut(() => GetOrderUseCase(repository: Get.find<OrderRepositoryImpl>()));
    Get.lazyPut(() => OrderController(getOrdersUseCase: Get.find<GetOrdersUseCase>()));
  }
}
