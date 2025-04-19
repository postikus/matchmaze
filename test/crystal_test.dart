import 'package:flutter_test/flutter_test.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:matchmaze/components/crystal.dart';
import 'package:matchmaze/game/field/game_field.dart';
import 'package:matchmaze/core/game_settings.dart';
import 'package:matchmaze/core/game.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Crystal Properties', () {
    test('Crystal should initialize with correct properties', () {
      final crystal = Crystal(
        color: CrystalColor.red,
        position: Vector2(100, 100),
        row: 1,
        col: 2,
      );
      
      expect(crystal.color, equals(CrystalColor.red));
      expect(crystal.row, equals(1));
      expect(crystal.col, equals(2));
      expect(crystal.position, equals(Vector2(100, 100)));
      expect(crystal.startPosition, equals(Vector2(100, 100)));
    });
    
    test('Crystal should have correct color representation', () {
      final redCrystal = Crystal(
        color: CrystalColor.red,
        position: Vector2(100, 100),
        row: 0,
        col: 0,
      );
      
      final blueCrystal = Crystal(
        color: CrystalColor.blue,
        position: Vector2(100, 100),
        row: 0,
        col: 1,
      );
      
      final greenCrystal = Crystal(
        color: CrystalColor.green,
        position: Vector2(100, 100),
        row: 0,
        col: 2,
      );
      
      expect(redCrystal.color, equals(CrystalColor.red));
      expect(blueCrystal.color, equals(CrystalColor.blue));
      expect(greenCrystal.color, equals(CrystalColor.green));
    });
  });
  
  group('Crystal Animation', () {
    test('Crystal should have animation helper methods', () {
      final crystal = Crystal(
        color: CrystalColor.red,
        position: Vector2(100, 100),
        row: 1,
        col: 2,
      );
      
      // Test that the crystal has the required methods
      expect(crystal.swapWith, isA<Function>());
      expect(crystal.matchEffect, isA<Function>());
    });
    
    test('Crystal should be able to swap with another crystal', () async {
      final crystal1 = Crystal(
        color: CrystalColor.red,
        position: Vector2(100, 100),
        row: 1,
        col: 1,
      );
      
      final crystal2 = Crystal(
        color: CrystalColor.blue,
        position: Vector2(150, 100),
        row: 1,
        col: 2,
      );
      
      // Capture original positions
      final originalPos1 = crystal1.position.clone();
      final originalPos2 = crystal2.position.clone();
      
      // Perform swap
      await crystal1.swapWith(crystal2);
      
      // Verify positions have been swapped (approximately due to animations)
      expect((crystal1.position - originalPos2).length, lessThan(0.1));
      expect((crystal2.position - originalPos1).length, lessThan(0.1));
    });
  });
}
