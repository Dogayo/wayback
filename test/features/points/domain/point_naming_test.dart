import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/features/points/domain/entities/point_naming.dart';

String _name(Iterable<String> existing) => defaultPointName(
  label: 'Машина',
  existingNames: existing,
  numbered: (label, number) => '$label $number',
);

void main() {
  test('the label itself while it is free', () {
    expect(_name(['Лагерь']), 'Машина');
  });

  test('the first free number once the label is taken', () {
    expect(_name(['Машина']), 'Машина 2');
    expect(_name(['Машина', 'Машина 2', 'Машина 4']), 'Машина 3');
  });
}
