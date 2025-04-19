import 'package:flutter_test/flutter_test.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/gestures.dart';
import 'package:matchmaze/components/crystal.dart';
import 'package:matchmaze/game/field/game_field.dart';
import 'package:matchmaze/core/game_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late GameField gameField;
  
  setUp(() {
    gameField = GameField();
  });
  
  group('Crystal Drag Mechanics', () {
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
    
    test('Crystal should handle drag start', () {
      final crystal = Crystal(
        color: CrystalColor.blue,
        position: Vector2(100, 100),
        row: 1,
        col: 2,
      );
      
      final dragStartEvent = DragStartEvent(
        0, // pointer id
        DragStartInfo.fromDetails(
          gameField,
          PointerDownEvent(
            position: const Offset(100, 100),
          ),
        ),
      );
      
      crystal.onDragStart(dragStartEvent);
      expect(crystal.startPosition, equals(Vector2(100, 100)));
    });
    
    test('Crystal should restrict horizontal movement during drag', () {
      final crystal = Crystal(
        color: CrystalColor.blue,
        position: Vector2(100, 100),
        row: 1,
        col: 2,
      );
      
      // Start the drag
      final dragStartEvent = DragStartEvent(
        0, // pointer id
        DragStartInfo.fromDetails(
          gameField,
          PointerDownEvent(
            position: const Offset(100, 100),
          ),
        ),
      );
      crystal.onDragStart(dragStartEvent);
      
      // Perform a horizontal drag
      final dragUpdateEvent = DragUpdateEvent(
        0, // pointer id
        DragUpdateInfo.fromDetails(
          gameField,
          PointerMoveEvent(
            position: const Offset(120, 100),
            delta: const Offset(20, 0),
          ),
        ),
      );
      crystal.onDragUpdate(dragUpdateEvent);
      
      // Crystal should move horizontally
      expect(crystal.position.x, greaterThan(100));
      expect(crystal.position.y, equals(100)); // y should not change
    });
    
    test('Crystal should restrict vertical movement during drag', () {
      final crystal = Crystal(
        color: CrystalColor.blue,
        position: Vector2(100, 100),
        row: 1,
        col: 2,
      );
      
      // Start the drag
      final dragStartEvent = DragStartEvent(
        0, // pointer id
        DragStartInfo.fromDetails(
          gameField,
          PointerDownEvent(
            position: const Offset(100, 100),
          ),
        ),
      );
      crystal.onDragStart(dragStartEvent);
      
      // Perform a vertical drag
      final dragUpdateEvent = DragUpdateEvent(
        0, // pointer id
        DragUpdateInfo.fromDetails(
          gameField,
          PointerMoveEvent(
            position: const Offset(100, 120),
            delta: const Offset(0, 20),
          ),
        ),
      );
      crystal.onDragUpdate(dragUpdateEvent);
      
      // Crystal should move vertically
      expect(crystal.position.x, equals(100)); // x should not change
      expect(crystal.position.y, greaterThan(100));
    });
  });
}
