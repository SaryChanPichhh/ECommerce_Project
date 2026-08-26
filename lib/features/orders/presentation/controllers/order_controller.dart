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
    isLoading.value = true;
    errorMessage.value = '';
    try {
      // Create a mocked list of two items as requested
      final dummyOrders = [
        Order(
          id: 'ORD-001',
          totalAmount: 120.0,
          status: 'processing',
          items: [
            OrderItem(
              id: 'ITEM-1',
              productId: 'PROD-1',
              productName: 'Wireless Headphones',
              quantity: 1,
              unitPrice: 120.0,
              totalPrice: 120.0,
            ),
          ],
        ),
        Order(
          id: 'ORD-002',
          totalAmount: 85.0,
          status: 'processing',
          items: [
            OrderItem(
              id: 'ITEM-2',
              productId: 'PROD-3',
              productName: 'Bluetooth Speaker',
              quantity: 1,
              unitPrice: 85.0,
              totalPrice: 85.0,
            ),
          ],
        ),
        Order(
          id: 'ORD-003',
          totalAmount: 250.0,
          status: 'completed',
          items: [
            OrderItem(
              id: 'ITEM-3',
              productId: 'PROD-2',
              productName: 'Smart Watch',
              quantity: 1,
              unitPrice: 250.0,
              totalPrice: 250.0,
            ),
          ],
        ),
        Order(
          id: 'ORD-004',
          totalAmount: 45.0,
          status: 'completed',
          items: [
            OrderItem(
              id: 'ITEM-4',
              productId: 'PROD-4',
              productName: 'Phone Case',
              quantity: 2,
              unitPrice: 22.5,
              totalPrice: 45.0,
            ),
          ],
        ),
      ];
      
      orders.assignAll(dummyOrders);
    } catch (e) { 
      errorMessage.value = 'An unexpected error occurred'; 
    } finally { 
      isLoading.value = false; 
    }
  }

  void onStatusFilterChanged(String status) { selectedStatus.value = status; fetchOrders(); }
  Future<void> refreshOrders() => fetchOrders();
}
