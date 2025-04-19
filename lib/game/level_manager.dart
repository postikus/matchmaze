import 'package:flame/components.dart';
import 'dart:math';
import '../components/crystal.dart';
import '../core/game_settings.dart';

class LevelManager {
  static const int gridSize = 8;
  static const double spacing = 5.0;

  List<List<Crystal?>> grid = List.generate(gridSize, (_) => List.filled(gridSize, null));
  final _random = Random();

  void generateField() {
    bool validField = false;
    int attempts = 0;
    const maxAttempts = 100;

    while (!validField && attempts < maxAttempts) {
      // Generate a new field
      for (int i = 0; i < gridSize; i++) {
        for (int j = 0; j < gridSize; j++) {
          CrystalColor color;
          bool validColor = false;
          int colorAttempts = 0;
          const maxColorAttempts = 10;

          // Try to find a color that doesn't create immediate matches
          while (!validColor && colorAttempts < maxColorAttempts) {
            color = CrystalColor.values[Random().nextInt(CrystalColor.values.length)];
            grid[i][j] = Crystal(
              color: color,
              position: _getPositionForCell(i, j),
              row: i,
              col: j,
            );

            // Check if this color creates a match
            if (!_createsMatch(i, j)) {
              validColor = true;
            } else {
              colorAttempts++;
            }
          }

          // If we couldn't find a valid color, start over
          if (!validColor) {
            break;
          }
        }
      }

      // Check if there's at least one possible match-3 move
      if (_hasPossibleMatch()) {
        validField = true;
      } else {
        attempts++;
      }
    }

    if (!validField) {
      // If we couldn't generate a valid field after max attempts,
      // generate a simple field with guaranteed match-3 possibility
      _generateGuaranteedField();
    }
  }

  bool _createsMatch(int row, int col) {
    if (row < 2 && col < 2) return false; // Can't have matches in first 2 rows/cols

    Crystal? current = grid[row][col];
    if (current == null) return false;

    // Check horizontal matches
    if (col >= 2) {
      if (grid[row][col - 1]?.color == current.color &&
          grid[row][col - 2]?.color == current.color) {
        return true;
      }
    }

    // Check vertical matches
    if (row >= 2) {
      if (grid[row - 1][col]?.color == current.color &&
          grid[row - 2][col]?.color == current.color) {
        return true;
      }
    }

    // Check square matches (2x2)
    if (row >= 1 && col >= 1) {
      if (grid[row - 1][col]?.color == current.color &&
          grid[row][col - 1]?.color == current.color &&
          grid[row - 1][col - 1]?.color == current.color) {
        return true;
      }
    }

    return false;
  }

  bool _hasPossibleMatch() {
    // Check all possible swaps
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        // Try swapping with right neighbor
        if (j < gridSize - 1) {
          _swapCrystals(i, j, i, j + 1);
          if (findMatches().isNotEmpty) {
            _swapCrystals(i, j, i, j + 1); // Swap back
            return true;
          }
          _swapCrystals(i, j, i, j + 1); // Swap back
        }

        // Try swapping with bottom neighbor
        if (i < gridSize - 1) {
          _swapCrystals(i, j, i + 1, j);
          if (findMatches().isNotEmpty) {
            _swapCrystals(i, j, i + 1, j); // Swap back
            return true;
          }
          _swapCrystals(i, j, i + 1, j); // Swap back
        }
      }
    }
    return false;
  }

  void _generateGuaranteedField() {
    // Clear the grid
    grid = List.generate(gridSize, (_) => List.filled(gridSize, null));

    // Fill with alternating colors to ensure no initial matches
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        CrystalColor color = (i + j) % 2 == 0 ? CrystalColor.red : CrystalColor.blue;
        grid[i][j] = Crystal(
          color: color,
          position: _getPositionForCell(i, j),
          row: i,
          col: j,
        );
      }
    }

    // Create a guaranteed match-3 opportunity
    // Place three same-colored crystals in a row with one gap
    int row = Random().nextInt(gridSize - 2);
    int col = Random().nextInt(gridSize - 2);
    CrystalColor matchColor = CrystalColor.green;

    grid[row][col] = Crystal(
      color: matchColor,
      position: _getPositionForCell(row, col),
      row: row,
      col: col,
    );
    grid[row][col + 2] = Crystal(
      color: matchColor,
      position: _getPositionForCell(row, col + 2),
      row: row,
      col: col + 2,
    );
  }

  void _swapCrystals(int row1, int col1, int row2, int col2) {
    Crystal? temp = grid[row1][col1];
    grid[row1][col1] = grid[row2][col2];
    grid[row2][col2] = temp;

    if (grid[row1][col1] != null) {
      grid[row1][col1]!.position = _getPositionForCell(row1, col1);
    }
    if (grid[row2][col2] != null) {
      grid[row2][col2]!.position = _getPositionForCell(row2, col2);
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
    matches.addAll(_findSquareMatches());
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

  Set<Crystal> _findSquareMatches() {
    final matches = <Crystal>{};
    for (int row = 0; row < GameSettings.gridSize - 1; row++) {
      for (int col = 0; col < GameSettings.gridSize - 1; col++) {
        final crystals = [
          grid[row][col],
          grid[row][col + 1],
          grid[row + 1][col],
          grid[row + 1][col + 1]
        ];
        if (_isValidMatch(crystals)) {
          matches.addAll(crystals.cast<Crystal>());
        }
      }
    }
    return matches;
  }

  bool _isValidMatch(List<Crystal?> crystals) {
    if (crystals.isEmpty || crystals.any((c) => c == null)) return false;
    
    final firstColor = crystals.first!.color;
    return crystals.every((c) => c!.color == firstColor) && 
           (crystals.length == 3 || crystals.length == 4);
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