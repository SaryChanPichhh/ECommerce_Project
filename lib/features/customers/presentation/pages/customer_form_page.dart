import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/customer_form_controller.dart';

class CustomerFormPage extends GetView<CustomerFormController> {
  const CustomerFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Obx(() => Text(controller.isEditing ? 'Edit Customer' : 'New Customer'))),
      body: Obx(() {
        if (controller.isLoading.value) return const AppLoading();
        return Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppDimensions.md),
            children: [
              AppTextField(controller: controller.nameController, label: 'Name', hint: 'Enter name', validator: (v) => Validators.required(v, 'Name')),
              const SizedBox(height: AppDimensions.md),
              AppTextField(controller: controller.emailController, label: 'Email', hint: 'Enter email', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: AppDimensions.md),
              AppTextField(controller: controller.phoneController, label: 'Phone', hint: 'Enter phone', keyboardType: TextInputType.phone),
              const SizedBox(height: AppDimensions.md),
              AppTextField(controller: controller.addressController, label: 'Address', hint: 'Enter address', maxLines: 2),
              const SizedBox(height: AppDimensions.md),
              AppTextField(controller: controller.companyController, label: 'Company', hint: 'Enter company'),
              const SizedBox(height: AppDimensions.xl),
              Obx(() => AppButton(text: controller.isEditing ? 'Update Customer' : 'Create Customer', onPressed: controller.saveCustomer, isLoading: controller.isSaving.value)),
            ],
          ),
        );
      }),
    );
  }
}
