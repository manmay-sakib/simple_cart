// Add this import for network connectivity checks
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_cart/core/providers/shared_prefs_provider.dart';
import 'package:simple_cart/features/product/domain/usecase/get_product_list_usecase.dart';
import 'package:simple_cart/features/product/presentation/states/product_list_state.dart';

import '../../domain/models/product_model.dart';

part 'product_list_viewmodel.g.dart';

@riverpod
class ProductListViewmodel extends _$ProductListViewmodel {
  static const int pageSize = 10;
  late List<ProductModel> _allProducts;
  final Map<int, bool> _favorites = {};

  // Define a key for SharedPreferences
  static const String _productListKey = 'product_list_data';

  @override
  FutureOr<ProductListState> build() async {
    return _fetchInitial();
  }

  Future<ProductListState> _fetchInitial() async {
    state = const AsyncLoading();
    final prefs = await ref.read(sharedPrefsProvider.future);
    final connectivityResult = await (Connectivity().checkConnectivity());
    final isConnected =
        connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi);

    // If online, fetch from network. If offline, load from cache.
    if (isConnected) {
      final result = await ref.read(getProductListUsecaseProvider.future);
      return result.match(
        (failure) async {
          // If network fails, try to load from cache
          return _loadFromCache(prefs, failure.message);
        },
        (products) async {
          _allProducts = products;
          // Save successful fetch to SharedPreferences
          await _saveToCache(prefs, products);
          return _initializeState(products, prefs);
        },
      );
    } else {
      // Load from cache when offline
      return _loadFromCache(
        prefs,
        "You are currently offline. Showing cached data.",
      );
    }
  }

  // New helper method to load data from cache
  Future<ProductListState> _loadFromCache(
    SharedPreferences prefs,
    String errorMessage,
  ) async {
    final cachedData = prefs.getString(_productListKey);
    if (cachedData != null) {
      final List<dynamic> jsonList = jsonDecode(cachedData);
      final products = jsonList.map((e) => ProductModel.fromJson(e)).toList();
      _allProducts = products;
      return _initializeState(products, prefs);
    } else {
      return ProductListState(
        isLoading: false,
        hasError: true,
        errorMessage: "No internet connection and no cached data available.",
      );
    }
  }

  // New helper method to save data to cache
  Future<void> _saveToCache(
    SharedPreferences prefs,
    List<ProductModel> products,
  ) async {
    final jsonList = products.map((e) => e.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_productListKey, jsonString);
  }

  // New helper method to initialize the state from a list of products
  Future<ProductListState> _initializeState(
    List<ProductModel> products,
    SharedPreferences prefs,
  ) async {
    _allProducts = products;
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
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final prefs = await ref.read(sharedPrefsProvider.future);
    final connectivityResult = await (Connectivity().checkConnectivity());
    final isConnected =
        connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi);

    if (isConnected) {
      final result = await ref.read(getProductListUsecaseProvider.future);
      state = await result.match(
        (failure) async {
          return AsyncData(await _loadFromCache(prefs, failure.message));
        },
        (products) async {
          await _saveToCache(prefs, products);
          return AsyncData(await _initializeState(products, prefs));
        },
      );
    } else {
      state = AsyncData(
        await _loadFromCache(
          prefs,
          "You are currently offline. Showing cached data.",
        ),
      );
    }
  }

  Future<void> toggleFavorite(ProductModel product) async {
    // ... your existing code for toggling favorites and persisting it
    final stateNow = state.asData?.value;
    if (stateNow == null) return;

    _favorites[product.id] = !(_favorites[product.id] ?? false);
    final updatedProducts = stateNow.products.map((p) {
      if (p.id == product.id) {
        return p.copyWith(isFavorite: _favorites[p.id]!);
      }
      return p;
    }).toList();
    state = AsyncData(stateNow.copyWith(products: updatedProducts));

    final prefs = await ref.read(sharedPrefsProvider.future);
    final favoriteIds = _favorites.entries
        .where((e) => e.value)
        .map((e) => e.key.toString())
        .toList();
    await prefs.setStringList('favorite_ids', favoriteIds);
  }

  // your existing searchProducts, syncFavorite, and loadMore methods
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

  Future<void> loadMore() async {
    final stateNow = state.asData?.value;
    if (stateNow == null) return;
    if (stateNow.isPaginating ||
        stateNow.products.length >= _allProducts.length) {
      return;
    }
    state = AsyncData(stateNow.copyWith(isPaginating: true));
    await Future.delayed(const Duration(milliseconds: 500));
    final nextPage = stateNow.currentPage + 1;
    final startIndex = nextPage * pageSize;
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
