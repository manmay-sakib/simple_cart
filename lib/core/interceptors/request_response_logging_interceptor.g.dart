// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_response_logging_interceptor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(requestResponseLoggingInterceptor)
const requestResponseLoggingInterceptorProvider =
    RequestResponseLoggingInterceptorProvider._();

final class RequestResponseLoggingInterceptorProvider
    extends
        $FunctionalProvider<
          RequestResponseLoggingInterceptor,
          RequestResponseLoggingInterceptor,
          RequestResponseLoggingInterceptor
        >
    with $Provider<RequestResponseLoggingInterceptor> {
  const RequestResponseLoggingInterceptorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'requestResponseLoggingInterceptorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$requestResponseLoggingInterceptorHash();

  @$internal
  @override
  $ProviderElement<RequestResponseLoggingInterceptor> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RequestResponseLoggingInterceptor create(Ref ref) {
    return requestResponseLoggingInterceptor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RequestResponseLoggingInterceptor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RequestResponseLoggingInterceptor>(
        value,
      ),
    );
  }
}

String _$requestResponseLoggingInterceptorHash() =>
    r'27eda569b0c123860fb3552264efd14c9f6e8a0a';
