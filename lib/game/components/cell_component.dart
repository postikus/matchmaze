import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../models/grid.dart';

class CellComponent extends PositionComponent {
  final Cell cell;
  final double cellSize;

  CellComponent({
    required this.cell,
    required this.cellSize,
  }) : super(size: Vector2.all(cellSize));

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = cell.color ?? Colors.grey[300]!
      ..style = PaintingStyle.fill;

    if (cell.isSelected) {
      paint.color = paint.color.withOpacity(0.7);
    }

    canvas.drawRect(
      Rect.fromLTWH(0, 0, cellSize, cellSize),
      paint,
    );

    // Draw cell border
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, cellSize, cellSize),
      borderPaint,
    );
  }
} 