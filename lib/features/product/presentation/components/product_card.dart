import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../domain/models/product_model.dart';
import 'product_card_shimmer.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isGrid;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.isGrid,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardHeight = isGrid ? 260.0 : 120.0;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: cardHeight,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: isGrid ? _buildGridContent() : _buildListContent(),
        ),
      ),
    );
  }

  Widget _buildGridContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: CachedNetworkImage(
            imageUrl: product.image,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const ProductCardShimmer(isGrid: true),
            errorWidget: (context, url, error) =>
                const Center(child: Icon(Icons.broken_image)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text("\$${product.price.toStringAsFixed(2)}"),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                    product.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: onFavoriteToggle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListContent() {
    return Row(
      children: [
        // Image
        CachedNetworkImage(
          imageUrl: product.image,
          width: 120,
          height: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              const ProductCardShimmer(isGrid: false),
          errorWidget: (context, url, error) =>
              const Center(child: Icon(Icons.broken_image)),
        ),
        const SizedBox(width: 12),
        // Info
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text("\$${product.price.toStringAsFixed(2)}"),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    icon: Icon(
                      product.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    onPressed: onFavoriteToggle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
