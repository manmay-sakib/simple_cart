import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:simple_cart/features/product/domain/models/product_model.dart';

part 'product_details_state.freezed.dart';

@freezed
abstract class ProductDetailsState with _$ProductDetailsState {
  const factory ProductDetailsState({
    ProductModel? product,
    @Default(true) bool isLoading,
    @Default(false) bool hasError,
    @Default("") String errorMessage,
  }) = _ProductDetailsState;
}
