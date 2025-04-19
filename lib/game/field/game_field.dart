import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import '../level_manager.dart';
import '../../components/crystal.dart';
import '../../core/game_settings.dart';

class GameField extends PositionComponent {
  final _levelManager = LevelManager();
  Crystal? _selectedCrystal;

  GameField() : super(anchor: Anchor.center) {
    final totalWidth = GameSettings.gridSize * (GameSettings.crystalSize + GameSettings.gridSpacing) - GameSettings.gridSpacing;
    final totalHeight = GameSettings.gridSize * (GameSettings.crystalSize + GameSettings.gridSpacing) - GameSettings.gridSpacing;
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
      col * (GameSettings.crystalSize + GameSettings.gridSpacing),
      row * (GameSettings.crystalSize + GameSettings.gridSpacing),
    );
  }

  void _generateField() {
    _levelManager.generateField();
    for (int row = 0; row < GameSettings.gridSize; row++) {
      for (int col = 0; col < GameSettings.gridSize; col++) {
        final crystal = _levelManager.grid[row][col];
        if (crystal != null) {
          crystal.position = _getPositionForCell(row, col);
          add(crystal);
        }
      }
    }
  }

  void onCrystalTapped(Crystal crystal) {
    if (_selectedCrystal == null) {
      _selectCrystal(crystal);
    } else if (_selectedCrystal == crystal) {
      _deselectCrystal();
    } else if (_levelManager.areNeighbors(_selectedCrystal!, crystal)) {
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

  Future<void> _trySwapCrystals(Crystal crystal1, Crystal crystal2) async {
    _levelManager.updateGridPosition(crystal1, crystal2);
    await crystal1.swapWith(crystal2);

    final matches = _levelManager.findMatches();
    if (matches.isEmpty) {
      _levelManager.updateGridPosition(crystal1, crystal2); // Swap back
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

  Future<void> _removeMatches(Set<Crystal> matches) async {
    await Future.wait(matches.map((crystal) => crystal.matchEffect()));
    await Future.delayed(Duration(milliseconds: GameSettings.matchEffectDelay));

    for (final crystal in matches) {
      crystal.removeFromParent();
    }
    _levelManager.removeMatches(matches);
  }

  Future<void> _refillGrid() async {
    _levelManager.moveCrystalsDown();
    _levelManager.fillEmptySpaces();
    
    // Update positions of all crystals after moving down
    for (int row = 0; row < GameSettings.gridSize; row++) {
      for (int col = 0; col < GameSettings.gridSize; col++) {
        final crystal = _levelManager.grid[row][col];
        if (crystal != null) {
          final targetPosition = _getPositionForCell(row, col);
          if (!children.contains(crystal)) {
            // New crystal - add with animation
            crystal.position = Vector2(targetPosition.x, -GameSettings.crystalSize);
            add(crystal);
            crystal.add(
              MoveToEffect(
                targetPosition,
                EffectController(duration: GameSettings.animationDuration),
              ),
            );
          } else {
            // Existing crystal - just update position
            crystal.position = targetPosition;
          }
        }
      }
    }
    
    await Future.delayed(Duration(milliseconds: GameSettings.matchEffectDelay));

    final newMatches = _levelManager.findMatches();
    if (newMatches.isNotEmpty) {
      await _processMatches(newMatches);
    }
  }
} 