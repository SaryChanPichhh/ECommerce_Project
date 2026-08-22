import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_product.dart';
import '../../../../core/errors/failures.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Product? product;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    final productId = Get.arguments as String?;
    if (productId == null) {
      setState(() {
        errorMessage = 'Product ID not provided';
        isLoading = false;
      });
      return;
    }

    try {
      final useCase = Get.find<GetProductUseCase>();
      final result = await useCase(productId);
      setState(() {
        product = result;
        isLoading = false;
      });
    } on Failure catch (e) {
      setState(() {
        errorMessage = e.message;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load product';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product?.name ?? 'Product Detail'),
        actions: [
          if (product != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Get.toNamed(
                  '/products/edit',
                  arguments: product!.id,
                );
                if (result == true) _loadProduct();
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const AppLoading(message: 'Loading product...');
    }

    if (errorMessage.isNotEmpty) {
      return AppError(
        message: errorMessage,
        onRetry: _loadProduct,
      );
    }

    if (product == null) {
      return const AppError(message: 'Product not found');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image placeholder
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppDimensions.lg),

          // Name
          Text(
            product!.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.sm),

          // Price
          Text(
            '\$${product!.price.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.md),

          // Category & Quantity
          Row(
            children: [
              if (product!.category != null) ...[
                Chip(
                  label: Text(product!.category!),
                  backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                ),
                const SizedBox(width: AppDimensions.sm),
              ],
              Chip(
                label: Text('Qty: ${product!.quantity}'),
                backgroundColor: product!.quantity > 0
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),

          // Description
          if (product!.description != null) ...[
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              product!.description!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ],
      ),
    );
  }
}
