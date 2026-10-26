import 'package:flutter/material.dart';

import '../models/product_item.dart';

class ProductCard extends StatelessWidget {
  final ProductItem product;
  final VoidCallback onSelect;

  const ProductCard({super.key, required this.product, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEE3D6),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Product Image: full top width with rounded top corners
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: AspectRatio(
                  aspectRatio: 1.7,
                  child: Image.asset(
                    product.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFFFECE5),
                        child: const Center(
                          child: Icon(
                            Icons.fastfood_outlined,
                            size: 32,
                            color: Color(0xFFAB2F00),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Product Info & Action
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Title (max 2 lines)
                    SizedBox(
                      height: 38,
                      child: Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Price and Plus Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            product.formattedPrice,
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),

                        // Plus Button (Opens Product Detail)
                        InkWell(
                          onTap: onSelect,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.add,
                                color: Color(0xFFAB2F00),
                                size: 24,
                              ),
                            ),
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
    );
  }
}
