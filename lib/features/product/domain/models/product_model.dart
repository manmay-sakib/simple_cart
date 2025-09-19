import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/entities/product_response.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
abstract class ProductModel with _$ProductModel {
  const factory ProductModel({
    required int id,
    required String title,
    required double price,
    required String description,
    String? category,
    required String image,
    @Default(false) bool isFavorite,
  }) = _ProductModel;

  const ProductModel._();

  factory ProductModel.fromResponse(ProductResponse response) {
    return ProductModel(
      id: response.id,
      title: response.title,
      price: response.price,
      description: response.description,
      image: response.image,
    );
  }
  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}
