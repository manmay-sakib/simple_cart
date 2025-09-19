import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductCardShimmer extends StatelessWidget {
  final bool isGrid;

  const ProductCardShimmer({super.key, this.isGrid = true});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: isGrid ? 140 : 100,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
