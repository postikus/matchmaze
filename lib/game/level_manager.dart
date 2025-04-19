import 'package:flame/components.dart';
import 'dart:math';
import '../components/crystal.dart';
import '../core/game_settings.dart';

class LevelManager {
  final List<List<Crystal?>> grid = List.generate(GameSettings.gridSize, (_) => List.filled(GameSettings.gridSize, null));
  final _random = Random();

  void generateField() {
    final colors = CrystalColor.values;
    
    for (int row = 0; row < GameSettings.gridSize; row++) {
      for (int col = 0; col < GameSettings.gridSize; col++) {
        final crystal = Crystal(
          color: colors[_random.nextInt(colors.length)],
          position: _getPositionForCell(row, col),
          row: row,
          col: col,
        );
        grid[row][col] = crystal;
      }
    }
  }

  Vector2 _getPositionForCell(int row, int col) {
    return Vector2(
      col * (GameSettings.crystalSize + GameSettings.gridSpacing),
      row * (GameSettings.crystalSize + GameSettings.gridSpacing),
    );
  }

  Set<Crystal> findMatches() {
    final matches = <Crystal>{};
    matches.addAll(_findHorizontalMatches());
    matches.addAll(_findVerticalMatches());
    return matches;
  }

  Set<Crystal> _findHorizontalMatches() {
    final matches = <Crystal>{};
    for (int row = 0; row < GameSettings.gridSize; row++) {
      for (int col = 0; col < GameSettings.gridSize - 2; col++) {
        final crystals = [grid[row][col], grid[row][col + 1], grid[row][col + 2]];
        if (_isValidMatch(crystals)) {
          matches.addAll(crystals.cast<Crystal>());
        }
      }
    }
    return matches;
  }

  Set<Crystal> _findVerticalMatches() {
    final matches = <Crystal>{};
    for (int row = 0; row < GameSettings.gridSize - 2; row++) {
      for (int col = 0; col < GameSettings.gridSize; col++) {
        final crystals = [grid[row][col], grid[row + 1][col], grid[row + 2][col]];
        if (_isValidMatch(crystals)) {
          matches.addAll(crystals.cast<Crystal>());
        }
      }
    }
    return matches;
  }

  bool _isValidMatch(List<Crystal?> crystals) {
    return crystals.every((c) => c != null) &&
           crystals.every((c) => c!.color == crystals[0]!.color);
  }

  void removeMatches(Set<Crystal> matches) {
    for (final crystal in matches) {
      grid[crystal.row][crystal.col] = null;
    }
  }

  void moveCrystalsDown() {
    for (int col = 0; col < GameSettings.gridSize; col++) {
      int emptyRow = GameSettings.gridSize - 1;
      while (emptyRow >= 0) {
        if (grid[emptyRow][col] == null) {
          int sourceRow = emptyRow - 1;
          while (sourceRow >= 0 && grid[sourceRow][col] == null) {
            sourceRow--;
          }
          
          if (sourceRow >= 0) {
            final crystal = grid[sourceRow][col]!;
            grid[emptyRow][col] = crystal;
            grid[sourceRow][col] = null;
            crystal.row = emptyRow;
          }
        }
        emptyRow--;
      }
    }
  }

  void fillEmptySpaces() {
    final colors = CrystalColor.values;

    for (int row = 0; row < GameSettings.gridSize; row++) {
      for (int col = 0; col < GameSettings.gridSize; col++) {
        if (grid[row][col] == null) {
          final crystal = Crystal(
            color: colors[_random.nextInt(colors.length)],
            position: Vector2(
              col * (GameSettings.crystalSize + GameSettings.gridSpacing),
              -GameSettings.crystalSize,
            ),
            row: row,
            col: col,
          );
          grid[row][col] = crystal;
        }
      }
    }
  }

  void updateGridPosition(Crystal crystal1, Crystal crystal2) {
    final tempRow = crystal1.row;
    final tempCol = crystal1.col;
    crystal1.row = crystal2.row;
    crystal1.col = crystal2.col;
    crystal2.row = tempRow;
    crystal2.col = tempCol;
    grid[crystal1.row][crystal1.col] = crystal1;
    grid[crystal2.row][crystal2.col] = crystal2;
  }

  // Removed areNeighbors method as it duplicates Crystal._canSwapWith functionality
}  