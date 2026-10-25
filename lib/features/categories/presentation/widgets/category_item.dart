import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
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
    final image = category.imageUrl ?? category.iconUrl;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        width: 76,
        margin: const EdgeInsets.only(right: AppDimensions.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              padding: const EdgeInsets.all(AppDimensions.xs),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              child: ClipOval(
                child: image != null && image.isNotEmpty && image.startsWith('http')
                    ? Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          _getFallbackIcon(category.name),
                          color: isSelected ? Colors.white : AppColors.primary,
                          size: 24,
                        ),
                      )
                    : Icon(
                        _getFallbackIcon(category.name),
                        color: isSelected ? Colors.white : AppColors.primary,
                        size: 24,
                      ),
              ),
            ),
            const SizedBox(height: AppDimensions.xs),
            Text(
              category.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primary : null,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFallbackIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('electronic')) return Icons.devices;
    if (lower.contains('cloth') || lower.contains('apparel') || lower.contains('fashion')) {
      return Icons.checkroom;
    }
    if (lower.contains('shoe')) return Icons.do_not_step;
    if (lower.contains('device')) return Icons.smartphone;
    if (lower.contains('accessor')) return Icons.watch;
    if (lower.contains('sport')) return Icons.sports_basketball;
    return Icons.category_outlined;
  }
}
