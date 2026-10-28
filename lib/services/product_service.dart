import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';

/// Reads the existing Oracle display-room endpoint; maps each master/detail row.
class ProductService {
  static const String _url =
      'https://e501.sihirbox.com:8071/ords/rpro/multiline-display-room/item-upload';

  /// Load ALL paginated Oracle master records before applying local UI filters.
  /// ORDS GET supports p_page and p_limit, max 100 per request. This avoids
  /// showing "No matching product" when a category is only on page 2+.
  Future<List<ProductModel>> getProducts() async {
    try {
      const pageSize = 100;
      final products = <ProductModel>[];
      final seenMasters = <String>{};
      var page = 1;
      while (true) {
        final uri = Uri.parse(_url).replace(queryParameters: {
          'p_page': '$page',
          'p_limit': '$pageSize',
        });
        final response = await http.get(
          uri,
          headers: const {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 60));
        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}: ${response.body}');
        }
        final decodedData = jsonDecode(response.body);
        if (decodedData is! Map) {
          throw Exception('Invalid API response format');
        }
        final decoded = Map<String, dynamic>.from(decodedData);
        final statusCode = int.tryParse(decoded['status_code']?.toString() ?? '') ?? 0;
        if (statusCode != 200) {
          throw Exception(decoded['message']?.toString() ?? 'Unable to load products');
        }
        final rawData = decoded['data'];
        if (rawData is! List || rawData.isEmpty) break;
        for (final masterItem in rawData) {
          if (masterItem is! Map) continue;
          final master = Map<String, dynamic>.from(masterItem);
          final masterKey = master['sl']?.toString();
          if (masterKey != null && !seenMasters.add(masterKey)) continue;
          final rawDetails = master['details'];
          if (rawDetails is List && rawDetails.isNotEmpty) {
            for (final detailItem in rawDetails) {
              if (detailItem is! Map) continue;
              try {
                products.add(ProductModel.fromMasterAndDetail(
                  master, Map<String, dynamic>.from(detailItem),
                ));
              } catch (e, stackTrace) {
                log('Product detail parsing failed', error: e, stackTrace: stackTrace);
              }
            }
          } else {
            try {
              products.add(ProductModel.fromMasterAndDetail(master, <String, dynamic>{}));
            } catch (e, stackTrace) {
              log('Product master parsing failed', error: e, stackTrace: stackTrace);
            }
          }
        }
        final totalPages = int.tryParse(decoded['total_pages']?.toString() ?? '');
        if (totalPages != null && totalPages >= 0) {
          if (page >= totalPages) break;
        } else if (rawData.length < pageSize) {
          break;
        }
        page++;
      }
      return products;
    } catch (e, stackTrace) {
      log('PRODUCT API ERROR', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

}
