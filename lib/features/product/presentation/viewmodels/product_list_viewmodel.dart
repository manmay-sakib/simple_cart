import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:simple_cart/core/providers/shared_prefs_provider.dart';
import 'package:simple_cart/features/product/domain/usecase/get_product_list_usecase.dart';
import 'package:simple_cart/features/product/presentation/states/product_list_state.dart';

import '../../domain/models/product_model.dart';

part 'product_list_viewmodel.g.dart';

@riverpod
class ProductListViewmodel extends _$ProductListViewmodel {
  static const int pageSize = 10;
  late List<ProductModel> _allProducts;

  /// NEW: store favorite states in memory
  final Map<int, bool> _favorites = {};

  @override
  FutureOr<ProductListState> build() async {
    return _fetchInitial();
  }

  Future<ProductListState> _fetchInitial() async {
    state = const AsyncLoading();
    final result = await ref.read(getProductListUsecaseProvider.future);

    return await result.match(
      (failure) async => ProductListState(
        isLoading: false,
        hasError: true,
        errorMessage: failure.message,
      ),
      (products) async {
        _allProducts = products;

        // Load favorite IDs from SharedPreferences
        final prefs = await ref.read(sharedPrefsProvider.future);
        final favoriteIds = prefs.getStringList('favorite_ids') ?? [];
        for (var p in _allProducts) {
          _favorites[p.id] = favoriteIds.contains(p.id.toString());
        }

        final firstPage = _allProducts.take(pageSize).map((p) {
          return p.copyWith(isFavorite: _favorites[p.id] ?? false);
        }).toList();

        return ProductListState(
          products: firstPage,
          isLoading: false,
          currentPage: 0,
        );
      },
    );
  }

  Future<void> toggleFavorite(ProductModel product) async {
    final stateNow = state.asData?.value;
    if (stateNow == null) return;

    // Update in-memory favorite
    _favorites[product.id] = !(_favorites[product.id] ?? false);

    // Update UI
    final updatedProducts = stateNow.products.map((p) {
      if (p.id == product.id) {
        return p.copyWith(isFavorite: _favorites[p.id]!);
      }
      return p;
    }).toList();

    state = AsyncData(stateNow.copyWith(products: updatedProducts));

    // Persist favorites
    final prefs = await ref.read(sharedPrefsProvider.future);
    final favoriteIds = _favorites.entries
        .where((e) => e.value)
        .map((e) => e.key.toString())
        .toList();
    await prefs.setStringList('favorite_ids', favoriteIds);
  }

  Future<void> searchProducts(String query) async {
    final stateNow = state.asData?.value;
    if (stateNow == null) return;

    List<ProductModel> filteredProducts;
    if (query.isEmpty) {
      filteredProducts = _allProducts.take(pageSize).toList();
    } else {
      filteredProducts = _allProducts
          .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    // Merge in-memory favorites instead of SharedPreferences
    final withFavorites = filteredProducts.map((p) {
      return p.copyWith(isFavorite: _favorites[p.id] ?? false);
    }).toList();

    state = AsyncData(
      stateNow.copyWith(
        products: withFavorites,
        currentPage: 0,
        searchQuery: query,
      ),
    );
  }

  void syncFavorite(int productId, bool isFavorite) {
    final stateNow = state.asData?.value;
    if (stateNow == null) return;

    final updatedProducts = stateNow.products.map((p) {
      if (p.id == productId) return p.copyWith(isFavorite: isFavorite);
      return p;
    }).toList();

    state = AsyncData(stateNow.copyWith(products: updatedProducts));
  }

  Future<void> refresh() async {
    // put loading state
    state = const AsyncLoading();

    final result = await ref.read(getProductListUsecaseProvider.future);

    state = await result.match(
      (failure) async => AsyncData(
        ProductListState(
          products: const [],
          isLoading: false,
          hasError: true,
          errorMessage: failure.message,
        ),
      ),
      (products) async {
        _allProducts = products;

        // reload favorites
        final prefs = await ref.read(sharedPrefsProvider.future);
        final favoriteIds = prefs.getStringList('favorite_ids') ?? [];
        for (var p in _allProducts) {
          _favorites[p.id] = favoriteIds.contains(p.id.toString());
        }

        final firstPage = _allProducts.take(pageSize).map((p) {
          return p.copyWith(isFavorite: _favorites[p.id] ?? false);
        }).toList();

        return AsyncData(
          ProductListState(
            products: firstPage,
            isLoading: false,
            currentPage: 0,
          ),
        );
      },
    );
  }

  Future<void> loadMore() async {
    final stateNow = state.asData?.value;
    if (stateNow == null) return;

    // Prevent duplicate pagination
    if (stateNow.isPaginating ||
        stateNow.products.length >= _allProducts.length) {
      return;
    }

    // Update state to show loading at the bottom
    state = AsyncData(stateNow.copyWith(isPaginating: true));

    await Future.delayed(const Duration(milliseconds: 500)); // simulate delay

    final nextPage = stateNow.currentPage + 1;
    final startIndex = nextPage * pageSize;
    final endIndex = startIndex + pageSize;

    final moreProducts = _allProducts
        .skip(startIndex)
        .take(pageSize)
        .map((p) => p.copyWith(isFavorite: _favorites[p.id] ?? false))
        .toList();

    final updatedProducts = [...stateNow.products, ...moreProducts];

    state = AsyncData(
      stateNow.copyWith(
        products: updatedProducts,
        currentPage: nextPage,
        isPaginating: false,
      ),
    );
  }
}
