import 'package:flutter/material.dart';
import 'package:wayback/features/settings/domain/entities/app_settings.dart';

export 'package:wayback/features/settings/domain/entities/app_settings.dart';

/// Gives the current [AppSettings] to every screen; the app rebuilds it on
/// each change.
class SettingsScope extends InheritedWidget {
  const SettingsScope({
    required this.settings,
    required super.child,
    super.key,
  });

  final AppSettings settings;

  /// Defaults without a scope, e.g. in a screen test.
  static AppSettings of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsScope>()?.settings ??
      AppSettings.defaults;

  @override
  bool updateShouldNotify(SettingsScope oldWidget) =>
      settings != oldWidget.settings;
}

extension SettingsContext on BuildContext {
  AppSettings get settings => SettingsScope.of(this);
}

extension AppThemeModeTheme on AppThemeMode {
  /// What `MaterialApp` is given; [AppThemeMode.system] follows the phone.
  ThemeMode get themeMode => switch (this) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };
}

extension AppLanguageLocale on AppLanguage {
  /// `null` lets Flutter follow the system language.
  Locale? get locale => switch (this) {
    AppLanguage.system => null,
    AppLanguage.ru => const Locale('ru'),
    AppLanguage.en => const Locale('en'),
  };
}
