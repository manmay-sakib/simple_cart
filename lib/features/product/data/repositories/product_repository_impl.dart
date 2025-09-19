import 'package:fpdart/fpdart.dart';
import 'package:simple_cart/core/errors/failure.dart';
import 'package:simple_cart/features/product/data/entities/product_response.dart';
import '../../domain/models/product_model.dart';
import '../../domain/repositories/product_repository.dart';
import '../services/product_service.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductService _productService;
  ProductRepositoryImpl(this._productService);

  @override
  FutureOrFailure<List<ProductModel>> fetchProducts() async {
    try {
      List<ProductResponse> response = await _productService.getProducts();
      if (response.isNotEmpty) {
        return right(
          response.map((e) => ProductModel.fromResponse(e)).toList(),
        );
      }
      if (response.isEmpty) {
        return left(Failure.unknown());
      }
      return left(
        const Failure(message: "Something went wrong on Fetching product list"),
      );
    } on Exception catch (e, s) {
      return left(Failure(message: e.toString(), stackTrace: s));
    }
  }

  @override
  FutureOrFailure<ProductModel> fetchProductById(int id) async {
    try {
      ProductResponse response = await _productService.getProductById(id);
      if (response.id == id) {
        return right(ProductModel.fromResponse(response));
      }
      return left(
        Failure(message: "Something went wrong on Fetching product by id"),
      );
    } on Exception catch (e, s) {
      return left(Failure(message: e.toString(), stackTrace: s));
    }
  }
}
