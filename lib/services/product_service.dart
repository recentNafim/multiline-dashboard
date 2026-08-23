// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:http/http.dart' as http;
//
// import '../models/product_model.dart';
//
// class ProductService {
//   static const String _url =
//       'https://e501.sihirbox.com:8071/ords/rpro/multiline-display-room/item-upload';
//
//   Future<List<ProductModel>> getProducts() async {
//     try {
//       final uri = Uri.parse(_url);
//
//       log('==========================================');
//       log('GET PRODUCT API');
//       log('URL => $uri');
//       log('==========================================');
//
//       final response = await http.get(
//         uri,
//         headers: {
//           'Accept': 'application/json',
//         },
//       );
//
//       log('STATUS CODE => ${response.statusCode}');
//       log('RESPONSE => ${response.body}');
//       log('==========================================');
//
//       if (response.statusCode != 200) {
//         throw Exception(
//           'HTTP ${response.statusCode}: ${response.body}',
//         );
//       }
//
//       final decoded = jsonDecode(response.body);
//
//       if (decoded is! Map<String, dynamic>) {
//         throw Exception('Invalid API response format');
//       }
//
//       final int statusCode =
//           int.tryParse(decoded['status_code'].toString()) ?? 0;
//
//       if (statusCode != 200) {
//         throw Exception(
//           decoded['message']?.toString() ??
//               'Unable to load products',
//         );
//       }
//
//       final List<dynamic> masterList =
//           decoded['data'] is List ? decoded['data'] : [];
//
//       final List<ProductModel> products = [];
//
//       for (final masterItem in masterList) {
//         if (masterItem is! Map) {
//           continue;
//         }
//
//         final Map<String, dynamic> master =
//             Map<String, dynamic>.from(masterItem);
//
//         final detailsData = master['details'];
//
//         if (detailsData is! List) {
//           continue;
//         }
//
//         for (final detailItem in detailsData) {
//           if (detailItem is! Map) {
//             continue;
//           }
//
//           final Map<String, dynamic> detail =
//               Map<String, dynamic>.from(detailItem);
//
//           products.add(
//             ProductModel.fromMasterAndDetail(
//               master,
//               detail,
//             ),
//           );
//         }
//       }
//
//       log('TOTAL PRODUCTS => ${products.length}');
//
//       return products;
//     } catch (e, stackTrace) {
//       log(
//         'PRODUCT API ERROR',
//         error: e,
//         stackTrace: stackTrace,
//       );
//
//       rethrow;
//     }
//   }
// }


import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class ProductService {
  static const String _url =
      'https://e501.sihirbox.com:8071/ords/rpro/multiline-display-room/item-upload';

  Future<List<ProductModel>> getProducts() async {
    try {
      final Uri uri = Uri.parse(_url);

      log('==========================================');
      log('GET DISPLAY ROOM API');
      log('URL => $uri');
      log('==========================================');

      final http.Response response = await http.get(
        uri,
        headers: const {
          'Accept': 'application/json',
        },
      );

      log('STATUS CODE => ${response.statusCode}');
      log('RESPONSE => ${response.body}');
      log('==========================================');

      // ==============================================================
      // HTTP STATUS CHECK
      // ==============================================================
      if (response.statusCode != 200) {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.body}',
        );
      }

      // ==============================================================
      // JSON DECODE
      // ==============================================================
      final dynamic decodedData = jsonDecode(response.body);

      if (decodedData is! Map) {
        throw Exception(
          'Invalid API response format',
        );
      }

      final Map<String, dynamic> decoded =
      Map<String, dynamic>.from(decodedData);

      // ==============================================================
      // API STATUS CHECK
      // ==============================================================
      final int statusCode =
          int.tryParse(
            decoded['status_code']?.toString() ?? '',
          ) ??
              0;

      if (statusCode != 200) {
        throw Exception(
          decoded['message']?.toString() ??
              'Unable to load display rooms',
        );
      }

      // ==============================================================
      // MASTER DATA
      // ==============================================================
      final dynamic rawData = decoded['data'];

      if (rawData is! List) {
        log('API DATA IS NOT LIST');
        return <ProductModel>[];
      }

      final List<ProductModel> products = <ProductModel>[];

      log('TOTAL MASTER RECORD => ${rawData.length}');

      // ==============================================================
      // MASTER LOOP
      // ==============================================================
      for (final dynamic masterItem in rawData) {
        if (masterItem is! Map) {
          continue;
        }

        final Map<String, dynamic> master =
        Map<String, dynamic>.from(masterItem);

        log('------------------------------------------');
        log('MASTER SL => ${master['sl']}');
        log('BUSINESS => ${master['business']}');
        log('SUB CATEGORY => ${master['sub_category']}');
        log('ORG ID => ${master['organization_id']}');
        log('ROOM NO => ${master['display_room_no']}');
        log('ROOM NAME => ${master['display_room_name']}');
        log('STATUS => ${master['status']}');
        log('DETAILS COUNT => ${master['details_count']}');

        final dynamic detailsData = master['details'];

        // ============================================================
        // CASE 1: DETAILS AVAILABLE
        // ============================================================
        if (detailsData is List && detailsData.isNotEmpty) {
          log(
            'DETAILS FOUND => ${detailsData.length}',
          );

          for (final dynamic detailItem in detailsData) {
            if (detailItem is! Map) {
              continue;
            }

            final Map<String, dynamic> detail =
            Map<String, dynamic>.from(detailItem);

            try {
              products.add(
                ProductModel.fromMasterAndDetail(
                  master,
                  detail,
                ),
              );
            } catch (e, stackTrace) {
              log(
                'DETAIL PARSE ERROR - MASTER SL ${master['sl']}',
                error: e,
                stackTrace: stackTrace,
              );
            }
          }
        }

        // ============================================================
        // CASE 2: DETAILS EMPTY
        // IMPORTANT:
        // Master record-টা তারপরও list-এ add হবে
        // ============================================================
        else {
          log(
            'NO DETAILS FOUND - ADDING MASTER ONLY '
                'SL => ${master['sl']}',
          );

          try {
            products.add(
              ProductModel.fromMasterAndDetail(
                master,
                <String, dynamic>{},
              ),
            );
          } catch (e, stackTrace) {
            log(
              'MASTER PARSE ERROR - SL ${master['sl']}',
              error: e,
              stackTrace: stackTrace,
            );
          }
        }
      }

      // ==============================================================
      // FINAL LOG
      // ==============================================================
      log('==========================================');
      log('TOTAL DISPLAY ROOM / PRODUCTS => ${products.length}');
      log('==========================================');

      return products;
    } catch (e, stackTrace) {
      log(
        'DISPLAY ROOM API ERROR',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }
}
