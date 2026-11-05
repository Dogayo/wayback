import 'package:intl/intl.dart';
import 'package:wayback/app/localization/generated/app_localizations.dart';

extension TimeL10n on AppLocalizations {
  /// When a point was saved, relative to [now] (docs/copy.md §5): "только
  /// что", "12 мин назад", "3 ч назад", "вчера", then the date.
  String savedWhen(DateTime at, {required DateTime now}) {
    final local = at.toLocal();
    final current = now.toLocal();
    final age = current.difference(local);
    final today = DateTime(current.year, current.month, current.day);
    final day = DateTime(local.year, local.month, local.day);
    if (age < const Duration(minutes: 1)) return timeJustNow;
    if (age < const Duration(hours: 1)) return timeMinutesAgo(age.inMinutes);
    if (day == today) return timeHoursAgo(age.inHours);
    if (day == today.subtract(const Duration(days: 1))) return timeYesterday;
    return (local.year == current.year
            ? DateFormat.MMMd(localeName)
            : DateFormat.yMMMd(localeName))
        .format(local);
  }
}
