import 'package:lettuce_travel/core/errors/failure.dart';

/// Explicit success/failure return type for repositories.
///
/// Repositories never throw across a layer boundary; they return a [Result] and
/// the caller decides what the user sees.
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;

  const factory Result.err(Failure failure) = Err<T>;

  bool get isOk => this is Ok<T>;

  T? get valueOrNull => switch (this) {
        Ok<T>(:final T value) => value,
        Err<T>() => null,
      };

  Failure? get failureOrNull => switch (this) {
        Ok<T>() => null,
        Err<T>(:final Failure failure) => failure,
      };

  R when<R>({
    required R Function(T value) ok,
    required R Function(Failure failure) err,
  }) =>
      switch (this) {
        Ok<T>(:final T value) => ok(value),
        Err<T>(:final Failure failure) => err(failure),
      };

  Result<R> map<R>(R Function(T value) transform) => switch (this) {
        Ok<T>(:final T value) => Ok<R>(transform(value)),
        Err<T>(:final Failure failure) => Err<R>(failure),
      };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
