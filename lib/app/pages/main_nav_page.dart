import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../../core/theme/app_colors.dart';
import '../../features/favorite/presentation/pages/favorite_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/orders/presentation/pages/order_list_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/search/presentation/pages/search_page.dart';

/// Main navigation screen with persistent bottom navigation bar.
/// Contains 5 tabs: Home, Order, Search, Favorite, Profile.
class MainNavPage extends StatelessWidget {
  const MainNavPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inactiveColor = theme.colorScheme.onSurface.withValues(alpha: 0.55);
    final isDark = theme.brightness == Brightness.dark;

    return PersistentTabView(
      tabs: [
        PersistentTabConfig(
          screen: const HomePage(),
          item: ItemConfig(
            icon: const Icon(Icons.home_rounded),
            inactiveIcon: const Icon(Icons.home_outlined),
            title: 'home'.tr,
            activeForegroundColor: AppColors.primary,
            inactiveForegroundColor: inactiveColor,
          ),
        ),
        PersistentTabConfig(
          screen: const OrderListPage(),
          item: ItemConfig(
            icon: const Icon(Icons.shopping_bag_rounded),
            inactiveIcon: const Icon(Icons.shopping_bag_outlined),
            title: 'order'.tr,
            activeForegroundColor: AppColors.primary,
            inactiveForegroundColor: inactiveColor,
          ),
        ),
        PersistentTabConfig(
          screen: const SearchPage(),
          item: ItemConfig(
            icon: const Icon(Icons.search_rounded),
            inactiveIcon: const Icon(Icons.search_outlined),
            title: 'search'.tr,
            activeForegroundColor: AppColors.primary,
            inactiveForegroundColor: inactiveColor,
          ),
        ),
        PersistentTabConfig(
          screen: const FavoritePage(),
          item: ItemConfig(
            icon: const Icon(Icons.favorite_rounded),
            inactiveIcon: const Icon(Icons.favorite_border_rounded),
            title: 'favorite'.tr,
            activeForegroundColor: AppColors.primary,
            inactiveForegroundColor: inactiveColor,
          ),
        ),
        PersistentTabConfig(
          screen: const ProfilePage(),
          item: ItemConfig(
            icon: const Icon(Icons.settings_rounded),
            inactiveIcon: const Icon(Icons.settings_outlined),
            title: 'setting'.tr,
            activeForegroundColor: AppColors.primary,
            inactiveForegroundColor: inactiveColor,
          ),
        ),
      ],
      navBarBuilder: (navBarConfig) => Style1BottomNavBar(
        navBarConfig: navBarConfig,
        navBarDecoration: NavBarDecoration(
          color: theme.cardColor,
          border: Border(
            top: BorderSide(
              color: theme.dividerColor.withValues(alpha: isDark ? 0.15 : 0.08),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.07),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      screenTransitionAnimation: const ScreenTransitionAnimation(
        curve: Curves.easeOutCubic,
        duration: Duration(milliseconds: 220),
      ),
    );
  }
}
