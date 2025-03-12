import 'package:conway/conway.dart';
import 'package:conway/conway_painter.dart';
import 'package:flutter/material.dart';

class ConwayGame extends StatelessWidget {
  const ConwayGame({required this.world, super.key});

  final WorldState world;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ConwayPainter(
        world: world,
      ),
    );
  }
}
