import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';

/// Reads the existing Oracle display-room endpoint; maps each master/detail row.
class ProductService {
  static const String _url =
      'https://e501.sihirbox.com:8071/ords/rpro/multiline-display-room/item-upload';

  /// GET is paginated by MASTER row, not by product detail.
  /// Load every page so a hardcoded Category/Subcategory filter does not
  /// incorrectly show zero products when matches are on later pages.
  Future<List<ProductModel>> getProducts() async {
    final products = <ProductModel>[];
    final seenMasters = <String>{};
    const int pageLimit = 100; // The provided ORDS handler caps p_limit at 100.
    int page = 1;

    try {
      while (true) {
        final uri = Uri.parse(_url).replace(queryParameters: <String, String>{
          'p_page': '$page',
          'p_limit': '$pageLimit',
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
        final statusCode =
            int.tryParse(decoded['status_code']?.toString() ?? '') ?? 0;
        if (statusCode != 200) {
          throw Exception(
            decoded['message']?.toString() ?? 'Unable to load products',
          );
        }
        final rawData = decoded['data'];
        if (rawData is! List || rawData.isEmpty) break;

        int newMasters = 0;
        for (final masterItem in rawData) {
          if (masterItem is! Map) continue;
          final master = Map<String, dynamic>.from(masterItem);
          // Prevent duplicates if a proxy/cache mistakenly repeats a page.
          final masterId = master['sl']?.toString();
          if (masterId != null && !seenMasters.add(masterId)) continue;
          newMasters++;

          final rawDetails = master['details'];
          if (rawDetails is List && rawDetails.isNotEmpty) {
            for (final detailItem in rawDetails) {
              if (detailItem is! Map) continue;
              try {
                products.add(ProductModel.fromMasterAndDetail(
                  master,
                  Map<String, dynamic>.from(detailItem),
                ));
              } catch (e, stackTrace) {
                log('Product detail parsing failed',
                    error: e, stackTrace: stackTrace);
              }
            }
          } else {
            try {
              products.add(ProductModel.fromMasterAndDetail(
                  master, <String, dynamic>{}));
            } catch (e, stackTrace) {
              log('Product master parsing failed',
                  error: e, stackTrace: stackTrace);
            }
          }
        }

        final totalPages =
            int.tryParse(decoded['total_pages']?.toString() ?? '');
        if (newMasters == 0 ||
            (totalPages != null && page >= totalPages) ||
            (totalPages == null && rawData.length < pageLimit)) {
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
