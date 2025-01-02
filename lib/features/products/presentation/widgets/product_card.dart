import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../domain/models/product.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;
  final double? cardWidth;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.cardWidth,
    required String heroTag,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isImageLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 1.015).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final defaultCardWidth = size.width > 600 ? 300.0 : size.width * 0.92;
    final cardHeight = size.width > 600 ? 140.0 : 160.0;
    final imageWidth = size.width > 600 ? 110.0 : 130.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: MouseRegion(
        onEnter: (_) => _controller.forward(),
        onExit: (_) => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.cardWidth ?? defaultCardWidth,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    offset: const Offset(0, 1),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: cardHeight,
                    padding: EdgeInsets.all(size.width > 600 ? 12 : 10),
                    child: Row(
                      children: [
                        // Product Image with shimmer effect
                        Hero(
                          tag: 'product-${widget.product.id}',
                          child: Container(
                            width: imageWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                children: [
                                  if (_isImageLoading)
                                    Shimmer.fromColors(
                                      baseColor: Colors.grey[200]!,
                                      highlightColor: Colors.grey[50]!,
                                      child: Container(
                                        color: Colors.white,
                                      ),
                                    ),
                                  Image.network(
                                    widget.product.images.first,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        _isImageLoading = false;
                                        return child;
                                      }
                                      return const SizedBox();
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      _isImageLoading = false;
                                      return Container(
                                        color: Colors.grey[100],
                                        child: const Center(
                                          child: Icon(
                                            Icons.image_not_supported_outlined,
                                            color: Colors.grey,
                                            size: 32,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: size.width > 600 ? 14 : 12),
                        // Product Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.product.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: size.width > 600 ? 17 : 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black.withOpacity(0.85),
                                      height: 1.2,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  SizedBox(height: size.width > 600 ? 6 : 5),
                                  Text(
                                    widget.product.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: size.width > 600 ? 13 : 12,
                                      color: Colors.grey[600],
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: size.width > 600 ? 12 : 10,
                                      vertical: size.width > 600 ? 6 : 5,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.blue[600]!,
                                          Colors.blue[500]!,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      '\$${widget.product.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: size.width > 600 ? 17 : 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: size.width > 600 ? 8 : 7,
                                      vertical: size.width > 600 ? 4 : 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber[50],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.star_rounded,
                                          size: size.width > 600 ? 20 : 18,
                                          color: Colors.amber[700],
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          widget.product.rating.toString(),
                                          style: TextStyle(
                                            fontSize:
                                                size.width > 600 ? 14 : 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.amber[900],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
