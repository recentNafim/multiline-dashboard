//
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../controllers/product_controller.dart';
// import '../widgets/cart_icon_button.dart';
// import '../widgets/product_card.dart';
//
// class DashboardPage extends StatefulWidget {
//   const DashboardPage({super.key});
//
//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }
//
// class _DashboardPageState extends State<DashboardPage> {
//   final ProductController controller = Get.find<ProductController>();
//
//   final TextEditingController _searchController = TextEditingController();
//
//   String _searchText = '';
//   String? _selectedBusiness;
//   String? _selectedCategory;
//
//   // ================================================================
//   // GET PRODUCT VALUE SAFELY
//   // ================================================================
//   String _getValue(dynamic product, String field) {
//     try {
//       switch (field) {
//         case 'itemName':
//           return product.itemName?.toString() ?? '';
//
//         case 'itemCode':
//           return product.itemCode?.toString() ?? '';
//
//         case 'business':
//           return product.business?.toString() ?? '';
//
//         case 'subCategory':
//           return product.subCategory?.toString() ?? '';
//
//         case 'productCategory':
//           return product.productCategory?.toString() ?? '';
//
//         case 'color':
//           return product.color?.toString() ?? '';
//
//         default:
//           return '';
//       }
//     } catch (_) {
//       return '';
//     }
//   }
//
//   // ================================================================
//   // FILTERED PRODUCTS
//   // ================================================================
//   List<dynamic> get filteredProducts {
//     return controller.products.where((product) {
//       final String itemName =
//       _getValue(product, 'itemName').toLowerCase();
//
//       final String itemCode =
//       _getValue(product, 'itemCode').toLowerCase();
//
//       final String business =
//       _getValue(product, 'business');
//
//       final String subCategory =
//       _getValue(product, 'subCategory').toLowerCase();
//
//       final String productCategory =
//       _getValue(product, 'productCategory');
//
//       final String color =
//       _getValue(product, 'color').toLowerCase();
//
//       final String search =
//       _searchText.trim().toLowerCase();
//
//       // --------------------------------------------------------------
//       // SEARCH FILTER
//       // --------------------------------------------------------------
//       final bool matchesSearch =
//           search.isEmpty ||
//               itemName.contains(search) ||
//               itemCode.contains(search) ||
//               business.toLowerCase().contains(search) ||
//               subCategory.contains(search) ||
//               productCategory.toLowerCase().contains(search) ||
//               color.contains(search);
//
//       // --------------------------------------------------------------
//       // BUSINESS FILTER
//       // --------------------------------------------------------------
//       final bool matchesBusiness =
//           _selectedBusiness == null ||
//               _selectedBusiness!.isEmpty ||
//               business == _selectedBusiness;
//
//       // --------------------------------------------------------------
//       // CATEGORY FILTER
//       // --------------------------------------------------------------
//       final bool matchesCategory =
//           _selectedCategory == null ||
//               _selectedCategory!.isEmpty ||
//               productCategory == _selectedCategory;
//
//       return matchesSearch &&
//           matchesBusiness &&
//           matchesCategory;
//     }).toList();
//   }
//
//   // ================================================================
//   // UNIQUE BUSINESS LIST
//   // ================================================================
//   List<String> get businessList {
//     final List<String> list = controller.products
//         .map(
//           (product) => _getValue(
//         product,
//         'business',
//       ),
//     )
//         .where(
//           (value) => value.trim().isNotEmpty,
//     )
//         .toSet()
//         .toList();
//
//     list.sort();
//
//     return list;
//   }
//
//   // ================================================================
//   // UNIQUE CATEGORY LIST
//   // ================================================================
//   List<String> get categoryList {
//     final List<String> list = controller.products
//         .map(
//           (product) => _getValue(
//         product,
//         'productCategory',
//       ),
//     )
//         .where(
//           (value) => value.trim().isNotEmpty,
//     )
//         .toSet()
//         .toList();
//
//     list.sort();
//
//     return list;
//   }
//
//   // ================================================================
//   // RESET FILTERS
//   // ================================================================
//   void _resetFilters() {
//     _searchController.clear();
//
//     setState(() {
//       _searchText = '';
//       _selectedBusiness = null;
//       _selectedCategory = null;
//     });
//   }
//
//   bool get _hasFilter {
//     return _searchText.trim().isNotEmpty ||
//         _selectedBusiness != null ||
//         _selectedCategory != null;
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   // ================================================================
//   // BUILD
//   // ================================================================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // ==============================================================
//       // LEFT FILTER DRAWER
//       // ==============================================================
//       drawer: SizedBox(
//         width: 330,
//         child: _buildFilterDrawer(),
//       ),
//
//       // ==============================================================
//       // APP BAR
//       // ==============================================================
//       appBar: AppBar(
//         title: const Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Display Room',
//               style: TextStyle(
//                 fontWeight: FontWeight.w800,
//                 fontSize: 20,
//               ),
//             ),
//             Text(
//               'Available products',
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w400,
//                 color: Color(0xFF7A8190),
//               ),
//             ),
//           ],
//         ),
//         actions: const [
//           CartIconButton(),
//           SizedBox(width: 8),
//         ],
//       ),
//
//       // ==============================================================
//       // BODY
//       // ==============================================================
//       body: Obx(() {
//         // ------------------------------------------------------------
//         // LOADING
//         // ------------------------------------------------------------
//         if (controller.isLoading.value &&
//             controller.products.isEmpty) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         }
//
//         // ------------------------------------------------------------
//         // ERROR
//         // ------------------------------------------------------------
//         if (controller.errorMessage.value.isNotEmpty &&
//             controller.products.isEmpty) {
//           return _ErrorView(
//             message: controller.errorMessage.value,
//             onRetry: controller.fetchProducts,
//           );
//         }
//
//         // ------------------------------------------------------------
//         // API PRODUCT LIST EMPTY
//         // ------------------------------------------------------------
//         if (controller.products.isEmpty) {
//           return RefreshIndicator(
//             onRefresh: controller.fetchProducts,
//             child: ListView(
//               physics:
//               const AlwaysScrollableScrollPhysics(),
//               children: const [
//                 SizedBox(height: 220),
//
//                 Icon(
//                   Icons.inventory_2_outlined,
//                   size: 70,
//                   color: Color(0xFF9AA2B1),
//                 ),
//
//                 SizedBox(height: 12),
//
//                 Center(
//                   child: Text(
//                     'No products found',
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         final List<dynamic> products =
//             filteredProducts;
//
//         // ------------------------------------------------------------
//         // FILTER RESULT EMPTY
//         // ------------------------------------------------------------
//         if (products.isEmpty) {
//           return RefreshIndicator(
//             onRefresh: controller.fetchProducts,
//             child: ListView(
//               physics:
//               const AlwaysScrollableScrollPhysics(),
//               children: [
//                 const SizedBox(height: 180),
//
//                 const Icon(
//                   Icons.filter_alt_off_outlined,
//                   size: 70,
//                   color: Color(0xFF9AA2B1),
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 const Center(
//                   child: Text(
//                     'No matching products found',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 Center(
//                   child: OutlinedButton.icon(
//                     onPressed: _resetFilters,
//                     icon: const Icon(
//                       Icons.restart_alt,
//                     ),
//                     label: const Text(
//                       'Reset Filters',
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         // ------------------------------------------------------------
//         // PRODUCT GRID
//         // ------------------------------------------------------------
//         return RefreshIndicator(
//           onRefresh: controller.fetchProducts,
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               int crossAxisCount = 2;
//
//               if (constraints.maxWidth >= 1200) {
//                 crossAxisCount = 5;
//               } else if (constraints.maxWidth >= 900) {
//                 crossAxisCount = 4;
//               } else if (constraints.maxWidth >= 650) {
//                 crossAxisCount = 3;
//               }
//
//               return GridView.builder(
//                 padding: const EdgeInsets.all(16),
//
//                 physics:
//                 const AlwaysScrollableScrollPhysics(),
//
//                 gridDelegate:
//                 SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: crossAxisCount,
//                   crossAxisSpacing: 14,
//                   mainAxisSpacing: 14,
//                   childAspectRatio: 0.72,
//                 ),
//
//                 itemCount: products.length,
//
//                 itemBuilder: (_, index) {
//                   return ProductCard(
//                     product: products[index],
//                   );
//                 },
//               );
//             },
//           ),
//         );
//       }),
//     );
//   }
//
//   // ================================================================
//   // FILTER DRAWER
//   // ================================================================
//   Widget _buildFilterDrawer() {
//     return Drawer(
//       child: SafeArea(
//         child: Column(
//           children: [
//             // ========================================================
//             // HEADER
//             // ========================================================
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.fromLTRB(
//                 20,
//                 20,
//                 16,
//                 18,
//               ),
//               child: Row(
//                 children: [
//                   // --------------------------------------------------
//                   // FILTER ICON
//                   // --------------------------------------------------
//                   Container(
//                     width: 44,
//                     height: 44,
//                     decoration: BoxDecoration(
//                       color: Theme.of(context)
//                           .colorScheme
//                           .primary
//                           .withOpacity(0.10),
//                       borderRadius:
//                       BorderRadius.circular(12),
//                     ),
//                     child: Icon(
//                       Icons.tune_rounded,
//                       color: Theme.of(context)
//                           .colorScheme
//                           .primary,
//                     ),
//                   ),
//
//                   const SizedBox(width: 12),
//
//                   // --------------------------------------------------
//                   // TITLE
//                   // --------------------------------------------------
//                   const Expanded(
//                     child: Column(
//                       crossAxisAlignment:
//                       CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Filter Products',
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight:
//                             FontWeight.w800,
//                           ),
//                         ),
//                         SizedBox(height: 2),
//                         Text(
//                           'Find products easily',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color:
//                             Color(0xFF7A8190),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // --------------------------------------------------
//                   // CLOSE BUTTON
//                   // --------------------------------------------------
//                   IconButton(
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                     icon: const Icon(
//                       Icons.close_rounded,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const Divider(height: 1),
//
//             // ========================================================
//             // FILTER CONTENT
//             // ========================================================
//             Expanded(
//               child: SingleChildScrollView(
//                 padding:
//                 const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment:
//                   CrossAxisAlignment.start,
//                   children: [
//                     // ==================================================
//                     // SEARCH TITLE
//                     // ==================================================
//                     const Text(
//                       'Search',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight:
//                         FontWeight.w700,
//                       ),
//                     ),
//
//                     const SizedBox(height: 8),
//
//                     // ==================================================
//                     // SEARCH FIELD
//                     // ==================================================
//                     TextField(
//                       controller:
//                       _searchController,
//
//                       onChanged: (value) {
//                         setState(() {
//                           _searchText = value;
//                         });
//                       },
//
//                       decoration: InputDecoration(
//                         hintText:
//                         'Name, code, color...',
//
//                         prefixIcon:
//                         const Icon(
//                           Icons.search_rounded,
//                         ),
//
//                         suffixIcon:
//                         _searchText.isNotEmpty
//                             ? IconButton(
//                           onPressed: () {
//                             _searchController
//                                 .clear();
//
//                             setState(() {
//                               _searchText =
//                               '';
//                             });
//                           },
//                           icon:
//                           const Icon(
//                             Icons
//                                 .close_rounded,
//                           ),
//                         )
//                             : null,
//
//                         border:
//                         OutlineInputBorder(
//                           borderRadius:
//                           BorderRadius
//                               .circular(12),
//                         ),
//
//                         enabledBorder:
//                         OutlineInputBorder(
//                           borderRadius:
//                           BorderRadius
//                               .circular(12),
//                           borderSide:
//                           const BorderSide(
//                             color:
//                             Color(
//                               0xFFE3E6EC,
//                             ),
//                           ),
//                         ),
//
//                         contentPadding:
//                         const EdgeInsets
//                             .symmetric(
//                           horizontal: 14,
//                           vertical: 14,
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 24),
//
//                     // ==================================================
//                     // BUSINESS TITLE
//                     // ==================================================
//                     const Text(
//                       'Business',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight:
//                         FontWeight.w700,
//                       ),
//                     ),
//
//                     const SizedBox(height: 8),
//
//                     // ==================================================
//                     // BUSINESS DROPDOWN
//                     // ==================================================
//                     DropdownButtonFormField<String>(
//                       value:
//                       _selectedBusiness,
//
//                       isExpanded: true,
//
//                       hint: const Text(
//                         'All Businesses',
//                       ),
//
//                       decoration:
//                       InputDecoration(
//                         prefixIcon:
//                         const Icon(
//                           Icons
//                               .business_outlined,
//                         ),
//
//                         border:
//                         OutlineInputBorder(
//                           borderRadius:
//                           BorderRadius
//                               .circular(12),
//                         ),
//
//                         enabledBorder:
//                         OutlineInputBorder(
//                           borderRadius:
//                           BorderRadius
//                               .circular(12),
//                           borderSide:
//                           const BorderSide(
//                             color:
//                             Color(
//                               0xFFE3E6EC,
//                             ),
//                           ),
//                         ),
//                       ),
//
//                       items:
//                       businessList.map(
//                             (business) {
//                           return DropdownMenuItem<
//                               String>(
//                             value: business,
//                             child: Text(
//                               business,
//                               overflow:
//                               TextOverflow
//                                   .ellipsis,
//                             ),
//                           );
//                         },
//                       ).toList(),
//
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedBusiness =
//                               value;
//                         });
//                       },
//                     ),
//
//                     const SizedBox(height: 24),
//
//                     // ==================================================
//                     // CATEGORY TITLE
//                     // ==================================================
//                     const Text(
//                       'Product Category',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight:
//                         FontWeight.w700,
//                       ),
//                     ),
//
//                     const SizedBox(height: 8),
//
//                     // ==================================================
//                     // CATEGORY DROPDOWN
//                     // ==================================================
//                     DropdownButtonFormField<String>(
//                       value:
//                       _selectedCategory,
//
//                       isExpanded: true,
//
//                       hint: const Text(
//                         'All Categories',
//                       ),
//
//                       decoration:
//                       InputDecoration(
//                         prefixIcon:
//                         const Icon(
//                           Icons
//                               .category_outlined,
//                         ),
//
//                         border:
//                         OutlineInputBorder(
//                           borderRadius:
//                           BorderRadius
//                               .circular(12),
//                         ),
//
//                         enabledBorder:
//                         OutlineInputBorder(
//                           borderRadius:
//                           BorderRadius
//                               .circular(12),
//                           borderSide:
//                           const BorderSide(
//                             color:
//                             Color(
//                               0xFFE3E6EC,
//                             ),
//                           ),
//                         ),
//                       ),
//
//                       items:
//                       categoryList.map(
//                             (category) {
//                           return DropdownMenuItem<
//                               String>(
//                             value: category,
//                             child: Text(
//                               category,
//                               overflow:
//                               TextOverflow
//                                   .ellipsis,
//                             ),
//                           );
//                         },
//                       ).toList(),
//
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedCategory =
//                               value;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             // ========================================================
//             // BOTTOM ACTION BUTTONS
//             // ========================================================
//             Container(
//               padding:
//               const EdgeInsets.all(16),
//               decoration:
//               const BoxDecoration(
//                 border: Border(
//                   top: BorderSide(
//                     color:
//                     Color(0xFFE7E9EE),
//                   ),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   // --------------------------------------------------
//                   // RESET
//                   // --------------------------------------------------
//                   Expanded(
//                     child:
//                     OutlinedButton.icon(
//                       onPressed: _hasFilter
//                           ? _resetFilters
//                           : null,
//                       icon: const Icon(
//                         Icons
//                             .restart_alt_rounded,
//                       ),
//                       label:
//                       const Text('Reset'),
//                       style: OutlinedButton
//                           .styleFrom(
//                         padding:
//                         const EdgeInsets
//                             .symmetric(
//                           vertical: 14,
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(width: 10),
//
//                   // --------------------------------------------------
//                   // DONE
//                   // --------------------------------------------------
//                   Expanded(
//                     child:
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         Navigator.of(context)
//                             .pop();
//                       },
//                       icon: const Icon(
//                         Icons.check_rounded,
//                       ),
//                       label:
//                       const Text('Done'),
//                       style: ElevatedButton
//                           .styleFrom(
//                         padding:
//                         const EdgeInsets
//                             .symmetric(
//                           vertical: 14,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ==================================================================
// // ERROR VIEW
// // ==================================================================
// class _ErrorView extends StatelessWidget {
//   final String message;
//   final Future<void> Function() onRetry;
//
//   const _ErrorView({
//     required this.message,
//     required this.onRetry,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding:
//         const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize:
//           MainAxisSize.min,
//           children: [
//             const Icon(
//               Icons.cloud_off_outlined,
//               size: 64,
//               color:
//               Color(0xFF9AA2B1),
//             ),
//
//             const SizedBox(height: 16),
//
//             Text(
//               message,
//               textAlign:
//               TextAlign.center,
//             ),
//
//             const SizedBox(height: 16),
//
//             ElevatedButton.icon(
//               onPressed: onRetry,
//               icon: const Icon(
//                 Icons.refresh,
//               ),
//               label:
//               const Text('Retry'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  String? _selectedBusiness;
  String? _selectedSubCategory;

  // ================================================================
  // SAFE VALUE
  // ================================================================
  String _getValue(dynamic item, String field) {
    try {
      // =============================================================
      // MAP SUPPORT
      // =============================================================
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

          case 'displayRoomNo':
            return item['display_room_no']?.toString() ??
                item['displayRoomNo']?.toString() ??
                '';

          case 'displayRoomName':
            return item['display_room_name']?.toString() ??
                item['displayRoomName']?.toString() ??
                '';

          case 'status':
            return item['status']?.toString() ?? '';

          case 'assignee':
            return item['assignee']?.toString() ?? '';

          case 'createdBy':
            return item['created_by']?.toString() ??
                item['createdBy']?.toString() ??
                '';

          case 'createdDate':
            return item['created_date']?.toString() ??
                item['createdDate']?.toString() ??
                '';

          case 'updatedBy':
            return item['updated_by']?.toString() ??
                item['updatedBy']?.toString() ??
                '';

          case 'updatedDate':
            return item['updated_date']?.toString() ??
                item['updatedDate']?.toString() ??
                '';

          case 'detailsCount':
            return item['details_count']?.toString() ??
                item['detailsCount']?.toString() ??
                '0';

          default:
            return '';
        }
      }

      // =============================================================
      // MODEL SUPPORT
      // =============================================================
      switch (field) {
        case 'sl':
          return item.sl?.toString() ?? '';

        case 'business':
          return item.business?.toString() ?? '';

        case 'subCategory':
          return item.subCategory?.toString() ?? '';

        case 'organizationId':
          return item.organizationId?.toString() ?? '';

        case 'displayRoomNo':
          return item.displayRoomNo?.toString() ?? '';

        case 'displayRoomName':
          return item.displayRoomName?.toString() ?? '';

        case 'status':
          return item.status?.toString() ?? '';

        case 'assignee':
          return item.assignee?.toString() ?? '';

        case 'createdBy':
          return item.createdBy?.toString() ?? '';

        case 'createdDate':
          return item.createdDate?.toString() ?? '';

        case 'updatedBy':
          return item.updatedBy?.toString() ?? '';

        case 'updatedDate':
          return item.updatedDate?.toString() ?? '';

        case 'detailsCount':
          return item.detailsCount?.toString() ?? '0';

        default:
          return '';
      }
    } catch (_) {
      return '';
    }
  }

  // ================================================================
  // FILTERED DISPLAY ROOMS
  // ================================================================
  List<dynamic> get filteredRooms {
    return controller.products.where((item) {
      final String displayRoomName =
      _getValue(item, 'displayRoomName').toLowerCase();

      final String displayRoomNo =
      _getValue(item, 'displayRoomNo').toLowerCase();

      final String business =
      _getValue(item, 'business');

      final String subCategory =
      _getValue(item, 'subCategory');

      final String organizationId =
      _getValue(item, 'organizationId').toLowerCase();

      final String status =
      _getValue(item, 'status').toLowerCase();

      final String search =
      _searchText.trim().toLowerCase();

      // =============================================================
      // SEARCH
      // =============================================================
      final bool matchesSearch =
          search.isEmpty ||
              displayRoomName.contains(search) ||
              displayRoomNo.contains(search) ||
              business.toLowerCase().contains(search) ||
              subCategory.toLowerCase().contains(search) ||
              organizationId.contains(search) ||
              status.contains(search);

      // =============================================================
      // BUSINESS FILTER
      // =============================================================
      final bool matchesBusiness =
          _selectedBusiness == null ||
              _selectedBusiness!.isEmpty ||
              business == _selectedBusiness;

      // =============================================================
      // SUB CATEGORY FILTER
      // =============================================================
      final bool matchesSubCategory =
          _selectedSubCategory == null ||
              _selectedSubCategory!.isEmpty ||
              subCategory == _selectedSubCategory;

      return matchesSearch &&
          matchesBusiness &&
          matchesSubCategory;
    }).toList();
  }

  // ================================================================
  // BUSINESS LIST
  // ================================================================
  List<String> get businessList {
    final List<String> list = controller.products
        .map(
          (item) => _getValue(
        item,
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
  // SUB CATEGORY LIST
  // ================================================================
  List<String> get subCategoryList {
    final List<String> list = controller.products
        .map(
          (item) => _getValue(
        item,
        'subCategory',
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
  // RESET FILTER
  // ================================================================
  void _resetFilters() {
    _searchController.clear();

    setState(() {
      _searchText = '';
      _selectedBusiness = null;
      _selectedSubCategory = null;
    });
  }

  bool get _hasFilter {
    return _searchText.trim().isNotEmpty ||
        _selectedBusiness != null ||
        _selectedSubCategory != null;
  }

  // ================================================================
  // OPEN DETAIL PAGE
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
      // ==============================================================
      // DRAWER
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
              'Available display rooms',
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
                  Icons.meeting_room_outlined,
                  size: 70,
                  color: Color(0xFF9AA2B1),
                ),
                SizedBox(height: 12),
                Center(
                  child: Text(
                    'No display room found',
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

        final List<dynamic> rooms =
            filteredRooms;

        // ============================================================
        // FILTER EMPTY
        // ============================================================
        if (rooms.isEmpty) {
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
                    'No matching display room found',
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
        // GRID
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
                  mainAxisExtent: 270,
                ),
                itemCount: rooms.length,
                itemBuilder: (
                    BuildContext context,
                    int index,
                    ) {
                  final dynamic room =
                  rooms[index];

                  return _buildDisplayRoomCard(
                    room,
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
  // DISPLAY ROOM CARD
  // ================================================================
  Widget _buildDisplayRoomCard(
      dynamic item,
      ) {
    final String sl =
    _getValue(item, 'sl');

    final String business =
    _getValue(item, 'business');

    final String subCategory =
    _getValue(item, 'subCategory');

    final String organizationId =
    _getValue(item, 'organizationId');

    final String displayRoomNo =
    _getValue(item, 'displayRoomNo');

    final String displayRoomName =
    _getValue(item, 'displayRoomName');

    final String status =
    _getValue(item, 'status');

    final String detailsCount =
    _getValue(item, 'detailsCount');

    final bool isActive =
        status.trim().toUpperCase() == 'ACTIVE';

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,

      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(18),
        side: const BorderSide(
          color: Color(0xFFE3E6EC),
        ),
      ),

      // ==============================================================
      // CLICKABLE CARD
      // ==============================================================
      child: InkWell(
        borderRadius:
        BorderRadius.circular(18),

        // ============================================================
        // DETAIL PAGE NAVIGATION
        // ============================================================
        onTap: () {
          _openDetailPage(item);
        },

        child: Padding(
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              // ======================================================
              // HEADER
              // ======================================================
              Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Container(
                    width: 48,
                    height: 48,

                    decoration:
                    BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.10),

                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
                    ),

                    child: Icon(
                      Icons
                          .meeting_room_outlined,

                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [
                        Text(
                          displayRoomName
                              .trim()
                              .isEmpty
                              ? 'Display Room'
                              : displayRoomName,

                          maxLines: 2,
                          overflow:
                          TextOverflow
                              .ellipsis,

                          style:
                          const TextStyle(
                            fontSize: 16,
                            fontWeight:
                            FontWeight.w800,
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        Text(
                          displayRoomNo
                              .trim()
                              .isEmpty
                              ? '-'
                              : displayRoomNo,

                          maxLines: 1,
                          overflow:
                          TextOverflow
                              .ellipsis,

                          style:
                          const TextStyle(
                            fontSize: 12,
                            color:
                            Color(
                              0xFF727985,
                            ),
                            fontWeight:
                            FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ==================================================
                  // STATUS
                  // ==================================================
                  Container(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),

                    decoration:
                    BoxDecoration(
                      color: isActive
                          ? const Color(
                        0xFFEAF7EF,
                      )
                          : const Color(
                        0xFFF1F2F4,
                      ),

                      borderRadius:
                      BorderRadius.circular(
                        20,
                      ),
                    ),

                    child: Text(
                      status.trim().isEmpty
                          ? 'N/A'
                          : status,

                      style: TextStyle(
                        fontSize: 10,
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

              const SizedBox(height: 18),

              const Divider(
                height: 1,
                color: Color(0xFFE8EAEE),
              ),

              const SizedBox(height: 16),

              // ======================================================
              // BUSINESS + CATEGORY
              // ======================================================
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons
                          .business_outlined,
                      title: 'Business',
                      value: business,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons
                          .category_outlined,
                      title: 'Sub Category',
                      value: subCategory,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ======================================================
              // ORGANIZATION + ITEM COUNT
              // ======================================================
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons
                          .apartment_outlined,
                      title: 'Organization',
                      value: organizationId,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons
                          .inventory_2_outlined,
                      title: 'Items',
                      value:
                      detailsCount.trim().isEmpty
                          ? '0'
                          : detailsCount,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // ======================================================
              // FOOTER
              // ======================================================
              Row(
                children: [
                  if (sl.trim().isNotEmpty)
                    Text(
                      'SL: $sl',
                      style:
                      const TextStyle(
                        fontSize: 10,
                        color:
                        Color(
                          0xFF9299A5,
                        ),
                        fontWeight:
                        FontWeight.w500,
                      ),
                    ),

                  const Spacer(),

                  Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 12,
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
                    size: 12,
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
          width: 32,
          height: 32,

          decoration: BoxDecoration(
            color: const Color(
              0xFFF4F6F8,
            ),
            borderRadius:
            BorderRadius.circular(8),
          ),

          child: Icon(
            icon,
            size: 16,
            color:
            const Color(
              0xFF737B88,
            ),
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              Text(
                title,
                style:
                const TextStyle(
                  fontSize: 10,
                  color:
                  Color(
                    0xFF8A919D,
                  ),
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value.trim().isEmpty
                    ? '-'
                    : value,

                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,

                style:
                const TextStyle(
                  fontSize: 12,
                  fontWeight:
                  FontWeight.w600,
                  color:
                  Color(
                    0xFF252A33,
                  ),
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
    final List<String> businesses =
        businessList;

    final List<String> subCategories =
        subCategoryList;

    final String? safeBusiness =
    _selectedBusiness != null &&
        businesses.contains(
          _selectedBusiness,
        )
        ? _selectedBusiness
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

                    decoration:
                    BoxDecoration(
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
                      CrossAxisAlignment
                          .start,

                      children: [
                        Text(
                          'Filter Display Rooms',
                          style:
                          TextStyle(
                            fontSize: 20,
                            fontWeight:
                            FontWeight
                                .w800,
                          ),
                        ),

                        SizedBox(height: 2),

                        Text(
                          'Find display rooms easily',
                          style:
                          TextStyle(
                            fontSize: 12,
                            color:
                            Color(
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
                const EdgeInsets.all(
                  20,
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    // ==================================================
                    // SEARCH
                    // ==================================================
                    const Text(
                      'Search',
                      style:
                      TextStyle(
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
                        'Room, business, org...',

                        prefixIcon:
                        const Icon(
                          Icons.search_rounded,
                        ),

                        suffixIcon:
                        _searchText
                            .isNotEmpty
                            ? IconButton(
                          onPressed:
                              () {
                            _searchController
                                .clear();

                            setState(
                                    () {
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
                    // BUSINESS
                    // ==================================================
                    const Text(
                      'Business',
                      style:
                      TextStyle(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    DropdownButtonFormField<
                        String>(
                      value: safeBusiness,

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

                      items: businesses
                          .map(
                            (business) =>
                            DropdownMenuItem<
                                String>(
                              value: business,

                              child: Text(
                                business,
                                overflow:
                                TextOverflow
                                    .ellipsis,
                              ),
                            ),
                      )
                          .toList(),

                      onChanged: (value) {
                        setState(() {
                          _selectedBusiness =
                              value;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // SUB CATEGORY
                    // ==================================================
                    const Text(
                      'Sub Category',
                      style:
                      TextStyle(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    DropdownButtonFormField<
                        String>(
                      value: safeSubCategory,

                      isExpanded: true,

                      hint: const Text(
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

                      items: subCategories
                          .map(
                            (category) =>
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

                      onChanged: (value) {
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
              const EdgeInsets.all(
                16,
              ),

              decoration:
              const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color:
                    Color(
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
                      const Text(
                        'Reset',
                      ),

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
                      const Text(
                        'Done',
                      ),

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
              Color(
                0xFF9AA2B1,
              ),
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
              const Text(
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }
}