import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:simple_cart/core/providers/shared_prefs_provider.dart';
import 'package:simple_cart/features/product/domain/usecase/get_product_details_usecase.dart';
import 'package:simple_cart/features/product/presentation/states/product_details_state.dart';
import 'package:simple_cart/features/product/presentation/viewmodels/product_list_viewmodel.dart';

part 'product_details_viewmodel.g.dart';

@riverpod
class ProductDetailsViewmodel extends _$ProductDetailsViewmodel {
  @override
  FutureOr<ProductDetailsState> build({required int id}) async {
    return await _fetchProduct(id);
  }

  Future<ProductDetailsState> _fetchProduct(int id) async {
    state = const AsyncLoading();

    final result = await ref.read(getProductDetailsUsecaseProvider(id).future);

    final prefs = await ref.read(sharedPrefsProvider.future);
    final favoriteIds = prefs.getStringList('favorite_ids') ?? [];

    return result.fold(
      (failure) => ProductDetailsState(
        product: null,
        isLoading: false,
        hasError: true,
        errorMessage: failure.message,
      ),
      (product) => ProductDetailsState(
        product: product.copyWith(
          isFavorite: favoriteIds.contains(product.id.toString()),
        ),
        isLoading: false,
        hasError: false,
        errorMessage: '',
      ),
    );
  }

  Future<void> refresh({required int id}) async {
    state = const AsyncLoading();
    final newState = await _fetchProduct(id);
    state = AsyncData(newState);
  }

  Future<void> toggleFavorite() async {
    final stateNow = state.asData?.value;
    if (stateNow == null || stateNow.product == null) return;

    final product = stateNow.product!;
    final updatedProduct = product.copyWith(isFavorite: !product.isFavorite);

    // Update state immediately
    state = AsyncData(stateNow.copyWith(product: updatedProduct));

    // Persist in SharedPreferences
    final prefs = await ref.read(sharedPrefsProvider.future);
    final favoriteIds = prefs.getStringList('favorite_ids') ?? [];

    if (updatedProduct.isFavorite) {
      if (!favoriteIds.contains(updatedProduct.id.toString())) {
        favoriteIds.add(updatedProduct.id.toString());
      }
    } else {
      favoriteIds.remove(updatedProduct.id.toString());
    }

    await prefs.setStringList('favorite_ids', favoriteIds);

    // ✅ Sync with ProductListViewmodel
    final listNotifier = ref.read(productListViewmodelProvider.notifier);
    listNotifier.syncFavorite(updatedProduct.id, updatedProduct.isFavorite);
  }
}
