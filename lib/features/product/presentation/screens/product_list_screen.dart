import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../components/product_card.dart';
import '../components/product_card_shimmer.dart';
import '../viewmodels/product_list_viewmodel.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  bool isGridView = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(productListViewmodelProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productListViewmodelProvider);
    final notifier = ref.read(productListViewmodelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        actions: [
          IconButton(
            icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          /// Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: notifier.searchProducts,
            ),
          ),

          /// Product List
          Expanded(
            child: state.when(
              data: (data) {
                if (data.products.isEmpty) {
                  return const Center(child: Text("No products found"));
                }

                return RefreshIndicator(
                  onRefresh: notifier.refresh,
                  child: isGridView
                      ? GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                mainAxisExtent: 260,
                              ),
                          itemCount:
                              data.products.length +
                              (data.isPaginating ? 2 : 0),
                          itemBuilder: (context, index) {
                            if (index < data.products.length) {
                              final product = data.products[index];
                              return ProductCard(
                                product: product,
                                isGrid: true,
                                onFavoriteToggle: () =>
                                    notifier.toggleFavorite(product),
                                onTap: () {
                                  context.pushNamed(
                                    "product-details",
                                    extra: {"productId": product.id},
                                  );
                                },
                              );
                            } else {
                              return const ProductCardShimmer(isGrid: true);
                            }
                          },
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          itemCount:
                              data.products.length +
                              (data.isPaginating ? 2 : 0),
                          itemBuilder: (context, index) {
                            if (index < data.products.length) {
                              final product = data.products[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ProductCard(
                                  product: product,
                                  isGrid: false,
                                  onFavoriteToggle: () =>
                                      notifier.toggleFavorite(product),
                                  onTap: () {
                                    context.goNamed(
                                      "product-details",
                                      extra: {"productId": product.id},
                                    );
                                  },
                                ),
                              );
                            } else {
                              return const Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: ProductCardShimmer(isGrid: false),
                              );
                            }
                          },
                        ),
                );
              },
              loading: () {
                // Show shimmer based on current view
                return isGridView
                    ? GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              mainAxisExtent: 260,
                            ),
                        itemCount: 6,
                        itemBuilder: (context, index) =>
                            const ProductCardShimmer(isGrid: true),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        itemCount: 6,
                        itemBuilder: (context, index) => const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: ProductCardShimmer(isGrid: false),
                        ),
                      );
              },
              error: (err, _) => Center(child: Text("Error: $err")),
            ),
          ),
        ],
      ),
    );
  }
}
