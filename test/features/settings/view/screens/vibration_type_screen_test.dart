import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/features/settings/domain/entities/app_settings.dart';
import 'package:wayback/features/settings/view/bloc/set_vibration_pattern_bloc.dart';
import 'package:wayback/features/settings/view/bloc/settings_bloc.dart';
import 'package:wayback/features/settings/view/bloc/test_vibration_bloc.dart';
import 'package:wayback/features/settings/view/screens/vibration_type_screen.dart';

import '../../../navigation/fake_vibration_repository.dart';
import '../../../points/view/screens/screen_host.dart';
import '../../fake_settings_repository.dart';

Future<void> _pump(
  WidgetTester tester,
  FakeSettingsRepository repository,
  FakeVibrationRepository vibration,
) async {
  await pumpScreen(
    tester,
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsBloc(repository)..fetch()),
        BlocProvider(create: (_) => SetVibrationPatternBloc(repository)),
        BlocProvider(create: (_) => TestVibrationBloc(vibration)),
      ],
      child: const VibrationTypeScreen(),
    ),
  );
  await settle(tester);
}

void main() {
  testWidgets('offers the vibrations and a way to test them', (tester) async {
    await _pump(tester, FakeSettingsRepository(), FakeVibrationRepository());

    expect(find.text('Вид вибрации'), findsOneWidget);
    for (final name in ['Обычная', 'Длинная', 'Двойная', 'Сильная']) {
      expect(find.text(name), findsOneWidget);
    }
    expect(find.text('Короткая'), findsNothing);
    expect(find.text('Проверить'), findsOneWidget);
  });

  testWidgets('Test plays the picked vibration, which is saved', (
    tester,
  ) async {
    final repository = FakeSettingsRepository();
    final vibration = FakeVibrationRepository();
    await _pump(tester, repository, vibration);

    await tester.tap(find.text('Сильная'));
    await settle(tester);
    await tester.tap(find.text('Проверить'));
    await settle(tester);

    expect(repository.settings.vibrationPattern, VibrationPattern.strong);
    expect(vibration.patterns, [VibrationPattern.strong]);
  });

  testWidgets('a failed write says so', (tester) async {
    final repository = FakeSettingsRepository()
      ..failNext = const StorageFailure(code: 'settings_storage_failed');
    await _pump(tester, repository, FakeVibrationRepository());

    await tester.tap(find.text('Длинная'));
    await settle(tester);

    expect(find.text('Не удалось сохранить настройки'), findsOneWidget);
    expect(repository.settings.vibrationPattern, VibrationPattern.standard);
  });
}
