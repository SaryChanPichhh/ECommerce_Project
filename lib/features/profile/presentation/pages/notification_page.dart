import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text('notification'.tr),
      ),
      body: ListView.builder(
        itemCount: 5, // Example count
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
            leading: const CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.notifications, color: Colors.white),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Notification Caption ', style: AppTextStyles.labelLarge),
                    Text('2 hours ago', style: AppTextStyles.caption),
                  ],
                ),
                const SizedBox(height: 4),
              ],
            ),
            subtitle: const Text('This is the description for the notification. It provides more details.', maxLines: 2, overflow: TextOverflow.ellipsis),
          );
        },
      ),
    );
  }
}
