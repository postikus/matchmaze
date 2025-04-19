import 'package:flutter_test/flutter_test.dart';
import 'package:matchmaze/components/crystal.dart';
import 'package:matchmaze/game/field/game_field.dart';
import 'package:matchmaze/game/level_manager.dart';
import 'package:matchmaze/core/game_settings.dart';
import 'package:flame/components.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late GameField gameField;
  late LevelManager levelManager;
  
  setUp(() {
    gameField = GameField();
    levelManager = LevelManager();
  });
  
  group('Game Field and Match Detection', () {
    test('Should detect horizontal matches', () {
      // Create a controlled grid with a known horizontal match
      final grid = List.generate(
        GameSettings.gridSize,
        (row) => List.generate(
          GameSettings.gridSize,
          (col) => Crystal(
            color: CrystalColor.values[row % CrystalColor.values.length],
            position: Vector2(
              col * (GameSettings.crystalSize + GameSettings.gridSpacing),
              row * (GameSettings.crystalSize + GameSettings.gridSpacing),
            ),
            row: row,
            col: col,
          ),
        ),
      );
      
      // Create a horizontal match of red crystals in row 0
      for (int col = 0; col < 3; col++) {
        grid[0][col].color = CrystalColor.red;
      }
      
      // Set the grid in level manager
      levelManager.grid.clear();
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
      // Create a controlled grid with a known vertical match
      final grid = List.generate(
        GameSettings.gridSize,
        (row) => List.generate(
          GameSettings.gridSize,
          (col) => Crystal(
            color: CrystalColor.values[col % CrystalColor.values.length],
            position: Vector2(
              col * (GameSettings.crystalSize + GameSettings.gridSpacing),
              row * (GameSettings.crystalSize + GameSettings.gridSpacing),
            ),
            row: row,
            col: col,
          ),
        ),
      );
      
      // Create a vertical match of blue crystals in column 0
      for (int row = 0; row < 3; row++) {
        grid[row][0].color = CrystalColor.blue;
      }
      
      // Set the grid in level manager
      levelManager.grid.clear();
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
    
    test('Should handle invalid swaps correctly', () {
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
      
      // Temporarily replace gameField._levelManager with our mock
      final originalLevelManager = gameField._levelManager;
      try {
        // Use reflection or any other method to set _levelManager
        // For this test plan, assume we have access to set the property
        gameField._levelManager = levelManager;
        
        // Test invalid swap
        gameField.onCrystalSwap(crystal1, crystal2);
        
        // After swap attempt, positions should return to original
        expect(crystal1.row, equals(1));
        expect(crystal1.col, equals(1));
        expect(crystal2.row, equals(1));
        expect(crystal2.col, equals(2));
      } finally {
        // Restore original level manager
        gameField._levelManager = originalLevelManager;
      }
    });
  });
}
