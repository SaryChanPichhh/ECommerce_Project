import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/helpers.dart';
import '../../domain/entities/customer.dart';
import '../../domain/usecases/create_customer.dart';
import '../../domain/usecases/update_customer.dart';
import '../../domain/usecases/get_customer.dart';

class CustomerFormController extends GetxController {
  final CreateCustomerUseCase _createCustomerUseCase;
  final UpdateCustomerUseCase _updateCustomerUseCase;
  final GetCustomerUseCase _getCustomerUseCase;

  CustomerFormController({required CreateCustomerUseCase createCustomerUseCase, required UpdateCustomerUseCase updateCustomerUseCase, required GetCustomerUseCase getCustomerUseCase})
      : _createCustomerUseCase = createCustomerUseCase, _updateCustomerUseCase = updateCustomerUseCase, _getCustomerUseCase = getCustomerUseCase;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final companyController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<Customer> customer = Rxn<Customer>();

  bool get isEditing => customer.value != null;

  @override
  void onInit() { super.onInit(); final args = Get.arguments; if (args is String) loadCustomer(args); }

  Future<void> loadCustomer(String id) async {
    isLoading.value = true;
    try {
      final result = await _getCustomerUseCase(id);
      customer.value = result;
      nameController.text = result.name;
      emailController.text = result.email ?? '';
      phoneController.text = result.phone ?? '';
      addressController.text = result.address ?? '';
      companyController.text = result.company ?? '';
    } on Failure catch (e) { errorMessage.value = e.message; }
    catch (e) { errorMessage.value = 'Failed to load customer'; }
    finally { isLoading.value = false; }
  }

  Future<void> saveCustomer() async {
    if (!formKey.currentState!.validate()) return;
    isSaving.value = true; errorMessage.value = '';
    try {
      final data = Customer(id: customer.value?.id ?? '', name: nameController.text.trim(),
        email: emailController.text.trim().isNotEmpty ? emailController.text.trim() : null,
        phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
        address: addressController.text.trim().isNotEmpty ? addressController.text.trim() : null,
        company: companyController.text.trim().isNotEmpty ? companyController.text.trim() : null);
      if (isEditing) { await _updateCustomerUseCase(data); Helpers.showSuccess('Customer updated'); }
      else { await _createCustomerUseCase(data); Helpers.showSuccess('Customer created'); }
      Get.back(result: true);
    } on Failure catch (e) { errorMessage.value = e.message; Helpers.showError(e.message); }
    catch (e) { Helpers.showError('Failed to save customer'); }
    finally { isSaving.value = false; }
  }

  @override
  void onClose() { nameController.dispose(); emailController.dispose(); phoneController.dispose(); addressController.dispose(); companyController.dispose(); super.onClose(); }
}
