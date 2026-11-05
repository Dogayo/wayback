import 'package:flutter/material.dart';

enum WbPointType {
  car,
  tent,
  fishing,
  backpack,
  house,
  meeting,
  parking,
  generic,
}

extension WbPointTypeData on WbPointType {
  String get label => switch (this) {
    WbPointType.car => 'Машина',
    WbPointType.tent => 'Лагерь',
    WbPointType.fishing => 'Рыбалка',
    WbPointType.backpack => 'Вещи',
    WbPointType.house => 'Домик',
    WbPointType.meeting => 'Встреча',
    WbPointType.parking => 'Парковка',
    WbPointType.generic => 'Точка',
  };
  IconData get icon => switch (this) {
    WbPointType.car => Icons.directions_car_outlined,
    WbPointType.tent => Icons.cabin_outlined,
    WbPointType.fishing => Icons.phishing_outlined,
    WbPointType.backpack => Icons.backpack_outlined,
    WbPointType.house => Icons.cottage_outlined,
    WbPointType.meeting => Icons.group_outlined,
    WbPointType.parking => Icons.local_parking_outlined,
    WbPointType.generic => Icons.location_on_outlined,
  };
}
