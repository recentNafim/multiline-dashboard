


import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import '../models/product_model.dart';
import '../widgets/cart_icon_button.dart';
import '../widgets/product_image.dart';

class ProductDetailPage extends StatelessWidget {
  final ProductModel product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      appBar: AppBar(
        title: const Text(
          'Product Details',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: const [
          CartIconButton(),
          SizedBox(width: 10),
        ],
      ),

      // কোনো bottomNavigationBar নেই
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          // Desktop / Web
          if (width >= 900) {
            return _buildDesktopView(
              context,
              cartController,
            );
          }

          // Mobile / Tablet
          return _buildMobileView(
            context,
            cartController,
          );
        },
      ),
    );
  }

  // =========================================================
  // DESKTOP / WEB
  // =========================================================

  Widget _buildDesktopView(
      BuildContext context,
      CartController cartController,
      ) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ===================================================
          // LEFT IMAGE
          // ===================================================

          Expanded(
            flex: 5,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(30),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F7),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ProductImage(
                  product: product,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                  borderRadius: 24,
                ),
              ),
            ),
          ),

          // ===================================================
          // RIGHT DETAILS
          // ===================================================

          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: _buildDetails(
                context,
                cartController,
                isDesktop: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // MOBILE / TABLET
  // =========================================================

  Widget _buildMobileView(
      BuildContext context,
      CartController cartController,
      ) {
    final width = MediaQuery.sizeOf(context).width;

    double imageHeight = width * 0.72;

    if (imageHeight > 400) {
      imageHeight = 400;
    }

    if (imageHeight < 230) {
      imageHeight = 230;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          Container(
            width: double.infinity,
            height: imageHeight,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F7),
              borderRadius: BorderRadius.circular(22),
            ),
            child: ProductImage(
              product: product,
              width: double.infinity,
              height: imageHeight,
              fit: BoxFit.contain,
              borderRadius: 22,
            ),
          ),

          const SizedBox(height: 24),

          // DETAILS
          _buildDetails(
            context,
            cartController,
            isDesktop: false,
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // =========================================================
  // PRODUCT DETAILS
  // =========================================================

  Widget _buildDetails(
      BuildContext context,
      CartController cartController, {
        required bool isDesktop,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =====================================================
        // CATEGORY
        // =====================================================

        if (product.productCategory.trim().isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              product.productCategory,
              style: const TextStyle(
                color: Color(0xFF315DC8),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        const SizedBox(height: 14),

        // =====================================================
        // PRODUCT NAME
        // =====================================================

        Text(
          product.description.trim().isEmpty
              ? product.itemCode
              : product.description,
          style: TextStyle(
            fontSize: isDesktop ? 30 : 23,
            fontWeight: FontWeight.w800,
            height: 1.25,
            color: const Color(0xFF1B1D22),
          ),
        ),

        const SizedBox(height: 10),

        // =====================================================
        // ITEM CODE
        // =====================================================

        Row(
          children: [
            const Icon(
              Icons.qr_code_2_rounded,
              size: 19,
              color: Color(0xFF757D8C),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                'Item Code: ${product.itemCode}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757D8C),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // =====================================================
        // SMALL ADD TO CART BUTTON
        // =====================================================

        SizedBox(
          height: 42,
          child: FilledButton.icon(
            onPressed: () {
              cartController.addToCart(product);
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            icon: const Icon(
              Icons.shopping_bag_outlined,
              size: 18,
            ),
            label: const Text(
              'Add to Cart',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 30),

        // =====================================================
        // PRODUCT INFORMATION TITLE
        // =====================================================

        const Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Product Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // =====================================================
        // INFORMATION CARD
        // =====================================================

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE8EBF0),
            ),
          ),
          child: Column(
            children: [
              _InfoRow(
                label: 'Business',
                value: product.business,
                icon: Icons.business_outlined,
              ),

              _InfoRow(
                label: 'Sub Category',
                value: product.subCategory,
                icon: Icons.category_outlined,
              ),

              _InfoRow(
                label: 'Available Qty',
                value:
                '${_prettyNumber(product.quantity)} ${product.uom}',
                icon: Icons.inventory_2_outlined,
              ),

              _InfoRow(
                label: 'UOM',
                value: product.uom,
                icon: Icons.straighten_outlined,
              ),

              _InfoRow(
                label: 'Weight',
                value: product.weight > 0
                    ? '${_prettyNumber(product.weight)} kg'
                    : '',
                icon: Icons.monitor_weight_outlined,
              ),

              _InfoRow(
                label: 'CBM',
                value: product.cbm > 0
                    ? _prettyNumber(product.cbm)
                    : '',
                icon: Icons.view_in_ar_outlined,
              ),

              _InfoRow(
                label: 'Sub Inventory',
                value: product.subInventoryCode,
                icon: Icons.warehouse_outlined,
              ),

              _InfoRow(
                label: 'Locator ID',
                value: product.locatorId > 0
                    ? product.locatorId.toString()
                    : '',
                icon: Icons.location_on_outlined,
              ),

              _InfoRow(
                label: 'Display Room',
                value: product.displayRoomName,
                icon: Icons.meeting_room_outlined,
              ),

              _InfoRow(
                label: 'Material',
                value: product.materialSpecification,
                icon: Icons.description_outlined,
                showDivider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _prettyNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }
}

// ===========================================================
// INFO ROW
// ===========================================================

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool showDivider;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 14,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Very small width
              if (constraints.maxWidth < 380) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          icon,
                          size: 18,
                          color: const Color(0xFF747B88),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Color(0xFF747B88),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 26,
                      ),
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    size: 19,
                    color: const Color(0xFF747B88),
                  ),

                  const SizedBox(width: 9),

                  SizedBox(
                    width: 125,
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF747B88),
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Color(0xFF202329),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        if (showDivider)
          const Divider(
            height: 1,
            color: Color(0xFFEEF0F4),
          ),
      ],
    );
  }
}