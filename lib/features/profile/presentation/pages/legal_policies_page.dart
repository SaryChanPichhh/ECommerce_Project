import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

class LegalPoliciesPage extends StatelessWidget {
  const LegalPoliciesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor = theme.colorScheme.onSurface.withValues(alpha: 0.72);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text('legal_and_policies'.tr),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.md),
        children: [
          _buildPolicyCard(
            context,
            theme: theme,
            isDark: isDark,
            secondaryColor: secondaryColor,
            number: '01',
            title: 'terms_and_conditions'.tr,
            content:
                'By using this application, you agree to our terms and conditions. '
                'We reserve the right to update these terms at any time.',
          ),
          const SizedBox(height: AppDimensions.md),
          _buildPolicyCard(
            context,
            theme: theme,
            isDark: isDark,
            secondaryColor: secondaryColor,
            number: '02',
            title: 'privacy_policy'.tr,
            content:
                'We value your privacy. Your data is stored securely and will not be shared '
                'with third parties without your explicit consent.',
          ),
          const SizedBox(height: AppDimensions.md),
          _buildPolicyCard(
            context,
            theme: theme,
            isDark: isDark,
            secondaryColor: secondaryColor,
            number: '03',
            title: 'data_usage'.tr,
            content:
                'We collect minimal data required to provide you with the best shopping experience, '
                'order tracking, and delivery fulfillment.',
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyCard(
    BuildContext context, {
    required ThemeData theme,
    required bool isDark,
    required Color secondaryColor,
    required String number,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  number,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.h4,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: secondaryColor,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
