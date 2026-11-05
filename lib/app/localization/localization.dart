import 'package:flutter/widgets.dart';

import 'package:wayback/app/localization/generated/app_localizations.dart';

export 'package:wayback/app/localization/generated/app_localizations.dart';

extension LocalizationContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
