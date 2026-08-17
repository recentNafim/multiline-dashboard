import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/product_controller.dart';
import '../widgets/cart_icon_button.dart';
import '../widgets/product_card.dart';

class DashboardPage extends GetView<ProductController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Display Room',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            Text(
              'Available products',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF7A8190),
              ),
            ),
          ],
        ),
        actions: const [
          CartIconButton(),
          SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.products.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.products.isEmpty) {
          return _ErrorView(
            message: controller.errorMessage.value,
            onRetry: controller.fetchProducts,
          );
        }

        if (controller.products.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.fetchProducts,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 220),
                Icon(
                  Icons.inventory_2_outlined,
                  size: 70,
                  color: Color(0xFF9AA2B1),
                ),
                SizedBox(height: 12),
                Center(
                  child: Text('No products found'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchProducts,
          child: LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 2;

              if (constraints.maxWidth >= 1200) {
                crossAxisCount = 5;
              } else if (constraints.maxWidth >= 900) {
                crossAxisCount = 4;
              } else if (constraints.maxWidth >= 650) {
                crossAxisCount = 3;
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.72,
                ),
                itemCount: controller.products.length,
                itemBuilder: (_, index) {
                  return ProductCard(
                    product: controller.products[index],
                  );
                },
              );
            },
          ),
        );
      }),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 64,
              color: Color(0xFF9AA2B1),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
