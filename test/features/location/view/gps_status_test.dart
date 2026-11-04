import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';
import 'package:wayback/features/location/view/bloc/location_cubit.dart';
import 'package:wayback/features/location/view/widgets/gps_status.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

import '../fake_location_repository.dart';

Future<void> _pump(WidgetTester tester, LocationState state) async {
  final cubit = LocationCubit(FakeLocationRepository())..emit(state);
  addTearDown(cubit.close);
  await tester.pumpWidget(
    MaterialApp(
      theme: WbTheme.light,
      locale: const Locale('ru'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: BlocProvider.value(value: cubit, child: const GpsStatus()),
      ),
    ),
  );
}

void main() {
  testWidgets('shows accuracy without a warning for a good fix', (
    tester,
  ) async {
    await _pump(tester, LocationReady(fixWithAccuracy(8.4)));

    expect(find.text('Точность ±8 м'), findsOneWidget);
    expect(find.textContaining('Слабый сигнал'), findsNothing);
  });

  testWidgets('warns about a weak signal instead of hiding it', (tester) async {
    await _pump(tester, LocationReady(fixWithAccuracy(65)));

    expect(find.text('Точность ±65 м'), findsOneWidget);
    expect(find.textContaining('Слабый сигнал GPS'), findsOneWidget);
  });

  testWidgets('asks for permission with an Allow action', (tester) async {
    await _pump(tester, const LocationPermissionNeeded());

    expect(find.text('Доступ к геолокации'), findsOneWidget);
    expect(find.text('Разрешить'), findsOneWidget);
  });

  testWidgets('permanent refusal leads to the settings', (tester) async {
    await _pump(
      tester,
      const LocationError(
        PermissionFailure(code: LocationErrorCodes.permissionDeniedForever),
      ),
    );

    expect(find.text('Доступ к геолокации запрещён'), findsOneWidget);
    expect(find.text('Открыть настройки'), findsOneWidget);
  });

  testWidgets('no fix offers a retry', (tester) async {
    await _pump(
      tester,
      const LocationError(SensorFailure(code: LocationErrorCodes.unavailable)),
    );

    expect(find.text('Не получается определить, где вы'), findsOneWidget);
    expect(find.text('Повторить'), findsOneWidget);
  });
}
