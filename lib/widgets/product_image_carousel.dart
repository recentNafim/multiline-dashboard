import 'package:flutter/material.dart';

/// Slide through the pictures returned in details[].images.
class ProductImageCarousel extends StatefulWidget {
  final List<String> urls;
  final double height;

  const ProductImageCarousel({
    super.key,
    required this.urls,
    this.height = 172,
  });

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void didUpdateWidget(covariant ProductImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.urls.join('\u0000') != widget.urls.join('\u0000')) {
      _index = 0;
      if (_controller.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _controller.hasClients) _controller.jumpToPage(0);
        });
      }
    }
  }

  void _goTo(int index) {
    if (index < 0 || index >= widget.urls.length) return;
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.urls;
    if (urls.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: urls.length,
            onPageChanged: (index) => setState(() => _index = index),
            itemBuilder: (context, index) => Image.network(
              urls[index],
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
          if (urls.length > 1) ...[
            Positioned(
              left: 3,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton.filledTonal(
                  tooltip: 'Previous picture',
                  onPressed: _index > 0 ? () => _goTo(_index - 1) : null,
                  icon: const Icon(Icons.chevron_left),
                ),
              ),
            ),
            Positioned(
              right: 3,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton.filledTonal(
                  tooltip: 'Next picture',
                  onPressed: _index < urls.length - 1
                      ? () => _goTo(_index + 1)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 9,
              child: Chip(
                visualDensity: VisualDensity.compact,
                label: Text('${_index + 1}/${urls.length}'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
