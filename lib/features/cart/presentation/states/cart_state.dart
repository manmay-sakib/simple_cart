import 'dart:convert';
import '../../../product/domain/models/product_model.dart';

class CartState {
  final Map<ProductModel, int> items;

  const CartState({this.items = const {}});

  int get itemCount => items.values.fold(0, (sum, q) => sum + q);

  double get totalPrice => items.entries.fold(
    0,
    (sum, entry) => sum + (entry.key.price * entry.value),
  );

  CartState copyWith({Map<ProductModel, int>? items}) {
    return CartState(items: items ?? this.items);
  }

  /// Convert CartState to JSON for SharedPreferences
  String toJson() {
    final jsonMap = items.map(
      (product, quantity) => MapEntry(product.id.toString(), {
        "quantity": quantity,
        "product": product.toJson(),
      }),
    );
    return jsonEncode(jsonMap);
  }

  /// Load CartState from JSON
  factory CartState.fromJson(String jsonString) {
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    final items = <ProductModel, int>{};
    map.forEach((key, value) {
      final product = ProductModel.fromJson(
        Map<String, dynamic>.from(value["product"]),
      );
      final quantity = value["quantity"] as int;
      items[product] = quantity;
    });
    return CartState(items: items);
  }
}
