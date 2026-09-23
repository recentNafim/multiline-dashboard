import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import 'dashboard_page.dart';

class CheckoutPage extends GetView<CartController> {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: Obx(
        () => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D0F172A),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.shopping_bag_outlined),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Total Items',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${controller.totalItems}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No checkout/order API is connected yet. '
                      'Confirming will complete the checkout locally and clear the cart.',
                    ),
                  ),
                ],
              ),
            ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Obx(
        () => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: controller.items.isEmpty
                    ? null
                    : () => _confirmCheckout(),
                child: const Text(
                  'Confirm Checkout',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmCheckout() {
    Get.dialog(
      AlertDialog(
        icon: const Icon(
          Icons.check_circle_outline,
          size: 54,
        ),
        title: const Text('Checkout complete'),
        content: const Text(
          'The demo checkout is complete. No server order was created.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () {
              controller.clearCart();

              Get.offAll(
                () => const DashboardPage(),
              );
            },
            child: const Text('Back to Dashboard'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
