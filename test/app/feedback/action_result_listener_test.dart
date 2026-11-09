import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/app/feedback/action_result_listener.dart';
import 'package:wayback/core/bloc/action/action_bloc.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

import '../../features/points/view/screens/screen_host.dart';

final class _Bloc extends ActionBloc<bool, int> {
  @override
  Future<Result<int>> perform(bool params) async => params
      ? const Result.success(7)
      : const Result.failure(
          StorageFailure(code: 'points_storage_write_failed'),
        );
}

void main() {
  late List<WbHaptic> haptics;
  late _Bloc bloc;

  setUp(() => haptics = []);

  Future<void> pump(
    WidgetTester tester, {
    WbHaptic? successHaptic,
    void Function(BuildContext, int)? onSuccess,
    VoidCallback? onFailure,
    bool reportFailure = true,
  }) async {
    await pumpScreen(
      tester,
      // Made and closed by the tree, so that it runs in the test's fake time.
      BlocProvider(
        lazy: false,
        create: (_) => bloc = _Bloc(),
        child: ActionResultListener<_Bloc, int>(
          successHaptic: successHaptic,
          onSuccess: onSuccess,
          onFailure: onFailure,
          reportFailure: reportFailure,
          child: const Scaffold(),
        ),
      ),
      haptics: haptics,
    );
  }

  Future<void> run(WidgetTester tester, {required bool succeed}) async {
    bloc.run(succeed);
    await settle(tester);
  }

  testWidgets('success plays the haptic, then the callback', (tester) async {
    int? result;
    var playedFirst = false;
    await pump(
      tester,
      successHaptic: WbHaptic.success,
      onSuccess: (_, value) {
        playedFirst = haptics.isNotEmpty;
        result = value;
      },
    );

    await run(tester, succeed: true);

    expect(haptics, [WbHaptic.success]);
    expect(result, 7);
    expect(playedFirst, isTrue);
  });

  testWidgets('no haptic asked, none played', (tester) async {
    await pump(tester);

    await run(tester, succeed: true);

    expect(haptics, isEmpty);
  });

  testWidgets('a failure warns and says what happened', (tester) async {
    await pump(tester, successHaptic: WbHaptic.tick);

    await run(tester, succeed: false);

    expect(haptics, [WbHaptic.warning]);
    expect(find.text('Не удалось сохранить точку'), findsOneWidget);
  });

  testWidgets('a silent listener stays silent but can still react', (
    tester,
  ) async {
    var failed = false;
    await pump(tester, reportFailure: false, onFailure: () => failed = true);

    await run(tester, succeed: false);

    expect(haptics, isEmpty);
    expect(find.byType(SnackBar), findsNothing);
    expect(failed, isTrue);
  });
}
