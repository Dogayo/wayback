import 'package:wayback/app/localization/generated/app_localizations.dart';

/// Every `Failure.code` that has its own translation (docs/copy.md §11.2).
/// Any other code falls back to the generic text.
const localizedErrorCodes = {
  'location_permission_denied',
  'location_permission_denied_forever',
  'location_service_disabled',
  'location_unavailable',
  'location_precise_required',
  'navigation_compass_unavailable',
  'points_storage_read_failed',
  'points_storage_write_failed',
  'points_not_found',
  'settings_storage_failed',
  'diagnostics_export_failed',
  'point_share_failed',
};

typedef ErrorText = ({String title, String body});

extension ErrorL10n on AppLocalizations {
  /// Title and explanation for an Alert, looked up by `Failure.code`.
  ///
  /// Unknown codes get the generic text; the caller logs the code
  /// (architecture.md §4.2), the user never sees it.
  ErrorText error(String code) => switch (code) {
    'point_share_failed' => (
      title: error_point_share_failed,
      body: error_point_share_failed_body,
    ),
    'location_permission_denied' => (
      title: error_location_permission_denied,
      body: error_location_permission_denied_body,
    ),
    'location_permission_denied_forever' => (
      title: error_location_permission_denied_forever,
      body: error_location_permission_denied_forever_body,
    ),
    'location_service_disabled' => (
      title: error_location_service_disabled,
      body: error_location_service_disabled_body,
    ),
    'location_unavailable' => (
      title: error_location_unavailable,
      body: error_location_unavailable_body,
    ),
    'location_precise_required' => (
      title: error_location_precise_required,
      body: error_location_precise_required_body,
    ),
    'navigation_compass_unavailable' => (
      title: error_navigation_compass_unavailable,
      body: error_navigation_compass_unavailable_body,
    ),
    'points_storage_read_failed' => (
      title: error_points_storage_read_failed,
      body: error_points_storage_read_failed_body,
    ),
    'points_storage_write_failed' => (
      title: error_points_storage_write_failed,
      body: error_points_storage_write_failed_body,
    ),
    'points_not_found' => (
      title: error_points_not_found,
      body: error_points_not_found_body,
    ),
    'settings_storage_failed' => (
      title: error_settings_storage_failed,
      body: error_settings_storage_failed_body,
    ),
    'diagnostics_export_failed' => (
      title: error_diagnostics_export_failed,
      body: error_diagnostics_export_failed_body,
    ),
    _ => (title: error_generic, body: error_generic_body),
  };
}
