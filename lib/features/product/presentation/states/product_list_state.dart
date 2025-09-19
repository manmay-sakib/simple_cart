import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/models/product_model.dart';

part 'product_list_state.freezed.dart';

@freezed
abstract class ProductListState with _$ProductListState {
  const factory ProductListState({
    @Default([]) List<ProductModel> products,
    @Default(true) bool isLoading,
    @Default(false) bool hasError,
    @Default("") String errorMessage,
    @Default(false) bool isPaginating,
    @Default(0) int currentPage,
    @Default("") String searchQuery,
  }) = _ProductListState;
}
