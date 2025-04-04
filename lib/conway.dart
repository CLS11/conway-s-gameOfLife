import 'dart:typed_data';

import 'package:conway/cell_position.dart';
import 'package:flutter/material.dart';

enum CellState { dead, alive }

typedef WorldStateCallback = Function(int x, int y, CellState value);

class WorldState extends ChangeNotifier {
  WorldState(this.height, this.width, [this.name = 'Unnamed']) {
    _data = Uint8List(width * height);
  }

  WorldState.clone(WorldState other)
      : width = other.width,
        height = other.height,
        name = other.name {
    _data = Uint8List.fromList(other._data);
  }

  WorldState withPadding(int pad) {
    final world = WorldState(height + 2 * pad, width + 2 * pad, name);
    forEach((x, y, value) {
      world.setDimensions(x + pad, y + pad, value);
    });
    return world;
  }

  late Uint8List _data;
  final int width;
  final int height;
  final String name;

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
    if (x < 0 || y < 0 || x >= width || y >= height) return;
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

  int countAliveNeighbors(int x, int y) {
    var count = 0;
    for (var dx = -1; dx <= 1; ++dx) {
      for (var dy = -1; dy <= 1; ++dy) {
        if (dx == 0 && dy == 0) continue;
        if (getDimensions(x + dx, y + dy) == CellState.alive) {
          ++count;
        }
      }
    }
    return count;
  }

  int countAlive() {
    var count = 0;
    forEach((x, y, value) {
      if (value == CellState.alive) count++;
    });
    return count;
  }

  String toFixture() {
    final buffer = StringBuffer();
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        buffer.write(getDimensions(x, y) == CellState.alive ? 'x' : '.');
      }
      buffer.write('\n');
    }
    return buffer.toString();
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! WorldState) return false;
    if (width != other.width || height != other.height) return false;
    for (var y = 0; y < height; ++y) {
      for (var x = 0; x < width; ++x) {
        if (getDimensions(x, y) != other.getDimensions(x, y)) return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => toFixture().hashCode;

  @override
  String toString() => 'World $name $width x $height';

  factory WorldState.fromFixture(String pickle, [String name = 'Unnamed']) {
    if (pickle.isEmpty) return WorldState(0, 0, name);

    final lines = pickle.split('\n');
    if (lines.length <= 1 || lines.last.isNotEmpty) {
      throw ArgumentError('Each line in pattern must end with a newline.');
    }

    final height = lines.length - 1;
    final width = lines[0].length;
    final world = WorldState(height, width, name);

    for (var y = 0; y < height; ++y) {
      if (lines[y].length != width) {
        throw ArgumentError('Each line in pattern must be the same length.');
      }
      for (var x = 0; x < width; ++x) {
        final ch = lines[y][x];
        if (ch == 'x') {
          world.setDimensions(x, y, CellState.alive);
        } else if (ch != '.') {
          throw ArgumentError('Invalid character in pattern: $ch');
        }
      }
    }

    return world;
  }

  factory WorldState.fromRLE(String rle) {
    final lines = rle.split('\n');
    var haveSize = false;
    late WorldState world;
    var name = 'Unnamed';
    var x = 0;
    var y = 0;

    for (final line in lines) {
      if (line.startsWith('#N ')) {
        name = line.substring(3);
        continue;
      }
      if (line.isEmpty || line.startsWith('#')) continue;

      if (!haveSize) {
        int? width;
        int? height;
        final attributes = line.split(',');
        for (final attribute in attributes) {
          final keyValue = attribute.split('=');
          if (keyValue.length != 2) {
            throw ArgumentError('Invalid attribute: $attribute');
          }
          final key = keyValue[0].trim();
          final value = keyValue[1].trim();
          switch (key) {
            case 'x':
              width = int.parse(value);
              break;
            case 'y':
              height = int.parse(value);
              break;
          }
        }

        if (width == null || height == null) {
          throw ArgumentError('Missing width or height.');
        }

        world = WorldState(height, width, name);
        haveSize = true;
        continue;
      }

      var runCountBuffer = '';

      int flushRunCount() {
        final buffer = runCountBuffer;
        runCountBuffer = '';
        return buffer.isEmpty ? 1 : int.parse(buffer);
      }

      for (var i = 0; i < line.length; ++i) {
        final c = line[i];
        if (c == 'b') {
          x += flushRunCount();
        } else if (c == 'o') {
          final runCount = flushRunCount();
          for (var j = 0; j < runCount; ++j) {
            world.setDimensions(x, y, CellState.alive);
            x += 1;
          }
        } else if (c == r'$') {
          x = 0;
          y += flushRunCount();
        } else if (c == '!') {
          return world;
        } else {
          runCountBuffer += c;
        }
      }
    }

    throw ArgumentError('Missing termination character (!) in RLE.');
  }
}

WorldState next(WorldState oldWorld) {
  final newWorld = WorldState(oldWorld.height, oldWorld.width, oldWorld.name);

  oldWorld.forEach((x, y, value) {
    final aliveNeighbors = oldWorld.countAliveNeighbors(x, y);
    if (value == CellState.alive) {
      if (aliveNeighbors == 2 || aliveNeighbors == 3) {
        newWorld.setDimensions(x, y, CellState.alive);
      }
    } else {
      if (aliveNeighbors == 3) {
        newWorld.setDimensions(x, y, CellState.alive);
      }
    }
  });

  return newWorld;
}
