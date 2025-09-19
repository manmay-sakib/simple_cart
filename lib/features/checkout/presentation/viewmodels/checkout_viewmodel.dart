import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../states/checkout_state.dart';

final checkoutProvider = NotifierProvider<CheckoutViewModel, CheckoutState>(
  () => CheckoutViewModel(),
);

class CheckoutViewModel extends Notifier<CheckoutState> {
  @override
  CheckoutState build() {
    return const CheckoutState();
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updateAddress(String address) {
    state = state.copyWith(address: address);
  }

  Future<void> submit(WidgetRef ref) async {
    if (state.name.isEmpty || state.email.isEmpty || state.address.isEmpty) {
      state = state.copyWith(error: "Please fill all fields");
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // On success: clear cart
    ref.read(cartProvider.notifier).clearCart();

    state = state.copyWith(isLoading: false, isSuccess: true);
  }

  void reset() {
    state = const CheckoutState();
  }
}
