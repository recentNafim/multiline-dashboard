import '../models/cart_item.dart';
import 'presentation_bridge.dart';

/// PowerPoint report payload for the matching premium PDF catalogue.
///
/// Source fields are taken from the actual GET product model. Deliberately
/// does not send the cart quantity: the client requested to remove Qty from
/// both Summary and Product Details in the presentation.
class CartPresentationService {
  static Future<void> generate({
    required List<CartItem> items,
    String imageBaseUrl = '',
  }) async {
    if (items.isEmpty) throw StateError('Cart is empty');

    String absoluteImageUrl(String raw) {
      final value = raw.trim();
      if (value.isEmpty) return '';
      if (value.startsWith('https://') || value.startsWith('http://') ||
          value.startsWith('data:image/')) {
        return value;
      }
      final base = imageBaseUrl.replaceFirst(RegExp(r'/+$'), '');
      if (base.isEmpty) return '';
      return '$base/${value.replaceFirst(RegExp(r'^/+'), '')}';
    }

    final entries = items.map((line) {
      final p = line.product;
      final imageUrls = <String>[];
      final seen = <String>{};

      void addImage(String value) {
        final url = absoluteImageUrl(value);
        if (url.isNotEmpty && seen.add(url)) imageUrls.add(url);
      }

      for (final image in p.imageUrls) {
        addImage(image);
      }
      addImage(p.fileUrl);

      return <String, Object?>{
        'itemCode': p.itemCode,
        'description': p.description,
        'itemName': p.description,
        'business': p.business,
        'category': p.productCategory,
        'subCategory': p.subCategory,
        'uom': p.uom,
        'sizeRange': p.sizeRange,
        'moq': p.moq,
        'fob': p.fob,
        'weight': p.weight,
        'cbm': p.cbm,
        'material': p.materialSpecification,
        'subInventory': p.subInventoryCode,
        'organizationId': p.organizationId,
        'displayRoom': p.displayRoomName,
        'status': p.status,
        'imageUrl': imageUrls.isEmpty ? '' : imageUrls.first,
        'images': imageUrls,
      };
    }).toList();

    final stamp = DateTime.now().millisecondsSinceEpoch;
    await generateProductPresentation(
      entries,
      'display-room-premium-lookbook-$stamp.pptx',
    );
  }
}
