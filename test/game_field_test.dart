import 'package:flutter_test/flutter_test.dart';
import 'package:matchmaze/components/crystal.dart';
import 'package:matchmaze/game/field/game_field.dart';
import 'package:matchmaze/game/level_manager.dart';
import 'package:matchmaze/core/game_settings.dart';
import 'package:matchmaze/core/game.dart';
import 'package:flame/components.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late MatchMazeGame game;
  late GameField gameField;
  late LevelManager levelManager;
  
  setUp(() {
    game = MatchMazeGame();
    gameField = GameField();
    game.add(gameField);
    levelManager = LevelManager();
  });
  
  group('Game Field and Match Detection', () {
    test('Should detect horizontal matches', () {
      // Create a controlled grid with NO matches initially
      final grid = List.generate(
        GameSettings.gridSize,
        (row) => List.generate(
          GameSettings.gridSize,
          (col) => Crystal(
            // Alternate colors to avoid accidental matches
            color: CrystalColor.values[(row + col) % CrystalColor.values.length],
            position: Vector2(
              col * (GameSettings.crystalSize + GameSettings.gridSpacing),
              row * (GameSettings.crystalSize + GameSettings.gridSpacing),
            ),
            row: row,
            col: col,
          ),
        ),
      );
      
      // Create ONLY ONE horizontal match of red crystals in row 0, cols 0-2
      for (int col = 0; col < 3; col++) {
        // Replace with new crystal instance with red color
        grid[0][col] = Crystal(
          color: CrystalColor.red,
          position: grid[0][col].position.clone(),
          row: 0,
          col: col,
        );
      }
      
      // Set the grid in level manager
      for (int row = 0; row < GameSettings.gridSize; row++) {
        for (int col = 0; col < GameSettings.gridSize; col++) {
          levelManager.grid[row][col] = grid[row][col];
        }
      }
      
      // Find matches
      final matches = levelManager.findMatches();
      
      // Should find exactly 3 matching crystals
      expect(matches.length, equals(3));
      
      // All matches should be red and in row 0
      for (final crystal in matches) {
        expect(crystal.color, equals(CrystalColor.red));
        expect(crystal.row, equals(0));
        expect(crystal.col, lessThan(3));
      }
    });
    
    test('Should detect vertical matches', () {
      // Create a controlled grid with NO matches initially
      final grid = List.generate(
        GameSettings.gridSize,
        (row) => List.generate(
          GameSettings.gridSize,
          (col) => Crystal(
            // Alternate colors to avoid accidental matches
            color: CrystalColor.values[(row + col + 1) % CrystalColor.values.length],
            position: Vector2(
              col * (GameSettings.crystalSize + GameSettings.gridSpacing),
              row * (GameSettings.crystalSize + GameSettings.gridSpacing),
            ),
            row: row,
            col: col,
          ),
        ),
      );
      
      // Create ONLY ONE vertical match of blue crystals in column 0, rows 0-2
      for (int row = 0; row < 3; row++) {
        // Replace with new crystal instance with blue color
        grid[row][0] = Crystal(
          color: CrystalColor.blue,
          position: grid[row][0].position.clone(),
          row: row,
          col: 0,
        );
      }
      
      // Set the grid in level manager
      for (int row = 0; row < GameSettings.gridSize; row++) {
        for (int col = 0; col < GameSettings.gridSize; col++) {
          levelManager.grid[row][col] = grid[row][col];
        }
      }
      
      // Find matches
      final matches = levelManager.findMatches();
      
      // Should find exactly 3 matching crystals
      expect(matches.length, equals(3));
      
      // All matches should be blue and in column 0
      for (final crystal in matches) {
        expect(crystal.color, equals(CrystalColor.blue));
        expect(crystal.col, equals(0));
        expect(crystal.row, lessThan(3));
      }
    });
    
    test('Should handle invalid swaps correctly', () async {
      // Create two crystals that would not create a match when swapped
      final crystal1 = Crystal(
        color: CrystalColor.red,
        position: Vector2(100, 100),
        row: 1,
        col: 1,
      );
      
      final crystal2 = Crystal(
        color: CrystalColor.blue,
        position: Vector2(100 + GameSettings.crystalSize + GameSettings.gridSpacing, 100),
        row: 1,
        col: 2,
      );
      
      // Mock the grid with these crystals
      levelManager.grid[1][1] = crystal1;
      levelManager.grid[1][2] = crystal2;
      
      // Mock the gameField._levelManager
      gameField.add(crystal1);
      gameField.add(crystal2);
      
      // Add crystals to the game field
      gameField.add(crystal1);
      gameField.add(crystal2);
      
      // Store original positions
      final originalPos1 = crystal1.position.clone();
      final originalPos2 = crystal2.position.clone();
      
      // Test invalid swap directly
      gameField.onCrystalSwap(crystal1, crystal2);
      
      // Wait for animations to complete
      await Future.delayed(Duration(milliseconds: (GameSettings.animationDuration * 1000).round()));
      
      // After swap attempt, positions should return to original
      expect(crystal1.row, equals(1));
      expect(crystal1.col, equals(1));
      expect(crystal2.row, equals(1));
      expect(crystal2.col, equals(2));
      
      // Positions should be close to original (allowing for small floating point differences)
      expect((crystal1.position - originalPos1).length, lessThan(0.1));
      expect((crystal2.position - originalPos2).length, lessThan(0.1));
    });
  });
}
