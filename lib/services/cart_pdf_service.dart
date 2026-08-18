

import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/cart_item.dart';

class CartPdfService {
  // ================================================================
  // BUILD CLIENT PRODUCT PDF
  // ================================================================
  static Future<Uint8List> buildPdf({
    required List<CartItem> items,

    // file_url যদি শুধু DP_ROOM_521.png এর মতো হয়,
    // তাহলে এখানে তোমার image server base URL পাঠাবে।
    String imageBaseUrl = '',
  }) async {
    final pdf = pw.Document(
      title: 'Display Room Product Selection',
      author: 'Display Room',
      creator: 'Display Room App',
    );

    // ==============================================================
    // LOAD PRODUCT IMAGES
    // ==============================================================
    final Map<int, pw.ImageProvider?> productImages = {};

    for (int i = 0; i < items.length; i++) {
      final product = items[i].product;

      final String rawUrl = _getImageUrl(product);

      if (rawUrl.isEmpty) {
        productImages[i] = null;
        continue;
      }

      final String finalUrl = _buildImageUrl(
        rawUrl,
        imageBaseUrl,
      );

      if (finalUrl.isEmpty) {
        productImages[i] = null;
        continue;
      }

      try {
        productImages[i] = await networkImage(finalUrl);
      } catch (_) {
        productImages[i] = null;
      }
    }

    final int totalQuantity = items.fold(
      0,
          (sum, item) => sum + item.quantity,
    );

    // ==============================================================
    // PDF
    // ==============================================================
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(
          32,
          30,
          32,
          32,
        ),

        // ============================================================
        // HEADER
        // ============================================================
        header: (context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(
              bottom: 18,
            ),
            padding: const pw.EdgeInsets.only(
              bottom: 10,
            ),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: PdfColors.grey300,
                  width: 0.8,
                ),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment:
              pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'DISPLAY ROOM',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo700,
                    letterSpacing: 1.2,
                  ),
                ),
                pw.Text(
                  'Product Selection',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          );
        },

        // ============================================================
        // FOOTER
        // ============================================================
        footer: (context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(
              top: 16,
            ),
            padding: const pw.EdgeInsets.only(
              top: 8,
            ),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(
                  color: PdfColors.grey300,
                  width: 0.6,
                ),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment:
              pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Generated from Display Room',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey500,
                  ),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey500,
                  ),
                ),
              ],
            ),
          );
        },

        build: (context) {
          return [
            // ========================================================
            // TITLE
            // ========================================================
            _buildDocumentHeader(
              productCount: items.length,
              totalQuantity: totalQuantity,
            ),

            pw.SizedBox(height: 24),

            // ========================================================
            // PRODUCTS
            // ========================================================
            ...List.generate(
              items.length,
                  (index) {
                return pw.Column(
                  children: [
                    _buildProductCard(
                      index: index,
                      item: items[index],
                      image: productImages[index],
                    ),
                    pw.SizedBox(height: 18),
                  ],
                );
              },
            ),

            pw.SizedBox(height: 10),

            // ========================================================
            // END NOTE
            // ========================================================
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.blueGrey50,
                borderRadius:
                pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment:
                pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Thank you',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blueGrey900,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Please review the selected products above. '
                        'For further information, availability, samples or commercial discussion, '
                        'please contact our representative.',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      lineSpacing: 3,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ================================================================
  // PDF HEADER
  // ================================================================
  static pw.Widget _buildDocumentHeader({
    required int productCount,
    required int totalQuantity,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: pw.BoxDecoration(
            color: PdfColors.indigo50,
            borderRadius: pw.BorderRadius.circular(20),
          ),
          child: pw.Text(
            'PRODUCT CATALOGUE',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.indigo700,
              letterSpacing: 1,
            ),
          ),
        ),

        pw.SizedBox(height: 12),

        pw.Text(
          'Selected Products',
          style: pw.TextStyle(
            fontSize: 28,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey900,
          ),
        ),

        pw.SizedBox(height: 6),

        pw.Text(
          'A curated selection of Display Room products for your review.',
          style: const pw.TextStyle(
            fontSize: 11,
            color: PdfColors.grey600,
          ),
        ),

        pw.SizedBox(height: 18),

        pw.Row(
          children: [
            _summaryBox(
              title: 'PRODUCTS',
              value: '$productCount',
            ),

            pw.SizedBox(width: 10),

            _summaryBox(
              title: 'TOTAL QTY',
              value: '$totalQuantity',
            ),

            pw.SizedBox(width: 10),

            _summaryBox(
              title: 'GENERATED',
              value: _formattedDate(),
              flex: 2,
            ),
          ],
        ),
      ],
    );
  }

  // ================================================================
  // SUMMARY BOX
  // ================================================================
  static pw.Widget _summaryBox({
    required String title,
    required String value,
    int flex = 1,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(7),
          border: pw.Border.all(
            color: PdfColors.grey300,
            width: 0.5,
          ),
        ),
        child: pw.Column(
          crossAxisAlignment:
          pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: const pw.TextStyle(
                fontSize: 7,
                color: PdfColors.grey600,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // PRODUCT CARD
  // ================================================================
  static pw.Widget _buildProductCard({
    required int index,
    required CartItem item,
    required pw.ImageProvider? image,
  }) {
    final dynamic product = item.product;

    final String description = _firstValue([
          () => product.description,
          () => product.itemName,
          () => product.Item_Name,
          () => product.item_name,
    ]);

    final String itemCode = _firstValue([
          () => product.itemCode,
          () => product.Item_code,
          () => product.ITEM_CODE,
          () => product.item_code,
    ]);

    final String business = _firstValue([
          () => product.business,
          () => product.BUSINESS,
    ]);

    final String subCategory = _firstValue([
          () => product.subCategory,
          () => product.sub_category,
          () => product.SUB_CATEGORY,
    ]);

    final String category = _firstValue([
          () => product.productCategory,
          () => product.product_category,
          () => product.PRODUCT_CATEGORY,
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

    final String displayRoom = _firstValue([
          () => product.displayRoomName,
          () => product.display_room_name,
          () => product.DISPLAY_ROOM_NAME,
    ]);

    final String printValue = _firstValue([
          () => product.print,
          () => product.PRINT,
    ]);

    final String psn = _firstValue([
          () => product.psn,
          () => product.PSN,
    ]);

    final String itemQr = _firstValue([
          () => product.itemQrcode,
          () => product.itemQrCode,
          () => product.item_qrcode,
          () => product.ITEM_QRCODE,
    ]);

    final String availableQty = _firstValue([
          () => product.qty,
          () => product.QTY,
          () => product.quantity,
    ]);

    final List<MapEntry<String, String>> details = [];

    _addDetail(details, 'Item Code', itemCode);
    _addDetail(details, 'Business', business);
    _addDetail(details, 'Product Category', category);
    _addDetail(details, 'Sub Category', subCategory);
    _addDetail(details, 'Color', color);
    _addDetail(details, 'UOM', uom);
    _addDetail(details, 'Unit Price', unitPrice);
    _addDetail(details, 'Available Qty', availableQty);
    _addDetail(details, 'Display Room', displayRoom);
    _addDetail(details, 'Print', printValue);
    _addDetail(details, 'PSN', psn);
    _addDetail(details, 'Item QR', itemQr);

    final String title = description.isNotEmpty
        ? description
        : itemCode.isNotEmpty
        ? itemCode
        : 'Product ${index + 1}';

    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(
          color: PdfColors.grey300,
          width: 0.7,
        ),
      ),
      child: pw.Row(
        crossAxisAlignment:
        pw.CrossAxisAlignment.start,
        children: [
          // ==========================================================
          // PRODUCT IMAGE
          // ==========================================================
          pw.Container(
            width: 155,
            height: 155,
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius:
              pw.BorderRadius.circular(8),
              border: pw.Border.all(
                color: PdfColors.grey300,
                width: 0.5,
              ),
            ),
            child: image != null
                ? pw.ClipRRect(
              horizontalRadius: 8,
              verticalRadius: 8,
              child: pw.Image(
                image,
                fit: pw.BoxFit.cover,
                width: 155,
                height: 155,
              ),
            )
                : pw.Center(
              child: pw.Column(
                mainAxisSize:
                pw.MainAxisSize.min,
                children: [
                  pw.Text(
                    'PRODUCT',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight:
                      pw.FontWeight.bold,
                      color:
                      PdfColors.grey500,
                    ),
                  ),
                  if (itemCode.isNotEmpty) ...[
                    pw.SizedBox(height: 5),
                    pw.Text(
                      itemCode,
                      textAlign:
                      pw.TextAlign.center,
                      style:
                      const pw.TextStyle(
                        fontSize: 7,
                        color:
                        PdfColors.grey500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          pw.SizedBox(width: 16),

          // ==========================================================
          // DETAILS
          // ==========================================================
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment:
              pw.CrossAxisAlignment.start,
              children: [
                // PRODUCT NUMBER + QTY
                pw.Row(
                  mainAxisAlignment:
                  pw.MainAxisAlignment
                      .spaceBetween,
                  children: [
                    pw.Container(
                      padding:
                      const pw.EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.indigo50,
                        borderRadius:
                        pw.BorderRadius.circular(20),
                      ),
                      child: pw.Text(
                        'PRODUCT ${index + 1}',
                        style: pw.TextStyle(
                          fontSize: 7,
                          fontWeight:
                          pw.FontWeight.bold,
                          color:
                          PdfColors.indigo700,
                        ),
                      ),
                    ),

                    pw.Container(
                      padding:
                      const pw.EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: pw.BoxDecoration(
                        color:
                        PdfColors.blueGrey900,
                        borderRadius:
                        pw.BorderRadius.circular(
                            20),
                      ),
                      child: pw.Text(
                        'Selected Qty: ${item.quantity}',
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight:
                          pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 10),

                // TITLE
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight:
                    pw.FontWeight.bold,
                    color:
                    PdfColors.blueGrey900,
                  ),
                ),

                if (itemCode.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Code: $itemCode',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],

                pw.SizedBox(height: 12),

                // PRODUCT DETAILS
                if (details.isNotEmpty)
                  _buildDetailsGrid(details),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // DETAILS GRID
  // ================================================================
  static pw.Widget _buildDetailsGrid(
      List<MapEntry<String, String>> details,
      ) {
    final rows =
    <List<MapEntry<String, String>>>[];

    for (int i = 0; i < details.length; i += 2) {
      rows.add(
        details.sublist(
          i,
          i + 2 > details.length
              ? details.length
              : i + 2,
        ),
      );
    }

    return pw.Column(
      children: rows.map((row) {
        return pw.Padding(
          padding:
          const pw.EdgeInsets.only(bottom: 7),
          child: pw.Row(
            crossAxisAlignment:
            pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _detailItem(
                  row[0].key,
                  row[0].value,
                ),
              ),

              pw.SizedBox(width: 12),

              pw.Expanded(
                child: row.length > 1
                    ? _detailItem(
                  row[1].key,
                  row[1].value,
                )
                    : pw.SizedBox(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ================================================================
  // DETAIL ITEM
  // ================================================================
  static pw.Widget _detailItem(
      String label,
      String value,
      ) {
    return pw.Column(
      crossAxisAlignment:
      pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label.toUpperCase(),
          style: const pw.TextStyle(
            fontSize: 6.5,
            color: PdfColors.grey500,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 8.5,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey800,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // ADD DETAIL ONLY WHEN VALUE EXISTS
  // ================================================================
  static void _addDetail(
      List<MapEntry<String, String>> list,
      String label,
      String value,
      ) {
    if (value.trim().isNotEmpty) {
      list.add(
        MapEntry(
          label,
          value.trim(),
        ),
      );
    }
  }

  // ================================================================
  // SAFE GET FIRST AVAILABLE MODEL FIELD
  // ================================================================
  static String _firstValue(
      List<dynamic Function()> getters,
      ) {
    for (final getter in getters) {
      try {
        final dynamic value = getter();

        if (value != null) {
          final String text =
          value.toString().trim();

          if (text.isNotEmpty &&
              text.toLowerCase() != 'null') {
            return text;
          }
        }
      } catch (_) {
        // Field does not exist in model.
      }
    }

    return '';
  }

  // ================================================================
  // PRODUCT IMAGE URL
  // ================================================================
  static String _getImageUrl(
      dynamic product,
      ) {
    return _firstValue([
          () => product.fileUrl,
          () => product.file_url,
          () => product.FILE_URL,
          () => product.imageUrl,
          () => product.image_url,
          () => product.image,
    ]);
  }

  // ================================================================
  // BUILD FINAL IMAGE URL
  // ================================================================
  static String _buildImageUrl(
      String rawUrl,
      String baseUrl,
      ) {
    final String value = rawUrl.trim();

    if (value.isEmpty) {
      return '';
    }

    // Already full URL
    if (value.startsWith('http://') ||
        value.startsWith('https://')) {
      return value;
    }

    if (baseUrl.trim().isEmpty) {
      return '';
    }

    String cleanBase = baseUrl.trim();

    if (cleanBase.endsWith('/')) {
      cleanBase = cleanBase.substring(
        0,
        cleanBase.length - 1,
      );
    }

    String cleanPath = value;

    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    return '$cleanBase/$cleanPath';
  }

  // ================================================================
  // DATE
  // ================================================================
  static String _formattedDate() {
    final now = DateTime.now();

    final day =
    now.day.toString().padLeft(2, '0');

    final month =
    now.month.toString().padLeft(2, '0');

    return '$day/$month/${now.year}';
  }
}