import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'nothing.dart';

class Failure implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const Failure({required this.message, this.stackTrace});

  factory Failure.unknown() {
    return Failure(
      message: "Something went wrong",
      stackTrace: StackTrace.current,
    );
  }

  void printStackTrace() {
    debugPrintStack(stackTrace: stackTrace);
  }

  static Future<AsyncValue<T>> guard<T>(
    FutureOrFailure<T> Function() future, [
    bool Function(Object)? test,
  ]) async {
    final result = await future();

    final r = switch (result) {
      Left<Failure, T> l => AsyncValue.error(l.value, StackTrace.current),
      Right<Failure, T> r => AsyncValue.data(r.value),
      Either<Failure, T>() => throw UnimplementedError(),
    };
    return r.value;
  }
}

/// A shorthand type for Future<Either<L,R>>
typedef FutureEither<L, R> = Future<Either<L, R>>;

/// A shorthand type for Future<Either<Failure, R>>
typedef FutureOrFailure<R> = FutureEither<Failure, R>;

typedef AsyncFailureOrNothing = FutureOrFailure<Nothing>;

typedef FailureEither<R> = Either<Failure, R>;
