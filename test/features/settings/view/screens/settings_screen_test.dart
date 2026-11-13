import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/features/settings/domain/entities/app_settings.dart';
import 'package:wayback/features/settings/view/bloc/send_log_bloc.dart';
import 'package:wayback/features/settings/view/bloc/set_language_bloc.dart';
import 'package:wayback/features/settings/view/bloc/set_theme_mode_bloc.dart';
import 'package:wayback/features/settings/view/bloc/set_touch_feedback_bloc.dart';
import 'package:wayback/features/settings/view/bloc/set_units_bloc.dart';
import 'package:wayback/features/settings/view/bloc/set_vibration_on_arrival_bloc.dart';
import 'package:wayback/features/settings/view/bloc/settings_bloc.dart';
import 'package:wayback/features/settings/view/screens/settings_screen.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

import '../../../points/view/screens/screen_host.dart';
import '../../fake_diagnostics_repository.dart';
import '../../fake_settings_repository.dart';

Future<void> _pump(
  WidgetTester tester,
  FakeSettingsRepository repository, {
  FakeDiagnosticsRepository? diagnostics,
}) async {
  await pumpScreen(
    tester,
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsBloc(repository)..fetch()),
        BlocProvider(create: (_) => SetUnitsBloc(repository)),
        BlocProvider(create: (_) => SetLanguageBloc(repository)),
        BlocProvider(create: (_) => SetThemeModeBloc(repository)),
        BlocProvider(create: (_) => SetVibrationOnArrivalBloc(repository)),
        BlocProvider(create: (_) => SetTouchFeedbackBloc(repository)),
        BlocProvider(
          create: (_) =>
              SendLogBloc(diagnostics ?? FakeDiagnosticsRepository()),
        ),
      ],
      child: const SettingsScreen(),
    ),
  );
  await settle(tester);
}

void main() {
  testWidgets('shows the current settings', (tester) async {
    await _pump(tester, FakeSettingsRepository());

    expect(find.text('Настройки'), findsOneWidget);
    expect(find.text('Единицы измерения'), findsOneWidget);
    expect(find.text('Метры и километры'), findsOneWidget);
    expect(find.text('Футы и мили'), findsOneWidget);
    expect(find.text('Как в системе'), findsOneWidget);
    expect(find.text('Русский'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Вибрация при прибытии'), findsOneWidget);
    expect(find.text('Вид вибрации'), findsOneWidget);
    expect(find.text('Обычная'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch).first).value, isTrue);
  });

  testWidgets('every change is saved right away', (tester) async {
    final repository = FakeSettingsRepository();
    await _pump(tester, repository);

    await tester.tap(find.text('Футы и мили'));
    await settle(tester);
    await tester.tap(find.text('English'));
    await settle(tester);
    await tester.tap(find.byType(Switch).first);
    await settle(tester);

    expect(
      repository.settings,
      const AppSettings(
        units: UnitSystem.imperial,
        language: AppLanguage.en,
        vibrationOnArrival: false,
      ),
    );
    expect(tester.widget<Switch>(find.byType(Switch).first).value, isFalse);
  });

  testWidgets('the app bar switches the theme', (tester) async {
    final repository = FakeSettingsRepository();
    await _pump(tester, repository);

    // The test host runs the light theme, so the sun is on screen.
    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
    expect(repository.settings.themeMode, AppThemeMode.system);

    await tester.tap(find.byType(WbThemeToggle));
    await settle(tester);

    expect(repository.settings.themeMode, AppThemeMode.dark);
  });

  testWidgets('a failed theme change says so', (tester) async {
    final repository = FakeSettingsRepository()
      ..failNext = const StorageFailure(code: 'settings_storage_failed');
    await _pump(tester, repository);

    await tester.tap(find.byType(WbThemeToggle));
    await settle(tester);

    expect(find.text('Не удалось сохранить настройки'), findsOneWidget);
    expect(repository.settings.themeMode, AppThemeMode.system);
  });

  testWidgets('haptic feedback has its own switch, on by default', (
    tester,
  ) async {
    final repository = FakeSettingsRepository();
    await _pump(tester, repository);

    expect(find.text('Отклик при нажатиях'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch).last).value, isTrue);

    await tester.tap(find.byType(Switch).last);
    await settle(tester);

    expect(repository.settings.touchFeedback, isFalse);
    expect(repository.settings.vibrationOnArrival, isTrue);
  });

  testWidgets('vibration turned off hides its type', (tester) async {
    await _pump(
      tester,
      FakeSettingsRepository(const AppSettings(vibrationOnArrival: false)),
    );

    expect(find.text('Вид вибрации'), findsNothing);
  });

  testWidgets('a failed write keeps the value and says so', (tester) async {
    final repository = FakeSettingsRepository()
      ..failNext = const StorageFailure(code: 'settings_storage_failed');
    await _pump(tester, repository);

    await tester.tap(find.byType(Switch).first);
    await settle(tester);

    expect(find.text('Не удалось сохранить настройки'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch).first).value, isTrue);
  });

  testWidgets('Send log shares it with a subject', (tester) async {
    final diagnostics = FakeDiagnosticsRepository();
    await _pump(tester, FakeSettingsRepository(), diagnostics: diagnostics);

    expect(find.text('Для разбора ошибок, без координат'), findsOneWidget);
    await tester.tap(find.text('Отправить журнал'));
    await settle(tester);

    expect(diagnostics.subjects, ['Журнал Wayback']);
  });

  testWidgets('a failed export says so', (tester) async {
    await _pump(
      tester,
      FakeSettingsRepository(),
      diagnostics: FakeDiagnosticsRepository()
        ..failNext = const StorageFailure(code: 'diagnostics_export_failed'),
    );

    await tester.tap(find.text('Отправить журнал'));
    await settle(tester);

    expect(find.text('Не удалось подготовить журнал'), findsOneWidget);
  });

  testWidgets('unreadable settings: error with retry', (tester) async {
    await _pump(
      tester,
      FakeSettingsRepository()
        ..readFailure = const StorageFailure(code: 'settings_storage_failed'),
    );

    expect(find.text('Не удалось сохранить настройки'), findsOneWidget);
    expect(find.text('Повторить'), findsOneWidget);
  });
}
