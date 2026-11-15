import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../network/resilient_network_image.dart';
import '../services/cloudflare_r2_service.dart';
import '../theme/app_colors.dart';

/// Reusable image widget that automatically resolves Cloudflare R2 URLs,
/// handles local assets, shows a subtle loading state, and renders a clean
/// theme-aware fallback icon on missing or failed images.
class AppNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final IconData fallbackIcon;
  final double fallbackIconSize;
  final Color? fallbackIconColor;
  final Color? backgroundColor;
  final Map<String, String>? headers;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.fallbackIcon = Icons.image_outlined,
    this.fallbackIconSize = 36,
    this.fallbackIconColor,
    this.backgroundColor,
    this.headers,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedUrl = CloudflareR2Service.resolveImageUrl(imageUrl);
    final bgColor =
        backgroundColor ?? theme.colorScheme.primary.withValues(alpha: 0.06);
    final iconColor =
        fallbackIconColor ??
        theme.colorScheme.onSurface.withValues(alpha: 0.35);

    Widget buildFallback() {
      return errorWidget ??
          Container(
            width: width,
            height: height,
            color: bgColor,
            alignment: Alignment.center,
            child: Icon(
              fallbackIcon,
              size: fallbackIconSize,
              color: iconColor,
            ),
          );
    }

    Widget content;
    if (resolvedUrl == null || resolvedUrl.isEmpty) {
      content = buildFallback();
    } else if (resolvedUrl.startsWith('assets/')) {
      content = Image.asset(
        resolvedUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => buildFallback(),
      );
    } else {
      final ImageProvider provider = kIsWeb
          ? NetworkImage(resolvedUrl, headers: headers)
          : ResilientNetworkImage(resolvedUrl, headers: headers);
      content = Image(
        image: provider,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ??
              Container(
                width: width,
                height: height,
                color: bgColor,
                alignment: Alignment.center,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
              );
        },
        errorBuilder: (_, _, _) => buildFallback(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: content,
      );
    }
    return content;
  }
}
