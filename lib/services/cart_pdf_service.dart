import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/cart_item.dart';

/// Premium Display Room lookbook.
///
/// Restores the original catalogue style:
/// cover -> product selection index -> product detail + photo gallery per
/// product -> thank-you page. This intentionally keeps the report generator
/// separate from the Cart/Filter UI and does not change cart quantities.
class CartPdfService {
  CartPdfService._();

  static final PdfColor _ink = PdfColor.fromInt(0xFF17272C);
  static final PdfColor _ink2 = PdfColor.fromInt(0xFF23363B);
  static final PdfColor _mint = PdfColor.fromInt(0xFFC7EFE7);
  static final PdfColor _coral = PdfColor.fromInt(0xFFF58270);
  static final PdfColor _muted = PdfColor.fromInt(0xFF64747A);
  static final PdfColor _line = PdfColor.fromInt(0xFFDCE3E3);
  static final PdfColor _paper = PdfColor.fromInt(0xFFF7F8F7);

  static const double _pageWidth = 595.28;
  static const double _pageHeight = 841.89;

  static Future<Uint8List> buildPdf({
    required List<CartItem> items,
    String imageBaseUrl = '',
  }) async {
    final doc = pw.Document(
      title: 'Display Room | Premium Product Lookbook',
      author: 'Display Room',
      creator: 'Display Room Flutter Application',
      compress: true,
    );
    if (items.isEmpty) return doc.save();

    // Fetch gallery images once per unique URL. Each product is loaded in
    // parallel; a missing or unsupported image leaves a clean placeholder.
    final imageCache = <String, Future<pw.MemoryImage?>>{};
    final galleries = await Future.wait(
      items.map((item) => _loadGallery(
            item,
            imageBaseUrl,
            imageCache,
          )),
    );

    final generated = DateTime.now().toLocal();
    final dateLabel = '${_two(generated.day)}.${_two(generated.month)}.${generated.year}';
    final totalUnits = items.fold<int>(0, (sum, row) => sum + row.quantity);

    doc.addPage(_coverPage(items, galleries, totalUnits, dateLabel));

    // Multiple selection pages prevent overflowing A4 for a large cart.
    const perIndexPage = 12;
    final indexPageCount = (items.length / perIndexPage).ceil();
    for (var index = 0; index < indexPageCount; index++) {
      final start = index * perIndexPage;
      final end = (start + perIndexPage < items.length)
          ? start + perIndexPage
          : items.length;
      doc.addPage(_selectionPage(
        items.sublist(start, end),
        start,
        index + 1,
        indexPageCount,
        2 + index,
      ));
    }

    for (var i = 0; i < items.length; i++) {
      final pageNumber = 2 + indexPageCount + (i * 2);
      doc.addPage(_productPage(
        items[i],
        galleries[i],
        i,
        items.length,
        pageNumber,
      ));
      doc.addPage(_galleryPage(
        items[i],
        galleries[i],
        i,
        pageNumber + 1,
      ));
    }

    doc.addPage(_thankYouPage(items.length, totalUnits, dateLabel));
    return doc.save();
  }

