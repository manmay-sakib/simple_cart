import 'package:retrofit/http.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';

part 'product_service.g.dart';

@riverpod
ProductService productService(Ref ref) {
  return ProductService(ref.read());
}

@RestApi(baseUrl: Endpoints.baseUrl)
abstract class ProductService {
  factory ProductService(Dio dio, {String baseUrl}) = _ProductService;
}
