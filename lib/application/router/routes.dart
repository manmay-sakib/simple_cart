import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_cart/features/cart/presentation/screens/cart_screen.dart';
import 'package:simple_cart/features/product/presentation/screens/product_list_screen.dart';

import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/product/presentation/screens/product_details_screen.dart';

part 'routes.g.dart';

@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/product-list',
    routes: [
      GoRoute(
        path: '/product-list',
        name: 'product-list',
        builder: (context, state) => const ProductListScreen(),
      ),
      GoRoute(
        path: '/product-details',
        name: 'product-details',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final productId = extra['productId'] as int;
          return ProductDetailsScreen(productId: productId);
        },
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
    ],
  );
}
