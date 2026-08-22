import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/app_loading.dart';
import '../controllers/product_form_controller.dart';
import '../widgets/product_form.dart';

class ProductFormPage extends GetView<ProductFormController> {
  const ProductFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.isEditing ? 'Edit Product' : 'New Product',
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoading(message: 'Loading product...');
        }
        return const ProductForm();
      }),
    );
  }
}
