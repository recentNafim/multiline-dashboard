

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import '../models/product_model.dart';
import '../widgets/cart_icon_button.dart';

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          if (width >= 900) {
            return _buildDesktopView(
              context,
              cartController,
            );
          }

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
          // LEFT IMAGE / GALLERY
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
                clipBehavior: Clip.antiAlias,
                child: _ProductImageGallery(
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

    double imageHeight = width * 0.82;

    if (imageHeight > 430) {
      imageHeight = 430;
    }

    if (imageHeight < 260) {
      imageHeight = 260;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===================================================
          // IMAGE / GALLERY
          // ===================================================
          Container(
            width: double.infinity,
            height: imageHeight,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F7),
              borderRadius: BorderRadius.circular(22),
            ),
            clipBehavior: Clip.antiAlias,
            child: _ProductImageGallery(
              product: product,
              width: double.infinity,
              height: imageHeight,
              fit: BoxFit.contain,
              borderRadius: 22,
            ),
          ),

          const SizedBox(height: 24),

          // ===================================================
          // DETAILS
          // ===================================================
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

// ============================================================================
// PRODUCT IMAGE GALLERY
// ============================================================================

class _ProductImageGallery extends StatefulWidget {
  final ProductModel product;
  final double width;
  final double height;
  final BoxFit fit;
  final double borderRadius;

  const _ProductImageGallery({
    required this.product,
    required this.width,
    required this.height,
    required this.fit,
    required this.borderRadius,
  });

