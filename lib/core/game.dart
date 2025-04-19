import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/field/game_field.dart';

class MatchMazeGame extends FlameGame {
  late final GameField gameField;

  @override
  Color backgroundColor() => const Color(0xFF2A2A2A);

  @override
  Future<void> onLoad() async {
    debugPrint('Game onLoad started');
    
    // Add the game field
    gameField = GameField();
    add(gameField);
    
    debugPrint('Game onLoad completed');
  }
} 