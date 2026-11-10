import 'package:wayback/core/bloc/action/action_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/settings/domain/repositories/diagnostics_repository.dart';

export 'package:wayback/core/bloc/action/action_bloc.dart';

/// Shares the diagnostic log; the parameter is the mail subject.
final class SendLogBloc extends ActionBloc<String, void> {
  SendLogBloc(this._diagnostics);

  final DiagnosticsRepository _diagnostics;

  @override
  Future<Result<void>> perform(String params) =>
      _diagnostics.shareLog(subject: params);
}
