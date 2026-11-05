import 'package:wayback/core/result/result.dart';

/// Failure codes [OnboardingRepository] can return (architecture.md §4.2).
///
/// Not localized: a failure here never reaches the user, the app moves on
/// (SCREENS.md §4.0).
abstract final class OnboardingErrorCodes {
  static const storageFailed = 'onboarding_storage_failed';
}

/// Whether the first-launch onboarding is done (mvp-scope.md §2.6).
/// Every method returns a [Result]; none of them throws.
abstract interface class OnboardingRepository {
  Future<Result<bool>> isCompleted();

  /// Marks onboarding done. It counts as done for this run even if saving
  /// fails, so the user is never sent back to it; it may show again on the
  /// next launch.
  Future<Result<void>> complete();
}
