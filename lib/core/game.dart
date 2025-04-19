import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/field/game_field.dart';

class MatchMazeGame extends FlameGame {
  GameField gameField = GameField();

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    debugPrint('Game onLoad started');
    
    // Add the game field
    add(gameField);
    
    debugPrint('Game onLoad completed');
  }
} 