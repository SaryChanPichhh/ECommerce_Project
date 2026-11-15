import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  static const List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Flash Deals Live Now',
      'body': 'Save up to 20% on MacBook Pro M4 & UltraPhone 15 Pro Max.',
      'time': '1h ago',
      'icon': Icons.local_fire_department_rounded,
      'color': AppColors.error,
      'unread': true,
    },
    {
      'title': 'Order Shipped',
      'body': 'Your tech order is on the way to Phnom Penh hub.',
      'time': '3h ago',
      'icon': Icons.local_shipping_outlined,
      'color': AppColors.info,
      'unread': true,
    },
    {
      'title': 'New Collection Dropped',
      'body': 'Explore Urban Streetwear & Apex Nitro running sneakers.',
      'time': '1d ago',
      'icon': Icons.checkroom_outlined,
      'color': AppColors.secondary,
      'unread': false,
    },
    {
      'title': 'Verified Account',
      'body': 'Your security settings and delivery address are up to date.',
      'time': '2d ago',
      'icon': Icons.verified_user_outlined,
      'color': AppColors.success,
      'unread': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor = theme.colorScheme.onSurface.withValues(alpha: 0.62);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text('notification'.tr),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.md),
        itemCount: _notifications.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.sm + 2),
        itemBuilder: (context, index) {
          final item = _notifications[index];
          final iconColor = item['color'] as Color;
          final isUnread = item['unread'] as bool;

          return Container(
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(
                color: isUnread
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.45),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['title'] as String,
                              style: AppTextStyles.labelLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item['time'] as String,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: secondaryColor,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['body'] as String,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: secondaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isUnread) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
