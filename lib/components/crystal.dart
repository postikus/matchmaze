import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import '../game/field/game_field.dart';
import '../core/game_settings.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame/game.dart';

enum CrystalColor {
  red,
  green,
  blue,
  yellow,
  purple,
}

class Crystal extends PositionComponent with DragCallbacks {
  final CrystalColor color;
  final int row;
  final int col;
  bool isMatched = false;
  Vector2 _startPosition = Vector2.zero();
  bool _isDragging = false;
  static const double _dragThreshold = 50.0;

  Crystal({
    required this.color,
    required Vector2 position,
    required this.row,
    required this.col,
  }) {
    this.position = position;
    _startPosition = position;
    size = Vector2.all(GameSettings.crystalSize);
  }

  @override
  void render(Canvas canvas) {
    final paint = BasicPalette.white.paint();
    final borderPaint = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Add glow effect when dragging
    if (_isDragging) {
      final glowPaint = Paint()
        ..color = const Color(0x40FFFFFF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
      canvas.drawCircle(
        size / 2,
        GameSettings.crystalSize / 2 + 5.0,
        glowPaint,
      );
    }

    // Draw crystal body with slight gradient effect
    final gradient = RadialGradient(
      center: const Alignment(0.0, 0.0),
      radius: 0.5,
      colors: [
        _getColorForCrystal(),
        _getColorForCrystal().withValues(alpha: 255, red: 200, green: 200, blue: 200),
      ],
    );
    final gradientPaint = Paint()
      ..shader = gradient.createShader(Rect.fromCenter(
        center: size / 2,
        width: GameSettings.crystalSize,
        height: GameSettings.crystalSize,
      ));

    canvas.drawCircle(
      size / 2,
      GameSettings.crystalSize / 2,
      gradientPaint,
    );

    // Draw crystal border
    canvas.drawCircle(
      size / 2,
      GameSettings.crystalSize / 2,
      borderPaint,
    );
  }

  Color _getColorForCrystal() {
    switch (color) {
      case CrystalColor.red:
        return const Color(0xFFFF0000).withValues(alpha: 255, red: 255, green: 0, blue: 0);
      case CrystalColor.blue:
        return const Color(0xFF0000FF).withValues(alpha: 255, red: 0, green: 0, blue: 255);
      case CrystalColor.green:
        return const Color(0xFF00FF00).withValues(alpha: 255, red: 0, green: 255, blue: 0);
      case CrystalColor.yellow:
        return const Color(0xFFFFFF00).withValues(alpha: 255, red: 255, green: 255, blue: 0);
      case CrystalColor.purple:
        return const Color(0xFF800080).withValues(alpha: 255, red: 128, green: 0, blue: 128);
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _isDragging = true;
    _startPosition = position;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!_isDragging) return;

    position += event.delta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _isDragging = false;
    final gameField = parent as GameField;
    
    // Find the nearest crystal to swap with
    Crystal? nearestCrystal = _findNearestCrystal();
    
    if (nearestCrystal != null && _canSwapWith(nearestCrystal)) {
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
    final rowDiff = (row - other.row).abs();
    final colDiff = (col - other.col).abs();
    return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1);
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

  Vector2 get startPosition => _startPosition;
}                                    