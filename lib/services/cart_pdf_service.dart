import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/cart_item.dart';
import '../models/product_model.dart';

/// DISPLAY ROOM | STUDIO EDITION
/// Premium A4 client catalogue automatically built from Cart products.
/// MOQ and selected Cart quantity are separate. Data never invented.
/// For product images, original image bytes are downloaded as returned by ORDS.
class CartPdfService {
  static final PdfColor _dark = PdfColor.fromHex('#17242A');
  static final PdfColor _dark2 = PdfColor.fromHex('#24343A');
  static final PdfColor _teal = PdfColor.fromHex('#087F77');
  static final PdfColor _coral = PdfColor.fromHex('#EF806B');
  static final PdfColor _aqua = PdfColor.fromHex('#C7EEE6');
  static final PdfColor _cream = PdfColor.fromHex('#FAF8F3');
  static final PdfColor _warm = PdfColor.fromHex('#F2F0EA');
  static final PdfColor _muted = PdfColor.fromHex('#67777B');
  static final PdfColor _border = PdfColor.fromHex('#DEE5E2');

  static String _value(String? v, [String fallback = 'Not provided']) {
    final s = (v ?? '').trim();
    return s.isEmpty || s.toLowerCase() == 'null' ? fallback : s;
  }

  static String _num(num v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  static String _moq(ProductModel p) => p.moq > 0
      ? '${_num(p.moq)} ${_value(p.uom, '')}'.trim()
      : 'Not provided';

  static String _fob(ProductModel p) => p.fob == null
      ? 'Not provided'
      : _num(p.fob!); // Never assume a currency not supplied by the API.

  static String _cbm(ProductModel p) => p.cbmRaw.trim().isNotEmpty
      ? p.cbmRaw.trim()
      : (p.cbm > 0 ? _num(p.cbm) : 'Not provided');

  static String _today(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  static String _imageUrl(String raw, String base) {
    final u = raw.trim();
    if (u.isEmpty) return '';
    if (u.startsWith('https://') || u.startsWith('http://')) return u;
    final parsed = Uri.tryParse(base);
    if (u.startsWith('/ords/') && parsed != null && parsed.hasAuthority) {
      return '${parsed.scheme}://${parsed.authority}$u';
    }
    final path = u.replaceFirst(RegExp(r'^/+'), '');
    final encoded = path.split('/').map(Uri.encodeComponent).join('/');
    return '${base.replaceFirst(RegExp(r'/+$'), '')}/$encoded';
  }

  static pw.Widget _txt(String value,
      {double size = 10,
      bool bold = false,
      PdfColor? color,
      int lines = 2,
      pw.TextAlign? align}) =>
      pw.Text(value,
          maxLines: lines,
          overflow: pw.TextOverflow.clip,
          textAlign: align,
          style: pw.TextStyle(
            fontSize: size,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color ?? _dark,
          ));

  static pw.Widget _pill(String value,
      {PdfColor? background, PdfColor? color}) =>
      pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: pw.BoxDecoration(
              color: background ?? _aqua,
              borderRadius:
                  const pw.BorderRadius.all(pw.Radius.circular(15))),
          child: _txt(value,
              size: 8.1, bold: true, color: color ?? _dark, lines: 1));

  static pw.Widget _section(String title) => pw.Row(children: [
        pw.Container(width: 5, height: 18, color: _coral),
        pw.SizedBox(width: 9),
        _txt(title, size: 12, bold: true)
      ]);

  static pw.Widget _field(String label, String value,
          {double width = 254, double height = 35}) =>
      pw.Container(
        width: width,
        height: height,
        padding: const pw.EdgeInsets.fromLTRB(10, 6, 10, 5),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: _border),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(7)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _txt(label.toUpperCase(), size: 6.7, color: _muted, bold: true, lines: 1),
            pw.SizedBox(height: 3),
            _txt(value, size: 9.6, bold: true, lines: 1),
          ],
        ),
      );

  static pw.Widget _stat(String label, String value,
      {PdfColor? background, PdfColor? textColor, double width = 254}) =>
      pw.Container(
        width: width,
        height: 61,
        padding: const pw.EdgeInsets.fromLTRB(13, 10, 13, 8),
        decoration: pw.BoxDecoration(
          color: background ?? _aqua,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(9)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _txt(label.toUpperCase(),
                size: 7.3, bold: true, color: textColor ?? _teal),
            pw.SizedBox(height: 7),
            _txt(value,
                size: 17, bold: true, color: textColor ?? _dark, lines: 1)
          ],
        ),
      );

  static pw.Widget _image(pw.ImageProvider? source,
      {double height = 187, double width = double.infinity}) =>
      pw.Container(
        height: height,
        width: width,
        alignment: pw.Alignment.center,
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: _border),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        ),
        child: source == null
            ? _txt('Product image unavailable', color: _muted, size: 10)
            : pw.Image(source,
                height: height - 20, fit: pw.BoxFit.contain),
      );

  static pw.Widget _foot(pw.Context ctx) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _txt('DISPLAY ROOM  /  PRODUCT LOOKBOOK',
              size: 7.1, bold: true, color: _muted),
          _txt('${ctx.pageNumber}', size: 8, color: _teal, bold: true)
        ],
      );

  static pw.Page _cover(List<CartItem> items, DateTime date,
      pw.ImageProvider? hero) {
    final units = items.fold<int>(0, (v, x) => v + x.quantity);
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) => pw.Stack(children: [
        pw.Container(width: 595, height: 842, color: _dark),
        pw.Positioned(
            left: 0,
            top: 0,
            child: pw.Container(height: 842, width: 9, color: _coral)),
        pw.Positioned(
            right: 0,
            top: 0,
            child: pw.Container(height: 842, width: 151, color: _dark2)),
        pw.Positioned(
          top: 64,
          left: 45,
          child: _txt('THE PRODUCT EDIT  /  AUTOMATED CATALOGUE',
              size: 9, color: _aqua, bold: true, lines: 1),
        ),
        pw.Positioned(
          top: 133,
          left: 45,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _txt('DISPLAY', size: 51, color: PdfColors.white, bold: true),
              _txt('ROOM', size: 51, color: PdfColors.white, bold: true),
              pw.SizedBox(height: 15),
              _txt('Premium Product Lookbook',
                  size: 17, color: _aqua, bold: true),
              pw.SizedBox(height: 11),
              pw.SizedBox(
                width: 435,
                child: _txt(
                  'A curated catalogue of your selected products, photographs and available specifications.',
                  size: 11, color: PdfColors.white, lines: 3),
              ),
            ],
          ),
        ),
        pw.Positioned(
          top: 391,
          left: 45,
          child: pw.Row(children: [
            _pill('${items.length} PRODUCTS',
                background: _aqua, color: _dark),
            pw.SizedBox(width: 11),
            _pill('$units SELECTED UNITS',
                background: _coral, color: PdfColors.white),
          ]),
        ),
        pw.Positioned(
          top: 469,
          left: 45,
          child: pw.Container(
            width: 502,
            height: 282,
            padding: const pw.EdgeInsets.all(15),
            color: PdfColors.white,
            alignment: pw.Alignment.center,
            child: hero == null
                ? _txt('PRODUCT SELECTION', size: 24, color: _muted)
                : pw.Image(hero, fit: pw.BoxFit.contain, height: 252),
          ),
        ),
        pw.Positioned(
          bottom: 39,
          left: 45,
          child: _txt('GENERATED ${_today(date)}',
              color: PdfColors.white, size: 9, bold: true),
        ),
      ]),
    );
  }

  static pw.Page _overview(List<CartItem> items, int offset, int pageCount) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(36, 36, 36, 32),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _pill('CURATED SELECTION'),
          pw.SizedBox(height: 14),
          _txt('Products at a glance', size: 25, bold: true),
          pw.SizedBox(height: 7),
          _txt('MOQ = minimum order quantity  |  Qty = selected cart quantity',
              size: 9, color: _muted),
          pw.SizedBox(height: 20),
          pw.Table(
            columnWidths: {
              0: const pw.FlexColumnWidth(.35),
              1: const pw.FlexColumnWidth(2.25),
              2: const pw.FlexColumnWidth(1.05),
              3: const pw.FlexColumnWidth(1.22),
              4: const pw.FlexColumnWidth(.45),
            },
            border: pw.TableBorder(horizontalInside: pw.BorderSide(color: _border)),
            children: [
              pw.TableRow(
                  decoration: pw.BoxDecoration(color: _dark),
                  children: [
                    for (final head in ['#', 'PRODUCT', 'SIZE', 'MOQ', 'QTY'])
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(9),
                          child: _txt(head,
                              color: PdfColors.white, size: 8, bold: true))
                  ]),
              for (var i = 0; i < items.length; i++)
                pw.TableRow(
                    decoration: pw.BoxDecoration(
                        color: i.isEven ? PdfColors.white : _cream),
                    children: [
                      for (final v in [
                        '${offset + i + 1}',
                        _value(items[i].product.description),
                        _value(items[i].product.sizeRange, '—'),
                        _moq(items[i].product),
                        '${items[i].quantity}',
                      ])
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(9),
                            child: _txt(v, size: 8.5, lines: 2))
                    ]),
            ],
          ),
          pw.Spacer(),
          pw.Divider(color: _border),
          pw.SizedBox(height: 8),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            _txt('SELECTION INDEX', color: _muted, size: 8, bold: true),
            _txt('GROUP $pageCount', color: _teal, size: 8, bold: true),
          ]),
          pw.SizedBox(height: 8),
          _foot(ctx),
        ],
      ),
    );
  }

  static pw.Page _product(CartItem item, int index, int total,
      List<pw.ImageProvider?> images) {
    final p = item.product;
    final fields = <List<String>>[
      ['Item Code', _value(p.itemCode)],
      ['Business', _value(p.business)],
      ['Category', _value(p.productCategory)],
      ['Sub Category', _value(p.subCategory)],
      ['UOM', _value(p.uom)],
      ['Weight', p.weight > 0 ? '${_num(p.weight)} g' : 'Not provided'],
      ['FOB', _fob(p)],
      ['CBM', _cbm(p)],
      ['Material', _value(p.materialSpecification)],
      ['Sub Inventory', _value(p.subInventoryCode)],
      ['Organization ID', p.organizationId > 0 ? '${p.organizationId}' : 'Not provided'],
      ['Display Room', _value(p.displayRoomName)],
      ['Status', _value(p.status)],
      ['Cart Quantity', '${item.quantity}'],
    ];
    return pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 31, 36, 30),
        build: (ctx) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.fromLTRB(16, 12, 16, 12),
                  decoration: pw.BoxDecoration(
                      color: _dark,
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(10))),
                  child: pw.Row(children: [
                    pw.Expanded(
                        child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _txt('PRODUCT ${index.toString().padLeft(2, '0')} / ${total.toString().padLeft(2, '0')}',
                            color: _aqua, size: 8, bold: true),
                        pw.SizedBox(height: 6),
                        _txt(_value(p.description, 'Product $index'),
                            color: PdfColors.white, size: 19, bold: true),
                      ],
                    )),
                    pw.SizedBox(width: 12),
                    _pill('CART ${item.quantity}',
                        background: _coral, color: PdfColors.white)
                  ]),
                ),
                pw.SizedBox(height: 10),
                _image(images.isNotEmpty ? images.first : null, height: 193),
                pw.SizedBox(height: 11),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _stat('Size Range', _value(p.sizeRange)),
                    _stat('Minimum Order Quantity', _moq(p), background: _dark,
                        textColor: PdfColors.white),
                  ],
                ),
                pw.SizedBox(height: 11),
                _section('Full product information'),
                pw.SizedBox(height: 9),
                for (int i = 0; i < fields.length; i += 2) ...[
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        _field(fields[i][0], fields[i][1]),
                        _field(fields[i + 1][0], fields[i + 1][1]),
                      ]),
                  pw.SizedBox(height: 5),
                ],
                pw.Spacer(),
                pw.Divider(color: _border),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _txt('AVAILABLE PHOTOS  ${images.where((i) => i != null).length}',
                          color: _muted, size: 8),
                      _foot(ctx)
                    ])
              ],
            ));
  }

  static pw.Page _gallery(CartItem item, int productNumber,
      List<pw.ImageProvider?> group, int start) =>
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 36, 36, 32),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _pill('PRODUCT $productNumber  /  IMAGE GALLERY'),
            pw.SizedBox(height: 14),
            _txt(_value(item.product.description), size: 25, bold: true),
            pw.SizedBox(height: 7),
            _txt('Additional product photographs supplied by the server.',
                size: 9, color: _muted),
            pw.SizedBox(height: 18),
            for (int k = 0; k < group.length; k += 2) ...[
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Column(children: [
                  _image(group[k], height: 244, width: 254),
                  pw.SizedBox(height: 5),
                  _txt('VIEW ${start + k + 1}', bold: true, color: _teal, size: 8)
                ]),
                if (k + 1 < group.length)
                  pw.Column(children: [
                    _image(group[k + 1], height: 244, width: 254),
                    pw.SizedBox(height: 5),
                    _txt('VIEW ${start + k + 2}',
                        bold: true, color: _teal, size: 8)
                  ])
                else
                  pw.SizedBox(width: 254),
              ]),
              pw.SizedBox(height: 12),
            ],
            pw.Spacer(),
            pw.Divider(color: _border),
            _foot(ctx),
          ],
        ),
      );

  static pw.Page _closing(int products, int qty, DateTime date) => pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (_) => pw.Stack(children: [
        pw.Container(width: 595, height: 842, color: _dark),
        pw.Positioned(
            top: 0,
            left: 0,
            child: pw.Container(width: 595, height: 9, color: _coral)),
        pw.Positioned(
            left: 54,
            top: 106,
            child: _txt('DISPLAY ROOM  /  PRODUCT LOOKBOOK',
                color: _aqua, bold: true, size: 10)),
        pw.Positioned(
            left: 59,
            top: 318,
            child: _txt('THANK YOU',
                color: PdfColors.white, bold: true, size: 51)),
        pw.Positioned(
            left: 61,
            top: 399,
            child: _txt('Your selected products, all in one place.',
                color: PdfColors.white, size: 15)),
        pw.Positioned(
          top: 475,
          left: 59,
          child: pw.Row(children: [
            _pill('$products PRODUCTS', background: _aqua),
            pw.SizedBox(width: 12),
            _pill('$qty SELECTED UNITS', background: _coral, color: PdfColors.white),
          ]),
        ),
        pw.Positioned(
            bottom: 48,
            left: 61,
            child: _txt('GENERATED  ${_today(date)}',
                color: PdfColors.white, bold: true, size: 9))
      ]));

  static List<String> _urls(ProductModel p) {
    final seen = <String>{};
    final result = <String>[];
    for (final u in [...p.imageUrls, p.fileUrl]) {
      final trimmed = u.trim();
      if (trimmed.isNotEmpty && seen.add(trimmed)) result.add(trimmed);
    }
    return result.take(5).toList();
  }

  /// Used by the existing CartPage PDF button. No new packages needed.
  static Future<Uint8List> buildPdf({
    required List<CartItem> items,
    String imageBaseUrl = '',
  }) async {
    final pdf = pw.Document(
        title: 'Display Room | Studio Product Catalogue',
        author: 'Display Room',
        creator: 'Display Room Flutter Application',
        compress: true);
    if (items.isEmpty) return pdf.save();
    final now = DateTime.now();
    final urls = items.map((row) => _urls(row.product)
        .map((u) => _imageUrl(u, imageBaseUrl)).toList()).toList();
    final pictures = <String, pw.ImageProvider?>{};
    final unique = urls.expand((x) => x).where((x) => x.startsWith('http')).toSet().toList();
    final client = http.Client();
    try {
      // At most 4 HTTP requests in parallel, even with a very large cart.
      // Avoids a flood of image requests and repeatedly fetching a shared URL.
      var next = 0;
      Future<void> worker() async {
        while (next < unique.length) {
          final url = unique[next++];
          try {
            final res = await client.get(Uri.parse(url))
                .timeout(const Duration(seconds: 15));
            if (res.statusCode == 200 && res.bodyBytes.isNotEmpty &&
                res.bodyBytes.length <= 24 * 1024 * 1024) {
              pictures[url] = pw.MemoryImage(res.bodyBytes);
            } else {
              pictures[url] = null;
            }
          } catch (_) {
            pictures[url] = null;
          }
        }
      }
      await Future.wait(List.generate(
          unique.length < 4 ? unique.length : 4, (_) => worker()));
    } finally {
      client.close();
    }
    final images = urls.map((row) => row.map((u) => pictures[u]).toList()).toList();
    final qty = items.fold<int>(0, (v, x) => v + x.quantity);
    pdf.addPage(_cover(items, now,
        images.first.isNotEmpty ? images.first.first : null));
    for (var i = 0; i < items.length; i += 10) {
      final end = i + 10 > items.length ? items.length : i + 10;
      pdf.addPage(_overview(items.sublist(i, end), i, 1 + i ~/ 10));
    }
    for (var i = 0; i < items.length; i++) {
      pdf.addPage(_product(items[i], i + 1, items.length, images[i]));
      // Galleries have their own pages and never overflow, even with 5 images.
      if (images[i].length > 1) {
        for (var k = 0; k < images[i].length; k += 4) {
          final end = k + 4 > images[i].length ? images[i].length : k + 4;
          pdf.addPage(_gallery(items[i], i + 1, images[i].sublist(k, end), k));
        }
      }
    }
    pdf.addPage(_closing(items.length, qty, now));
    return pdf.save();
  }
}