  @override
  State<_ProductImageGallery> createState() =>
      _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<_ProductImageGallery> {
  static const String _serverBaseUrl =
      'https://e501.sihirbox.com:8071';

  static const String _imageBaseUrl =
      'https://e501.sihirbox.com:8071/ords/rpro/image_service/get/';

  final PageController _pageController = PageController();

  int _currentIndex = 0;

  late final List<String> _imageUrls;

  @override
  void initState() {
    super.initState();

    _imageUrls = _resolveProductImageUrls(
      widget.product,
    );

    debugPrint('==========================================');
    debugPrint('PRODUCT IMAGE URLS');
    debugPrint('ITEM CODE => ${widget.product.itemCode}');
    debugPrint('TOTAL IMAGE => ${_imageUrls.length}');

    for (int i = 0; i < _imageUrls.length; i++) {
      debugPrint('IMAGE ${i + 1} => ${_imageUrls[i]}');
    }

    debugPrint('==========================================');
  }

  // ============================================================
  // NORMALIZE URL
  // ============================================================
  String _normalizeImageUrl(dynamic value) {
    if (value == null) {
      return '';
    }

    String url = value.toString().trim();

    if (url.isEmpty || url.toLowerCase() == 'null') {
      return '';
    }

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

    // API যদি relative ORDS URL return করে
    if (url.startsWith('ords/')) {
      return '$_serverBaseUrl/$url';
    }

    // API যদি শুধু physical filename return করে
    final encodedPath = url
        .split('/')
        .where((part) => part.isNotEmpty)
        .map(Uri.encodeComponent)
        .join('/');

    if (encodedPath.isEmpty) {
      return '';
    }

    return '$_imageBaseUrl$encodedPath';
  }

  // ============================================================
  // COLLECT ALL POSSIBLE IMAGE FIELDS
  // ============================================================
  List<String> _resolveProductImageUrls(
      ProductModel product,
      ) {
    final List<String> result = <String>[];
    final Set<String> unique = <String>{};

    void addUrl(dynamic value) {
      final String normalized =
      _normalizeImageUrl(value);

      if (normalized.isEmpty) {
        return;
      }

      if (unique.add(normalized)) {
        result.add(normalized);
      }
    }

    void readNode(
        dynamic node, {
          int depth = 0,
        }) {
      if (node == null || depth > 5) {
        return;
      }

      if (node is String) {
        addUrl(node);
        return;
      }

      // --------------------------------------------------------
      // MAP JSON SUPPORT
      // --------------------------------------------------------
      if (node is Map) {
        addUrl(
          node['image_url'] ??
              node['imageUrl'],
        );

        addUrl(
          node['file_url'] ??
              node['fileUrl'],
        );

        final dynamic images =
        node['images'];

        if (images is Iterable) {
          for (final dynamic image in images) {
            readNode(
              image,
              depth: depth + 1,
            );
          }
        }

        final dynamic details =
        node['details'];

        if (details is Iterable) {
          for (final dynamic detail in details) {
            readNode(
              detail,
              depth: depth + 1,
            );
          }
        }

        return;
      }

      // --------------------------------------------------------
      // MODEL / OBJECT SUPPORT
      // --------------------------------------------------------
      final dynamic dynamicNode = node;

      try {
        addUrl(dynamicNode.imageUrl);
      } catch (_) {}

      try {
        addUrl(dynamicNode.image_url);
      } catch (_) {}

      try {
        addUrl(dynamicNode.fileUrl);
      } catch (_) {}

      try {
        addUrl(dynamicNode.file_url);
      } catch (_) {}

      try {
        final dynamic images =
            dynamicNode.images;

        if (images is Iterable) {
          for (final dynamic image in images) {
            readNode(
              image,
              depth: depth + 1,
            );
          }
        }
      } catch (_) {}

      try {
        final dynamic details =
            dynamicNode.details;

        if (details is Iterable) {
          for (final dynamic detail in details) {
            readNode(
              detail,
              depth: depth + 1,
            );
          }
        }
      } catch (_) {}
    }

    // ProductModel কে dynamic হিসেবে read করা হচ্ছে,
    // তাই imageUrl/fileUrl field model-এ না থাকলেও compile error হবে না।
    readNode(product);

    return result;
  }

  // ============================================================
  // FULL SCREEN PREVIEW
  // ============================================================
  void _openFullScreenPreview(
      BuildContext context,
      String imageUrl,
      ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
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
                        return const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 80,
                            color: Colors.white70,
                          ),
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
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    icon: const Icon(
                      Icons.close_rounded,
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

  // ============================================================
  // MAIN IMAGE
  // ============================================================
  Widget _buildNetworkImage(
      String imageUrl,
      ) {
    return GestureDetector(
      onTap: () {
        _openFullScreenPreview(
          context,
          imageUrl,
        );
      },
      child: Container(
        color: const Color(0xFFF1F3F7),
        alignment: Alignment.center,
        child: Image.network(
          imageUrl,
          width: double.infinity,
          height: double.infinity,
          fit: widget.fit,

          loadingBuilder: (
              context,
              child,
              loadingProgress,
              ) {
            if (loadingProgress == null) {
              return child;
            }

            final total =
                loadingProgress.expectedTotalBytes;

            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
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
              'IMAGE LOAD FAILED => $imageUrl',
            );
            debugPrint(
              'IMAGE ERROR => $error',
            );

            return const _ImageErrorPlaceholder();
          },
        ),
      ),
    );
  }

  // ============================================================
  // THUMBNAIL
  // ============================================================
  Widget _buildThumbnail(
      String url,
      int index,
      ) {
    final bool selected =
        index == _currentIndex;

    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(
            milliseconds: 250,
          ),
          curve: Curves.easeOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 180,
        ),
        width: 64,
        height: 64,
        margin: const EdgeInsets.only(
          right: 8,
        ),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? Theme.of(context)
                .colorScheme
                .primary
                : const Color(
              0xFFDDE1E8,
            ),
            width: selected ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius:
          BorderRadius.circular(7),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (
                context,
                error,
                stackTrace,
                ) {
              return const ColoredBox(
                color: Color(0xFFF1F3F7),
                child: Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 20,
                    color: Color(
                      0xFF9AA2B1,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ============================================================
    // NO IMAGE
    // ============================================================
    if (_imageUrls.isEmpty) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const _NoImagePlaceholder(),
      );
    }

    // ============================================================
    // SINGLE / MULTIPLE IMAGE
    // ============================================================
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: PageView.builder(
                    controller:
                    _pageController,
                    itemCount:
                    _imageUrls.length,
                    onPageChanged:
                        (index) {
                      setState(() {
                        _currentIndex =
                            index;
                      });
                    },
                    itemBuilder: (
                        context,
                        index,
                        ) {
                      return _buildNetworkImage(
                        _imageUrls[index],
                      );
                    },
                  ),
                ),

                // Image counter
                if (_imageUrls.length > 1)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration:
                      BoxDecoration(
                        color: Colors.black
                            .withOpacity(
                          0.58,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          20,
                        ),
                      ),
                      child: Text(
                        '${_currentIndex + 1}/${_imageUrls.length}',
                        style:
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight:
                          FontWeight
                              .w700,
                        ),
                      ),
                    ),
                  ),

                // Zoom hint
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding:
                    const EdgeInsets
                        .all(7),
                    decoration:
                    BoxDecoration(
                      color: Colors.black
                          .withOpacity(
                        0.45,
                      ),
                      shape:
                      BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.zoom_in_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // THUMBNAILS
          // ======================================================
          if (_imageUrls.length > 1)
            Container(
              height: 82,
              width: double.infinity,
              padding:
              const EdgeInsets.fromLTRB(
                12,
                9,
                12,
                9,
              ),
              decoration:
              const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color:
                    Color(0xFFE4E7EC),
                  ),
                ),
              ),
              child:
              ListView.builder(
                scrollDirection:
                Axis.horizontal,
                itemCount:
                _imageUrls.length,
                itemBuilder: (
                    context,
                    index,
                    ) {
                  return _buildThumbnail(
                    _imageUrls[index],
                    index,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

// ============================================================================
// NO IMAGE PLACEHOLDER
// ============================================================================

class _NoImagePlaceholder extends StatelessWidget {
  const _NoImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF1F3F7),
      child: const Center(
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 64,
              color: Color(
                0xFF9AA2B1,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'No Image Available',
              style: TextStyle(
                color: Color(
                  0xFF7A8190,
                ),
                fontSize: 14,
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// IMAGE ERROR PLACEHOLDER
// ============================================================================

class _ImageErrorPlaceholder extends StatelessWidget {
  const _ImageErrorPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF1F3F7),
      child: const Center(
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              Icons.broken_image_outlined,
              size: 58,
              color: Color(
                0xFF9AA2B1,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Image unavailable',
              style: TextStyle(
                color: Color(
                  0xFF7A8190,
                ),
                fontSize: 13,
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
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
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          icon,
                          size: 18,
                          color: const Color(
                            0xFF747B88,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Color(
                              0xFF747B88,
                            ),
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
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    size: 19,
                    color: const Color(
                      0xFF747B88,
                    ),
                  ),

                  const SizedBox(width: 9),

                  SizedBox(
                    width: 125,
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Color(
                          0xFF747B88,
                        ),
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
                        color: Color(
                          0xFF202329,
                        ),
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w700,
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
            color: Color(
              0xFFEEF0F4,
            ),
          ),
      ],
    );
  }
}
