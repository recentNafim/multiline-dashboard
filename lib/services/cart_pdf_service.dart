import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/cart_item.dart';

class CartPdfService {
  static Future<Uint8List> buildPdf({
    required List<CartItem> items,
    String imageBaseUrl = '',
  }) async {
    final doc = pw.Document(
      title: 'Display Room Product Catalogue', author: 'Display Room',
    );
    if (items.isEmpty) return doc.save();

    final List<pw.Widget> content = [
      pw.Text('DISPLAY ROOM PRODUCT CATALOGUE',
        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 10),
      pw.Text('Prepared: ${DateTime.now().toLocal()}  |  Selected items: ${items.length}',
        style: const pw.TextStyle(fontSize: 9)),
      pw.SizedBox(height: 14),
    ];

    for (final row in items) {
      final p = row.product;
      pw.ImageProvider? photo;
      var url = p.imageUrls.isNotEmpty ? p.imageUrls.first : p.fileUrl;
      if (url.trim().isNotEmpty && !url.startsWith('http')) {
        url = '${imageBaseUrl.replaceFirst(RegExp(r"/+$"), '')}/${url.replaceFirst(RegExp(r"^/+"), '')}';
      }
      if (url.startsWith('http')) {
        try {
          final response = await http.get(Uri.parse(url))
              .timeout(const Duration(seconds: 7));
          if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
            photo = pw.MemoryImage(response.bodyBytes);
          }
        } catch (_) {
          // A missing picture must not prevent the catalogue from exporting.
        }
      }
      content.add(pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 14),
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(7)),
        ),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 100, height: 96,
              alignment: pw.Alignment.center,
              color: PdfColors.grey100,
              child: photo == null
                  ? pw.Text('Image unavailable', style: const pw.TextStyle(fontSize: 9))
                  : pw.Image(photo, fit: pw.BoxFit.contain),
            ),
            pw.SizedBox(width: 12),
            pw.Expanded(child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(p.description.isNotEmpty ? p.description : p.itemCode,
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text('Item code: ${p.itemCode}'),
                pw.Text('Business: ${p.business}'),
                pw.Text('Category: ${p.productCategory}'),
                pw.Text('Size Range: ${p.sizeRange.isEmpty ? '-' : p.sizeRange}'),
                pw.Text('MOQ: ${p.moq} ${p.uom}'),
                pw.Text('Cart quantity: ${row.quantity}'),
              ],
            )),
          ],
        ),
      ));
    }
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(30),
      build: (_) => content,
      footer: (_) => pw.Center(child: pw.Text('Display Room Product Selection',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700))),
    ));
    return doc.save();
  }
}
