import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
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
    final theme = Theme.of(context);
    final controller = _getController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'categories'.tr,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.products),
              child: Text('see_all'.tr),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sm),
        SizedBox(
          height: 96,
          child: Obx(() {
            if (controller.isLoading.value && controller.categories.isEmpty) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) => Container(
                  width: 72,
                  margin: const EdgeInsets.only(right: AppDimensions.sm + 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 48,
                        height: 10,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
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
                      controller.errorMessage.value,
                      style: theme.textTheme.bodySmall?.copyWith(
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
              return Center(
                child: Text(
                  'no_products_found'.tr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
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
                          AppRoutes.categoryDetail,
                          arguments: {
                            'id': category.id,
                            'name': category.name,
                            'imageUrl': category.imageUrl ?? category.iconUrl,
                          },
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
