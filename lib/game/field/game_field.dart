import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'dart:math';
import '../../components/crystal.dart';

class GameField extends PositionComponent {
  static const int gridSize = 10;
  static const double spacing = 5.0;
  static const animationDuration = 0.3;
  
  final List<List<Crystal?>> _grid = List.generate(gridSize, (_) => List.filled(gridSize, null));
  Crystal? _selectedCrystal;
  final _random = Random();

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

  Vector2 _getPositionForCell(int row, int col) {
    return Vector2(
      col * (Crystal.crystalSize + spacing),
      row * (Crystal.crystalSize + spacing),
    );
  }

  void _generateField() {
    final colors = CrystalColor.values;
    
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        final crystal = Crystal(
          color: colors[_random.nextInt(colors.length)],
          position: _getPositionForCell(row, col),
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
      _selectCrystal(crystal);
    } else if (_selectedCrystal == crystal) {
      _deselectCrystal();
    } else if (_areNeighbors(_selectedCrystal!, crystal)) {
      _trySwapCrystals(_selectedCrystal!, crystal);
    } else {
      _switchSelection(crystal);
    }
  }

  void _selectCrystal(Crystal crystal) {
    _selectedCrystal = crystal;
    crystal.isSelected = true;
  }

  void _deselectCrystal() {
    _selectedCrystal!.isSelected = false;
    _selectedCrystal = null;
  }

  void _switchSelection(Crystal crystal) {
    _selectedCrystal!.isSelected = false;
    crystal.isSelected = true;
    _selectedCrystal = crystal;
  }

  bool _areNeighbors(Crystal a, Crystal b) {
    final rowDiff = (a.row - b.row).abs();
    final colDiff = (a.col - b.col).abs();
    return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1);
  }

  void _updateGridPosition(Crystal crystal1, Crystal crystal2) {
    final tempRow = crystal1.row;
    final tempCol = crystal1.col;
    crystal1.row = crystal2.row;
    crystal1.col = crystal2.col;
    crystal2.row = tempRow;
    crystal2.col = tempCol;
    _grid[crystal1.row][crystal1.col] = crystal1;
    _grid[crystal2.row][crystal2.col] = crystal2;
  }

  Future<void> _trySwapCrystals(Crystal crystal1, Crystal crystal2) async {
    _updateGridPosition(crystal1, crystal2);
    await crystal1.swapWith(crystal2);

    final matches = _findMatches();
    if (matches.isEmpty) {
      _updateGridPosition(crystal1, crystal2); // Swap back
      await crystal1.swapWith(crystal2);
    } else {
      await _processMatches(matches);
    }

    _deselectCrystal();
  }

  Future<void> _processMatches(Set<Crystal> matches) async {
    await _removeMatches(matches);
    await _refillGrid();
  }

  Set<Crystal> _findMatches() {
    final matches = <Crystal>{};
    matches.addAll(_findHorizontalMatches());
    matches.addAll(_findVerticalMatches());
    return matches;
  }

  Set<Crystal> _findHorizontalMatches() {
    final matches = <Crystal>{};
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize - 2; col++) {
        final crystals = [_grid[row][col], _grid[row][col + 1], _grid[row][col + 2]];
        if (_isValidMatch(crystals)) {
          matches.addAll(crystals.cast<Crystal>());
        }
      }
    }
    return matches;
  }

  Set<Crystal> _findVerticalMatches() {
    final matches = <Crystal>{};
    for (int row = 0; row < gridSize - 2; row++) {
      for (int col = 0; col < gridSize; col++) {
        final crystals = [_grid[row][col], _grid[row + 1][col], _grid[row + 2][col]];
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

  Future<void> _removeMatches(Set<Crystal> matches) async {
    await Future.wait(matches.map((crystal) => crystal.matchEffect()));
    await Future.delayed(const Duration(milliseconds: 300));

    for (final crystal in matches) {
      _grid[crystal.row][crystal.col] = null;
      crystal.removeFromParent();
    }
  }

  Future<void> _refillGrid() async {
    await _moveCrystalsDown();
    await _fillEmptySpaces();
    await Future.delayed(const Duration(milliseconds: 300));

    final newMatches = _findMatches();
    if (newMatches.isNotEmpty) {
      await _processMatches(newMatches);
    }
  }

  Future<void> _moveCrystalsDown() async {
    for (int col = 0; col < gridSize; col++) {
      int emptyRow = gridSize - 1;
      while (emptyRow >= 0) {
        if (_grid[emptyRow][col] == null) {
          int sourceRow = emptyRow - 1;
          while (sourceRow >= 0 && _grid[sourceRow][col] == null) {
            sourceRow--;
          }
          
          if (sourceRow >= 0) {
            final crystal = _grid[sourceRow][col]!;
            _grid[emptyRow][col] = crystal;
            _grid[sourceRow][col] = null;
            crystal.row = emptyRow;
            crystal.add(
              MoveToEffect(
                _getPositionForCell(emptyRow, col),
                EffectController(duration: animationDuration),
              ),
            );
          }
        }
        emptyRow--;
      }
    }
  }

  Future<void> _fillEmptySpaces() async {
    final colors = CrystalColor.values;

    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (_grid[row][col] == null) {
          final crystal = Crystal(
            color: colors[_random.nextInt(colors.length)],
            position: Vector2(
              col * (Crystal.crystalSize + spacing),
              -Crystal.crystalSize,
            ),
            row: row,
            col: col,
          );
          _grid[row][col] = crystal;
          add(crystal);

          crystal.add(
            MoveToEffect(
              _getPositionForCell(row, col),
              EffectController(duration: animationDuration),
            ),
          );
        }
      }
    }
  }
} 