import 'package:flutter/material.dart';

import '../models/product_model.dart';

class ProductImage extends StatelessWidget {
  final ProductModel product;
  final double? height;
  final double? width;
  final BoxFit fit;
  final double borderRadius;

  const ProductImage({
    super.key,
    required this.product,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final child = product.hasNetworkImage
        ? Image.network(
            product.fileUrl,
            height: height,
            width: width,
            fit: fit,
            errorBuilder: (_, __, ___) => _placeholder(),
          )
        : _placeholder();

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: child,
    );
  }

  Widget _placeholder() {
    return Container(
      height: height,
      width: width,
      color: const Color(0xFFF0F2F7),
      alignment: Alignment.center,
      child: const Icon(
        Icons.inventory_2_outlined,
        size: 48,
        color: Color(0xFF9AA2B1),
      ),
    );
  }
}
