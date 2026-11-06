import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/location/domain/entities/location_access.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';
import 'package:wayback/features/location/view/bloc/location_fix_bloc.dart';
import 'package:wayback/features/location/view/bloc/open_location_settings_bloc.dart';
import 'package:wayback/features/location/view/bloc/request_location_permission_bloc.dart';
import 'package:wayback/features/location/view/widgets/gps_status.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

import '../fake_location_repository.dart';

Future<FakeLocationRepository> _pump(
  WidgetTester tester, {
  Result<LocationAccess> access = const Result.success(LocationAccess.granted),
}) async {
  final repository = FakeLocationRepository(access: access);
  await tester.pumpWidget(
    MaterialApp(
      theme: WbTheme.light,
      locale: const Locale('ru'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => LocationFixBloc(repository)..fetch()),
            BlocProvider(
              create: (_) => RequestLocationPermissionBloc(repository),
            ),
            BlocProvider(create: (_) => OpenLocationSettingsBloc(repository)),
          ],
          child: const GpsStatus(),
        ),
      ),
    ),
  );
  await tester.pump();
  return repository;
}

/// The app goes to the background and comes back, through every state the
/// lifecycle listener expects.
void _leaveAndReturn(WidgetTester tester) => [
  AppLifecycleState.inactive,
  AppLifecycleState.hidden,
  AppLifecycleState.paused,
  AppLifecycleState.hidden,
  AppLifecycleState.inactive,
  AppLifecycleState.resumed,
].forEach(tester.binding.handleAppLifecycleStateChanged);

void main() {
  testWidgets('accuracy without a warning for a good fix', (tester) async {
    final repository = await _pump(tester);
    repository.fixes.add(Result.success(fixWithAccuracy(8.4)));
    await tester.pump();

    expect(find.text('Точность ±8 м'), findsOneWidget);
    expect(find.textContaining('Слабый сигнал'), findsNothing);
  });

  testWidgets('a weak signal is shown, not hidden', (tester) async {
    final repository = await _pump(tester);
    repository.fixes.add(Result.success(fixWithAccuracy(65)));
    await tester.pump();

    expect(find.text('Точность ±65 м'), findsOneWidget);
    expect(find.textContaining('Слабый сигнал GPS'), findsOneWidget);
  });

  testWidgets('no permission yet: Allow asks, then fixes come', (tester) async {
    final repository = await _pump(
      tester,
      access: const Result.success(LocationAccess.denied),
    );
    expect(find.text('Доступ к геолокации'), findsOneWidget);

    await tester.tap(find.text('Разрешить'));
    await tester.pump();
    await tester.pump();
    repository.fixes.add(Result.success(fixWithAccuracy(8)));
    await tester.pump();

    expect(repository.requests, 1);
    expect(find.text('Точность ±8 м'), findsOneWidget);
  });

  testWidgets('back from settings re-checks; other returns do not', (
    tester,
  ) async {
    final repository = await _pump(
      tester,
      access: const Result.success(LocationAccess.serviceDisabled),
    );
    expect(find.text('Геолокация выключена'), findsOneWidget);
    final checks = repository.checks;

    // A return from a system dialog the request itself raised.
    _leaveAndReturn(tester);
    await tester.pump();
    expect(repository.checks, checks);

    await tester.tap(find.text('Открыть настройки'));
    await tester.pump();
    await tester.pump();
    _leaveAndReturn(tester);
    await tester.pump();

    expect(repository.opened, ['location']);
    // Once when the settings open, once on the way back.
    expect(repository.checks, checks + 2);
  });

  testWidgets('approximate access offers precise and recovers', (tester) async {
    final repository = await _pump(
      tester,
      access: const Result.success(LocationAccess.approximate),
    );
    await tester.pump();
    expect(find.text('Нужна точная геолокация'), findsOneWidget);

    await tester.tap(find.text('Включить точную геолокацию'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    repository.fixes.add(Result.success(fixWithAccuracy(8)));
    await tester.pump(const Duration(milliseconds: 50));

    expect(repository.preciseRequests, 1);
    expect(repository.opened, isEmpty);
    expect(find.text('Нужна точная геолокация'), findsNothing);
    expect(find.textContaining('±8'), findsOneWidget);
  });

  testWidgets('no fix offers a retry', (tester) async {
    final repository = await _pump(tester);
    repository.fixes.add(
      const Result.failure(SensorFailure(code: LocationErrorCodes.unavailable)),
    );
    await tester.pump();

    expect(find.text('Не получается определить, где вы'), findsOneWidget);
    expect(find.text('Повторить'), findsOneWidget);
  });
}
