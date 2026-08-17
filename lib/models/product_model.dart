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
  final String uom;
  final double quantity;
  final String materialSpecification;
  final double cbm;
  final double weight;
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
    required this.uom,
    required this.quantity,
    required this.materialSpecification,
    required this.cbm,
    required this.weight,
    required this.fileUrl,
    required this.fileName,
    required this.mimeType,
  });

  String get cartKey => '$masterSl-$itemCode-$locatorId';

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
      uom: _toString(detail['uom']),
      quantity: _toDouble(detail['quantity']),
      materialSpecification:
          _toString(detail['material_specification']),
      cbm: _toDouble(detail['cbm']),
      weight: _toDouble(detail['weight']),
      fileUrl: _toString(detail['file_url']),
      fileName: _toString(detail['file_name']),
      mimeType: _toString(detail['mime_type']),
    );
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
