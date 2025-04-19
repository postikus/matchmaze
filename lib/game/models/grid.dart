import 'package:flutter/material.dart';

class Grid {
  final int width = 8;
  final int height = 8;
  late List<List<Cell>> cells;

  Grid() {
    cells = List.generate(
      height,
      (y) => List.generate(
        width,
        (x) => Cell(x: x, y: y),
      ),
    );
  }
}

class Cell {
  final int x;
  final int y;
  Color? color;
  bool isSelected = false;

  Cell({
    required this.x,
    required this.y,
  });
} 