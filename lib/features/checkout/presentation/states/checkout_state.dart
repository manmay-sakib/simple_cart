import 'package:freezed_annotation/freezed_annotation.dart';

part 'checkout_state.freezed.dart';

@freezed
abstract class CheckoutState with _$CheckoutState {
  const factory CheckoutState({
    @Default('') String name,
    @Default('') String email,
    @Default('') String address,
    @Default(false) isLoading,
    @Default(false) isSuccess,
    String? error,
  }) = _CheckoutState;
}
