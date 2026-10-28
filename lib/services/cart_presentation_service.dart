import '../models/cart_item.dart';
import '../models/product_model.dart';
import 'presentation_bridge.dart';

/// Maps all available server-backed fields to the browser PowerPoint generator.
/// No fabricated values: missing information is shown as "Not specified".
class CartPresentationService {
  static String _number(num v) => v == v.roundToDouble()
      ? v.toInt().toString()
      : v.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');

  static String _toUrl(String input, String base) {
    final u = input.trim();
    if (u.isEmpty) return '';
    if (u.startsWith('https://') || u.startsWith('http://')) return u;
    if (u.startsWith('/ords/')) {
      final parsed = Uri.tryParse(base);
      if (parsed != null && parsed.hasAuthority) {
        return '${parsed.scheme}://${parsed.authority}$u';
      }
    }
    return '${base.replaceFirst(RegExp(r"/+$"), "")}/${u.replaceFirst(RegExp(r"^/+"), "").split('/').map(Uri.encodeComponent).join('/')}';
  }

  static String _cbm(ProductModel p) => p.cbmRaw.trim().isNotEmpty
      ? p.cbmRaw
      : (p.cbm > 0 ? _number(p.cbm) : '');

  static Future<void> generate({
    required List<CartItem> items,
    String imageBaseUrl = '',
  }) async {
    if (items.isEmpty) throw StateError('Cart is empty');

    final entries = items.map((row) {
      final p = row.product;
      final urls = <String>[];
      final seen = <String>{};
      for (final u in [...p.imageUrls, p.fileUrl]) {
        final normalized = _toUrl(u, imageBaseUrl);
        if (normalized.isNotEmpty && seen.add(normalized)) urls.add(normalized);
      }
      return <String, Object?>{
        'itemCode': p.itemCode,
        'description': p.description,
        'itemName': p.description,
        'business': p.business,
        'category': p.productCategory,
        'subCategory': p.subCategory,
        'organizationId': p.organizationId > 0 ? p.organizationId : null,
        'displayRoom': p.displayRoomName,
        'status': p.status,
        'subInventory': p.subInventoryCode,
        'material': p.materialSpecification,
        'weightG': p.weight > 0 ? p.weight : null,
        'cbm': _cbm(p),
        'fob': p.fob,
        'uom': p.uom,
        'quantity': row.quantity, // Cart-selected units; NOT MOQ.
        'sizeRange': p.sizeRange,
        'moq': p.moq > 0 ? p.moq : null,
        'imageUrl': urls.isNotEmpty ? urls.first : '',
        'images': urls.take(5).toList(),
      };
    }).toList();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    await generateProductPresentation(
      entries, 'Display_Room_FULL_INFO_V6_$stamp.pptx');
  }
}
