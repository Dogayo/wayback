import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wayback/core/error/exceptions.dart';
import 'package:wayback/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:wayback/features/onboarding/data/datasources/shared_preferences_onboarding_datasource.dart';
import 'package:wayback/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:wayback/features/onboarding/domain/repositories/onboarding_repository.dart';

const _key = SharedPreferencesOnboardingDatasource.storageKey;

Future<OnboardingRepositoryImpl> _build([
  Map<String, Object> values = const {},
]) async {
  SharedPreferences.setMockInitialValues(values);
  return OnboardingRepositoryImpl(
    SharedPreferencesOnboardingDatasource(
      await SharedPreferences.getInstance(),
    ),
  );
}

final class _BrokenDatasource implements OnboardingLocalDatasource {
  @override
  Future<bool> readCompleted() async => false;

  @override
  Future<void> writeCompleted() async =>
      throw const StorageException(code: OnboardingErrorCodes.storageFailed);
}

void main() {
  test('a fresh install has not seen onboarding', () async {
    expect((await (await _build()).isCompleted()).valueOrNull, isFalse);
  });

  test('completion survives a restart', () async {
    await (await _build()).complete();
    final stored = (await SharedPreferences.getInstance()).getBool(_key)!;

    final restarted = await _build({_key: stored});

    expect((await restarted.isCompleted()).valueOrNull, isTrue);
  });

  test('a failed save still counts for this run', () async {
    final repository = OnboardingRepositoryImpl(_BrokenDatasource());

    final result = await repository.complete();

    expect(result.failureOrNull?.code, OnboardingErrorCodes.storageFailed);
    expect((await repository.isCompleted()).valueOrNull, isTrue);
  });
}
