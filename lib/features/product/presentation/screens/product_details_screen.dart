import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../domain/models/product_model.dart';
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
            context.goNamed('product-list');
          },
        ),
        title: const Text('Product Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart, size: 26),
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

          Widget buildAddToCartSection(
            BuildContext context,
            ProductModel product,
            Map<ProductModel, int> cartItems,
            CartNotifier cartNotifier,
          ) {
            final cartQuantity = cartItems[product] ?? 0;

            if (cartQuantity == 0) {
              // Show Add to Cart button
              return SizedBox(
                width: double.infinity,
                child: Material(
                  borderRadius: BorderRadius.circular(12),
                  elevation: 4,
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      cartNotifier.addToCart(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.green,
                          content: Text(
                            'Added ${cartState.items[product] ?? 1} item to cart',
                          ),
                        ),
                      );
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5B2C6F), Color(0xFF8E44AD)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else {
              // Show quantity selector
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade400,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.deepPurple,
                        size: 28,
                      ),
                      onPressed: () {
                        cartNotifier.decreaseQuantity(product);
                        final newQuantity = (cartItems[product] ?? 1) - 1;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.orange,
                            duration: const Duration(seconds: 1),
                            content: Text(
                              newQuantity > 0
                                  ? 'Updated quantity: $newQuantity'
                                  : 'Removed from cart',
                            ),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        cartQuantity.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.deepPurple,
                        size: 28,
                      ),
                      onPressed: () {
                        cartNotifier.addToCart(product);
                        final newQuantity = (cartItems[product] ?? 0) + 1;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 1),
                            content: Text('Updated quantity: $newQuantity'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }
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

                /// Add to Cart / Quantity Selector
                buildAddToCartSection(
                  context,
                  product,
                  cartState.items,
                  cartNotifier,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
