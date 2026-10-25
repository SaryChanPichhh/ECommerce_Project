import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/category.dart';
import '../bindings/categories_binding.dart';
import '../controllers/categories_controller.dart';
import 'category_item.dart';

class CategoryList extends StatelessWidget {
  final void Function(Category category)? onCategorySelected;

  const CategoryList({
    super.key,
    this.onCategorySelected,
  });

  CategoriesController _getController() {
    if (!Get.isRegistered<CategoriesController>()) {
      CategoriesBinding().dependencies();
    }
    return Get.find<CategoriesController>();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _getController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppDimensions.md),
        SizedBox(
          height: 85,
          child: Obx(() {
            if (controller.isLoading.value && controller.categories.isEmpty) {
              return const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }

            if (controller.errorMessage.value.isNotEmpty &&
                controller.categories.isEmpty) {
              return Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Failed to load categories',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 18),
                      onPressed: () => controller.fetchCategories(),
                    ),
                  ],
                ),
              );
            }

            if (controller.categories.isEmpty) {
              return const Center(
                child: Text('No categories available'),
              );
            }

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.categories.length,
              itemBuilder: (context, index) {
                final category = controller.categories[index];
                return Obx(() {
                  final isSelected =
                      controller.selectedCategoryId.value == category.id;
                  return CategoryItem(
                    category: category,
                    isSelected: isSelected,
                    onTap: () {
                      controller.selectCategory(category.id);
                      if (onCategorySelected != null) {
                        onCategorySelected!(category);
                      } else {
                        Get.toNamed(
                          '/category-detail',
                          arguments: category.name,
                        );
                      }
                    },
                  );
                });
              },
            );
          }),
        ),
      ],
    );
  }
}
