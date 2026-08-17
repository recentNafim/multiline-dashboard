import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class ProductService {
  static const String _url =
      'https://e502.sihirbox.com:8072/ords/rpro/multiline-display-room/item-upload';

  Future<List<ProductModel>> getProducts() async {
    try {
      final uri = Uri.parse(_url);

      log('==========================================');
      log('GET PRODUCT API');
      log('URL => $uri');
      log('==========================================');

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );

      log('STATUS CODE => ${response.statusCode}');
      log('RESPONSE => ${response.body}');
      log('==========================================');

      if (response.statusCode != 200) {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid API response format');
      }

      final int statusCode =
          int.tryParse(decoded['status_code'].toString()) ?? 0;

      if (statusCode != 200) {
        throw Exception(
          decoded['message']?.toString() ??
              'Unable to load products',
        );
      }

      final List<dynamic> masterList =
          decoded['data'] is List ? decoded['data'] : [];

      final List<ProductModel> products = [];

      for (final masterItem in masterList) {
        if (masterItem is! Map) {
          continue;
        }

        final Map<String, dynamic> master =
            Map<String, dynamic>.from(masterItem);

        final detailsData = master['details'];

        if (detailsData is! List) {
          continue;
        }

        for (final detailItem in detailsData) {
          if (detailItem is! Map) {
            continue;
          }

          final Map<String, dynamic> detail =
              Map<String, dynamic>.from(detailItem);

          products.add(
            ProductModel.fromMasterAndDetail(
              master,
              detail,
            ),
          );
        }
      }

      log('TOTAL PRODUCTS => ${products.length}');

      return products;
    } catch (e, stackTrace) {
      log(
        'PRODUCT API ERROR',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }
}
