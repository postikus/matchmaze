import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import '../game/field/game_field.dart';

enum CrystalColor {
  red,
  green,
  blue,
  yellow,
  purple,
}

class Crystal extends PositionComponent with TapCallbacks {
  final CrystalColor color;
  static const double crystalSize = 50.0;
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
          size: Vector2.all(crystalSize),
        );

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = _getColor()
      ..style = PaintingStyle.fill;

    // Draw glow effect for matched crystals
    if (isMatched) {
      final glowPaint = Paint()
        ..color = _getColor().withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-5, -5, crystalSize + 10, crystalSize + 10),
          const Radius.circular(13),
        ),
        glowPaint,
      );
    }

    // Draw selection indicator
    if (isSelected) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-2, -2, crystalSize + 4, crystalSize + 4),
          const Radius.circular(10),
        ),
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Draw crystal with rounded corners
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, crystalSize, crystalSize),
        const Radius.circular(8),
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
  bool onTapDown(TapDownEvent event) {
    final parent = this.parent;
    if (parent is GameField) {
      parent.onCrystalTapped(this);
    }
    return true;
  }

  Future<void> swapWith(Crystal other) async {
    final myPosition = position.clone();
    final otherPosition = other.position.clone();

    // Animate the swap
    add(
      MoveToEffect(
        otherPosition,
        EffectController(duration: 0.3),
      ),
    );
    other.add(
      MoveToEffect(
        myPosition,
        EffectController(duration: 0.3),
      ),
    );

    // Wait for the animation to complete
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> matchEffect() async {
    isMatched = true;
    
    // Add scale and fade effect
    add(
      SequenceEffect(
        [
          ScaleEffect.by(
            Vector2.all(1.2),
            EffectController(duration: 0.2),
          ),
          ScaleEffect.by(
            Vector2.all(0.8),
            EffectController(duration: 0.2),
          ),
        ],
      ),
    );

    // Add particle effect
    final particleSystem = ParticleSystemComponent(
      particle: Particle.generate(
        count: 10,
        lifespan: 0.5,
        generator: (i) {
          final color = _getColor();
          return AcceleratedParticle(
            position: Vector2(crystalSize / 2, crystalSize / 2),
            speed: Vector2.random() * 100,
            acceleration: Vector2(0, 100),
            child: CircleParticle(
              paint: Paint()..color = color,
              radius: 4,
            ),
          );
        },
      ),
    );
    add(particleSystem);
  }
} 