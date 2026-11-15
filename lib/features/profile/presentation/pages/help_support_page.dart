import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor = theme.colorScheme.onSurface.withValues(alpha: 0.65);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text('help_and_support'.tr),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.md),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(AppDimensions.lg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Text(
                    'how_can_we_help'.tr,
                    style: AppTextStyles.h3.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.lg),

          // FAQ Cards
          _buildFaqCard(
            theme: theme,
            isDark: isDark,
            secondaryColor: secondaryColor,
            question: 'faq_1'.tr,
            answer: 'faq_1_answer'.tr,
          ),
          const SizedBox(height: AppDimensions.sm + 4),
          _buildFaqCard(
            theme: theme,
            isDark: isDark,
            secondaryColor: secondaryColor,
            question: 'faq_2'.tr,
            answer: 'faq_2_answer'.tr,
          ),
          const SizedBox(height: AppDimensions.xl),

          // Contact Us Card
          Text('contact_us'.tr, style: AppTextStyles.h4),
          const SizedBox(height: AppDimensions.sm),
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(
                color:
                    theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.45),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                    child: const Icon(
                      Icons.email_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: const Text('support@example.com'),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                    child: const Icon(
                      Icons.phone_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: const Text('+855 12 345 678'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqCard({
    required ThemeData theme,
    required bool isDark,
    required Color secondaryColor,
    required String question,
    required String answer,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.45),
        ),
      ),
      child: ExpansionTile(
        shape: const Border(),
        title: Text(
          question,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppDimensions.md,
          0,
          AppDimensions.md,
          AppDimensions.md,
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: AppTextStyles.bodyMedium.copyWith(color: secondaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
