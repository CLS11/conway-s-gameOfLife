import 'package:conway/conway.dart';
import 'package:test/test.dart';

void main() {
  test('World test', () {
    final world = WorldState(10, 10);
    expect(world.getDimensions(1, 2), CellState.dead);
    world.setDimensions(1, 2, CellState.alive);
    //SAVING THE STATE
    expect(world.getDimensions(1, 2), CellState.alive);
    expect(world.getDimensions(1, 2), CellState.alive);
    //CLEARING AFTER FETCHING
    world.setDimensions(1, 2, CellState.dead);
    expect(world.getDimensions(1, 2), CellState.dead);
    //OUT OF BOUNDS
    expect(world.getDimensions(-1, -1), CellState.dead);
    world.setDimensions(-1, -1, CellState.alive);
    expect(world.getDimensions(-1, -1), CellState.dead);

    expect(world.getDimensions(-3, 7), CellState.dead);
    world.setDimensions(-3, 7, CellState.alive);
    expect(world.getDimensions(-3, 7), CellState.dead);

    expect(world.getDimensions(3, -7), CellState.dead);
    world.setDimensions(3, -7, CellState.alive);
    expect(world.getDimensions(3, -7), CellState.dead);

    expect(world.getDimensions(11, 12), CellState.dead);
    world.setDimensions(11, 12, CellState.alive);
    expect(world.getDimensions(11, 12), CellState.dead);
  });

  test('All alive boundary test', () {
    //CHECKING FOR WIDTH/HEIGHT OFF-BY ONE
    //Creating new object
    final world = WorldState(10, 10)..setAll(CellState.alive);

    expect(world.getDimensions(9, 7), CellState.alive);
    expect(world.getDimensions(8, 7), CellState.alive);

    expect(world.getDimensions(10, 7), CellState.dead);
    expect(world.getDimensions(11, 7), CellState.dead);
    expect(world.getDimensions(7, 10), CellState.dead);
    expect(world.getDimensions(7, 11), CellState.dead);
  });

  test('Rectangular test', () {
    //CHECK THE SWAPPING OF WIDTH AND HEIGHT
    //Creating a new object
    final world = WorldState(5, 10);
    expect(world.getDimensions(6, 9), CellState.dead);
    expect(world.getDimensions(9, 6), CellState.dead);
  });

  test('Count alive test', () {
    final world = WorldState(4, 4);
    expect(world.countAlive(), 0);
    world.setDimensions(1, 1, CellState.alive);
    expect(world.countAlive(), 1);
  });

  test('forEach control', () {
    final world = WorldState(3, 7);
    expect(world.width, 3);
    expect(world.height, 7);
    expect(world.countAlive(), 0);
    world.setAll(CellState.alive);
    expect(world.countAlive(), 3 * 7);
    var count = 0;
    world.forEach((x, y, value) {
      ++count;
      expect(value, CellState.alive);
    });
    expect(count, 3 * 7);
  });

  test('One cell dies', () {
    final world = WorldState(4, 4);
    expect(world.countAlive(), 0);
    world.setDimensions(1, 1, CellState.alive);
    expect(world.countAlive(), 1);
    final newWorld = next(world)!;
    expect(world.countAlive(), 1);
    expect(newWorld.countAlive(), 0);
  });

  test('Block endures', () {
    final world = WorldState(4, 4);
    expect(world.countAlive(), 0);
    world
      ..setDimensions(1, 1, CellState.alive)
      ..setDimensions(1, 2, CellState.alive)
      ..setDimensions(2, 1, CellState.alive)
      ..setDimensions(2, 2, CellState.alive);
    expect(world.countAlive(), 4);
    final newWorld = next(world)!;
    expect(world.countAlive(), 4);
    expect(newWorld.countAlive(), 4);
  });

  test('toString empty world', () {
    final world = WorldState(0, 0);
    expect(world.width, 0);
    expect(world.height, 0);
    expect(world.countAlive(), 0);
    expect(world.toString(), '');
    final reconstructed = WorldState.fromString(world.toString());
    expect(reconstructed.width, 0);
    expect(reconstructed.height, 0);
    expect(reconstructed.countAlive(), 0);
  });

  test('toString empty 0x5', () {
    final world = WorldState(0, 5);
    expect(world.width, 0);
    expect(world.height, 5);
    expect(world.countAlive(), 0);
    expect(world.toString(), '\n\n\n\n\n');
    final reconstructed = WorldState.fromString(world.toString());
    expect(reconstructed.width, 0);
    expect(reconstructed.height, 5);
    expect(reconstructed.countAlive(), 0);
  });

  test('toString empty 5x0', () {
    final world = WorldState(5, 0);
    expect(world.width, 5);
    expect(world.height, 0);
    expect(world.countAlive(), 0);
    expect(world.toString(), '');
    final reconstructed = WorldState.fromString(world.toString());
    expect(reconstructed.width, 0);
    expect(reconstructed.height, 0);
    expect(reconstructed.countAlive(), 0);
  });

  test('toString', () {
    final world = WorldState(4, 5);
    expect(world.countAlive(), 0);
    world
      ..setDimensions(1, 1, CellState.alive)
      ..setDimensions(1, 2, CellState.alive)
      ..setDimensions(2, 1, CellState.alive)
      ..setDimensions(2, 2, CellState.alive)
      ..setDimensions(2, 3, CellState.alive);
    expect(world.countAlive(), 5);
    expect(world.toString(), '''
        ....
        .xx.
        .xx.
        ..x.
        ....
    ''');
  });

  test('fromString empty', () {
    final world = WorldState.fromString('');
    expect(world.width, 0);
    expect(world.height, 0);
    expect(world.countAlive(), 0);
  });

  test('fromString', () {
    final world = WorldState.fromString('''
    ....
    .xx.
    .xx.
    ..x.
    ....
    ''');
    expect(world.width, 4);
    expect(world.height, 5);
    expect(world.countAlive(), 5);
    expect(world.getDimensions(1, 1), CellState.alive);
    expect(world.getDimensions(1, 2), CellState.alive);
    expect(world.getDimensions(2, 1), CellState.alive);
    expect(world.getDimensions(2, 2), CellState.alive);
    expect(world.getDimensions(2, 3), CellState.alive);
  });

  test('fromString invalid', () {
    expect(() {
      WorldState.fromString('x');
    }, throwsArgumentError,
    );
    expect(() {
      WorldState.fromString('x\nx');
    }, throwsArgumentError,
    );
    expect(() {
      WorldState.fromString('x\nxx\n');
    }, throwsArgumentError,
    );
    expect(() {
      WorldState.fromString('xy\nxx\n');
    }, throwsArgumentError,
    );
  });
}
