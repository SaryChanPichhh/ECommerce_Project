import 'package:get/get.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/get_orders.dart';

class OrderController extends GetxController {
  final GetOrdersUseCase _getOrdersUseCase;
  OrderController({required GetOrdersUseCase getOrdersUseCase}) : _getOrdersUseCase = getOrdersUseCase;

  final RxList<Order> orders = <Order>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedStatus = ''.obs;

  @override
  void onInit() { super.onInit(); fetchOrders(); }

  Future<void> fetchOrders() async {
    isLoading.value = true; errorMessage.value = '';
    try {
      final result = await _getOrdersUseCase(status: selectedStatus.value.isNotEmpty ? selectedStatus.value : null);
      orders.assignAll(result);
    } on Failure catch (e) { errorMessage.value = e.message; }
    catch (e) { errorMessage.value = 'An unexpected error occurred'; }
    finally { isLoading.value = false; }
  }

  void onStatusFilterChanged(String status) { selectedStatus.value = status; fetchOrders(); }
  Future<void> refreshOrders() => fetchOrders();
}
