import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_provider.g.dart';

@riverpod
BaseOptions baseOptions(Ref ref, bool validateUnauthorized) {
  return BaseOptions(
    contentType: Headers.jsonContentType,
    validateStatus: (status) {
      !validateUnauthorized ? true : status != 401;
      if (!validateUnauthorized) return true;
      return status != 401;
    },
  );
}


@riverpod
Dio dio(Ref ref) {
  final BaseOptions baseOptions = ref.watch(baseOptionsProvider(false));
  
  final loggingInterceptor = ref.read(reque)
  
  return Dio(baseOptions)..interceptors.add(loggingInterceptor);
}