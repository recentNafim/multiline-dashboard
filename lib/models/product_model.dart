class ProductModel {
  final int masterSl;
  final String business;
  final String subCategory;
  final int organizationId;
  final String displayRoomNo;
  final String displayRoomName;
  final String status;
  final String assignee;

  final String itemCode;
  final String description;
  final String productCategory;
  final String subInventoryCode;
  final int locatorId;
  final String sizeRange;
  final List<String> imageUrls;
  final String uom;
  final double quantity;
  final String materialSpecification;
  final double cbm;
  final double weight;
  final double fob;
  final String fileUrl;
  final String fileName;
  final String mimeType;

  const ProductModel({
    required this.masterSl,
    required this.business,
    required this.subCategory,
    required this.organizationId,
    required this.displayRoomNo,
    required this.displayRoomName,
    required this.status,
    required this.assignee,
    required this.itemCode,
    required this.description,
    required this.productCategory,
    required this.subInventoryCode,
    required this.locatorId,
    required this.sizeRange,
    required this.imageUrls,
    required this.uom,
    required this.quantity,
    required this.materialSpecification,
    required this.cbm,
    required this.weight,
    this.fob = 0,
    required this.fileUrl,
    required this.fileName,
    required this.mimeType,
  });

  String get cartKey => '$masterSl-$itemCode-${sizeRange.isEmpty ? locatorId : sizeRange}';

  double get moq => quantity;

  bool get hasNetworkImage {
    final uri = Uri.tryParse(fileUrl);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  factory ProductModel.fromMasterAndDetail(
    Map<String, dynamic> master,
    Map<String, dynamic> detail,
  ) {
    return ProductModel(
      masterSl: _toInt(master['sl']),
      business: _toString(master['business']),
      subCategory: _toString(master['sub_category']),
      organizationId:
          _toInt(detail['organization_id'] ?? master['organization_id']),
      displayRoomNo: _toString(master['display_room_no']),
      displayRoomName: _toString(master['display_room_name']),
      status: _toString(master['status']),
      assignee: _toString(master['assignee']),
      itemCode: _toString(detail['item_code']),
      description: _toString(detail['description']),
      productCategory: _toString(detail['product_category']),
      subInventoryCode: _toString(detail['sub_inventory_code']),
      locatorId: _toInt(detail['locator_id']),
      sizeRange: readSizeRange(detail, master: master),
      imageUrls: _extractImageUrls(detail),
      uom: _toString(detail['uom']),
      quantity: readMoq(detail, master: master) ?? 0,
      materialSpecification:
          _toString(detail['material_specification']),
      cbm: _toDouble(detail['cbm']),
      weight: _toDouble(detail['weight']),
      fob: _toDouble(detail['fob']),
      fileUrl: _toString(detail['file_url']),
      fileName: _toString(detail['file_name']),
      mimeType: _toString(detail['mime_type']),
    );
  }

  /// Read Size Range from the same Oracle detail used by the report.
  /// ORDS can return snake_case, uppercase, or camelCase JSON keys.
  /// Never substitute locator_id: it is not a shoe/clothing size range.
  static String readSizeRange(
    Map<String, dynamic> detail, {
    Map<String, dynamic>? master,
  }) {
    String fromMap(Map<String, dynamic> source) {
      String lower = '';
      String upper = '';
      for (final entry in source.entries) {
        final normalizedKey = entry.key
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]'), '');
        final value = entry.value?.toString().trim() ?? '';
        if (value.isEmpty || value.toLowerCase() == 'null') continue;
        if (const {'sizerange', 'sizewise', 'sizewiserange'}.contains(normalizedKey)) return value;
        if (normalizedKey == 'lowersize' ||
            normalizedKey == 'sizelower' ||
            normalizedKey == 'minsize') {
          lower = value;
        }
        if (normalizedKey == 'uppersize' ||
            normalizedKey == 'sizeupper' ||
            normalizedKey == 'maxsize') {
          upper = value;
        }
      }
      if (lower.isNotEmpty && upper.isNotEmpty) return '$lower-$upper';
      return '';
    }

    final detailValue = fromMap(detail);
    if (detailValue.isNotEmpty) return detailValue;
    if (master != null) return fromMap(master);
    return '';
  }


  /// MOQ is an ordering threshold, not the available stock quantity.
  /// Read explicit MOQ aliases first; `quantity` remains a last-resort
  /// compatibility fallback for old ORDS payloads.
  static double? readMoq(
    Map<String, dynamic> detail, {
    Map<String, dynamic>? master,
  }) {
    double? search(Map<String, dynamic> source) {
      for (final entry in source.entries) {
        final key = entry.key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        if (const {'moq', 'minimumorderquantity', 'minimumqty', 'minimumquantity'}
            .contains(key)) {
          final value = double.tryParse(entry.value?.toString().trim() ?? '');
          if (value != null) return value;
        }
      }
      return null;
    }

    final explicit = search(detail) ?? (master == null ? null : search(master));
    if (explicit != null) return explicit;
    // Legacy backend used `quantity` to represent MOQ.
    final legacy = detail['quantity'] ?? detail['QUANTITY'];
    return legacy == null ? null : double.tryParse(legacy.toString());
  }

  static List<String> _extractImageUrls(Map<String, dynamic> detail) {
    final result = <String>[];
    final seen = <String>{};
    void add(dynamic value) {
      if (value == null) return;
      var url = value.toString().trim();
      if (url.isEmpty || url.toLowerCase() == 'null') return;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = url.replaceFirst(RegExp(r'^/+'), '');
        if (url.startsWith('ords/')) {
          url = 'https://e501.sihirbox.com:8071/$url';
        } else {
          final path = url.split('/').map(Uri.encodeComponent).join('/');
          url = 'https://e501.sihirbox.com:8071/ords/rpro/image_service/get/$path';
        }
      }
      if (seen.add(url)) result.add(url);
    }
    final images = detail['images'];
    if (images is List) {
      for (final image in images) {
        if (image is Map) {
          add(image['original_url'] ?? image['full_image_url'] ?? image['high_res_url'] ?? image['image_url'] ?? image['file_url'] ?? image['file_name']);
        } else {
          add(image);
        }
      }
    }
    add(detail['image_url']);
    add(detail['file_url']);
    return result;
  }

  static String _toString(dynamic value) => value?.toString() ?? '';

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
