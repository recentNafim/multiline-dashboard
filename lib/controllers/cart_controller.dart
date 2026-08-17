import 'package:get/get.dart';

import '../models/cart_item.dart';
import '../models/product_model.dart';

class CartController extends GetxController {
  final items = <String, CartItem>{}.obs;

  int get totalItems =>
      items.values.fold(0, (sum, item) => sum + item.quantity);

  bool contains(ProductModel product) => items.containsKey(product.cartKey);

  int quantityOf(ProductModel product) =>
      items[product.cartKey]?.quantity ?? 0;

  void addToCart(ProductModel product) {
    final key = product.cartKey;

    if (items.containsKey(key)) {
      items[key]!.quantity++;
      items.refresh();
    } else {
      items[key] = CartItem(product: product);
    }

    Get.snackbar(
      'Added to cart',
      product.description.isEmpty ? product.itemCode : product.description,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  void increment(String key) {
    final item = items[key];
    if (item == null) return;

    item.quantity++;
    items.refresh();
  }

  void decrement(String key) {
    final item = items[key];
    if (item == null) return;

    if (item.quantity <= 1) {
      items.remove(key);
    } else {
      item.quantity--;
      items.refresh();
    }
  }

  void remove(String key) {
    items.remove(key);
  }

  void clearCart() {
    items.clear();
  }
}
