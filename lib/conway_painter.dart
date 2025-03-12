import 'package:conway/conway.dart';
import 'package:flutter/material.dart';

class ConwayPainter extends CustomPainter {
  const ConwayPainter({required this.world});

  final WorldState world;

  @override
  void paint(Canvas canvas, Size size) {
    final xStep = size.width / world.width;
    final yStep = size.height / world.height;
    final paint = Paint()..color = Colors.black;
    for (var y = 0; y < world.height; ++y) {
      for (var x = 0; x < world.width; ++x) {
        if (world.getDimensions(x, y) == CellState.alive) {
          canvas.drawRect(
            Rect.fromLTWH(x * xStep, y * yStep, xStep, yStep),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(ConwayPainter oldDelegate) {
    return world != oldDelegate.world;
  }
}
