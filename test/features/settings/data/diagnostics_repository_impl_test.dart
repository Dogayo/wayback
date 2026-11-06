import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/error/exceptions.dart';
import 'package:wayback/features/settings/data/datasources/diagnostics_datasource.dart';
import 'package:wayback/features/settings/data/repositories/diagnostics_repository_impl.dart';
import 'package:wayback/features/settings/domain/repositories/diagnostics_repository.dart';

final class _Datasource implements DiagnosticsDatasource {
  _Datasource({this.fails = false});

  final bool fails;
  String? subject;

  @override
  Future<void> shareLog({required String subject}) async {
    if (fails) {
      throw const StorageException(code: DiagnosticsErrorCodes.exportFailed);
    }
    this.subject = subject;
  }
}

void main() {
  test('passes the subject on', () async {
    final datasource = _Datasource();

    final result = await DiagnosticsRepositoryImpl(
      datasource,
    ).shareLog(subject: 'Журнал Wayback');

    expect(result.failureOrNull, isNull);
    expect(datasource.subject, 'Журнал Wayback');
  });

  test('a failed export is a failure, not an exception', () async {
    final result = await DiagnosticsRepositoryImpl(
      _Datasource(fails: true),
    ).shareLog(subject: 'x');

    expect(result.failureOrNull?.code, DiagnosticsErrorCodes.exportFailed);
  });
}
