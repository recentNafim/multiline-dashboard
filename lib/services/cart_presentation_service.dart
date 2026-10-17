import '../models/cart_item.dart';
import 'presentation_bridge.dart';

class CartPresentationService {
  static Future<void> generate({
    required List<CartItem> items,
    String imageBaseUrl = '',
  }) async {
    if (items.isEmpty) throw StateError('Cart is empty');
    final entries = items.map((line) {
      final p = line.product;
      final String url = p.fileUrl.startsWith('http')
          ? p.fileUrl
          : '${imageBaseUrl.replaceFirst(RegExp(r"/+$"), '')}/${p.fileUrl.replaceFirst(RegExp(r"^/+"), '')}';
      return <String, Object?>{
        'itemCode': p.itemCode,
        'description': p.description,
        'itemName': p.description,
        'business': p.business,
        'category': p.productCategory,
        'subCategory': p.subCategory,
        'color': '',
        'uom': p.uom,
        'unitPrice': '',
        'quantity': line.quantity,
        'sizeRange': p.sizeRange,
        'moq': p.moq,
        'imageUrl': url,
        'images': p.imageUrls,
      };
    }).toList();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    await generateProductPresentation(entries, 'display-room-products-$stamp.pptx');
  }
}
