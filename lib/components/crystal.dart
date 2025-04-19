import 'dart:async';
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
    if (parent == null || parent is! GameField) {
      return;
    }
    final gameField = parent as GameField;
    if (gameField.isAnimating) {
      return;
    }
    _isDragging = true;
    _startPosition = position.clone();
    gameField.updateState('Crystal is being dragged');
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (parent == null || parent is! GameField) {
      return;
    }
    final gameField = parent as GameField;
    if (gameField.isAnimating) {
      return;
    }
    final delta = event.localDelta;
    final maxDistance = GameSettings.crystalSize / 2;
    
    // Calculate the current distance from start position
    final currentDistance = position.distanceTo(_startPosition);
    
    // If we haven't moved much yet, allow movement in any direction
    if (currentDistance < maxDistance * 0.2) {
      position += delta;
      return;
    }
    
    // Once we've moved a bit, determine the dominant direction and lock to it
    final xDiff = (position.x - _startPosition.x).abs();
    final yDiff = (position.y - _startPosition.y).abs();
    
    if (xDiff > yDiff) {
      // Horizontal movement only
      position.y = _startPosition.y;
      final newX = position.x + delta.x;
      final newDistance = (newX - _startPosition.x).abs();
      
      if (newDistance <= maxDistance) {
        position.x = newX;
      }
    } else {
      // Vertical movement only
      position.x = _startPosition.x;
      final newY = position.y + delta.y;
      final newDistance = (newY - _startPosition.y).abs();
      
      if (newDistance <= maxDistance) {
        position.y = newY;
      }
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (parent == null || parent is! GameField) {
      return;
    }
    final gameField = parent as GameField;
    if (gameField.isAnimating) {
      return;
    }
    _isDragging = false;
    
    // Find the nearest crystal to swap with
    Crystal? nearestCrystal = _findNearestCrystal();
    
    if (nearestCrystal != null && _canSwapWith(nearestCrystal)) {
      // Return to start position first
      position = _startPosition.clone();
      // Let the GameField handle the swap
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
    
    // Determine drag direction based on current position vs start position
    final xDiff = position.x - _startPosition.x;
    final yDiff = position.y - _startPosition.y;
    
    // Check if movement is predominantly horizontal or vertical
    if (xDiff.abs() > yDiff.abs()) {
      // Horizontal movement
      final horizontalDirection = xDiff > 0 ? 1 : -1; // 1 for right, -1 for left
      // Check the crystal in that direction
      return gameField.getCrystalAt(row, col + horizontalDirection);
    } else if (yDiff.abs() > 0) {
      // Vertical movement
      final verticalDirection = yDiff > 0 ? 1 : -1; // 1 for down, -1 for up
      // Check the crystal in that direction
      return gameField.getCrystalAt(row + verticalDirection, col);
    }
    
    // If no significant movement, return null
    return null;
  }

  bool _canSwapWith(Crystal other) {
    // Check if crystals are adjacent
    final rowDiff = (row - other.row).abs();
    final colDiff = (col - other.col).abs();
    if (!((rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1))) {
      return false;
    }

    // Check if swap would create a match
    final gameField = parent as GameField;
    return gameField.canSwapCrystals(this, other);
  }

  Future<void> swapWith(Crystal other) async {
    final tempPosition = position.clone();
    final targetPosition = other.position.clone();
    
    // Use helper method for animations
    _addMoveAnimation(targetPosition);
    other._addMoveAnimation(tempPosition);
    
    // Wait for the animation to complete
    await Future.delayed(Duration(milliseconds: (GameSettings.animationDuration * 1000).round()));
    
    // Update actual positions after animation completes
    position = targetPosition.clone();
    other.position = tempPosition.clone();
    
    // Update start positions to match new positions
    updateStartPosition();
    other.updateStartPosition();
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
  
  void _addMoveAnimation(Vector2 targetPosition, {double durationFactor = 1.0, Curve curve = Curves.easeInOut}) {
    add(
      MoveToEffect(
        targetPosition,
        EffectController(
          duration: GameSettings.animationDuration * durationFactor,
          curve: curve,
        ),
      ),
    );
  }
  
  void updateStartPosition() {
    _startPosition = position.clone();
  }
}                                    