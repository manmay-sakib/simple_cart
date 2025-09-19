import 'package:retrofit/http.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import 'package:simple_cart/core/providers/dio_provider.dart';
import 'package:retrofit/error_logger.dart';
import 'package:simple_cart/features/product/data/entities/product_response.dart';

import '../../../../core/constants/api_endpoints.dart';

part 'product_service.g.dart';

@riverpod
ProductService productService(Ref ref) {
  return ProductService(ref.read(dioProvider));
}

@RestApi(baseUrl: ApiEndpoints.baseUrl)
abstract class ProductService {
  factory ProductService(Dio dio, {String baseUrl}) = _ProductService;

  @GET(ApiEndpoints.product)
  Future<List<ProductResponse>> getProducts();

  @GET(ApiEndpoints.productById)
  Future<ProductResponse> getProductById(@Path("id") int id);
}
