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

class Crystal extends PositionComponent with TapCallbacks {
  final CrystalColor color;
  int row;
  int col;
  bool isSelected = false;
  bool isMatched = false;

  Crystal({
    required this.color,
    required Vector2 position,
    required this.row,
    required this.col,
  }) : super(
          position: position,
          size: Vector2.all(GameSettings.crystalSize),
          anchor: Anchor.center,
        );

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = _getColor()
      ..style = PaintingStyle.fill;

    if (isSelected) {
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
  void onTapDown(TapDownEvent event) {
    final gameField = parent as GameField;
    gameField.onCrystalTapped(this);
  }

  Future<void> swapWith(Crystal other) async {
    final tempPosition = position.clone();
    position = other.position.clone();
    other.position = tempPosition;
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