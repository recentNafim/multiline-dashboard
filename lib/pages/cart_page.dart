import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import '../models/cart_item.dart';
import '../widgets/product_image.dart';
import 'checkout_page.dart';

class CartPage extends GetView<CartController> {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Obx(() {
        if (controller.items.isEmpty) {
          return const _EmptyCart();
        }

        final entries = controller.items.entries.toList();

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, index) {
            final entry = entries[index];

            return _CartItemCard(
              cartKey: entry.key,
              item: entry.value,
            );
          },
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.items.isEmpty) {
          return const SizedBox.shrink();
        }

        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFEEF0F4)),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () => Get.to(
                  () => const CheckoutPage(),
                ),
                child: Text(
                  'Proceed to Checkout (${controller.totalItems} items)',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final String cartKey;
  final CartItem item;

  const _CartItemCard({
    required this.cartKey,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    final product = item.product;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductImage(
            product: product,
            height: 100,
            width: 100,
            borderRadius: 14,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.description.isEmpty
                      ? product.itemCode
                      : product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.itemCode,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7A8190),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _QtyButton(
                      icon: Icons.remove,
                      onTap: () => cart.decrement(cartKey),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _QtyButton(
                      icon: Icons.add,
                      onTap: () => cart.increment(cartKey),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Remove',
                      onPressed: () => cart.remove(cartKey),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F7),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 72,
            color: Color(0xFF9AA2B1),
          ),
          SizedBox(height: 14),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
