import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_cart/core/providers/shared_prefs_provider.dart';

import '../../../product/domain/models/product_model.dart';
import '../states/cart_state.dart';

// The Notifier now handles the quantity logic.
class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    _loadCart();
    return const CartState();
  }

  Future<void> _loadCart() async {
    final prefs = await ref.read(sharedPrefsProvider.future);
    final jsonString = prefs.getString('cart');
    if (jsonString != null) {
      state = CartState.fromJson(jsonString);
    }
  }

  Future<void> _saveCart() async {
    final prefs = await ref.read(sharedPrefsProvider.future);
    await prefs.setString('cart', state.toJson());
  }

  Future<void> addToCart(ProductModel product) async {
    final newItems = Map<ProductModel, int>.from(state.items);
    newItems.update(product, (q) => q + 1, ifAbsent: () => 1);
    state = state.copyWith(items: newItems);
    await _saveCart();
  }

  Future<void> decreaseQuantity(ProductModel product) async {
    final newItems = Map<ProductModel, int>.from(state.items);
    final q = newItems[product] ?? 0;
    if (q > 1) {
      newItems[product] = q - 1;
    } else {
      newItems.remove(product);
    }
    state = state.copyWith(items: newItems);
    await _saveCart();
  }

  Future<void> removeFromCart(ProductModel product) async {
    final newItems = Map<ProductModel, int>.from(state.items);
    newItems.remove(product);
    state = state.copyWith(items: newItems);
    await _saveCart();
  }

  Future<void> clearCart() async {
    state = const CartState();
    await _saveCart();
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(
  () => CartNotifier(),
);