  static pw.Page _coverPage(
    List<CartItem> items,
    List<List<pw.MemoryImage?>> galleries,
    int totalUnits,
    String dateLabel,
  ) {
    final firstImage = galleries.isNotEmpty && galleries.first.isNotEmpty
        ? galleries.first.first
        : null;
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (_) => pw.SizedBox(
        width: _pageWidth,
        height: _pageHeight,
        child: pw.Stack(
        children: [
          pw.Positioned(
            left: 0, top: 0,
            child: pw.SizedBox(width: _pageWidth, height: _pageHeight,
                child: pw.Container(color: _ink)),
          ),
          pw.Positioned(
            right: 0, top: 0,
            child: pw.SizedBox(width: 116, height: _pageHeight,
                child: pw.Container(color: _ink2)),
          ),
          pw.Positioned(
            right: 0, top: 0,
            child: pw.SizedBox(width: 10, height: _pageHeight,
                child: pw.Container(color: _coral)),
          ),
          pw.Positioned(
            left: 44, top: 64,
            child: _text('THE PRODUCT EDIT / AUTOMATED CATALOGUE',
                9, PdfColors.white, bold: true),
          ),
          pw.Positioned(
            left: 44, top: 147,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _text('DISPLAY', 58, PdfColors.white, bold: true),
                _text('ROOM', 58, PdfColors.white, bold: true),
                pw.SizedBox(height: 15),
                _text('Premium Product Lookbook', 20, _mint, bold: true),
                pw.SizedBox(height: 9),
                pw.SizedBox(
                  width: 420,
                  child: _text(
                      'A curated catalogue of your selected products, '
                      'photographs and available specifications.',
                      11, PdfColors.white),
                ),
              ],
            ),
          ),
          pw.Positioned(
            left: 44, top: 425,
            child: pw.Row(children: [
              _pill('${items.length} PRODUCTS', _mint, _ink),
              pw.SizedBox(width: 10),
              _pill('$totalUnits SELECTED UNITS', _coral, PdfColors.white),
            ]),
          ),
          pw.Positioned(
            left: 44, top: 493,
            child: pw.SizedBox(width: 502, height: 270,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  color: PdfColors.white,
                  child: _photo(firstImage, 476, 246),
                )),
          ),
          pw.Positioned(
            left: 44, top: 798,
            child: _text('GENERATED $dateLabel', 9, PdfColors.white,
                bold: true),
          ),
        ],
        ),
      ),
    );
  }

  static pw.Page _selectionPage(
    List<CartItem> rows,
    int offset,
    int index,
    int indexCount,
    int pageNumber,
  ) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(24, 30, 24, 24),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _pill('CURATED SELECTION', _mint, _ink),
          pw.SizedBox(height: 20),
          _text('Products at a glance', 29, _ink, bold: true),
          pw.SizedBox(height: 8),
          _text('MOQ = minimum order quantity  |  Qty = selected cart quantity',
              9.5, _muted),
          pw.SizedBox(height: 21),
          _indexRow(
            '#', 'PRODUCT', 'SIZE', 'MOQ', 'QTY', header: true,
          ),
          ...rows.asMap().entries.map((e) {
            final p = e.value.product;
            return _indexRow(
              '${offset + e.key + 1}',
              _productName(p.description, p.itemCode),
              _value(p.sizeRange),
              '${_fmt(p.moq)} ${p.uom}'.trim(),
              '${e.value.quantity}',
              alternate: e.key.isOdd,
            );
          }),
          pw.Spacer(),
          _footer('SELECTION INDEX',
              indexCount > 1 ? 'GROUP $index OF $indexCount' : 'GROUP 1',
              pageNumber),
        ],
      ),
    );
  }

  static pw.Widget _indexRow(
    String no,
    String product,
    String size,
    String moq,
    String qty, {
    bool header = false,
    bool alternate = false,
  }) {
    final fg = header ? PdfColors.white : _ink;
    return pw.Container(
      height: header ? 33 : 40,
      padding: const pw.EdgeInsets.symmetric(horizontal: 11),
      color: header ? _ink : (alternate ? _paper : PdfColors.white),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.SizedBox(width: 31, child: _text(no, 9, fg, bold: header)),
          pw.Expanded(flex: 7,
              child: _text(product, 9, fg, bold: header, maxLines: 1)),
          pw.Expanded(flex: 2,
              child: _text(size, 9, fg, bold: header, maxLines: 1)),
          pw.Expanded(flex: 3,
              child: _text(moq, 9, fg, bold: header, maxLines: 1)),
          pw.SizedBox(width: 34, child: _text(qty, 9, fg, bold: header)),
        ],
      ),
    );
  }

  static pw.Page _productPage(
    CartItem item,
    List<pw.MemoryImage?> photos,
    int productIndex,
    int total,
    int pageNumber,
  ) {
    final p = item.product;
    final firstImage = photos.isNotEmpty ? photos.first : null;
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(24, 21, 24, 24),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            height: 64,
            padding: const pw.EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: pw.BoxDecoration(
              color: _ink,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(children: [
              pw.Expanded(child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  _text('PRODUCT ${_two(productIndex + 1)} / ${_two(total)}',
                      7.5, _mint, bold: true),
                  pw.SizedBox(height: 5),
                  _text(_productName(p.description, p.itemCode),
                      16, PdfColors.white, bold: true, maxLines: 1),
                ],
              )),
              _pill('CART ${item.quantity}', _coral, PdfColors.white),
            ]),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            height: 190,
            width: double.infinity,
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _line),
              borderRadius: pw.BorderRadius.circular(9),
            ),
            child: _photo(firstImage, 520, 175),
          ),
          pw.SizedBox(height: 13),
          pw.Row(children: [
            pw.Expanded(child: _highlight(
              'SIZE RANGE', _value(p.sizeRange), _mint, _ink,
            )),
            pw.SizedBox(width: 11),
            pw.Expanded(child: _highlight(
              'MINIMUM ORDER QUANTITY',
              '${_fmt(p.moq)} ${p.uom}'.trim(), _ink, PdfColors.white,
            )),
          ]),
          pw.SizedBox(height: 14),
          pw.Row(children: [
            pw.Container(width: 4, height: 15, color: _coral),
            pw.SizedBox(width: 8),
            _text('Full product information', 11.5, _ink, bold: true),
          ]),
          pw.SizedBox(height: 9),
          _specRow('ITEM CODE', p.itemCode, 'BUSINESS', p.business),
          _specRow('CATEGORY', p.productCategory, 'SUB CATEGORY', p.subCategory),
          _specRow('UOM', p.uom, 'WEIGHT',
              p.weight > 0 ? '${_fmt(p.weight)} g' : '-'),
          _specRow('FOB', p.fob > 0 ? _fmt(p.fob) : '-',
              'CBM', p.cbm > 0 ? '${_fmt(p.cbm)} CBM' : '-'),
          _specRow('MATERIAL', p.materialSpecification,
              'SUB INVENTORY', p.subInventoryCode),
          _specRow('ORGANIZATION ID', '${p.organizationId}',
              'DISPLAY ROOM', p.displayRoomName),
          _specRow('STATUS', p.status, 'CART QUANTITY', '${item.quantity}'),
          pw.Spacer(),
          _footer('AVAILABLE PHOTOS ${photos.where((p) => p != null).length}',
              'DISPLAY ROOM / PRODUCT LOOKBOOK', pageNumber),
        ],
      ),
    );
  }

  static pw.Page _galleryPage(
    CartItem item,
    List<pw.MemoryImage?> photos,
    int productIndex,
    int pageNumber,
  ) {
    final p = item.product;
    final gallery = photos.isEmpty ? <pw.MemoryImage?>[null] : photos;
    // Show up to four photos on one page, two per row. Duplicate photos are
    // not added by the loader unless that is all the API actually returned.
    final display = gallery.take(4).toList();
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(24, 30, 24, 24),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _pill('PRODUCT ${productIndex + 1} / IMAGE GALLERY', _mint, _ink),
          pw.SizedBox(height: 22),
          _text(_productName(p.description, p.itemCode), 30, _ink,
              bold: true, maxLines: 2),
          pw.SizedBox(height: 10),
          _text('Additional product photographs supplied by the server.',
              10.5, _muted),
          pw.SizedBox(height: 25),
          for (var start = 0; start < display.length; start += 2) ...[
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(child: _galleryCard(
                  display[start], start + 1,
                  height: display.length > 2 ? 204 : 292,
                )),
                pw.SizedBox(width: 15),
                pw.Expanded(child: start + 1 < display.length
                    ? _galleryCard(display[start + 1], start + 2,
                        height: display.length > 2 ? 204 : 292)
                    : pw.SizedBox()),
              ],
            ),
            pw.SizedBox(height: 16),
          ],
          pw.Spacer(),
          _footer('DISPLAY ROOM / PRODUCT LOOKBOOK', '', pageNumber),
        ],
      ),
    );
  }

  static pw.Page _thankYouPage(
      int products, int totalUnits, String dateLabel) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (_) => pw.SizedBox(
        width: _pageWidth,
        height: _pageHeight,
        child: pw.Stack(children: [
        pw.Positioned(left: 0, top: 0,
            child: pw.SizedBox(width: _pageWidth, height: _pageHeight,
                child: pw.Container(color: _ink))),
        pw.Positioned(left: 0, top: 0,
            child: pw.SizedBox(width: _pageWidth, height: 9,
                child: pw.Container(color: _coral))),
        pw.Positioned(left: 58, top: 100,
            child: _text('DISPLAY ROOM / PRODUCT LOOKBOOK',
                9, _mint, bold: true)),
        pw.Positioned(
          left: 58, top: 328,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _text('THANK YOU', 55, PdfColors.white, bold: true),
              pw.SizedBox(height: 17),
              _text('Your selected products, all in one place.',
                  15, PdfColors.white),
              pw.SizedBox(height: 55),
              pw.Row(children: [
                _pill('$products PRODUCTS', _mint, _ink),
                pw.SizedBox(width: 10),
                _pill('$totalUnits SELECTED UNITS', _coral, PdfColors.white),
              ]),
            ],
          ),
        ),
        pw.Positioned(left: 58, top: 792,
            child: _text('GENERATED $dateLabel', 9, PdfColors.white,
                bold: true)),
        ]),
      ),
    );
  }

  static pw.Widget _galleryCard(pw.MemoryImage? photo, int number,
      {required double height}) {
    return pw.Column(
      children: [
        pw.Container(
          height: height,
          width: double.infinity,
          padding: const pw.EdgeInsets.all(9),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _line),
            borderRadius: pw.BorderRadius.circular(11),
          ),
          child: _photo(photo, 245, height - 18),
        ),
        pw.SizedBox(height: 7),
        _text('VIEW $number', 9, PdfColor.fromInt(0xFF208778), bold: true),
      ],
    );
  }

  static pw.Widget _specRow(
      String aLabel, String aValue, String bLabel, String bValue) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(children: [
        pw.Expanded(child: _specCell(aLabel, aValue)),
        pw.SizedBox(width: 10),
        pw.Expanded(child: _specCell(bLabel, bValue)),
      ]),
    );
  }

  static pw.Widget _specCell(String label, String value) {
    return pw.Container(
      height: 37,
      padding: const pw.EdgeInsets.fromLTRB(8, 5, 7, 3),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _line),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          _text(label, 6.5, _muted, bold: true, maxLines: 1),
          pw.SizedBox(height: 3),
          _text(_value(value), 8.7, _ink, bold: true, maxLines: 1),
        ],
      ),
    );
  }

  static pw.Widget _highlight(
      String label, String value, PdfColor bg, PdfColor fg) {
    return pw.Container(
      height: 61,
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: pw.BorderRadius.circular(7),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          _text(label, 7.1, fg, bold: true),
          pw.SizedBox(height: 8),
          _text(_value(value), 15, fg, bold: true, maxLines: 1),
        ],
      ),
    );
  }

  static pw.Widget _footer(String left, String right, int pageNumber) {
    return pw.Column(children: [
      pw.Container(height: 0.7, color: _line),
      pw.SizedBox(height: 8),
      pw.Row(children: [
        pw.Expanded(child: _text(left, 7.5, _muted, bold: true)),
        _text(right, 7.5, PdfColor.fromInt(0xFF208778), bold: true),
      ]),
      pw.SizedBox(height: 9),
      pw.Row(children: [
        pw.Expanded(child: _text('DISPLAY ROOM / PRODUCT LOOKBOOK',
            7.5, _muted)),
        _text('$pageNumber', 8, PdfColor.fromInt(0xFF208778), bold: true),
      ]),
    ]);
  }

  static pw.Widget _photo(pw.MemoryImage? photo, double width, double height) {
    if (photo == null) {
      return pw.Container(
        width: width,
        height: height,
        alignment: pw.Alignment.center,
        color: _paper,
        child: _text('Product image not available', 10, _muted),
      );
    }
    return pw.Center(
      child: pw.Image(photo, width: width, height: height,
          fit: pw.BoxFit.contain),
    );
  }

  static pw.Widget _pill(String value, PdfColor bg, PdfColor fg) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: pw.BorderRadius.circular(20),
      ),
      child: _text(value, 8, fg, bold: true),
    );
  }

  static pw.Widget _text(String value, double size, PdfColor color,
      {bool bold = false, int? maxLines}) {
    return pw.Text(
      value,
      maxLines: maxLines,
      overflow: maxLines == null ? pw.TextOverflow.visible : pw.TextOverflow.clip,
      style: pw.TextStyle(
        color: color,
        fontSize: size,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    );
  }

  static String _value(String? text) {
    final result = (text ?? '').trim();
    return result.isEmpty ? '-' : result;
  }

  static String _productName(String name, String fallback) =>
      name.trim().isEmpty ? fallback : name.trim();

  static String _fmt(num value) =>
      value == value.truncateToDouble()
          ? value.toInt().toString()
          : value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');

  static String _two(int value) => value.toString().padLeft(2, '0');

  static Future<List<pw.MemoryImage?>> _loadGallery(
    CartItem item,
    String imageBaseUrl,
    Map<String, Future<pw.MemoryImage?>> cache,
  ) async {
    final p = item.product;
    final urls = <String>[];
    final seen = <String>{};
    for (final original in [...p.imageUrls, p.fileUrl]) {
      final url = _resolvedUrl(original, imageBaseUrl);
      if (url.isNotEmpty && seen.add(url)) urls.add(url);
      if (urls.length >= 4) break;
    }
    if (urls.isEmpty) return [null];
    final photos = await Future.wait(urls.map(
      (url) => cache.putIfAbsent(url, () => _download(url)),
    ));
    final available = photos.whereType<pw.MemoryImage>().toList();
    return available.isEmpty ? [null] : available;
  }

  static String _resolvedUrl(String original, String imageBaseUrl) {
    final trimmed = original.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return '';
    final absolute = Uri.tryParse(trimmed);
    if (absolute != null &&
        (absolute.scheme == 'https' || absolute.scheme == 'http') &&
        absolute.host.isNotEmpty) {
      return trimmed;
    }
    final base = imageBaseUrl.replaceFirst(RegExp(r'/+$'), '');
    if (base.isEmpty) return '';
    return '$base/${trimmed.replaceFirst(RegExp(r'^/+'), '')}';
  }

  static Future<pw.MemoryImage?> _download(String url) async {
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Accept': 'image/jpeg,image/png,image/*',
      }).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) return null;
      // dart_pdf reliably accepts JPEG/PNG. Gracefully skip other formats.
      final bytes = response.bodyBytes;
      final jpeg = bytes.length > 2 && bytes[0] == 0xFF && bytes[1] == 0xD8;
      final png = bytes.length > 4 &&
          bytes[0] == 0x89 && bytes[1] == 0x50 &&
          bytes[2] == 0x4E && bytes[3] == 0x47;
      if (!jpeg && !png) return null;
      return pw.MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }
}
