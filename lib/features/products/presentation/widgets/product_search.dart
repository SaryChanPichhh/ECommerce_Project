import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';

class ProductSearch extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String? hintText;

  const ProductSearch({
    super.key,
    required this.onChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText ?? 'Search products...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
      ),
    );
  }
}
