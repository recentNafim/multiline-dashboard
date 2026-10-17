import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';

/// Reads the existing Oracle display-room endpoint; maps each master/detail row.
class ProductService {
  static const String _url =
      'https://e501.sihirbox.com:8071/ords/rpro/multiline-display-room/item-upload';

  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse(_url),
        headers: const {'Accept': 'application/json'},
      );
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
      if (rawData is! List) return <ProductModel>[];
      final products = <ProductModel>[];
      for (final masterItem in rawData) {
        if (masterItem is! Map) continue;
        final master = Map<String, dynamic>.from(masterItem);
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
      return products;
    } catch (e, stackTrace) {
      log('PRODUCT API ERROR', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
