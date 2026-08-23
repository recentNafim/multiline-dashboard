import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../controllers/product_controller.dart';
import '../widgets/cart_icon_button.dart';
import 'product_detail_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ProductController controller = Get.find<ProductController>();

  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';

  // API category = BUSINESS
  String? _selectedCategory;
  String? _selectedSubCategory;

  // Updated GET API top-level filter metadata.
  final List<String> _apiCategoryList = <String>[];
  final Map<String, List<String>> _apiSubCategoryMap =
  <String, List<String>>{};

  bool _isFilterMetaLoading = false;

  static const String _productApiUrl =
      'https://e501.sihirbox.com:8071/ords/rpro/'
      'multiline-display-room/item-upload';

  // ================================================================
  // IMAGE URL
  // ================================================================
  static const String _serverBaseUrl =
      'https://e501.sihirbox.com:8071';

  static const String _imageBaseUrl =
      'https://e501.sihirbox.com:8071/ords/rpro/image_service/get/';

  @override
  void initState() {
    super.initState();

    // Category/Sub Category list comes from the updated GET API.
    _loadCategoryAndSubCategory();
  }

  // ================================================================
  // LOAD CATEGORY + CATEGORY-WISE SUB CATEGORY
  // ================================================================
  Future<void> _loadCategoryAndSubCategory() async {
    if (_isFilterMetaLoading) {
      return;
    }

    setState(() {
      _isFilterMetaLoading = true;
    });

    try {
      // Only 1 master row is enough here because category metadata
      // is returned at the top level of the response.
      final Uri uri = Uri.parse(_productApiUrl).replace(
        queryParameters: const {
          'p_page': '1',
          'p_limit': '1',
        },
      );

      debugPrint('==========================================');
      debugPrint('LOAD CATEGORY / SUB CATEGORY');
      debugPrint('URL => $uri');
      debugPrint('==========================================');

      final http.Response response = await http
          .get(
        uri,
        headers: const {
          'Accept': 'application/json',
        },
      )
          .timeout(
        const Duration(seconds: 60),
      );

      debugPrint(
        'CATEGORY API STATUS => ${response.statusCode}',
      );

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          'HTTP ${response.statusCode}',
        );
      }

      final dynamic decoded =
      jsonDecode(response.body);

      if (decoded is! Map) {
        throw Exception(
          'Invalid category API response.',
        );
      }

      // --------------------------------------------------------------
      // CATEGORY LIST
      // --------------------------------------------------------------
      final List<String> categories =
      <String>[];

      final dynamic rawCategories =
      decoded['category_list'];

      if (rawCategories is List) {
        for (final dynamic value
        in rawCategories) {
          final String category =
              value?.toString().trim() ?? '';

          if (category.isNotEmpty &&
              !categories.contains(category)) {
            categories.add(category);
          }
        }
      }

      categories.sort(
            (a, b) => a
            .toLowerCase()
            .compareTo(
          b.toLowerCase(),
        ),
      );

      // --------------------------------------------------------------
      // CATEGORY-WISE SUB CATEGORY
      // --------------------------------------------------------------
      final Map<String, List<String>>
      subCategoryMap =
      <String, List<String>>{};

      final dynamic rawCategoryWise =
      decoded[
      'category_wise_sub_category_list'];

      if (rawCategoryWise is List) {
        for (final dynamic row
        in rawCategoryWise) {
          if (row is! Map) {
            continue;
          }

          final String category =
              row['category']
                  ?.toString()
                  .trim() ??
                  '';

          if (category.isEmpty) {
            continue;
          }

          final List<String> subCategories =
          <String>[];

          final dynamic rawSubs =
          row['sub_categories'];

          if (rawSubs is List) {
            for (final dynamic subValue
            in rawSubs) {
              final String subCategory =
                  subValue
                      ?.toString()
                      .trim() ??
                      '';

              if (subCategory.isNotEmpty &&
                  !subCategories.contains(
                    subCategory,
                  )) {
                subCategories.add(
                  subCategory,
                );
              }
            }
          }

          subCategories.sort(
                (a, b) => a
                .toLowerCase()
                .compareTo(
              b.toLowerCase(),
            ),
          );

          subCategoryMap[category] =
              subCategories;
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _apiCategoryList
          ..clear()
          ..addAll(categories);

        _apiSubCategoryMap
          ..clear()
          ..addAll(subCategoryMap);

        // If a refresh removes the selected category, clear filters.
        if (_selectedCategory != null &&
            !_apiCategoryList.contains(
              _selectedCategory,
            )) {
          _selectedCategory = null;
          _selectedSubCategory = null;
        }

        if (_selectedCategory != null &&
            _selectedSubCategory != null) {
          final List<String> validSubs =
              _apiSubCategoryMap[
              _selectedCategory] ??
                  const <String>[];

          if (!validSubs.contains(
            _selectedSubCategory,
          )) {
            _selectedSubCategory = null;
          }
        }
      });

      debugPrint(
        'CATEGORY COUNT => ${_apiCategoryList.length}',
      );

      debugPrint(
        'CATEGORY MAP => $_apiSubCategoryMap',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'CATEGORY API ERROR => $e',
      );
      debugPrint(
        stackTrace.toString(),
      );

      // No blocking error:
      // getters below automatically fall back to controller.products.
    } finally {
      if (mounted) {
        setState(() {
          _isFilterMetaLoading = false;
        });
      }
    }
  }

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
  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.trim().isEmpty) {
      return Container(
        width: double.infinity,
        height: 155,
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
      height: 155,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
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

      final bool matchesCategory =
          _selectedCategory == null ||
              _selectedCategory!.isEmpty ||
              business == _selectedCategory;

      final bool matchesSubCategory =
          _selectedSubCategory == null ||
              _selectedSubCategory!.isEmpty ||
              subCategory == _selectedSubCategory;

      return matchesSearch &&
          matchesCategory &&
          matchesSubCategory;
    }).toList();
  }

  // ================================================================
  // CATEGORY LIST
  //
  // API category = master BUSINESS
  // ================================================================
  List<String> get categoryList {
    if (_apiCategoryList.isNotEmpty) {
      return List<String>.from(
        _apiCategoryList,
      );
    }

    // Fallback if metadata API fails.
    final List<String> list =
    controller.products
        .map(
          (item) => _getValue(
        item,
        'business',
      ),
    )
        .where(
          (value) =>
      value.trim().isNotEmpty,
    )
        .toSet()
        .toList();

    list.sort(
          (a, b) => a
          .toLowerCase()
          .compareTo(
        b.toLowerCase(),
      ),
    );

    return list;
  }

  // ================================================================
  // SELECTED CATEGORY-WISE SUB CATEGORY LIST
  // ================================================================
  List<String> get subCategoryList {
    final String? category =
        _selectedCategory;

    if (category == null ||
        category.trim().isEmpty) {
      return const <String>[];
    }

    // First priority: updated GET API metadata.
    final List<String>? apiList =
    _apiSubCategoryMap[category];

    if (apiList != null) {
      return List<String>.from(
        apiList,
      );
    }

    // Fallback: derive from loaded products.
    final List<String> list =
    controller.products
        .where(
          (item) =>
      _getValue(
        item,
        'business',
      ) ==
          category,
    )
        .map(
          (item) => _getValue(
        item,
        'subCategory',
      ),
    )
        .where(
          (value) =>
      value.trim().isNotEmpty,
    )
        .toSet()
        .toList();

    list.sort(
          (a, b) => a
          .toLowerCase()
          .compareTo(
        b.toLowerCase(),
      ),
    );

    return list;
  }

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
  Widget _buildTopFilterBar() {
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

    Widget searchField = SizedBox(
      width: 330,
      child: TextField(
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
      ),
    );

    Widget categoryDropdown = SizedBox(
      width: 220,
      child:
      DropdownButtonFormField<String>(
        value: safeCategory,
        isExpanded: true,
        hint: Text(
          _isFilterMetaLoading
              ? 'Loading...'
              : 'All Categories',
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
        items: categories
            .map(
              (category) =>
              DropdownMenuItem<String>(
                value: category,
                child: Text(
                  category,
                  overflow:
                  TextOverflow.ellipsis,
                ),
              ),
        )
            .toList(),
        onChanged:
        _isFilterMetaLoading
            ? null
            : (value) {
          setState(() {
            _selectedCategory =
                value;

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
        value: safeSubCategory,
        isExpanded: true,
        hint: Text(
          safeCategory == null
              ? 'Select Category First'
              : subCategories.isEmpty
              ? 'No Sub Category'
              : 'All Sub Categories',
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
        items: subCategories
            .map(
              (subCategory) =>
              DropdownMenuItem<String>(
                value: subCategory,
                child: Text(
                  subCategory,
                  overflow:
                  TextOverflow.ellipsis,
                ),
              ),
        )
            .toList(),
        onChanged: safeCategory == null
            ? null
            : (value) {
          setState(() {
            _selectedSubCategory =
                value;
          });
        },
      ),
    );

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.fromLTRB(
        16,
        14,
        16,
        10,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F8FA),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE8EAEE),
          ),
        ),
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

  // ================================================================
  // BUILD
  // ================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SizedBox(
        width: 330,
        child: _buildFilterDrawer(),
      ),

      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Products',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            Text(
              'Available display room products',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF7A8190),
              ),
            ),
          ],
        ),
        actions: const [
          CartIconButton(),
          SizedBox(width: 8),
        ],
      ),

      body: Column(
        children: [
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

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      physics:
                      const AlwaysScrollableScrollPhysics(),
                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 410,
                      ),
                      itemCount: products.length,
                      itemBuilder: (
                          BuildContext context,
                          int index,
                          ) {
                        return _buildProductCard(
                          products[index],
                        );
                      },
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

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: Color(0xFFE3E6EC),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
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
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
              child: _buildProductImage(
                imageUrl,
              ),
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

                    // ==================================================
                    // FOOTER
                    // ==================================================
                    Row(
                      children: [
                        if (sl.trim().isNotEmpty)
                          Text(
                            'SL: $sl',
                            style: const TextStyle(
                              fontSize: 10,
                              color:
                              Color(0xFF9299A5),
                              fontWeight:
                              FontWeight.w500,
                            ),
                          ),

                        if (detailsCount
                            .trim()
                            .isNotEmpty &&
                            detailsCount != '0') ...[
                          const SizedBox(width: 10),
                          Text(
                            'Items: $detailsCount',
                            style: const TextStyle(
                              fontSize: 10,
                              color:
                              Color(0xFF9299A5),
                              fontWeight:
                              FontWeight.w500,
                            ),
                          ),
                        ],

                        const Spacer(),

                        Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                            FontWeight.w700,
                            color: Theme.of(context)
                                .colorScheme
                                .primary,
                          ),
                        ),

                        const SizedBox(width: 4),

                        Icon(
                          Icons
                              .arrow_forward_ios_rounded,
                          size: 11,
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
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

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filter Products',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Find products easily',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(
                              0xFF7A8190,
                            ),
                          ),
                        ),
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
                      value: safeCategory,
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
                      items: categories
                          .map(
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
                      )
                          .toList(),
                      onChanged:
                      _isFilterMetaLoading
                          ? null
                          : (value) {
                        setState(() {
                          _selectedCategory =
                              value;
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
                      value:
                      safeSubCategory,
                      isExpanded: true,
                      hint: Text(
                        safeCategory == null
                            ? 'Select Category First'
                            : subCategories.isEmpty
                            ? 'No Sub Category'
                            : 'All Sub Categories',
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
                      items: subCategories
                          .map(
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
                      )
                          .toList(),
                      onChanged:
                      safeCategory == null
                          ? null
                          : (value) {
                        setState(() {
                          _selectedSubCategory =
                              value;
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