import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
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

  Crystal? getCrystalAt(int row, int col) {
    if (row >= 0 && row < GameSettings.gridSize && col >= 0 && col < GameSettings.gridSize) {
      return _levelManager.grid[row][col];
    }
    return null;
  }

  // Removed onCrystalTapped method as it's no longer needed with drag-and-drop functionality

  // Removed selection methods as they're no longer needed with drag-and-drop functionality

  // Removed _trySwapCrystals method as its functionality is covered by onCrystalSwap
  
  Future<void> onCrystalSwap(Crystal crystal1, Crystal crystal2) async {
    // Store original positions before updating grid
    final originalPos1 = crystal1.position.clone();
    final originalPos2 = crystal2.position.clone();
    
    // Store original grid positions
    final originalRow1 = crystal1.row;
    final originalCol1 = crystal1.col;
    final originalRow2 = crystal2.row;
    final originalCol2 = crystal2.col;
    
    // Update grid positions to check for matches
    _levelManager.updateGridPosition(crystal1, crystal2);
    
    // Check for matches before actually swapping
    final matches = _levelManager.findMatches();
    
    if (matches.isEmpty) {
      // If no matches, revert grid positions
      crystal1.row = originalRow1;
      crystal1.col = originalCol1;
      crystal2.row = originalRow2;
      crystal2.col = originalCol2;
      
      // Update the grid to match the reverted positions
      _levelManager.grid[originalRow1][originalCol1] = crystal1;
      _levelManager.grid[originalRow2][originalCol2] = crystal2;
      
      // Return both crystals to their original positions
      crystal1.add(_createMoveAnimation(originalPos1, durationFactor: 0.3, curve: Curves.easeOut));
      crystal2.add(_createMoveAnimation(originalPos2, durationFactor: 0.3, curve: Curves.easeOut));
      
      // Wait for animations to complete
      await Future.delayed(Duration(milliseconds: (GameSettings.animationDuration * 0.3 * 1000).round()));
      
      // Update actual positions after animations complete
      crystal1.position = originalPos1.clone();
      crystal2.position = originalPos2.clone();
      
      return;
    }
    
    // If matches found, proceed with the swap animation
    await crystal1.swapWith(crystal2);
    
    // Process matches and refill the grid
    await _processMatches(matches);
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
            crystal.add(_createMoveAnimation(targetPosition));
          } else {
            // Existing crystal - just update position
            crystal.position = targetPosition;
            crystal.updateStartPosition(); // Update start position as well
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
  
  MoveToEffect _createMoveAnimation(Vector2 targetPosition, {double durationFactor = 1.0, Curve curve = Curves.easeInOut}) {
    return MoveToEffect(
      targetPosition,
      EffectController(
        duration: GameSettings.animationDuration * durationFactor,
        curve: curve,
      ),
    );
  }

  bool canSwapCrystals(Crystal crystal1, Crystal crystal2) {
    // Store original positions
    final originalRow1 = crystal1.row;
    final originalCol1 = crystal1.col;
    final originalRow2 = crystal2.row;
    final originalCol2 = crystal2.col;
    
    // Temporarily swap positions in the grid
    _levelManager.updateGridPosition(crystal1, crystal2);
    
    // Check for matches after swap
    final matches = _levelManager.findMatches();
    
    // Restore original positions in the grid
    crystal1.row = originalRow1;
    crystal1.col = originalCol1;
    crystal2.row = originalRow2;
    crystal2.col = originalCol2;
    _levelManager.grid[originalRow1][originalCol1] = crystal1;
    _levelManager.grid[originalRow2][originalCol2] = crystal2;

    return matches.isNotEmpty;
  }

  Set<Crystal> findMatches() {
    return _levelManager.findMatches();
  }
}                      