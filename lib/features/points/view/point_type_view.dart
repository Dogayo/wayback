import 'package:wayback/features/points/domain/entities/point_type.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

extension PointTypeView on PointType {
  /// The design system type with the icon and default label.
  WbPointType get design => WbPointType.values.byName(name);
}

extension WbPointTypeDomain on WbPointType {
  PointType get domain => PointType.values.byName(name);
}
