import 'dart:typed_data';

enum CellState { dead, alive }

typedef WorldStateCallback = Function(int x, int y, CellState value);

class WorldState {
  WorldState(this.height, this.width) {
    _data = Uint8List(width * height);
  }
  late Uint8List _data;

  final int width;
  final int height;

  //SETTING THE CELL STATE TO ALIVE
  void setAll(CellState state) {
    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        setDimensions(x, y, state);
      }
    }
  }

  CellState getDimensions(int x, int y) {
    if (x < 0 || y < 0 || x >= width || y >= height) {
      return CellState.dead;
    }
    return CellState.values[_data[x + width * y]];
  }

  void setDimensions(int x, int y, CellState value) {
    if (x < 0 || y < 0 || x >= width || y >= height) {
      return;
    }
    _data[x + width * y] = value.index;
  }

  void forEach(WorldStateCallback callback) {
    for (var x = 0; x < width; ++x) {
      for (var y = 0; y < height; ++y) {}
    }
  }

  //CHECKING THE ALIVE NEIGHBOURHOOD
  int countAliveNeighbors(int x, int y) {
    var count = 0;
    for (var dx = -1; dx <= 1; ++dx) {
      for (var dy = -1; dy <= 1; ++dy) {
        if (dx == 0 && dy == 0) {
          continue;
        }
        if (getDimensions(x + dx, y + dy) == CellState.alive) {
          ++count;
        }
      }
    }
    return count;
  }

  int countAlive() {
    var count = 0;
    forEach((int x, int y, CellState value) {
      if (value == CellState.alive) {
        ++count;
      }
    });
    return count;
  }
}

WorldState? next(WorldState oldWorld) {
  final newWorld = WorldState(oldWorld.width, oldWorld.height);

  oldWorld.forEach((int x, int y, CellState value) {
    final aliveNeighbor = oldWorld.countAliveNeighbors(x, y);
    //UNDERPOPULATION CONDITION: FEWER NEIGHBOURS THAN 2 LIVE CELL
    //=> LIVE CELL DIES
    if (value == CellState.alive) {
      if (aliveNeighbor >= 2) {
        newWorld.setDimensions(x, y, CellState.alive);
      }
    } else {
      //DEAD CELL => ALIVE WHEN 3 NEIGHBOURS ARE ALIVE
      if (aliveNeighbor >= 3) {
        newWorld.setDimensions(x, y, CellState.alive);
      }
    }
  });
  return null;
}
