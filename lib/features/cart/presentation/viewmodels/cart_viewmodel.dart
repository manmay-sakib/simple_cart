import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cart');
    if (jsonString != null) {
      state = CartState.fromJson(jsonString);
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cart', state.toJson());
  }

  void addToCart(ProductModel product) {
    final newItems = Map<ProductModel, int>.from(state.items);
    newItems.update(product, (q) => q + 1, ifAbsent: () => 1);
    state = state.copyWith(items: newItems);
    _saveCart();
  }

  void decreaseQuantity(ProductModel product) {
    final newItems = Map<ProductModel, int>.from(state.items);
    final q = newItems[product] ?? 0;
    if (q > 1) {
      newItems[product] = q - 1;
    } else {
      newItems.remove(product);
    }
    state = state.copyWith(items: newItems);
    _saveCart();
  }

  void removeFromCart(ProductModel product) {
    final newItems = Map<ProductModel, int>.from(state.items);
    newItems.remove(product);
    state = state.copyWith(items: newItems);
    _saveCart();
  }

  void clearCart() {
    state = const CartState();
    _saveCart();
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(
  () => CartNotifier(),
);
