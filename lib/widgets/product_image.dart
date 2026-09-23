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
    final Widget child = product.hasNetworkImage
        ? Image.network(
            product.fileUrl,
            height: height,
            width: width,
            fit: fit,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) {
                return child;
              }

              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                child: child,
              );
            },
            loadingBuilder: (context, child, progress) {
              if (progress == null) {
                return child;
              }

              final int? total = progress.expectedTotalBytes;
              final double? value = total == null
                  ? null
                  : progress.cumulativeBytesLoaded / total;

              return Container(
                height: height,
                width: width,
                color: const Color(0xFFF3F6FA),
                alignment: Alignment.center,
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 2.4,
                  ),
                ),
              );
            },
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFEEF2F7),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 46,
            color: Color(0xFF94A3B8),
          ),
          SizedBox(height: 8),
          Text(
            'Image unavailable',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
