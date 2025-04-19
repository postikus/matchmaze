import 'package:flutter_test/flutter_test.dart';
import 'package:matchmaze/components/crystal.dart';

void main() {
  test('Crystal creation test', () {
    final crystal = Crystal(
      color: CrystalColor.red,
      position: Vector2.zero(),
      row: 0,
      col: 0,
    );
    expect(crystal.color, equals(CrystalColor.red));
  });
}
