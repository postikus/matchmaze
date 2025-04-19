import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'dart:math';
import 'crystal.dart';

class GameField extends Component {
  static const int gridSize = 10;
  static const double spacing = 5.0;
  final List<List<Crystal?>> _grid = List.generate(gridSize, (_) => List.filled(gridSize, null));
  Crystal? _selectedCrystal;

  @override
  Future<void> onLoad() async {
    _generateField();
  }

  void _generateField() {
    final random = Random();
    final colors = CrystalColor.values;

    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        final color = colors[random.nextInt(colors.length)];
        final crystal = Crystal(
          color: color,
          position: Vector2(
            col * (Crystal.crystalSize + spacing),
            row * (Crystal.crystalSize + spacing),
          ),
          row: row,
          col: col,
        );
        _grid[row][col] = crystal;
        add(crystal);
      }
    }
  }

  void onCrystalTapped(Crystal crystal) {
    if (_selectedCrystal == null) {
      // First crystal selected
      _selectedCrystal = crystal;
      crystal.isSelected = true;
    } else if (_selectedCrystal == crystal) {
      // Same crystal tapped - deselect
      _selectedCrystal!.isSelected = false;
      _selectedCrystal = null;
    } else if (_areNeighbors(_selectedCrystal!, crystal)) {
      // Attempt to swap
      _swapCrystals(_selectedCrystal!, crystal);
      _selectedCrystal!.isSelected = false;
      _selectedCrystal = null;
    } else {
      // Non-neighbor selected - switch selection
      _selectedCrystal!.isSelected = false;
      crystal.isSelected = true;
      _selectedCrystal = crystal;
    }
  }

  bool _areNeighbors(Crystal a, Crystal b) {
    final rowDiff = (a.row - b.row).abs();
    final colDiff = (a.col - b.col).abs();
    return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1);
  }

  Future<void> _swapCrystals(Crystal a, Crystal b) async {
    // Swap positions in grid
    _grid[a.row][a.col] = b;
    _grid[b.row][b.col] = a;

    // Swap row and col values
    final tempRow = a.row;
    final tempCol = a.col;
    a.row = b.row;
    a.col = b.col;
    b.row = tempRow;
    b.col = tempCol;

    // Animate the swap
    await a.swapWith(b);

    // Check for matches
    final hasMatches = _checkForMatches();
    if (!hasMatches) {
      // If no matches, swap back
      await _swapCrystals(a, b);
    }
  }

  bool _checkForMatches() {
    final matches = <Crystal>{};

    // Check horizontal matches
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize - 2; col++) {
        final crystal1 = _grid[row][col];
        final crystal2 = _grid[row][col + 1];
        final crystal3 = _grid[row][col + 2];
        
        if (crystal1 != null && crystal2 != null && crystal3 != null &&
            crystal1.color == crystal2.color && crystal2.color == crystal3.color) {
          matches.addAll([crystal1, crystal2, crystal3]);
        }
      }
    }

    // Check vertical matches
    for (int row = 0; row < gridSize - 2; row++) {
      for (int col = 0; col < gridSize; col++) {
        final crystal1 = _grid[row][col];
        final crystal2 = _grid[row + 1][col];
        final crystal3 = _grid[row + 2][col];
        
        if (crystal1 != null && crystal2 != null && crystal3 != null &&
            crystal1.color == crystal2.color && crystal2.color == crystal3.color) {
          matches.addAll([crystal1, crystal2, crystal3]);
        }
      }
    }

    if (matches.isNotEmpty) {
      _removeMatches(matches);
      return true;
    }

    return false;
  }

  Future<void> _removeMatches(Set<Crystal> matches) async {
    // Play match effects
    await Future.wait(matches.map((crystal) => crystal.matchEffect()));
    
    // Wait for effects to complete
    await Future.delayed(const Duration(milliseconds: 300));

    // Remove crystals
    for (final crystal in matches) {
      _grid[crystal.row][crystal.col] = null;
      crystal.removeFromParent();
    }

    // Refill the grid
    _refillGrid();
  }

  void _refillGrid() {
    final random = Random();
    final colors = CrystalColor.values;

    // Move existing crystals down
    for (int col = 0; col < gridSize; col++) {
      int emptyRow = gridSize - 1;
      while (emptyRow >= 0) {
        if (_grid[emptyRow][col] == null) {
          // Find the first non-null crystal above
          int sourceRow = emptyRow - 1;
          while (sourceRow >= 0 && _grid[sourceRow][col] == null) {
            sourceRow--;
          }
          
          if (sourceRow >= 0) {
            // Move crystal down
            final crystal = _grid[sourceRow][col]!;
            _grid[emptyRow][col] = crystal;
            _grid[sourceRow][col] = null;
            crystal.row = emptyRow;
            crystal.add(
              MoveToEffect(
                Vector2(
                  col * (Crystal.crystalSize + spacing),
                  emptyRow * (Crystal.crystalSize + spacing),
                ),
                EffectController(duration: 0.3),
              ),
            );
          }
        }
        emptyRow--;
      }
    }

    // Fill empty spaces with new crystals
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (_grid[row][col] == null) {
          final color = colors[random.nextInt(colors.length)];
          final crystal = Crystal(
            color: color,
            position: Vector2(
              col * (Crystal.crystalSize + spacing),
              -Crystal.crystalSize, // Start above the grid
            ),
            row: row,
            col: col,
          );
          _grid[row][col] = crystal;
          add(crystal);

          // Animate falling
          crystal.add(
            MoveToEffect(
              Vector2(
                col * (Crystal.crystalSize + spacing),
                row * (Crystal.crystalSize + spacing),
              ),
              EffectController(duration: 0.3),
            ),
          );
        }
      }
    }

    // Check for new matches after refill
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_checkForMatches()) {
        // Continue chain reaction
      }
    });
  }
} 