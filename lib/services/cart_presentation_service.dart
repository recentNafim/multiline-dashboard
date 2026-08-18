import '../models/cart_item.dart';
import 'presentation_bridge.dart';

class CartPresentationService {
  static Future<void> generate({
    required List<CartItem> items,
    String imageBaseUrl = '',
  }) async {
    if (items.isEmpty) {
      throw Exception(
        'No cart items found.',
      );
    }

    final List<Map<String, Object?>> products =
    items.map((item) {
      final dynamic product = item.product;

      final String itemCode = _firstValue([
            () => product.itemCode,
            () => product.item_code,
            () => product.ITEM_CODE,
            () => product.Item_code,
      ]);

      final String description = _firstValue([
            () => product.description,
            () => product.itemName,
            () => product.item_name,
            () => product.ITEM_NAME,
            () => product.Item_Name,
      ]);

      final String business = _firstValue([
            () => product.business,
            () => product.BUSINESS,
      ]);

      final String category = _firstValue([
            () => product.productCategory,
            () => product.product_category,
            () => product.PRODUCT_CATEGORY,
      ]);

      final String subCategory = _firstValue([
            () => product.subCategory,
            () => product.sub_category,
            () => product.SUB_CATEGORY,
      ]);

      final String color = _firstValue([
            () => product.color,
            () => product.COLOR,
      ]);

      final String uom = _firstValue([
            () => product.uom,
            () => product.UOM,
      ]);

      final String unitPrice = _firstValue([
            () => product.unitPrice,
            () => product.unit_price,
            () => product.UNIT_PRICE,
      ]);

      final String rawImageUrl = _firstValue([
            () => product.fileUrl,
            () => product.file_url,
            () => product.FILE_URL,
            () => product.imageUrl,
            () => product.image_url,
            () => product.image,
      ]);

      final String imageUrl = _buildImageUrl(
        rawImageUrl,
        imageBaseUrl,
      );

      return <String, Object?>{
        'itemCode': itemCode,
        'description': description,
        'itemName': description,
        'business': business,
        'category': category,
        'subCategory': subCategory,
        'color': color,
        'uom': uom,
        'unitPrice': unitPrice,
        'quantity': item.quantity,
        'imageUrl': imageUrl,
      };
    }).toList();

    final DateTime now = DateTime.now();

    final String year =
    now.year.toString();

    final String month =
    now.month.toString().padLeft(2, '0');

    final String day =
    now.day.toString().padLeft(2, '0');

    final String hour =
    now.hour.toString().padLeft(2, '0');

    final String minute =
    now.minute.toString().padLeft(2, '0');

    final String fileName =
        'Display_Room_Product_Presentation_'
        '$year$month$day'
        '_$hour$minute.pptx';

    await generateProductPresentation(
      products,
      fileName,
    );
  }

  // ================================================================
  // SAFE MODEL VALUE
  // ================================================================
  static String _firstValue(
      List<dynamic Function()> getters,
      ) {
    for (final getter in getters) {
      try {
        final dynamic value = getter();

        if (value == null) {
          continue;
        }

        final String text =
        value.toString().trim();

        if (text.isEmpty ||
            text.toLowerCase() == 'null') {
          continue;
        }

        return text;
      } catch (_) {
        // Field doesn't exist
      }
    }

    return '';
  }

  // ================================================================
  // IMAGE URL
  // ================================================================
  static String _buildImageUrl(
      String value,
      String baseUrl,
      ) {
    final String rawUrl =
    value.trim();

    if (rawUrl.isEmpty) {
      return '';
    }

    if (rawUrl.startsWith('http://') ||
        rawUrl.startsWith('https://')) {
      return rawUrl;
    }

    if (baseUrl.trim().isEmpty) {
      return '';
    }

    String base =
    baseUrl.trim();

    String path =
        rawUrl;

    if (base.endsWith('/')) {
      base =
          base.substring(
            0,
            base.length - 1,
          );
    }

    if (path.startsWith('/')) {
      path =
          path.substring(1);
    }

    return '$base/$path';
  }
}