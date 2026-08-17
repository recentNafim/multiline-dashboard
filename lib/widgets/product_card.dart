

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import '../models/product_model.dart';
import '../pages/product_detail_page.dart';
import 'product_image.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();

    return InkWell(
      borderRadius: BorderRadius.circular(20),

      // =====================================================
      // PRODUCT DETAILS NAVIGATION
      // =====================================================
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return ProductDetailPage(
                product: product,
              );
            },
          ),
        );
      },

      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================================================
            // PRODUCT IMAGE
            // =================================================
            Expanded(
              child: ProductImage(
                product: product,
                width: double.infinity,
                borderRadius: 0,
              ),
            ),

            // =================================================
            // PRODUCT NAME
            // =================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                12,
                12,
                4,
              ),
              child: Text(
                product.description.isEmpty
                    ? product.itemCode
                    : product.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  height: 1.25,
                ),
              ),
            ),

            // =================================================
            // ITEM CODE
            // =================================================
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              child: Text(
                product.itemCode,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF7A8190),
                  fontSize: 12,
                ),
              ),
            ),

            // =================================================
            // AVAILABLE QTY + CART BUTTON
            // =================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                8,
                8,
                10,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Available: '
                          '${_prettyNumber(product.quantity)} '
                          '${product.uom}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF737B8C),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  IconButton.filledTonal(
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      cart.addToCart(product);
                    },
                    icon: const Icon(
                      Icons.add_shopping_cart,
                      size: 19,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _prettyNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }
}