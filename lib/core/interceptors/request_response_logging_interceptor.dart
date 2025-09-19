import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'request_response_logging_interceptor.g.dart';

@riverpod
RequestResponseLoggingInterceptor requestResponseLoggingInterceptor(Ref ref) {
  return RequestResponseLoggingInterceptor();
}

class RequestResponseLoggingInterceptor extends Interceptor with Logging {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final String message =
        """
    ReceivedResponse: ${response.statusCode} ${response.data}
    From: ${response.requestOptions.method} ${response.requestOptions.uri} """;
    handler.next(response);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final String message =
        """
    Error: ${err.message}
    From:${err.requestOptions.method} ${err.requestOptions.uri}
    Response Body: ${err.response?.data}
    """;
    handler.next(err);
  }
}
