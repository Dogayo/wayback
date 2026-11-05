import 'package:wayback/app/localization/generated/app_localizations.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

extension PointTypeL10n on AppLocalizations {
  /// Localized label for a point type; also the default point name.
  String pointType(WbPointType type) => switch (type) {
    WbPointType.car => pointTypeCar,
    WbPointType.tent => pointTypeTent,
    WbPointType.fishing => pointTypeFishing,
    WbPointType.backpack => pointTypeBackpack,
    WbPointType.house => pointTypeHouse,
    WbPointType.meeting => pointTypeMeeting,
    WbPointType.parking => pointTypeParking,
    WbPointType.generic => pointTypeGeneric,
  };
}
