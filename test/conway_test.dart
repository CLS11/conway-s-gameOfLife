import 'package:conway/conway.dart';
import 'package:test/test.dart';

void main() {
  test('World test', () {
    final world = WorldState(10, 10);
    expect(world.getDimensions(1, 2), CellState.dead);
    world.setDimensions(1, 2, CellState.alive);
    expect(world.getDimensions(1, 2), CellState.alive);
    //OUT OF BOUNDS 
    expect(world.getDimensions(-1, -1), CellState.dead);
    expect(world.getDimensions(11, 12), CellState.dead);
  });
}
