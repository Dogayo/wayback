import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/features/settings/domain/entities/app_settings.dart';
import 'package:wayback/features/settings/view/bloc/set_language_bloc.dart';
import 'package:wayback/features/settings/view/bloc/set_units_bloc.dart';
import 'package:wayback/features/settings/view/bloc/set_vibration_on_arrival_bloc.dart';
import 'package:wayback/features/settings/view/bloc/settings_bloc.dart';

import '../fake_settings_repository.dart';

void main() {
  late FakeSettingsRepository repository;

  setUp(() => repository = FakeSettingsRepository());

  test('SettingsBloc shows the settings and follows changes', () async {
    final bloc = SettingsBloc(repository)..fetch();
    addTearDown(bloc.close);
    await pumpEventQueue();
    expect(bloc.state.dataOrNull, AppSettings.defaults);

    await repository.setUnits(UnitSystem.imperial);
    await pumpEventQueue();
    expect(bloc.state.dataOrNull?.units, UnitSystem.imperial);
  });

  test('each action bloc changes its own setting', () async {
    final units = SetUnitsBloc(repository);
    final language = SetLanguageBloc(repository);
    final vibration = SetVibrationOnArrivalBloc(repository);
    addTearDown(units.close);
    addTearDown(language.close);
    addTearDown(vibration.close);

    units.run(UnitSystem.imperial);
    language.run(AppLanguage.ru);
    vibration.run(false);
    await pumpEventQueue();

    expect(
      repository.settings,
      const AppSettings(
        units: UnitSystem.imperial,
        language: AppLanguage.ru,
        vibrationOnArrival: false,
      ),
    );
    expect(units.state.mapOrNull(success: (_) => true), isTrue);
  });

  test('a failed write is a failure state', () async {
    repository.failNext = const StorageFailure(code: 'settings_storage_failed');
    final bloc = SetUnitsBloc(repository);
    addTearDown(bloc.close);

    bloc.run(UnitSystem.imperial);
    await pumpEventQueue();

    expect(
      bloc.state.mapOrNull(failure: (s) => s.failure.code),
      'settings_storage_failed',
    );
    expect(repository.settings.units, UnitSystem.metric);
  });
}
