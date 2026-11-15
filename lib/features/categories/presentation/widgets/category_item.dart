import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/category.dart';

class CategoryItem extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryItem({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = category.imageUrl ?? category.iconUrl;

    return Padding(
      padding: const EdgeInsets.only(right: AppDimensions.sm + 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: SizedBox(
          width: 78,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.14)
                      : theme.cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : theme.dividerColor.withValues(alpha: 0.14),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isSelected ? AppColors.primary : Colors.black)
                          .withValues(alpha: isSelected ? 0.18 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: AppNetworkImage(
                  imageUrl: image,
                  borderRadius: BorderRadius.circular(15),
                  fallbackIcon: _getFallbackIcon(category.name),
                  fallbackIconSize: 26,
                  fallbackIconColor:
                      isSelected ? AppColors.primary : AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                category.name,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.85),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFallbackIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('electronic') || lower.contains('tech')) {
      return Icons.devices_rounded;
    }
    if (lower.contains('phone') || lower.contains('tablet')) {
      return Icons.smartphone_rounded;
    }
    if (lower.contains('audio') || lower.contains('headphone')) {
      return Icons.headphones_rounded;
    }
    if (lower.contains('laptop') || lower.contains('comput')) {
      return Icons.laptop_mac_rounded;
    }
    if (lower.contains('watch') || lower.contains('wearable')) {
      return Icons.watch_rounded;
    }
    if (lower.contains('gaming') || lower.contains('game')) {
      return Icons.sports_esports_rounded;
    }
    if (lower.contains('camera') || lower.contains('drone')) {
      return Icons.camera_alt_rounded;
    }
    if (lower.contains('home') || lower.contains('living')) {
      return Icons.chair_outlined;
    }
    if (lower.contains('cloth') ||
        lower.contains('apparel') ||
        lower.contains('fashion')) {
      return Icons.checkroom_rounded;
    }
    if (lower.contains('shoe') || lower.contains('footwear')) {
      return Icons.directions_run_rounded;
    }
    return Icons.category_outlined;
  }
}
