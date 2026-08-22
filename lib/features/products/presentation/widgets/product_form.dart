import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/product_form_controller.dart';

class ProductForm extends GetView<ProductFormController> {
  const ProductForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.md),
        children: [
          AppTextField(
            controller: controller.nameController,
            label: 'Product Name',
            hint: 'Enter product name',
            validator: (v) => Validators.required(v, 'Product name'),
          ),
          const SizedBox(height: AppDimensions.md),

          AppTextField(
            controller: controller.descriptionController,
            label: 'Description',
            hint: 'Enter product description',
            maxLines: 3,
          ),
          const SizedBox(height: AppDimensions.md),

          AppTextField(
            controller: controller.priceController,
            label: 'Price',
            hint: 'Enter price',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) => Validators.number(v, 'Price'),
          ),
          const SizedBox(height: AppDimensions.md),

          AppTextField(
            controller: controller.quantityController,
            label: 'Quantity',
            hint: 'Enter quantity',
            keyboardType: TextInputType.number,
            validator: (v) => Validators.number(v, 'Quantity'),
          ),
          const SizedBox(height: AppDimensions.md),

          AppTextField(
            controller: controller.categoryController,
            label: 'Category',
            hint: 'Enter category',
          ),
          const SizedBox(height: AppDimensions.xl),

          Obx(
            () => AppButton(
              text: controller.isEditing ? 'Update Product' : 'Create Product',
              onPressed: controller.saveProduct,
              isLoading: controller.isSaving.value,
            ),
          ),
        ],
      ),
    );
  }
}
