import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../categories/domain/entities/category.dart';
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
          // Image picker card
          _buildImagePicker(context),
          const SizedBox(height: AppDimensions.lg),

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

          _buildCategorySelector(context),
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

  Widget _buildImagePicker(BuildContext context) {
    return Obx(() {
      final imgUrl = controller.imageUrl.value;
      final isUploading = controller.isUploadingImage.value;
      final isDark = Get.isDarkMode;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Image',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          InkWell(
            onTap: isUploading ? null : () => _showImageSourcePicker(context),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1.5,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (controller.localImageBytes.value != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      child: Image.memory(
                        controller.localImageBytes.value!,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.edit, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'Change',
                              style: AppTextStyles.caption.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (imgUrl.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      child: AppNetworkImage(
                        imageUrl: imgUrl,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        errorWidget: _buildPlaceholder(isDark),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.edit, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'Change',
                              style: AppTextStyles.caption.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    _buildPlaceholder(isDark),
                  ],

                  if (isUploading)
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                            SizedBox(height: 12),
                            Text(
                              'Uploading to Cloudflare R2...',
                              style: TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCategorySelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final categories = controller.availableCategories;
      final selected = controller.selectedCategory.value;
      final isLoading = controller.isLoadingCategories.value;

      Category? currentValue;
      if (selected != null && categories.contains(selected)) {
        currentValue = selected;
      } else if (categories.isNotEmpty && controller.categoryController.text.isNotEmpty) {
        for (final c in categories) {
          if (c.name.toLowerCase() == controller.categoryController.text.toLowerCase() ||
              c.id == controller.categoryController.text) {
            currentValue = c;
            break;
          }
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Category',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.xs),
          DropdownButtonFormField<Category>(
            initialValue: currentValue,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: isLoading ? 'Loading categories...' : 'Select a category',
              prefixIcon: const Icon(Icons.category_outlined, size: 20),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.md,
                vertical: AppDimensions.sm,
              ),
            ),
            dropdownColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            items: categories.map((Category cat) {
              return DropdownMenuItem<Category>(
                value: cat,
                child: Text(
                  cat.name,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
            onChanged: (Category? newCat) {
              if (newCat != null) {
                controller.onCategorySelected(newCat);
              }
            },
            validator: (v) {
              if (v == null && controller.categoryController.text.isEmpty) {
                return 'Please select a category';
              }
              return null;
            },
          ),
        ],
      );
    });
  }

  Widget _buildPlaceholder(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_upload_outlined,
          size: 44,
          color: AppColors.primary.withValues(alpha: 0.8),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose Product Image',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Upload via Cloudflare R2',
          style: AppTextStyles.caption.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  void _showImageSourcePicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppDimensions.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusLg),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Choose Image Source', style: AppTextStyles.h4),
              const SizedBox(height: AppDimensions.lg),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.camera_alt, color: Colors.white),
                ),
                title: Text('Camera', style: AppTextStyles.bodyLarge),
                onTap: () {
                  Get.back();
                  controller.pickAndUploadImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.secondary,
                  child: Icon(Icons.photo_library, color: Colors.white),
                ),
                title: Text('Gallery', style: AppTextStyles.bodyLarge),
                onTap: () {
                  Get.back();
                  controller.pickAndUploadImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
