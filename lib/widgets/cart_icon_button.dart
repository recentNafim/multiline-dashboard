import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import '../pages/cart_page.dart';

class CartIconButton extends StatelessWidget {
  const CartIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();

    return Obx(
      () => Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            onPressed: () => Get.to(() => const CartPage()),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
          if (cart.totalItems > 0)
            Positioned(
              right: 3,
              top: 3,
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  cart.totalItems > 99 ? '99+' : '${cart.totalItems}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
