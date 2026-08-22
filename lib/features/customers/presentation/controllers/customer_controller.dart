import 'package:get/get.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../domain/entities/customer.dart';
import '../../domain/usecases/get_customers.dart';
import '../../domain/usecases/delete_customer.dart';

class CustomerController extends GetxController {
  final GetCustomersUseCase _getCustomersUseCase;
  final DeleteCustomerUseCase _deleteCustomerUseCase;

  CustomerController({required GetCustomersUseCase getCustomersUseCase, required DeleteCustomerUseCase deleteCustomerUseCase})
      : _getCustomersUseCase = getCustomersUseCase, _deleteCustomerUseCase = deleteCustomerUseCase;

  final RxList<Customer> customers = <Customer>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() { super.onInit(); fetchCustomers(); }

  Future<void> fetchCustomers() async {
    isLoading.value = true; errorMessage.value = '';
    try {
      final result = await _getCustomersUseCase(search: searchQuery.value.isNotEmpty ? searchQuery.value : null);
      customers.assignAll(result);
    } on Failure catch (e) { errorMessage.value = e.message; }
    catch (e) { errorMessage.value = 'An unexpected error occurred'; }
    finally { isLoading.value = false; }
  }

  Future<void> deleteCustomer(String id) async {
    final confirmed = await AppDialog.showConfirm(title: 'Delete Customer', message: 'Are you sure?', confirmText: 'Delete', isDanger: true);
    if (!confirmed) return;
    try { await _deleteCustomerUseCase(id); customers.removeWhere((c) => c.id == id); Helpers.showSuccess('Customer deleted'); }
    on Failure catch (e) { Helpers.showError(e.message); }
    catch (e) { Helpers.showError('Failed to delete customer'); }
  }

  void onSearchChanged(String query) { searchQuery.value = query; fetchCustomers(); }
  Future<void> refreshCustomers() => fetchCustomers();
}
