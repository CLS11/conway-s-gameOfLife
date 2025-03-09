import 'dart:typed_data';

enum CellState { dead, alive }

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
}

WorldState? next(WorldState old) {
  return null;
}
