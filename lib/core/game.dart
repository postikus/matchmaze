import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/field/game_field.dart';

class MatchMazeGame extends FlameGame {
  late final GameField gameField;

  @override
  Color backgroundColor() => Colors.white;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position = Vector2.zero();
    
    gameField = GameField();
    add(gameField);
  }
} 