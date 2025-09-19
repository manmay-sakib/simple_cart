import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:simple_cart/features/product/domain/repositories/product_repository.dart';

import '../../../../core/errors/failure.dart';
import '../models/product_model.dart';

part 'get_product_list_usecase.g.dart';

@riverpod
Future<Either<Failure, List<ProductModel>>> getProductListUsecase(
  Ref ref,
) async {
  final productRepository = ref.watch(productRepositoryProvider);
  try {
    final productList = await productRepository.fetchProducts();
    return productList;
  } on Failure {
    return left(Failure(message: "Something went wrong"));
  } catch (e, s) {
    return left(Failure(message: e.toString(), stackTrace: s));
  }
}
