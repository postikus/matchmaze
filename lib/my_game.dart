import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'components/game_field.dart';

class MyGame extends FlameGame {
  late final GameField gameField;

  @override
  Color backgroundColor() => const Color(0xFF2A2A2A);

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    
    gameField = GameField();
    add(gameField);
  }
} 