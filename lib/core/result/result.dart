import 'package:wayback/core/error/failures.dart';

/// Outcome of a repository call: either a value or a [Failure].
///
/// Repositories return it instead of throwing, so exceptions never cross the
/// `data` boundary (architecture.md §4.3). Match it exhaustively:
///
/// ```dart
/// switch (await repository.getAll()) {
///   case Success(:final value): emit(PointsState.content(value));
///   case Failed(:final failure): emit(PointsState.error(failure));
/// }
/// ```
sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(Failure failure) = Failed<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failed<T>;

  T? get valueOrNull => switch (this) {
    Success(:final value) => value,
    Failed() => null,
  };

  Failure? get failureOrNull => switch (this) {
    Success() => null,
    Failed(:final failure) => failure,
  };

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) => switch (this) {
    Success(:final value) => onSuccess(value),
    Failed(:final failure) => onFailure(failure),
  };

  /// Transforms the value and passes a failure through unchanged.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Success(:final value) => Success(transform(value)),
    Failed(:final failure) => Failed(failure),
  };
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Success<T> && other.value == value;

  @override
  int get hashCode => Object.hash(Success, value);

  @override
  String toString() => 'Success($value)';
}

final class Failed<T> extends Result<T> {
  const Failed(this.failure);

  final Failure failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Failed<T> && other.failure == failure;

  @override
  int get hashCode => Object.hash(Failed, failure);

  @override
  String toString() => 'Failed($failure)';
}
