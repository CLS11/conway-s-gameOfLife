import 'dart:typed_data';
import 'package:conway/cell_position.dart';
import 'package:flutter/material.dart';

enum CellState { dead, alive }

typedef WorldStateCallback = Function(int x, int y, CellState value);

class WorldState extends ChangeNotifier {
  WorldState(this.height, this.width) {
    _data = Uint8List(width * height);
  }

  //FACTORY CONSTRUCTOR
  factory WorldState.fromFixture(String pickle) {
    if (pickle.isEmpty) {
      return WorldState(0, 0);
    }
    final lines = pickle.split('\n');
    if (lines.length <= 1 || lines.last.isNotEmpty) {
      throw ArgumentError('Each line in pattern is terminated using new line');
    }
    final height = lines.length - 1;
    final width = lines[0].length;
    final world = WorldState(height, width);
    for (var y = 0; y < height; ++y) {
      if (lines[y].length != width) {
        throw ArgumentError('Each line in pattern must be same length');
      }
      for (var x = 0; x < width; ++x) {
        final ch = lines[y][x];
        switch (ch) {
          case 'x':
            world.setDimensions(x, y, CellState.alive);
            break;
          case '.':
            //CELLS - DEFAULT TO DEAD IN A NEWLY CREATED WORLD
            break;
          default:
            throw ArgumentError('Inavlid character');
        }
      }
    }
    return world;
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

  CellState getPosition(CellPosition position) =>
      getDimensions(position.x, position.y);

  void setDimensions(int x, int y, CellState value) {
    if (x < 0 || y < 0 || x >= width || y >= height) {
      return;
    }
    _data[x + width * y] = value.index;
    notifyListeners();
  }

  void setPosition(CellPosition position, CellState value) {
    setDimensions(position.x, position.y, value);
  }

  void toggle(CellPosition position) {
    switch (getPosition(position)) {
      case CellState.alive:
        setPosition(position, CellState.dead);
        break;
      case CellState.dead:
        setPosition(position, CellState.alive);
        break;
    }
  }

  void forEach(WorldStateCallback callback) {
    for (var y = 0; y < height; ++y) {
      for (var x = 0; x < width; ++x) {
        callback(x, y, getDimensions(x, y));
      }
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

  @override
  String toFixture() {
    final buffer = StringBuffer();
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        switch (getDimensions(x, y)) {
          case CellState.dead:
            buffer.write('.');
            break;
          case CellState.alive:
            buffer.write('x');
            break;
        }
      }
      buffer.write('\n');
    }
    return buffer.toString();
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! WorldState) {
      return false;
    }
    final typedOther = other;
    if (width != typedOther.width || height != typedOther.height) {
      return false;
    }
    for (var y = 0; y < height; ++y) {
      for (var x = 0; x < width; ++x) {
        if (getDimensions(x, y) != typedOther.getDimensions(x, y)) {
          return false;
        }
      }
    }
    return true;
  }
}

WorldState? next(WorldState oldWorld) {
  final newWorld = WorldState(oldWorld.height, oldWorld.width);

  oldWorld.forEach((int x, int y, CellState value) {
    final aliveNeighbor = oldWorld.countAliveNeighbors(x, y);
    //UNDERPOPULATION CONDITION: FEWER NEIGHBOURS THAN 2 LIVE CELL
    //=> LIVE CELL DIES
    if (value == CellState.alive) {
      if (aliveNeighbor == 2 || aliveNeighbor == 3) {
        newWorld.setDimensions(x, y, CellState.alive);
      }
    } else {
      //DEAD CELL => ALIVE WHEN 3 NEIGHBOURS ARE ALIVE
      if (aliveNeighbor == 3) {
        newWorld.setDimensions(x, y, CellState.alive);
      }
    }
  });
  return newWorld;
}
