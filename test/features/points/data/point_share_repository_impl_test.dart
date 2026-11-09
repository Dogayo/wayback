import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/error/exceptions.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/points/data/datasources/point_share_datasource.dart';
import 'package:wayback/features/points/data/repositories/point_share_repository_impl.dart';
import 'package:wayback/features/points/domain/repositories/point_share_repository.dart';

final class _Datasource implements PointShareDatasource {
  _Datasource({this.fails = false});

  final bool fails;
  String? shared;

  @override
  Future<void> shareText(String text) async {
    if (fails) {
      throw const StorageException(code: PointShareErrorCodes.shareFailed);
    }
    shared = text;
  }
}

void main() {
  test('passes the text on', () async {
    final datasource = _Datasource();

    final result = await PointShareRepositoryImpl(datasource).shareText('x');

    expect(result, isA<Success<void>>());
    expect(datasource.shared, 'x');
  });

  test('a failure becomes a result, not an exception', () async {
    final result = await PointShareRepositoryImpl(
      _Datasource(fails: true),
    ).shareText('x');

    expect(
      (result as Failed<void>).failure,
      isA<Failure>().having(
        (failure) => failure.code,
        'code',
        PointShareErrorCodes.shareFailed,
      ),
    );
  });
}
