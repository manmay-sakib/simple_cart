import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductCardShimmer extends StatelessWidget {
  final bool isGrid;

  const ProductCardShimmer({super.key, this.isGrid = true});

  @override
  Widget build(BuildContext context) {
    // Adjust height according to card height in GridView/ListView
    final cardHeight = isGrid ? 260.0 : 120.0;
    final imageHeight = isGrid ? 160.0 : 100.0; // flexible placeholder

    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // shrink-wrap content
          children: [
            // Image placeholder
            Container(
              height: imageHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
            ),
            if (isGrid) ...[
              const SizedBox(height: 8),
              Container(
                height: 16,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 14,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey.shade100,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
