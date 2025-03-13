import 'package:conway/cell_position.dart';
import 'package:conway/conway.dart';
import 'package:conway/conway_painter.dart';
import 'package:flutter/material.dart';

typedef CellPositionCallback = void Function(CellPosition position);

class ConwayGame extends StatelessWidget {
  const ConwayGame({required this.world, required this.onToggle, super.key});

  final WorldState world;
  final CellPositionCallback onToggle;

  GestureTapUpCallback? _createOnTapUp(
    ConwayPainter painter,
    BuildContext context,
  ) {
    if (onToggle == null) {
      return null;
    }
    return (TapUpDetails details) {
      CellPosition position = painter.findHitCell(
        details.localPosition,
        context.size!,
      );
      // It's possible painter might want borders
      // or other non-cell positions in the future
      // but for now we assume all pixels inside painter
      // represent valid positions.
      assert(position != null);
      onToggle(position);
    };
  }

  @override
  Widget build(BuildContext context) {
    final painter = ConwayPainter(world: world);
    return GestureDetector(
      onTapUp: _createOnTapUp(painter, context),
      child: CustomPaint(
        painter: painter,
      ),
    );
  }
}
