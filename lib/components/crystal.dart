import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import '../game/field/game_field.dart';
import '../core/game_settings.dart';

enum CrystalColor {
  red,
  green,
  blue,
  yellow,
  purple,
}

class Crystal extends PositionComponent with DragCallbacks {
  final CrystalColor color;
  int row;
  int col;
  bool isSelected = false;
  bool isMatched = false;
  Vector2 _startPosition = Vector2.zero();
  bool _isDragging = false;

  Crystal({
    required this.color,
    required Vector2 position,
    required this.row,
    required this.col,
  }) : super(
          position: position,
          size: Vector2.all(GameSettings.crystalSize),
          anchor: Anchor.center,
        ) {
    _startPosition = position.clone();
  }

  Vector2 get startPosition => _startPosition;

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = _getColor()
      ..style = PaintingStyle.fill;

    if (_isDragging) {
      paint.color = paint.color.withOpacity(GameSettings.crystalSelectedOpacity);
    }

    if (isMatched) {
      final glowPaint = Paint()
        ..color = Colors.white.withOpacity(GameSettings.crystalMatchedGlowOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, GameSettings.crystalGlowRadius);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          size.toRect(),
          Radius.circular(GameSettings.crystalCornerRadius),
        ),
        glowPaint,
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        size.toRect(),
        Radius.circular(GameSettings.crystalCornerRadius),
      ),
      paint,
    );
  }

  Color _getColor() {
    switch (color) {
      case CrystalColor.red:
        return Colors.red;
      case CrystalColor.green:
        return Colors.green;
      case CrystalColor.blue:
        return Colors.blue;
      case CrystalColor.yellow:
        return Colors.yellow;
      case CrystalColor.purple:
        return Colors.purple;
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    _isDragging = true;
    _startPosition = position.clone();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    final delta = event.localDelta;
    final maxDistance = GameSettings.crystalSize / 2;
    
    // Calculate the current distance from start position
    final currentDistance = position.distanceTo(_startPosition);
    
    // Determine the dominant direction of movement
    if (delta.x.abs() > delta.y.abs()) {
      // Horizontal movement
      final newX = position.x + delta.x;
      final newDistance = Vector2(newX, position.y).distanceTo(_startPosition);
      
      if (newDistance <= maxDistance) {
        position = Vector2(newX, position.y);
      }
    } else {
      // Vertical movement
      final newY = position.y + delta.y;
      final newDistance = Vector2(position.x, newY).distanceTo(_startPosition);
      
      if (newDistance <= maxDistance) {
        position = Vector2(position.x, newY);
      }
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    _isDragging = false;
    final gameField = parent as GameField;
    
    // Find the nearest crystal to swap with
    Crystal? nearestCrystal = _findNearestCrystal();
    
    if (nearestCrystal != null && _canSwapWith(nearestCrystal)) {
      // Swap positions in the grid
      final tempRow = row;
      final tempCol = col;
      row = nearestCrystal.row;
      col = nearestCrystal.col;
      nearestCrystal.row = tempRow;
      nearestCrystal.col = tempCol;
      
      gameField.onCrystalSwap(this, nearestCrystal);
    } else {
      // Return to original position with smooth animation
      add(
        MoveToEffect(
          _startPosition,
          EffectController(
            duration: GameSettings.animationDuration * 0.3,
            curve: Curves.easeOut,
          ),
        ),
      );
    }
  }

  Crystal? _findNearestCrystal() {
    final gameField = parent as GameField;
    Crystal? nearest;
    double minDistance = double.infinity;

    // Check adjacent cells
    final adjacentPositions = [
      [row - 1, col], // up
      [row + 1, col], // down
      [row, col - 1], // left
      [row, col + 1], // right
    ];

    for (final pos in adjacentPositions) {
      final crystal = gameField.getCrystalAt(pos[0], pos[1]);
      if (crystal != null) {
        final distance = position.distanceTo(crystal.position);
        if (distance < minDistance) {
          minDistance = distance;
          nearest = crystal;
        }
      }
    }

    return nearest;
  }

  bool _canSwapWith(Crystal other) {
    // Check if crystals are adjacent
    final rowDiff = (row - other.row).abs();
    final colDiff = (col - other.col).abs();
    return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1);
  }

  Future<void> swapWith(Crystal other) async {
    final tempPosition = position.clone();
    final targetPosition = other.position.clone();
    
    // Animate both crystals
    add(
      MoveToEffect(
        targetPosition,
        EffectController(
          duration: GameSettings.animationDuration,
          curve: Curves.easeInOut,
        ),
      ),
    );
    
    other.add(
      MoveToEffect(
        tempPosition,
        EffectController(
          duration: GameSettings.animationDuration,
          curve: Curves.easeInOut,
        ),
      ),
    );
    
    // Wait for animation to complete
    await Future.delayed(Duration(milliseconds: (GameSettings.animationDuration * 1000).round()));
  }

  Future<void> matchEffect() async {
    isMatched = true;
    add(
      ScaleEffect.by(
        Vector2.all(GameSettings.matchEffectScale),
        EffectController(
          duration: GameSettings.matchEffectDuration,
          reverseDuration: GameSettings.matchEffectDuration,
        ),
      ),
    );
    await Future.delayed(Duration(milliseconds: (GameSettings.matchEffectDuration * 1000).round()));
    isMatched = false;
  }
} 