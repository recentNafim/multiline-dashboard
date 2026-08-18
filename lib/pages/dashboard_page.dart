

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/product_controller.dart';
import '../widgets/cart_icon_button.dart';
import '../widgets/product_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ProductController controller = Get.find<ProductController>();

  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';
  String? _selectedBusiness;
  String? _selectedCategory;

  // ================================================================
  // GET PRODUCT VALUE SAFELY
  // ================================================================
  String _getValue(dynamic product, String field) {
    try {
      switch (field) {
        case 'itemName':
          return product.itemName?.toString() ?? '';

        case 'itemCode':
          return product.itemCode?.toString() ?? '';

        case 'business':
          return product.business?.toString() ?? '';

        case 'subCategory':
          return product.subCategory?.toString() ?? '';

        case 'productCategory':
          return product.productCategory?.toString() ?? '';

        case 'color':
          return product.color?.toString() ?? '';

        default:
          return '';
      }
    } catch (_) {
      return '';
    }
  }

  // ================================================================
  // FILTERED PRODUCTS
  // ================================================================
  List<dynamic> get filteredProducts {
    return controller.products.where((product) {
      final String itemName =
      _getValue(product, 'itemName').toLowerCase();

      final String itemCode =
      _getValue(product, 'itemCode').toLowerCase();

      final String business =
      _getValue(product, 'business');

      final String subCategory =
      _getValue(product, 'subCategory').toLowerCase();

      final String productCategory =
      _getValue(product, 'productCategory');

      final String color =
      _getValue(product, 'color').toLowerCase();

      final String search =
      _searchText.trim().toLowerCase();

      // --------------------------------------------------------------
      // SEARCH FILTER
      // --------------------------------------------------------------
      final bool matchesSearch =
          search.isEmpty ||
              itemName.contains(search) ||
              itemCode.contains(search) ||
              business.toLowerCase().contains(search) ||
              subCategory.contains(search) ||
              productCategory.toLowerCase().contains(search) ||
              color.contains(search);

      // --------------------------------------------------------------
      // BUSINESS FILTER
      // --------------------------------------------------------------
      final bool matchesBusiness =
          _selectedBusiness == null ||
              _selectedBusiness!.isEmpty ||
              business == _selectedBusiness;

      // --------------------------------------------------------------
      // CATEGORY FILTER
      // --------------------------------------------------------------
      final bool matchesCategory =
          _selectedCategory == null ||
              _selectedCategory!.isEmpty ||
              productCategory == _selectedCategory;

      return matchesSearch &&
          matchesBusiness &&
          matchesCategory;
    }).toList();
  }

  // ================================================================
  // UNIQUE BUSINESS LIST
  // ================================================================
  List<String> get businessList {
    final List<String> list = controller.products
        .map(
          (product) => _getValue(
        product,
        'business',
      ),
    )
        .where(
          (value) => value.trim().isNotEmpty,
    )
        .toSet()
        .toList();

    list.sort();

    return list;
  }

  // ================================================================
  // UNIQUE CATEGORY LIST
  // ================================================================
  List<String> get categoryList {
    final List<String> list = controller.products
        .map(
          (product) => _getValue(
        product,
        'productCategory',
      ),
    )
        .where(
          (value) => value.trim().isNotEmpty,
    )
        .toSet()
        .toList();

    list.sort();

    return list;
  }

  // ================================================================
  // RESET FILTERS
  // ================================================================
  void _resetFilters() {
    _searchController.clear();

    setState(() {
      _searchText = '';
      _selectedBusiness = null;
      _selectedCategory = null;
    });
  }

  bool get _hasFilter {
    return _searchText.trim().isNotEmpty ||
        _selectedBusiness != null ||
        _selectedCategory != null;
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
      // ==============================================================
      // LEFT FILTER DRAWER
      // ==============================================================
      drawer: SizedBox(
        width: 330,
        child: _buildFilterDrawer(),
      ),

      // ==============================================================
      // APP BAR
      // ==============================================================
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Display Room',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            Text(
              'Available products',
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

      // ==============================================================
      // BODY
      // ==============================================================
      body: Obx(() {
        // ------------------------------------------------------------
        // LOADING
        // ------------------------------------------------------------
        if (controller.isLoading.value &&
            controller.products.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // ------------------------------------------------------------
        // ERROR
        // ------------------------------------------------------------
        if (controller.errorMessage.value.isNotEmpty &&
            controller.products.isEmpty) {
          return _ErrorView(
            message: controller.errorMessage.value,
            onRetry: controller.fetchProducts,
          );
        }

        // ------------------------------------------------------------
        // API PRODUCT LIST EMPTY
        // ------------------------------------------------------------
        if (controller.products.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.fetchProducts,
            child: ListView(
              physics:
              const AlwaysScrollableScrollPhysics(),
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
                    'No products found',
                  ),
                ),
              ],
            ),
          );
        }

        final List<dynamic> products =
            filteredProducts;

        // ------------------------------------------------------------
        // FILTER RESULT EMPTY
        // ------------------------------------------------------------
        if (products.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.fetchProducts,
            child: ListView(
              physics:
              const AlwaysScrollableScrollPhysics(),
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
                    'No matching products found',
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

        // ------------------------------------------------------------
        // PRODUCT GRID
        // ------------------------------------------------------------
        return RefreshIndicator(
          onRefresh: controller.fetchProducts,
          child: LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 2;

              if (constraints.maxWidth >= 1200) {
                crossAxisCount = 5;
              } else if (constraints.maxWidth >= 900) {
                crossAxisCount = 4;
              } else if (constraints.maxWidth >= 650) {
                crossAxisCount = 3;
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),

                physics:
                const AlwaysScrollableScrollPhysics(),

                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.72,
                ),

                itemCount: products.length,

                itemBuilder: (_, index) {
                  return ProductCard(
                    product: products[index],
                  );
                },
              );
            },
          ),
        );
      }),
    );
  }

  // ================================================================
  // FILTER DRAWER
  // ================================================================
  Widget _buildFilterDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // ========================================================
            // HEADER
            // ========================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                16,
                18,
              ),
              child: Row(
                children: [
                  // --------------------------------------------------
                  // FILTER ICON
                  // --------------------------------------------------
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.10),
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // --------------------------------------------------
                  // TITLE
                  // --------------------------------------------------
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
                            color:
                            Color(0xFF7A8190),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --------------------------------------------------
                  // CLOSE BUTTON
                  // --------------------------------------------------
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
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
                    // ==================================================
                    // SEARCH TITLE
                    // ==================================================
                    const Text(
                      'Search',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ==================================================
                    // SEARCH FIELD
                    // ==================================================
                    TextField(
                      controller:
                      _searchController,

                      onChanged: (value) {
                        setState(() {
                          _searchText = value;
                        });
                      },

                      decoration: InputDecoration(
                        hintText:
                        'Name, code, color...',

                        prefixIcon:
                        const Icon(
                          Icons.search_rounded,
                        ),

                        suffixIcon:
                        _searchText.isNotEmpty
                            ? IconButton(
                          onPressed: () {
                            _searchController
                                .clear();

                            setState(() {
                              _searchText =
                              '';
                            });
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
                              .circular(12),
                        ),

                        enabledBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius
                              .circular(12),
                          borderSide:
                          const BorderSide(
                            color:
                            Color(
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
                    // BUSINESS TITLE
                    // ==================================================
                    const Text(
                      'Business',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ==================================================
                    // BUSINESS DROPDOWN
                    // ==================================================
                    DropdownButtonFormField<String>(
                      value:
                      _selectedBusiness,

                      isExpanded: true,

                      hint: const Text(
                        'All Businesses',
                      ),

                      decoration:
                      InputDecoration(
                        prefixIcon:
                        const Icon(
                          Icons
                              .business_outlined,
                        ),

                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius
                              .circular(12),
                        ),

                        enabledBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius
                              .circular(12),
                          borderSide:
                          const BorderSide(
                            color:
                            Color(
                              0xFFE3E6EC,
                            ),
                          ),
                        ),
                      ),

                      items:
                      businessList.map(
                            (business) {
                          return DropdownMenuItem<
                              String>(
                            value: business,
                            child: Text(
                              business,
                              overflow:
                              TextOverflow
                                  .ellipsis,
                            ),
                          );
                        },
                      ).toList(),

                      onChanged: (value) {
                        setState(() {
                          _selectedBusiness =
                              value;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // CATEGORY TITLE
                    // ==================================================
                    const Text(
                      'Product Category',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ==================================================
                    // CATEGORY DROPDOWN
                    // ==================================================
                    DropdownButtonFormField<String>(
                      value:
                      _selectedCategory,

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
                              .circular(12),
                        ),

                        enabledBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius
                              .circular(12),
                          borderSide:
                          const BorderSide(
                            color:
                            Color(
                              0xFFE3E6EC,
                            ),
                          ),
                        ),
                      ),

                      items:
                      categoryList.map(
                            (category) {
                          return DropdownMenuItem<
                              String>(
                            value: category,
                            child: Text(
                              category,
                              overflow:
                              TextOverflow
                                  .ellipsis,
                            ),
                          );
                        },
                      ).toList(),

                      onChanged: (value) {
                        setState(() {
                          _selectedCategory =
                              value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ========================================================
            // BOTTOM ACTION BUTTONS
            // ========================================================
            Container(
              padding:
              const EdgeInsets.all(16),
              decoration:
              const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color:
                    Color(0xFFE7E9EE),
                  ),
                ),
              ),
              child: Row(
                children: [
                  // --------------------------------------------------
                  // RESET
                  // --------------------------------------------------
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
                      style: OutlinedButton
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

                  // --------------------------------------------------
                  // DONE
                  // --------------------------------------------------
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
                      style: ElevatedButton
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