import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'dart:math';
import '../../components/crystal.dart';

class GameField extends PositionComponent {
  static const int gridSize = 10;
  static const double spacing = 5.0;
  final List<List<Crystal?>> _grid = List.generate(gridSize, (_) => List.filled(gridSize, null));
  Crystal? _selectedCrystal;

  GameField() : super(anchor: Anchor.center) {
    final totalWidth = gridSize * (Crystal.crystalSize + spacing) - spacing;
    final totalHeight = gridSize * (Crystal.crystalSize + spacing) - spacing;
    size = Vector2(totalWidth, totalHeight);
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    position = gameSize / 2;
  }

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

  Future<void> _swapCrystals(Crystal crystal1, Crystal crystal2) async {
    // Swap positions in the grid
    final tempRow = crystal1.row;
    final tempCol = crystal1.col;
    crystal1.row = crystal2.row;
    crystal1.col = crystal2.col;
    crystal2.row = tempRow;
    crystal2.col = tempCol;
    _grid[crystal1.row][crystal1.col] = crystal1;
    _grid[crystal2.row][crystal2.col] = crystal2;

    // Animate the swap
    await crystal1.swapWith(crystal2);

    // Check if the swap creates any matches
    final matches = _findMatches();
    if (matches.isEmpty) {
      // If no matches, swap back
      final tempRow2 = crystal1.row;
      final tempCol2 = crystal1.col;
      crystal1.row = crystal2.row;
      crystal1.col = crystal2.col;
      crystal2.row = tempRow2;
      crystal2.col = tempCol2;
      _grid[crystal1.row][crystal1.col] = crystal1;
      _grid[crystal2.row][crystal2.col] = crystal2;
      
      // Animate the swap back
      await crystal1.swapWith(crystal2);
    } else {
      // Process matches if they exist
      await _removeMatches(matches);
      await _refillGrid();
    }

    // Reset selection
    _selectedCrystal = null;
  }

  Set<Crystal> _findMatches() {
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

    return matches;
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
  }

  Future<void> _refillGrid() async {
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

    // Wait for animations to complete
    await Future.delayed(const Duration(milliseconds: 300));

    // Check for new matches after refill
    final newMatches = _findMatches();
    if (newMatches.isNotEmpty) {
      await _removeMatches(newMatches);
      await _refillGrid();
    }
  }
} 