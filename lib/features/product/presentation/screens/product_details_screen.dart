import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../components/product_details_shimmer.dart';
import '../viewmodels/product_details_viewmodel.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final int productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productDetailsViewmodelProvider(id: productId));
    final notifier = ref.read(
      productDetailsViewmodelProvider(id: productId).notifier,
    );
    final cartState = ref.watch(cartProvider);
    final cartItemCount = cartState.itemCount;
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text('Product Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (cartItemCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$cartItemCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              context.pushNamed('cart');
            },
          ),
        ],
      ),
      body: state.when(
        loading: () => const ProductDetailsShimmer(),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (data) {
          final product = data.product;
          if (product == null) {
            return const Center(child: Text("Product not found"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: product.image,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => const ProductImageShimmer(),
                    errorWidget: (_, _, _) =>
                        const Center(child: Icon(Icons.broken_image, size: 50)),
                  ),
                ),
                const SizedBox(height: 16),

                /// Product Name & Favorite
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        product.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        // Toggle favorite
                        notifier.toggleFavorite();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                /// Price
                Text(
                  "\$${product.price.toStringAsFixed(2)}",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                /// Description
                Text(
                  product.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),

                /// Add to Cart Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      cartNotifier.addToCart(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to cart')),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Add to Cart',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
