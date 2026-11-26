import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/catalogue_logo_data.dart';
import '../controllers/product_controller.dart';
import '../controllers/cart_controller.dart';
import '../models/product_model.dart';
import '../widgets/product_image_carousel.dart';
import 'cart_page.dart';
import 'product_detail_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ProductController controller = Get.find<ProductController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Reuse the same official company logo embedded for the PDF cover.
  // No change to pubspec.yaml, assets, or any network request is needed.
  late final Uint8List _headerLogoBytes = base64Decode(mlilCompanyLogoBase64);

  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';

  // API category = BUSINESS
  String? _selectedCategory;
  String? _selectedSubCategory;

  // Fixed client-approved dropdown choices. Filtering is performed against
  // GET response master fields `business` and `sub_category`.
  static const List<String> _categoryOptions = <String>[
    'Footwear',
    'Bag & Luggage',
    'Tent',
    'Umbrella',
    'Handicraft',
  ];

  static const List<String> _subCategoryOptions = <String>[
    'Export',
    'Domestic',
  ];

  // ================================================================
  // IMAGE URL
  // ================================================================
  static const String _serverBaseUrl =
      'https://e501.sihirbox.com:8071';

  static const String _imageBaseUrl =
      'https://e501.sihirbox.com:8071/ords/rpro/image_service/get/';

  // ================================================================
  // SAFE VALUE READER
  // ================================================================
  String _getValue(
      dynamic item,
      String field,
      ) {
    try {
      // --------------------------------------------------------------
      // MAP SUPPORT
      // --------------------------------------------------------------
      if (item is Map) {
        switch (field) {
          case 'sl':
            return item['sl']?.toString() ?? '';

          case 'business':
            return item['business']?.toString() ?? '';

          case 'subCategory':
            return item['sub_category']?.toString() ??
                item['subCategory']?.toString() ??
                '';

          case 'organizationId':
            return item['organization_id']?.toString() ??
                item['organizationId']?.toString() ??
                '';

          case 'organizationCode':
            return item['organization_code']?.toString() ??
                item['organizationCode']?.toString() ??
                '';

          case 'status':
            return item['status']?.toString() ?? '';

          case 'detailsCount':
            return item['details_count']?.toString() ??
                item['detailsCount']?.toString() ??
                '0';

        // ===========================================================
        // PRODUCT FIELDS
        // ===========================================================
          case 'description':
            return item['description']?.toString() ??
                item['product_description']?.toString() ??
                item['productDescription']?.toString() ??
                '';

          case 'itemCode':
            return item['item_code']?.toString() ??
                item['itemCode']?.toString() ??
                '';

          case 'productCategory':
            return item['product_category']?.toString() ??
                item['productCategory']?.toString() ??
                '';

        // ===========================================================
        // IMAGE FIELDS
        // ===========================================================
          case 'imageUrl':
            return item['image_url']?.toString() ??
                item['imageUrl']?.toString() ??
                '';

          case 'fileUrl':
            return item['file_url']?.toString() ??
                item['fileUrl']?.toString() ??
                '';

          default:
            return '';
        }
      }

      // --------------------------------------------------------------
      // MODEL SUPPORT
      // --------------------------------------------------------------
      switch (field) {
        case 'sl':
          try {
            return item.sl?.toString() ?? '';
          } catch (_) {
            return '';
          }

        case 'business':
          try {
            return item.business?.toString() ?? '';
          } catch (_) {
            return '';
          }

        case 'subCategory':
          try {
            return item.subCategory?.toString() ?? '';
          } catch (_) {
            return '';
          }

        case 'organizationId':
          try {
            return item.organizationId?.toString() ?? '';
          } catch (_) {
            return '';
          }

        case 'organizationCode':
          try {
            return item.organizationCode?.toString() ?? '';
          } catch (_) {
            return '';
          }

        case 'status':
          try {
            return item.status?.toString() ?? '';
          } catch (_) {
            return '';
          }

        case 'detailsCount':
          try {
            return item.detailsCount?.toString() ?? '0';
          } catch (_) {
            return '0';
          }

        case 'description':
          try {
            return item.description?.toString() ?? '';
          } catch (_) {
            return '';
          }

        case 'itemCode':
          try {
            return item.itemCode?.toString() ?? '';
          } catch (_) {
            return '';
          }

        case 'productCategory':
          try {
            return item.productCategory?.toString() ?? '';
          } catch (_) {
            return '';
          }

        case 'imageUrl':
          try {
            return item.imageUrl?.toString() ?? '';
          } catch (_) {
            return '';
          }

        case 'fileUrl':
          try {
            return item.fileUrl?.toString() ?? '';
          } catch (_) {
            return '';
          }

        default:
          return '';
      }
    } catch (_) {
      return '';
    }
  }

  // ================================================================
  // NORMALIZE IMAGE URL
  // ================================================================
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

    if (url.startsWith('ords/')) {
      return '$_serverBaseUrl/$url';
    }

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

  // ================================================================
  // FIND IMAGE FROM MAP
  // ================================================================
  String _getImageFromMap(
      Map<dynamic, dynamic> data, {
        int depth = 0,
      }) {
    if (depth > 5) {
      return '';
    }

    String url = _normalizeImageUrl(
      data['image_url'] ?? data['imageUrl'],
    );

    if (url.isNotEmpty) {
      return url;
    }

    url = _normalizeImageUrl(
      data['file_url'] ?? data['fileUrl'],
    );

    if (url.isNotEmpty) {
      return url;
    }

    final dynamic images = data['images'];

    if (images is Iterable) {
      for (final dynamic image in images) {
        if (image is Map) {
          url = _getImageFromMap(
            image,
            depth: depth + 1,
          );
        } else {
          url = _getImageFromModel(
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
          url = _getImageFromMap(
            detail,
            depth: depth + 1,
          );
        } else {
          url = _getImageFromModel(
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

  // ================================================================
  // FIND IMAGE FROM MODEL
  // ================================================================
  String _getImageFromModel(
      dynamic item, {
        int depth = 0,
      }) {
    if (item == null || depth > 5) {
      return '';
    }

    if (item is Map) {
      return _getImageFromMap(
        item,
        depth: depth,
      );
    }

    String url = '';

    try {
      url = _normalizeImageUrl(item.imageUrl);
      if (url.isNotEmpty) return url;
    } catch (_) {}

    try {
      url = _normalizeImageUrl(item.image_url);
      if (url.isNotEmpty) return url;
    } catch (_) {}

    try {
      url = _normalizeImageUrl(item.fileUrl);
      if (url.isNotEmpty) return url;
    } catch (_) {}

    try {
      url = _normalizeImageUrl(item.file_url);
      if (url.isNotEmpty) return url;
    } catch (_) {}

    try {
      final dynamic images = item.images;

      if (images is Iterable) {
        for (final dynamic image in images) {
          url = _getImageFromModel(
            image,
            depth: depth + 1,
          );

          if (url.isNotEmpty) {
            return url;
          }
        }
      }
    } catch (_) {}

    try {
      final dynamic details = item.details;

      if (details is Iterable) {
        for (final dynamic detail in details) {
          url = _getImageFromModel(
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

  // ================================================================
  // PRODUCT IMAGE
  // ================================================================
  String _getProductImageUrl(dynamic item) {
    try {
      final String url = item is Map
          ? _getImageFromMap(item)
          : _getImageFromModel(item);

      if (url.isNotEmpty) {
        debugPrint('✅ PRODUCT IMAGE => $url');
        return url;
      }
    } catch (e) {
      debugPrint('❌ PRODUCT IMAGE ERROR => $e');
    }

    debugPrint('⚠️ PRODUCT IMAGE NOT FOUND');
    return '';
  }

  // ================================================================
  // IMAGE WIDGET
  // ================================================================
  Widget _buildProductImage(String imageUrl, {double height = 172}) {
    if (imageUrl.trim().isEmpty) {
      return Container(
        width: double.infinity,
        height: height,
        color: const Color(0xFFF4F6F8),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                size: 42,
                color: Color(0xFF9AA2B1),
              ),
              SizedBox(height: 7),
              Text(
                'No Image Available',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF8A919D),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Image.network(
        imageUrl,
        fit: height == 172 ? BoxFit.cover : BoxFit.contain,
        loadingBuilder: (
            context,
            child,
            loadingProgress,
            ) {
          if (loadingProgress == null) {
            return child;
          }

          final int? total =
              loadingProgress.expectedTotalBytes;

          return Container(
            color: const Color(0xFFF4F6F8),
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              value: total != null
                  ? loadingProgress.cumulativeBytesLoaded / total
                  : null,
            ),
          );
        },
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          debugPrint('❌ IMAGE LOAD FAILED');
          debugPrint('URL => $imageUrl');
          debugPrint('ERROR => $error');

          return Container(
            color: const Color(0xFFF4F6F8),
            alignment: Alignment.center,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  size: 42,
                  color: Color(0xFF9AA2B1),
                ),
                SizedBox(height: 7),
                Text(
                  'Image unavailable',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8A919D),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================================================================
  // FILTERED PRODUCTS
  // ================================================================
  List<dynamic> get filteredProducts {
    final String search =
    _searchText.trim().toLowerCase();

    return controller.products.where((item) {
      final String description =
      _getValue(item, 'description');

      final String itemCode =
      _getValue(item, 'itemCode');

      final String productCategory =
      _getValue(item, 'productCategory');

      final String business =
      _getValue(item, 'business');

      final String subCategory =
      _getValue(item, 'subCategory');

      final String organizationId =
      _getValue(item, 'organizationId');

      final String organizationCode =
      _getValue(item, 'organizationCode');

      final String status =
      _getValue(item, 'status');

      final bool matchesSearch =
          search.isEmpty ||
              description.toLowerCase().contains(search) ||
              itemCode.toLowerCase().contains(search) ||
              productCategory.toLowerCase().contains(search) ||
              business.toLowerCase().contains(search) ||
              subCategory.toLowerCase().contains(search) ||
              organizationId.toLowerCase().contains(search) ||
              organizationCode.toLowerCase().contains(search) ||
              status.toLowerCase().contains(search);

      // Exact, case-insensitive matches against the GET API MASTER fields:
      // business = category, sub_category = subcategory.
      final bool matchesCategory =
          _selectedCategory == null ||
              _selectedCategory!.isEmpty ||
              business.trim().toLowerCase() ==
                  _selectedCategory!.trim().toLowerCase();

      final bool matchesSubCategory =
          _selectedSubCategory == null ||
              _selectedSubCategory!.isEmpty ||
              subCategory.trim().toLowerCase() ==
                  _selectedSubCategory!.trim().toLowerCase();

      return matchesSearch &&
          matchesCategory &&
          matchesSubCategory;
    }).toList();
  }

  // ================================================================
  // HARDCODED FILTER OPTIONS
  // GET API: data[].business and data[].sub_category (master fields).
  // These options do NOT depend on the product list or metadata API.
  // ================================================================
  List<String> get categoryList => _categoryOptions;
  List<String> get subCategoryList => _subCategoryOptions;

  // ================================================================
  // RESET FILTER
  // ================================================================
  void _resetFilters() {
    _searchController.clear();

    setState(() {
      _searchText = '';
      _selectedCategory = null;
      _selectedSubCategory = null;
    });
  }

  bool get _hasFilter {
    return _searchText.trim().isNotEmpty ||
        _selectedCategory != null ||
        _selectedSubCategory != null;
  }

  // ================================================================
  // TOP CATEGORY / SUB CATEGORY / SEARCH BAR
  // ================================================================
  // True mobile storefront: one search row and a filter drawer trigger.
  // The larger desktop category/dropdown toolbar is intentionally hidden.
  Widget _buildMobileTopFilterBar() {
    final int activeFilters =
        (_selectedCategory == null ? 0 : 1) +
        (_selectedSubCategory == null ? 0 : 1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onChanged: (value) => setState(() => _searchText = value),
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search products / item code',
                      hintStyle: const TextStyle(
                        color: Color(0xFF8892A2), fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, size: 21),
                      suffixIcon: _searchText.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchText = '');
                              },
                            ),
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: const BorderSide(color: Color(0xFFE1E6F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: const BorderSide(
                          color: Color(0xFF5269BA), width: 1.5),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: IconButton.filledTonal(
                        tooltip: 'Filter products',
                        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFE9ECFB),
                          foregroundColor: const Color(0xFF354A8D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13)),
                        ),
                        icon: const Icon(Icons.tune_rounded, size: 22),
                      ),
                    ),
                    if (activeFilters > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Color(0xFF354A8D), shape: BoxShape.circle),
                          child: Text('$activeFilters',
                            style: const TextStyle(
                              color: Colors.white, fontSize: 10,
                              fontWeight: FontWeight.w800)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.grid_view_rounded,
                size: 15, color: Color(0xFF6C7790)),
              const SizedBox(width: 6),
              Expanded(
                child: Obx(() {
                  final int total = controller.products.length;
                  final bool loading = controller.isLoading.value && total == 0;
                  final int matching = _hasFilter ? filteredProducts.length : total;
                  return Text(
                    loading
                        ? 'Loading products...'
                        : _hasFilter
                            ? 'Showing $matching of $total products'
                            : '$total products',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12,
                      fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                  );
                }),
              ),
              if (_hasFilter)
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: _resetFilters,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    child: Text('Clear filters',
                      style: TextStyle(fontSize: 12,
                        fontWeight: FontWeight.w700, color: Color(0xFF4055A0))),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopFilterBar() {
    if (MediaQuery.sizeOf(context).width < 650) {
      return _buildMobileTopFilterBar();
    }
    final List<String> categories =
        categoryList;

    final List<String> subCategories =
        subCategoryList;

    final String? safeCategory =
    _selectedCategory != null &&
        categories.contains(
          _selectedCategory,
        )
        ? _selectedCategory
        : null;

    final String? safeSubCategory =
    _selectedSubCategory != null &&
        subCategories.contains(
          _selectedSubCategory,
        )
        ? _selectedSubCategory
        : null;

    Widget searchField = TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchText = value;
          });
        },
        decoration: InputDecoration(
          hintText:
          'Search description, item code...',
          prefixIcon: const Icon(
            Icons.search_rounded,
          ),
          suffixIcon: _searchText.isNotEmpty
              ? IconButton(
            tooltip: 'Clear Search',
            onPressed: () {
              _searchController.clear();

              setState(() {
                _searchText = '';
              });
            },
            icon: const Icon(
              Icons.close_rounded,
            ),
          )
              : null,
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(12),
          ),
          enabledBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(12),
            borderSide:
            const BorderSide(
              color: Color(0xFFE3E6EC),
            ),
          ),
        ),
    );

    Widget categoryDropdown = SizedBox(
      width: 220,
      child:
      DropdownButtonFormField<String>(
        key: ValueKey<String>("top-category-${safeCategory ?? ''}"),
        value: safeCategory ?? '',
        isExpanded: true,
        hint: Text(
          'All Categories',
        ),
        decoration: InputDecoration(
          labelText: 'Category',
          prefixIcon: const Icon(
            Icons.category_outlined,
          ),
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(12),
          ),
          enabledBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(12),
            borderSide:
            const BorderSide(
              color: Color(0xFFE3E6EC),
            ),
          ),
        ),
        items: <DropdownMenuItem<String>>[
          const DropdownMenuItem<String>(
            value: '',
            child: Text('All Categories'),
          ),
          ...categories.map(
              (category) =>
              DropdownMenuItem<String>(
                value: category,
                child: Text(
                  category,
                  overflow:
                  TextOverflow.ellipsis,
                ),
              ),
        ),
        ],
        onChanged: (value) {
          setState(() {
            _selectedCategory =
                value == null || value.isEmpty ? null : value;

            // Category changes =>
            // reset dependent sub category.
            _selectedSubCategory =
            null;
          });
        },
      ),
    );

    Widget subCategoryDropdown =
    SizedBox(
      width: 220,
      child:
      DropdownButtonFormField<String>(
        key: ValueKey<String>("top-sub-${safeCategory ?? ''}-${safeSubCategory ?? ''}"),
        value: safeSubCategory ?? '',
        isExpanded: true,
        hint: Text(
          'All Sub Categories',
        ),
        decoration: InputDecoration(
          labelText: 'Sub Category',
          prefixIcon: const Icon(
            Icons.account_tree_outlined,
          ),
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(12),
          ),
          enabledBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(12),
            borderSide:
            const BorderSide(
              color: Color(0xFFE3E6EC),
            ),
          ),
        ),
        items: <DropdownMenuItem<String>>[
          const DropdownMenuItem<String>(
            value: '',
            child: Text('All Sub Categories'),
          ),
          ...subCategories.map(
              (subCategory) =>
              DropdownMenuItem<String>(
                value: subCategory,
                child: Text(
                  subCategory,
                  overflow:
                  TextOverflow.ellipsis,
                ),
              ),
        ),
        ],
        onChanged: (value) {
          setState(() {
            _selectedSubCategory =
                value == null || value.isEmpty ? null : value;
          });
        },
      ),
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 2),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF7FAFF),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE4E9F2),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (
            context,
            constraints,
            ) {
          final bool compact =
              constraints.maxWidth < 900;

          if (compact) {
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width:
                  constraints.maxWidth,
                  child: searchField,
                ),
                SizedBox(
                  width: constraints.maxWidth < 520
                      ? constraints.maxWidth
                      : (constraints.maxWidth -
                      10) /
                      2,
                  child:
                  categoryDropdown,
                ),
                SizedBox(
                  width: constraints.maxWidth < 520
                      ? constraints.maxWidth
                      : (constraints.maxWidth -
                      10) /
                      2,
                  child:
                  subCategoryDropdown,
                ),
                if (_hasFilter)
                  OutlinedButton.icon(
                    onPressed:
                    _resetFilters,
                    icon: const Icon(
                      Icons
                          .restart_alt_rounded,
                    ),
                    label: const Text(
                      'Reset',
                    ),
                  ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: searchField,
              ),
              const SizedBox(width: 10),
              categoryDropdown,
              const SizedBox(width: 10),
              subCategoryDropdown,
              if (_hasFilter) ...[
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed:
                  _resetFilters,
                  icon: const Icon(
                    Icons
                        .restart_alt_rounded,
                  ),
                  label:
                  const Text('Reset'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  // ================================================================
  // OPEN PRODUCT DETAIL
  // ================================================================
  void _openDetailPage(dynamic item) {
    Get.to(
          () => ProductDetailPage(
        product: item,
      ),
      transition: Transition.rightToLeft,
      duration: const Duration(
        milliseconds: 250,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  // ==================================================================
  // CART ACTIONS: clearing affects only the local shopping cart.
  // Product records and server-side data are never deleted.
  // ==================================================================
  Future<void> _confirmClearCart() async {
    final CartController cart = Get.find<CartController>();
    if (cart.totalItems == 0) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Cart?'),
        content: Text(
          'Remove all ${cart.totalItems} item(s) from your cart? '
          'This will not delete any product records.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Clear Cart'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    cart.clearCart();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cart cleared successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openCart() {
    Get.to(() => const CartPage());
  }

  Widget _buildCartHeaderActions() {
    final bool compact = MediaQuery.sizeOf(context).width < 630;
    final CartController cart = Get.find<CartController>();
    final bool phone = MediaQuery.sizeOf(context).width < 650;

    return Obx(() {
      final int itemCount = cart.totalItems;
      if (phone) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            tooltip: 'Open cart ($itemCount items)',
            onPressed: _openCart,
            icon: Badge(
              isLabelVisible: itemCount > 0,
              label: Text(itemCount > 99 ? '99+' : '$itemCount'),
              child: const Icon(Icons.shopping_bag_outlined, size: 23),
            ),
          ),
        );
      }
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (compact)
            IconButton(
              tooltip: 'Clear Cart',
              onPressed: itemCount > 0 ? _confirmClearCart : null,
              icon: const Icon(Icons.delete_sweep_outlined),
            )
          else
            OutlinedButton.icon(
              onPressed: itemCount > 0 ? _confirmClearCart : null,
              icon: const Icon(Icons.delete_sweep_outlined, size: 18),
              label: const Text('Clear'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFC62828),
                side: const BorderSide(color: Color(0xFFEF9A9A)),
              ),
            ),
          const SizedBox(width: 8),
          FilledButton.tonalIcon(
            onPressed: _openCart,
            icon: const Icon(Icons.shopping_bag_outlined, size: 19),
            label: Text(itemCount > 0 ? 'Cart ($itemCount)' : 'Cart'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(0, 42),
            ),
          ),
          const SizedBox(width: 12),
        ],
      );
    });
  }

  // ================================================================
  // COMPANY LOGO (header only)
  // ================================================================
  Widget _buildHeaderLogo({required double width, required double height}) {
    return SizedBox(
      width: width,
      height: height,
      child: Image.memory(
        _headerLogoBytes,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
        semanticLabel: 'Multi-Line Industries Limited',
      ),
    );
  }

  Widget _buildPhoneHeaderTitle() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: _buildHeaderLogo(width: 210, height: 40),
      ),
    );
  }

  // ================================================================
  // BUILD
  // ================================================================
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool phoneHeader = screenWidth < 650;
    final bool compactHeader = screenWidth < 900;

    return Scaffold(
      key: _scaffoldKey,
      drawer: SizedBox(
        width: screenWidth < 370 ? screenWidth * 0.91 : 330,
        child: _buildFilterDrawer(),
      ),
      appBar: AppBar(
        toolbarHeight: phoneHeader ? 60 : 72,
        titleSpacing: phoneHeader ? 6 : null,
        leading: phoneHeader
            ? IconButton(
                tooltip: 'Open product filters',
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                icon: const Icon(Icons.menu_rounded, size: 25),
              )
            : null,
        // Desktop keeps the centered logo. On phones the transparent
        // logo sits directly in the title area, so no extra logo row is shown.
        flexibleSpace: !compactHeader
            ? SafeArea(
                child: Center(
                  child: IgnorePointer(
                    child: _buildHeaderLogo(width: 270, height: 46),
                  ),
                ),
              )
            : null,
        title: phoneHeader
            ? _buildPhoneHeaderTitle()
            : const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MLIL Display Room', maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w900,
                      fontSize: 21, letterSpacing: -0.3)),
                  SizedBox(height: 2),
                  Text('Explore available products and collections',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B))),
                ],
              ),
        actions: [_buildCartHeaderActions()],
        bottom: !phoneHeader && compactHeader
            ? PreferredSize(
                preferredSize: const Size.fromHeight(44),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildHeaderLogo(width: 220, height: 36),
                ),
              )
            : null,
      ),

      body: Column(
        children: [
          // Fixed dropdowns stay visible even before GET products load.
          _buildTopFilterBar(),
          Expanded(
            child: Obx(() {
              // ============================================================
              // LOADING
              // ============================================================
              if (controller.isLoading.value &&
                  controller.products.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // ============================================================
              // ERROR
              // ============================================================
              if (controller.errorMessage.value.isNotEmpty &&
                  controller.products.isEmpty) {
                return _ErrorView(
                  message: controller.errorMessage.value,
                  onRetry: controller.fetchProducts,
                );
              }

              // ============================================================
              // EMPTY
              // ============================================================
              if (controller.products.isEmpty) {
                return RefreshIndicator(
                  onRefresh: controller.fetchProducts,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 220),
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 70,
                        color: Color(0xFF9AA2B1),
                      ),
                      SizedBox(height: 12),
                      Center(
                        child: Text(
                          'No product found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final List<dynamic> products =
                  filteredProducts;

              // ============================================================
              // FILTER EMPTY
              // ============================================================
              if (products.isEmpty) {
                return RefreshIndicator(
                  onRefresh: controller.fetchProducts,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 180),
                      const Icon(
                        Icons.filter_alt_off_outlined,
                        size: 70,
                        color: Color(0xFF9AA2B1),
                      ),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          'No matching product found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: _resetFilters,
                          icon: const Icon(
                            Icons.restart_alt,
                          ),
                          label: const Text(
                            'Reset Filters',
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // ============================================================
              // PRODUCT GRID
              // ============================================================
              return RefreshIndicator(
                onRefresh: controller.fetchProducts,
                child: LayoutBuilder(
                  builder: (
                      BuildContext context,
                      BoxConstraints constraints,
                      ) {
                    int crossAxisCount = 1;

                    if (constraints.maxWidth >= 1400) {
                      crossAxisCount = 4;
                    } else if (constraints.maxWidth >= 1000) {
                      crossAxisCount = 3;
                    } else if (constraints.maxWidth >= 650) {
                      crossAxisCount = 2;
                    }

                    final bool mobileCards = constraints.maxWidth < 650;
                    final bool twoColumnPhone = constraints.maxWidth >= 350;
                    if (mobileCards) {
                      if (!twoColumnPhone) {
                        return ListView.separated(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 28),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: products.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) =>
                              _buildNarrowPhoneProductCard(products[index]),
                        );
                      }
                      return GridView.builder(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 28),
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 11,
                          mainAxisExtent: 330,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) =>
                            _buildMobileProductCard(products[index], compact: true),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                      physics: const AlwaysScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 482,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) => _buildProductCard(products[index]),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Responsive storefront card for phones; desktop product card is unchanged.
  Widget _buildMobileProductCard(dynamic item, {required bool compact}) {
    final String name = _getValue(item, 'description');
    final String code = _getValue(item, 'itemCode');
    final String business = _getValue(item, 'business');
    final String subCategory = _getValue(item, 'subCategory');
    final String status = _getValue(item, 'status');
    final String imageUrl = _getProductImageUrl(item);
    final double imageHeight = compact ? 129 : 155;
    final ProductModel? model = item is ProductModel ? item : null;

    Widget miniRow(IconData icon, String text) => Row(
      children: [
        Icon(icon, size: 12, color: const Color(0xFF8B93A3)),
        const SizedBox(width: 5),
        Expanded(
          child: Text(text.isEmpty ? '-' : text, maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Color(0xFF626D7D))),
        ),
      ],
    );

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17),
        side: const BorderSide(color: Color(0xFFE3E9F2))),
      child: InkWell(
        onTap: () => _openDetailPage(item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ColoredBox(
                  color: const Color(0xFFF8F9FB),
                  child: item is ProductModel && item.imageUrls.isNotEmpty
                      ? ProductImageCarousel(urls: item.imageUrls, height: imageHeight, compactControls: compact)
                      : _buildProductImage(imageUrl, height: imageHeight),
                ),
                if (status.trim().isNotEmpty)
                  Positioned(
                    top: 7, right: 7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.94),
                        borderRadius: BorderRadius.circular(20)),
                      child: Text(status, maxLines: 1,
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                          color: status.toUpperCase() == 'ACTIVE'
                            ? const Color(0xFF23864B) : const Color(0xFF64748B))),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(compact ? 9 : 13, 9,
                  compact ? 9 : 13, 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name.trim().isEmpty ? 'Product' : name,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: compact ? 12 : 15,
                        fontWeight: FontWeight.w800, height: 1.22)),
                    const SizedBox(height: 4),
                    Text('Item: ${code.isEmpty ? '-' : code}', maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, color: Color(0xFF798293))),
                    const SizedBox(height: 9),
                    miniRow(Icons.business_outlined, business),
                    const SizedBox(height: 4),
                    miniRow(Icons.category_outlined, subCategory),
                    const Spacer(),
                    if (model != null) ...[
                      Text('MOQ: ${model.moq.toStringAsFixed(model.moq == model.moq.roundToDouble() ? 0 : 2)} ${model.uom}',
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text('Size: ${model.sizeRange.isEmpty ? '-' : model.sizeRange}',
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                      const SizedBox(height: 9),
                    ],
                    Row(
                      children: [
                        if (model != null) ...[
                          SizedBox(
                            width: compact ? 38 : 46, height: 37,
                            child: IconButton.filledTonal(
                              tooltip: 'Add to Cart',
                              onPressed: () => Get.find<CartController>().addToCart(model),
                              icon: const Icon(Icons.add_shopping_cart_outlined, size: 19),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          const SizedBox(width: 5),
                        ],
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _openDetailPage(item),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              minimumSize: const Size(0, 37),
                              side: const BorderSide(color: Color(0xFFE2E7F2)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            child: Text(compact ? 'Details' : 'View Details',
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Under 350 logical pixels, use a horizontal list instead of a cramped grid.
  Widget _buildNarrowPhoneProductCard(dynamic item) {
    final String name = _getValue(item, 'description');
    final String code = _getValue(item, 'itemCode');
    final String business = _getValue(item, 'business');
    final String imageUrl = _getProductImageUrl(item);
    final ProductModel? model = item is ProductModel ? item : null;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Color(0xFFE3E9F2)),
      ),
      child: InkWell(
        onTap: () => _openDetailPage(item),
        child: SizedBox(
          height: 154,
          child: Row(
            children: [
              SizedBox(
                width: 112,
                child: ColoredBox(
                  color: const Color(0xFFF7F8FB),
                  child: model != null && model.imageUrls.isNotEmpty
                      ? ProductImageCarousel(
                          urls: model.imageUrls,
                          height: 154,
                          compactControls: true,
                        )
                      : _buildProductImage(imageUrl, height: 154),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name.isEmpty ? 'Product' : name,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12,
                          fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text('Item: $code', maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10,
                          color: Color(0xFF7A8394))),
                      const SizedBox(height: 5),
                      Text(business, maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11,
                          color: Color(0xFF596579))),
                      const Spacer(),
                      Row(
                        children: [
                          if (model != null) ...[
                            SizedBox(
                              width: 36, height: 34,
                              child: IconButton.filledTonal(
                                tooltip: 'Add to Cart',
                                onPressed: () =>
                                    Get.find<CartController>().addToCart(model),
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.add_shopping_cart_outlined, size: 18),
                              ),
                            ),
                            const SizedBox(width: 5),
                          ],
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _openDetailPage(item),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 34),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9)),
                              ),
                              child: const Text('Details',
                                style: TextStyle(fontSize: 11)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // PRODUCT CARD
  // ================================================================
  Widget _buildProductCard(dynamic item) {
    final String sl =
    _getValue(item, 'sl');

    final String productDescription =
    _getValue(item, 'description');

    final String itemCode =
    _getValue(item, 'itemCode');

    final String productCategory =
    _getValue(item, 'productCategory');

    final String business =
    _getValue(item, 'business');

    final String subCategory =
    _getValue(item, 'subCategory');

    final String organizationId =
    _getValue(item, 'organizationId');

    final String organizationCode =
    _getValue(item, 'organizationCode');

    final String status =
    _getValue(item, 'status');

    final String detailsCount =
    _getValue(item, 'detailsCount');

    final String imageUrl =
    _getProductImageUrl(item);

    final bool isActive =
        status.trim().toUpperCase() == 'ACTIVE';

    final String organizationText =
    organizationCode.trim().isNotEmpty
        ? organizationCode
        : organizationId;

    return _HoverLift(
      child: Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: Color(0xFFE3E6EC),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          _openDetailPage(item);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========================================================
            // PRODUCT IMAGE
            // ========================================================
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: item is ProductModel && item.imageUrls.isNotEmpty
                   ? ProductImageCarousel(urls: item.imageUrls)
                   : _buildProductImage(imageUrl),
            ),

            // ========================================================
            // PRODUCT DETAILS
            // ========================================================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // PRODUCT DESCRIPTION + ITEM CODE
                    // ==================================================
                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.10),
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 21,
                            color: Theme.of(context)
                                .colorScheme
                                .primary,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              // =========================================
                              // PRODUCT DESCRIPTION
                              // =========================================
                              Text(
                                productDescription
                                    .trim()
                                    .isEmpty
                                    ? 'Product Description'
                                    : productDescription,
                                maxLines: 2,
                                overflow:
                                TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                  FontWeight.w800,
                                  height: 1.2,
                                ),
                              ),

                              const SizedBox(height: 4),

                              // =========================================
                              // ITEM CODE
                              // =========================================
                              Text(
                                itemCode.trim().isEmpty
                                    ? '-'
                                    : 'Item Code: $itemCode',
                                maxLines: 1,
                                overflow:
                                TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color:
                                  Color(0xFF727985),
                                  fontWeight:
                                  FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 6),

                        if (status.trim().isNotEmpty)
                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(
                                0xFFEAF7EF,
                              )
                                  : const Color(
                                0xFFF1F2F4,
                              ),
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight:
                                FontWeight.w700,
                                color: isActive
                                    ? const Color(
                                  0xFF23864B,
                                )
                                    : const Color(
                                  0xFF777E89,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    const Divider(
                      height: 1,
                      color: Color(0xFFE8EAEE),
                    ),

                    const SizedBox(height: 12),

                    // ==================================================
                    // BUSINESS + SUB CATEGORY
                    // ==================================================
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            icon:
                            Icons.business_outlined,
                            title: 'Business',
                            value: business,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildInfoItem(
                            icon:
                            Icons.category_outlined,
                            title: 'Sub Category',
                            value: subCategory,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ==================================================
                    // PRODUCT CATEGORY + ORGANIZATION
                    // ==================================================
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            icon: Icons
                                .sell_outlined,
                            title:
                            'Product Category',
                            value: productCategory,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildInfoItem(
                            icon: Icons
                                .apartment_outlined,
                            title:
                            'Organization',
                            value:
                            organizationText,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                     if (item is ProductModel)
                       Padding(
                         padding: const EdgeInsets.only(bottom: 7),
                         child: Row(
                           children: [
                             Expanded(
                               child: Text(
                                 'MOQ: ${item.moq.toStringAsFixed(item.moq == item.moq.roundToDouble() ? 0 : 2)}',
                                 style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                 overflow: TextOverflow.ellipsis,
                               ),
                             ),
                             Expanded(
                               child: Text(
                                 'Size: ${item.sizeRange.isEmpty ? '-' : item.sizeRange}',
                                 style: const TextStyle(fontSize: 11),
                                 overflow: TextOverflow.ellipsis,
                                 textAlign: TextAlign.end,
                               ),
                             ),
                           ],
                         ),
                       ),

                    // ==================================================
                    // FOOTER: explicit quick-add and detail access.
                    // ==================================================
                    if (sl.trim().isNotEmpty ||
                        (detailsCount.trim().isNotEmpty && detailsCount != '0'))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          [
                            if (sl.trim().isNotEmpty) 'SL: $sl',
                            if (detailsCount.trim().isNotEmpty && detailsCount != '0')
                              'Items: $detailsCount',
                          ].join('   '),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF9299A5),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    Row(
                      children: [
                        if (item is ProductModel) ...[
                          Expanded(
                            flex: 6,
                            child: FilledButton.tonalIcon(
                              onPressed: () => Get.find<CartController>().addToCart(item),
                              icon: const Icon(Icons.add_shopping_cart_outlined, size: 17),
                              label: const Text(
                                'Add to Cart',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12),
                              ),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(0, 38),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          flex: 5,
                          child: TextButton(
                            onPressed: () => _openDetailPage(item),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              minimumSize: const Size(0, 38),
                            ),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'View Details',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(width: 3),
                                  Icon(Icons.arrow_forward_ios_rounded, size: 11),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  // ================================================================
  // INFO ITEM
  // ================================================================
  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(
              0xFFF4F6F8,
            ),
            borderRadius:
            BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 15,
            color: const Color(
              0xFF737B88,
            ),
          ),
        ),

        const SizedBox(width: 7),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 9,
                  color:
                  Color(0xFF8A919D),
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value.trim().isEmpty
                    ? '-'
                    : value,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight:
                  FontWeight.w600,
                  color:
                  Color(0xFF252A33),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================================================================
  // FILTER DRAWER
  // ================================================================
  Widget _buildFilterDrawer() {
    final List<String> categories =
        categoryList;

    final List<String> subCategories =
        subCategoryList;

    final String? safeCategory =
    _selectedCategory != null &&
        categories.contains(
          _selectedCategory,
        )
        ? _selectedCategory
        : null;

    final String? safeSubCategory =
    _selectedSubCategory != null &&
        subCategories.contains(
          _selectedSubCategory,
        )
        ? _selectedSubCategory
        : null;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // ========================================================
            // HEADER
            // ========================================================
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.fromLTRB(
                20,
                20,
                16,
                18,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.10),
                      borderRadius:
                      BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Filter Products',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        // Count products from the same reactive list used
                        // by the dashboard; never use cart item quantity.
                        Obx(() {
                          final int totalProducts = controller.products.length;
                          final bool loading = controller.isLoading.value &&
                              totalProducts == 0;
                          final int matchingProducts = _hasFilter
                              ? filteredProducts.length
                              : totalProducts;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                loading
                                    ? 'Loading products...'
                                    : 'Total Products: $totalProducts',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF576174),
                                ),
                              ),
                              if (!loading && _hasFilter)
                                Text(
                                  'Matching Products: $matchingProducts',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF7A8190),
                                  ),
                                ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop();
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // ========================================================
            // FILTER CONTENT
            // ========================================================
            Expanded(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Search',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller:
                      _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchText =
                              value;
                        });
                      },
                      decoration:
                      InputDecoration(
                        hintText:
                        'Description, item code, category...',
                        prefixIcon:
                        const Icon(
                          Icons.search_rounded,
                        ),
                        suffixIcon:
                        _searchText.isNotEmpty
                            ? IconButton(
                          onPressed:
                              () {
                            _searchController
                                .clear();

                            setState(
                                  () {
                                _searchText =
                                '';
                              },
                            );
                          },
                          icon:
                          const Icon(
                            Icons
                                .close_rounded,
                          ),
                        )
                            : null,
                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                            12,
                          ),
                        ),
                        enabledBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                            12,
                          ),
                          borderSide:
                          const BorderSide(
                            color: Color(
                              0xFFE3E6EC,
                            ),
                          ),
                        ),
                        contentPadding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // CATEGORY
                    // ==================================================
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    DropdownButtonFormField<
                        String>(
                      key: ValueKey<String>('drawer-category-${safeCategory ?? ''}'),
                      value: safeCategory ?? '',
                      isExpanded: true,
                      hint: const Text(
                        'All Categories',
                      ),
                      decoration:
                      InputDecoration(
                        prefixIcon:
                        const Icon(
                          Icons
                              .category_outlined,
                        ),
                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                            12,
                          ),
                        ),
                        enabledBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                            12,
                          ),
                          borderSide:
                          const BorderSide(
                            color: Color(
                              0xFFE3E6EC,
                            ),
                          ),
                        ),
                      ),
                      items: <DropdownMenuItem<String>>[
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('All Categories'),
                        ),
                        ...categories.map(
                            (
                            category,
                            ) =>
                            DropdownMenuItem<
                                String>(
                              value: category,
                              child: Text(
                                category,
                                overflow:
                                TextOverflow
                                    .ellipsis,
                              ),
                            ),
                      ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory =
                              value == null || value.isEmpty ? null : value;
                          _selectedSubCategory =
                          null;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // SUB CATEGORY
                    // ==================================================
                    const Text(
                      'Sub Category',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    DropdownButtonFormField<
                        String>(
                      key: ValueKey<String>(
                        'drawer-sub-${safeCategory ?? ''}-${safeSubCategory ?? ''}',
                      ),
                      value: safeSubCategory ?? '',
                      isExpanded: true,
                      hint: Text(
                        'All Sub Categories',
                      ),
                      decoration:
                      InputDecoration(
                        prefixIcon:
                        const Icon(
                          Icons
                              .category_outlined,
                        ),
                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                            12,
                          ),
                        ),
                        enabledBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                            12,
                          ),
                          borderSide:
                          const BorderSide(
                            color: Color(
                              0xFFE3E6EC,
                            ),
                          ),
                        ),
                      ),
                      items: <DropdownMenuItem<String>>[
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('All Sub Categories'),
                        ),
                        ...subCategories.map(
                            (
                            category,
                            ) =>
                            DropdownMenuItem<
                                String>(
                              value: category,
                              child: Text(
                                category,
                                overflow:
                                TextOverflow
                                    .ellipsis,
                              ),
                            ),
                      ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedSubCategory =
                              value == null || value.isEmpty ? null : value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ========================================================
            // BOTTOM BUTTONS
            // ========================================================
            Container(
              padding:
              const EdgeInsets.all(16),
              decoration:
              const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(
                      0xFFE7E9EE,
                    ),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child:
                    OutlinedButton.icon(
                      onPressed: _hasFilter
                          ? _resetFilters
                          : null,
                      icon: const Icon(
                        Icons
                            .restart_alt_rounded,
                      ),
                      label:
                      const Text('Reset'),
                      style:
                      OutlinedButton
                          .styleFrom(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child:
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context)
                            .pop();
                      },
                      icon: const Icon(
                        Icons.check_rounded,
                      ),
                      label:
                      const Text('Done'),
                      style:
                      ElevatedButton
                          .styleFrom(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          vertical: 14,
                        ),
                      ),
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
}

// ==================================================================
// ERROR VIEW
// ==================================================================


class _HoverLift extends StatefulWidget {
  final Widget child;

  const _HoverLift({required this.child});

  @override
  State<_HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<_HoverLift> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _hovered ? -5 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _hovered
                  ? const Color(0x1F0F172A)
                  : const Color(0x0D0F172A),
              blurRadius: _hovered ? 28 : 14,
              offset: Offset(0, _hovered ? 12 : 6),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 64,
              color:
              Color(0xFF9AA2B1),
            ),

            const SizedBox(height: 16),

            Text(
              message,
              textAlign:
              TextAlign.center,
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh,
              ),
              label:
              const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}