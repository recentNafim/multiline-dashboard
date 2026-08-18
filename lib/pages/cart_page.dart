
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';

import '../controllers/cart_controller.dart';
import '../models/cart_item.dart';
import '../services/cart_pdf_service.dart';
import '../widgets/product_image.dart';

class CartPage extends GetView<CartController> {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ==============================================================
      // APP BAR
      // ==============================================================
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ==============================================================
      // BODY
      // ==============================================================
      body: Obx(() {
        if (controller.items.isEmpty) {
          return const _EmptyCart();
        }

        final entries = controller.items.entries.toList();

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            100,
          ),
          itemCount: entries.length,
          separatorBuilder: (_, __) =>
          const SizedBox(height: 12),
          itemBuilder: (_, index) {
            final entry = entries[index];

            return _CartItemCard(
              cartKey: entry.key,
              item: entry.value,
            );
          },
        );
      }),

      // ==============================================================
      // BOTTOM ACTIONS
      // ==============================================================
      bottomNavigationBar: Obx(() {
        if (controller.items.isEmpty) {
          return const SizedBox.shrink();
        }

        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              16,
              10,
              16,
              10,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Color(0xFFEEF0F4),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.end,
              children: [
                // ====================================================
                // PRESENTATION BUTTON
                // ====================================================
                SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: _makePresentation,
                    icon: const Icon(
                      Icons.slideshow_rounded,
                      size: 18,
                    ),
                    label: const Text(
                      'Presentation',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    style:
                    OutlinedButton.styleFrom(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // ====================================================
                // PDF BUTTON
                // ====================================================
                SizedBox(
                  height: 42,
                  child: FilledButton.icon(
                    onPressed: _makePdf,
                    icon: const Icon(
                      Icons
                          .picture_as_pdf_outlined,
                      size: 18,
                    ),
                    label: const Text(
                      'PDF',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 18,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ================================================================
  // MAKE PRESENTATION
  // ================================================================
  void _makePresentation() {
    if (controller.items.isEmpty) {
      Get.snackbar(
        'Cart Empty',
        'Please add at least one product.',
        snackPosition:
        SnackPosition.BOTTOM,
        margin:
        const EdgeInsets.all(16),
      );

      return;
    }

    Get.snackbar(
      'Presentation',
      'Presentation generation will be added here.',
      snackPosition:
      SnackPosition.BOTTOM,
      margin:
      const EdgeInsets.all(16),
    );
  }

  // ================================================================
  // MAKE PDF
  // ================================================================
  Future<void> _makePdf() async {
    if (controller.items.isEmpty) {
      Get.snackbar(
        'Cart Empty',
        'Please add at least one product.',
        snackPosition:
        SnackPosition.BOTTOM,
        margin:
        const EdgeInsets.all(16),
      );

      return;
    }

    // ==============================================================
    // SHOW LOADING DIALOG
    // ==============================================================
    Get.dialog(
      const PopScope(
        canPop: false,
        child: Center(
          child: Card(
            child: Padding(
              padding:
              EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 22,
              ),
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),

                  SizedBox(height: 16),

                  Text(
                    'Preparing PDF...',
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Please wait while your catalogue is being created.',
                    textAlign:
                    TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color:
                      Color(0xFF7A8190),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // ============================================================
      // GET CART ITEMS
      // ============================================================
      final List<CartItem> cartItems =
      controller.items.values.toList();

      // ============================================================
      // GENERATE PDF
      // ============================================================
      final pdfBytes =
      await CartPdfService.buildPdf(
        items: cartItems,

        // ----------------------------------------------------------
        // IMPORTANT
        // ----------------------------------------------------------
        // যদি product.fileUrl already full URL হয়:
        // imageBaseUrl: '',
        //
        // যদি fileUrl হয়:
        // DP_ROOM_521.png
        //
        // তাহলে তোমার actual image server URL এখানে দাও:
        //
        // imageBaseUrl:
        //     'https://example.com/images',
        //
        imageBaseUrl: '',
      );

      // ============================================================
      // CLOSE LOADING
      // ============================================================
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // ============================================================
      // FILE NAME
      // ============================================================
      final DateTime now =
      DateTime.now();

      final String year =
      now.year.toString();

      final String month =
      now.month
          .toString()
          .padLeft(2, '0');

      final String day =
      now.day
          .toString()
          .padLeft(2, '0');

      final String hour =
      now.hour
          .toString()
          .padLeft(2, '0');

      final String minute =
      now.minute
          .toString()
          .padLeft(2, '0');

      final String fileName =
          'Display_Room_Product_Catalogue_'
          '$year$month$day'
          '_$hour$minute.pdf';

      // ============================================================
      // SHARE PDF
      // ============================================================
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: fileName,
      );
    } catch (e) {
      // ============================================================
      // CLOSE LOADING
      // ============================================================
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // ============================================================
      // ERROR
      // ============================================================
      Get.snackbar(
        'PDF Failed',
        'Could not create PDF.\n$e',
        snackPosition:
        SnackPosition.BOTTOM,
        margin:
        const EdgeInsets.all(16),
        duration:
        const Duration(
          seconds: 5,
        ),
      );
    }
  }
}

// ==================================================================
// CART ITEM CARD
// ==================================================================
class _CartItemCard
    extends StatelessWidget {
  final String cartKey;
  final CartItem item;

  const _CartItemCard({
    required this.cartKey,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final CartController cart =
    Get.find<CartController>();

    final product = item.product;

    return Container(
      padding:
      const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color:
          const Color(0xFFF0F1F4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.025),
            blurRadius: 10,
            offset:
            const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          // ==========================================================
          // PRODUCT IMAGE
          // ==========================================================
          ProductImage(
            product: product,
            height: 100,
            width: 100,
            borderRadius: 14,
          ),

          const SizedBox(width: 12),

          // ==========================================================
          // PRODUCT DETAILS
          // ==========================================================
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                // ====================================================
                // PRODUCT NAME
                // ====================================================
                Text(
                  product.description.isEmpty
                      ? product.itemCode
                      : product.description,
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.w700,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 4),

                // ====================================================
                // ITEM CODE
                // ====================================================
                Text(
                  product.itemCode,
                  style:
                  const TextStyle(
                    fontSize: 12,
                    color:
                    Color(0xFF7A8190),
                  ),
                ),

                const SizedBox(height: 12),

                // ====================================================
                // QUANTITY + DELETE
                // ====================================================
                Row(
                  children: [
                    // ------------------------------------------------
                    // MINUS
                    // ------------------------------------------------
                    _QtyButton(
                      icon: Icons.remove,
                      onTap: () {
                        cart.decrement(
                          cartKey,
                        );
                      },
                    ),

                    // ------------------------------------------------
                    // QUANTITY
                    // ------------------------------------------------
                    Padding(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 12,
                      ),
                      child: Text(
                        '${item.quantity}',
                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    // ------------------------------------------------
                    // PLUS
                    // ------------------------------------------------
                    _QtyButton(
                      icon: Icons.add,
                      onTap: () {
                        cart.increment(
                          cartKey,
                        );
                      },
                    ),

                    const Spacer(),

                    // ------------------------------------------------
                    // DELETE
                    // ------------------------------------------------
                    IconButton(
                      tooltip: 'Remove',
                      onPressed: () {
                        cart.remove(
                          cartKey,
                        );
                      },
                      icon: const Icon(
                        Icons
                            .delete_outline_rounded,
                        color:
                        Colors.redAccent,
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

// ==================================================================
// QUANTITY BUTTON
// ==================================================================
class _QtyButton
    extends StatelessWidget {
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
      borderRadius:
      BorderRadius.circular(10),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color:
          const Color(0xFFF1F3F7),
          borderRadius:
          BorderRadius.circular(10),
        ),
        alignment:
        Alignment.center,
        child: Icon(
          icon,
          size: 18,
        ),
      ),
    );
  }
}

// ==================================================================
// EMPTY CART
// ==================================================================
class _EmptyCart
    extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            Icons
                .shopping_bag_outlined,
            size: 72,
            color:
            Color(0xFF9AA2B1),
          ),

          SizedBox(height: 14),

          Text(
            'Your cart is empty',
            style: TextStyle(
              fontWeight:
              FontWeight.w800,
              fontSize: 18,
            ),
          ),

          SizedBox(height: 6),

          Text(
            'Add products to create a catalogue.',
            style: TextStyle(
              fontSize: 12,
              color:
              Color(0xFF7A8190),
            ),
          ),
        ],
      ),
    );
  }
}