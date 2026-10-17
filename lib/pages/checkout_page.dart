import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import 'dashboard_page.dart';

class CheckoutPage extends GetView<CartController> {
  const CheckoutPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: Obx(() => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Icon(Icons.check_circle_outline, color: Color(0xFF16A34A), size: 72),
                const SizedBox(height: 18),
                Text('Product selection ready', textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 14),
                Text('Items selected: ${controller.totalItems}',
                  textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ...controller.items.values.map((line) => ListTile(
                  title: Text(line.product.description.isNotEmpty
                      ? line.product.description : line.product.itemCode),
                  subtitle: Text('Code: ${line.product.itemCode}  •  Size: ${line.product.sizeRange}'),
                  trailing: Text('Qty: ${line.quantity}'),
                )),
                const SizedBox(height: 20),
                FilledButton.icon(onPressed: () {
                  controller.clearCart();
                  Get.offAll(() => const DashboardPage());
                }, icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Return to products')),
              ],
            ),
          ),
        )),
      );
}
