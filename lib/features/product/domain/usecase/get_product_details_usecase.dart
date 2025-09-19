import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';

part 'get_product_details_usecase.g.dart';

@riverpod
Future<Either<Failure, ProductModel>> getProductDetailsUsecase(
  Ref ref,
  int id,
) async {
  final productRepository = ref.watch(productRepositoryProvider);
  try {
    final productDetails = await productRepository.fetchProductById(id);
    return productDetails;
  } on Failure {
    return left(Failure(message: "Something went wrong"));
  } catch (e, s) {
    return left(Failure(message: e.toString(), stackTrace: s));
  }
}
