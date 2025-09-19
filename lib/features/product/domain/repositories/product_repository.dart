import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:simple_cart/core/errors/failure.dart';
import 'package:simple_cart/features/product/data/repositories/product_repository_impl.dart';
import 'package:simple_cart/features/product/data/services/product_service.dart';
import 'package:simple_cart/features/product/domain/models/product_model.dart';

part 'product_repository.g.dart';

@riverpod
ProductRepository productRepository(Ref ref) {
  return ProductRepositoryImpl(ref.watch(productServiceProvider));
}

abstract class ProductRepository {
  FutureOrFailure<List<ProductModel>> fetchProducts();
  FutureOrFailure<ProductModel> fetchProductById(int id);
}
