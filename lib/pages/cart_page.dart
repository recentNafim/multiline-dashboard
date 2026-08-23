

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';

import '../controllers/cart_controller.dart';
import '../models/cart_item.dart';
import '../services/cart_pdf_service.dart';
import '../services/cart_presentation_service.dart';

class CartPage extends GetView<CartController> {
  const CartPage({super.key});

  static const String _imageBaseUrl =
      'https://e501.sihirbox.com:8071/ords/rpro/image_service/get/';

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
          separatorBuilder: (_, __) {
            return const SizedBox(height: 12);
          },
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
      // BOTTOM ACTION BUTTONS
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
              mainAxisAlignment: MainAxisAlignment.end,
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                      Icons.picture_as_pdf_outlined,
                      size: 18,
                    ),
                    label: const Text(
                      'PDF',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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

  // ==================================================================
  // MAKE PRESENTATION
  // ==================================================================
  Future<void> _makePresentation() async {
    if (controller.items.isEmpty) {
      Get.snackbar(
        'Cart Empty',
        'Please add at least one product.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );

      return;
    }

    _showLoadingDialog(
      title: 'Preparing Presentation...',
      subtitle: 'Creating product slides...',
    );

    try {
      final List<CartItem> cartItems =
      controller.items.values.toList();

      await CartPresentationService.generate(
        items: cartItems,

        // API যদি শুধু filename return করে,
        // presentation service এই base URL ব্যবহার করবে।
        imageBaseUrl: _imageBaseUrl,
      );

      _closeLoadingDialog();

      Get.snackbar(
        'Presentation Ready',
        'PowerPoint presentation downloaded successfully.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    } catch (e, stackTrace) {
      _closeLoadingDialog();

      debugPrint('================================================');
      debugPrint('PRESENTATION ERROR');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      debugPrint('================================================');

      Get.snackbar(
        'Presentation Failed',
        'Could not create presentation.\n$e',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 6),
      );
    }
  }

  // ==================================================================
  // MAKE PDF
  // ==================================================================
  Future<void> _makePdf() async {
    if (controller.items.isEmpty) {
      Get.snackbar(
        'Cart Empty',
        'Please add at least one product.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );

      return;
    }

    _showLoadingDialog(
      title: 'Preparing PDF...',
      subtitle: 'Creating product catalogue...',
    );

    try {
      final List<CartItem> cartItems =
      controller.items.values.toList();

      final pdfBytes = await CartPdfService.buildPdf(
        items: cartItems,

        // API যদি শুধু filename return করে,
        // PDF service এই base URL ব্যবহার করবে।
        imageBaseUrl: _imageBaseUrl,
      );

      final DateTime now = DateTime.now();

      final String year = now.year.toString();
      final String month = now.month.toString().padLeft(2, '0');
      final String day = now.day.toString().padLeft(2, '0');
      final String hour = now.hour.toString().padLeft(2, '0');
      final String minute = now.minute.toString().padLeft(2, '0');

      final String baseFileName =
          'Display_Room_Product_Catalogue_'
          '$year$month$day'
          '_$hour$minute';

      _closeLoadingDialog();

      // ==============================================================
      // FLUTTER WEB
      // ==============================================================
      if (kIsWeb) {
        await FileSaver.instance.saveFile(
          name: baseFileName,
          bytes: pdfBytes,
          fileExtension: 'pdf',
          mimeType: MimeType.pdf,
        );

        Get.snackbar(
          'PDF Ready',
          'Product catalogue downloaded successfully.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );

        return;
      }

      // ==============================================================
      // MOBILE / DESKTOP
      // ==============================================================
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: '$baseFileName.pdf',
        subject: 'Display Room Product Catalogue',
        body:
        'Please find the selected Display Room products attached.',
      );
    } catch (e, stackTrace) {
      _closeLoadingDialog();

      debugPrint('================================================');
      debugPrint('PDF ERROR');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      debugPrint('================================================');

      Get.snackbar(
        'PDF Failed',
        'Could not create PDF.\n$e',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 6),
      );
    }
  }

  // ==================================================================
  // SHOW LOADING DIALOG
  // ==================================================================
  void _showLoadingDialog({
    required String title,
    required String subtitle,
  }) {
    Get.dialog(
      Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 300,
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 24,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7A8190),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ==================================================================
  // CLOSE LOADING DIALOG
  // ==================================================================
  void _closeLoadingDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}

// ====================================================================
// CART ITEM CARD
// ====================================================================
class _CartItemCard extends StatelessWidget {
  final String cartKey;
  final CartItem item;

  const _CartItemCard({
    required this.cartKey,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final CartController cart = Get.find<CartController>();

    final product = item.product;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF0F1F4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================================
          // PRODUCT IMAGE
          // ==========================================================
          _CartProductImage(
            product: product,
            height: 110,
            width: 110,
            borderRadius: 14,
          ),

          const SizedBox(width: 12),

          // ==========================================================
          // PRODUCT DETAILS
          // ==========================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ====================================================
                // PRODUCT NAME
                // ====================================================
                Text(
                  product.description.isEmpty
                      ? product.itemCode
                      : product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 4),

                // ====================================================
                // ITEM CODE
                // ====================================================
                Text(
                  product.itemCode,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7A8190),
                  ),
                ),

                const SizedBox(height: 12),

                // ====================================================
                // QUANTITY
                // ====================================================
                Row(
                  children: [
                    _QtyButton(
                      icon: Icons.remove,
                      onTap: () {
                        cart.decrement(cartKey);
                      },
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    _QtyButton(
                      icon: Icons.add,
                      onTap: () {
                        cart.increment(cartKey);
                      },
                    ),

                    const Spacer(),

                    IconButton(
                      tooltip: 'Remove',
                      onPressed: () {
                        cart.remove(cartKey);
                      },
                      icon: const Icon(
                        Icons.delete_outline_rounded,
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

// ====================================================================
// CART PRODUCT IMAGE
// ====================================================================
class _CartProductImage extends StatelessWidget {
  final dynamic product;
  final double width;
  final double height;
  final double borderRadius;

  const _CartProductImage({
    required this.product,
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  static const String _serverBaseUrl =
      'https://e501.sihirbox.com:8071';

  static const String _imageBaseUrl =
      'https://e501.sihirbox.com:8071/ords/rpro/image_service/get/';

  // ==================================================================
  // NORMALIZE IMAGE URL
  // ==================================================================
  String _normalizeImageUrl(dynamic value) {
    if (value == null) {
      return '';
    }

    String url = value.toString().trim();

    if (url.isEmpty || url.toLowerCase() == 'null') {
      return '';
    }

    // Already complete URL.
    if (url.startsWith('https://') ||
        url.startsWith('http://')) {
      return url;
    }

    while (url.startsWith('/')) {
      url = url.substring(1);
    }

    if (url.isEmpty) {
      return '';
    }

    // Relative ORDS URL.
    if (url.startsWith('ords/')) {
      return '$_serverBaseUrl/$url';
    }

    // Usually FILE_URL contains just the generated file name.
    final String encodedPath = url
        .split('/')
        .where((part) => part.isNotEmpty)
        .map(Uri.encodeComponent)
        .join('/');

    if (encodedPath.isEmpty) {
      return '';
    }

    return '$_imageBaseUrl$encodedPath';
  }

  // ==================================================================
  // READ IMAGE FROM MAP / JSON
  // ==================================================================
  String _readImageFromMap(
      Map<dynamic, dynamic> data, {
        int depth = 0,
      }) {
    if (depth > 5) {
      return '';
    }

    String url = _normalizeImageUrl(
      data['image_url'] ??
          data['imageUrl'],
    );

    if (url.isNotEmpty) {
      return url;
    }

    url = _normalizeImageUrl(
      data['file_url'] ??
          data['fileUrl'],
    );

    if (url.isNotEmpty) {
      return url;
    }

    final dynamic images = data['images'];

    if (images is Iterable) {
      for (final dynamic image in images) {
        if (image is Map) {
          url = _readImageFromMap(
            image,
            depth: depth + 1,
          );
        } else {
          url = _readImageFromObject(
            image,
            depth: depth + 1,
          );
        }

        if (url.isNotEmpty) {
          return url;
        }
      }
    }

    final dynamic details = data['details'];

    if (details is Iterable) {
      for (final dynamic detail in details) {
        if (detail is Map) {
          url = _readImageFromMap(
            detail,
            depth: depth + 1,
          );
        } else {
          url = _readImageFromObject(
            detail,
            depth: depth + 1,
          );
        }

        if (url.isNotEmpty) {
          return url;
        }
      }
    }

    return '';
  }

  // ==================================================================
  // READ IMAGE FROM MODEL / DYNAMIC OBJECT
  // ==================================================================
  String _readImageFromObject(
      dynamic data, {
        int depth = 0,
      }) {
    if (data == null || depth > 5) {
      return '';
    }

    if (data is Map) {
      return _readImageFromMap(
        data,
        depth: depth,
      );
    }

    String url = '';

    // imageUrl
    try {
      url = _normalizeImageUrl(
        data.imageUrl,
      );

      if (url.isNotEmpty) {
        return url;
      }
    } catch (_) {}

    // image_url
    try {
      url = _normalizeImageUrl(
        data.image_url,
      );

      if (url.isNotEmpty) {
        return url;
      }
    } catch (_) {}

    // fileUrl
    try {
      url = _normalizeImageUrl(
        data.fileUrl,
      );

      if (url.isNotEmpty) {
        return url;
      }
    } catch (_) {}

    // file_url
    try {
      url = _normalizeImageUrl(
        data.file_url,
      );

      if (url.isNotEmpty) {
        return url;
      }
    } catch (_) {}

    // images[]
    try {
      final dynamic images =
          data.images;

      if (images is Iterable) {
        for (final dynamic image in images) {
          url = _readImageFromObject(
            image,
            depth: depth + 1,
          );

          if (url.isNotEmpty) {
            return url;
          }
        }
      }
    } catch (_) {}

    // details[]
    try {
      final dynamic details =
          data.details;

      if (details is Iterable) {
        for (final dynamic detail in details) {
          url = _readImageFromObject(
            detail,
            depth: depth + 1,
          );

          if (url.isNotEmpty) {
            return url;
          }
        }
      }
    } catch (_) {}

    return '';
  }

  String _getImageUrl() {
    final String imageUrl =
    _readImageFromObject(product);

    if (imageUrl.isNotEmpty) {
      debugPrint(
        '✅ CART IMAGE => $imageUrl',
      );
    } else {
      debugPrint(
        '⚠️ CART IMAGE NOT FOUND',
      );
    }

    return imageUrl;
  }

  // ==================================================================
  // FULLSCREEN IMAGE
  // ==================================================================
  void _showFullImage(
      BuildContext context,
      String imageUrl,
      ) {
    showDialog(
      context: context,
      barrierColor:
      Colors.black.withOpacity(0.92),
      builder: (
          BuildContext dialogContext,
          ) {
        return Dialog(
          backgroundColor:
          Colors.transparent,
          insetPadding:
          const EdgeInsets.all(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 0.7,
                  maxScale: 5,
                  child: Center(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return const Icon(
                          Icons
                              .broken_image_outlined,
                          size: 80,
                          color:
                          Colors.white70,
                        );
                      },
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color:
                  Colors.black54,
                  shape:
                  const CircleBorder(),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(
                        dialogContext,
                      ).pop();
                    },
                    icon: const Icon(
                      Icons
                          .close_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl =
    _getImageUrl();

    if (imageUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(
            0xFFF1F3F7,
          ),
          borderRadius:
          BorderRadius.circular(
            borderRadius,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Icon(
                Icons
                    .image_not_supported_outlined,
                size: 34,
                color: Color(
                  0xFF9AA2B1,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'No Image',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(
                    0xFF8A919D,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        _showFullImage(
          context,
          imageUrl,
        );
      },
      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(
          borderRadius,
        ),
        child: Container(
          width: width,
          height: height,
          color: const Color(
            0xFFF1F3F7,
          ),
          child: Image.network(
            imageUrl,
            width: width,
            height: height,
            fit: BoxFit.cover,
            loadingBuilder: (
                context,
                child,
                loadingProgress,
                ) {
              if (loadingProgress ==
                  null) {
                return child;
              }

              final int? total =
                  loadingProgress
                      .expectedTotalBytes;

              return Center(
                child:
                CircularProgressIndicator(
                  strokeWidth: 2.3,
                  value: total != null
                      ? loadingProgress
                      .cumulativeBytesLoaded /
                      total
                      : null,
                ),
              );
            },
            errorBuilder: (
                context,
                error,
                stackTrace,
                ) {
              debugPrint(
                '❌ CART IMAGE LOAD FAILED',
              );
              debugPrint(
                'URL => $imageUrl',
              );
              debugPrint(
                'ERROR => $error',
              );

              return const Center(
                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    Icon(
                      Icons
                          .broken_image_outlined,
                      size: 34,
                      color: Color(
                        0xFF9AA2B1,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Image error',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(
                          0xFF8A919D,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// QUANTITY BUTTON
// ====================================================================
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
      borderRadius:
      BorderRadius.circular(10),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(
            0xFFF1F3F7,
          ),
          borderRadius:
          BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
        ),
      ),
    );
  }
}

// ====================================================================
// EMPTY CART
// ====================================================================
class _EmptyCart extends StatelessWidget {
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
            color: Color(
              0xFF9AA2B1,
            ),
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
              color: Color(
                0xFF7A8190,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
