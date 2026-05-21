import 'dart:typed_data';
import 'dart:math';
import 'package:image/image.dart' as img;

class TileInfo {
  final int x;
  final int y;
  final int width;
  final int height;
  final Float32List tensorData;

  const TileInfo({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.tensorData,
  });
}

class TileProcessor {
  List<TileInfo> splitToTiles({
    required img.Image image,
    required int tileSize,
    int overlap = 32,
  }) {
    final tiles = <TileInfo>[];
    final step = tileSize - overlap;

    for (int y = 0; y < image.height; y += step) {
      for (int x = 0; x < image.width; x += step) {
        final tw = min(tileSize, image.width - x);
        final th = min(tileSize, image.height - y);

        final tile = img.copyCrop(image, x: x, y: y, width: tw, height: th);

        // Pad to tileSize if smaller
        img.Image padded;
        if (tw < tileSize || th < tileSize) {
          padded = img.Image(width: tileSize, height: tileSize);
          img.compositeImage(padded, tile);
        } else {
          padded = tile;
        }

        final tensor = _toFloat32(padded);
        tiles.add(TileInfo(x: x, y: y, width: tw, height: th, tensorData: tensor));
      }
    }
    return tiles;
  }

  img.Image stitchTiles({
    required List<TileInfo> tiles,
    required List<Float32List> outputs,
    required int fullWidth,
    required int fullHeight,
    required int tileSize,
    int overlap = 32,
  }) {
    final result = img.Image(width: fullWidth, height: fullHeight);
    final weightMap = List.generate(
      fullHeight,
      (_) => Float32List(fullWidth * 3),
    );
    final countMap = List.generate(
      fullHeight,
      (_) => Float32List(fullWidth),
    );

    for (int i = 0; i < tiles.length; i++) {
      final tile = tiles[i];
      final output = outputs[i];

      for (int ty = 0; ty < tile.height; ty++) {
        for (int tx = 0; tx < tile.width; tx++) {
          final gx = tile.x + tx;
          final gy = tile.y + ty;
          if (gx >= fullWidth || gy >= fullHeight) continue;

          final srcIdx = (ty * tileSize + tx) * 3;
          final dstIdx = gx * 3;

          weightMap[gy][dstIdx] += output[srcIdx];
          weightMap[gy][dstIdx + 1] += output[srcIdx + 1];
          weightMap[gy][dstIdx + 2] += output[srcIdx + 2];
          countMap[gy][gx] += 1.0;
        }
      }
    }

    for (int y = 0; y < fullHeight; y++) {
      for (int x = 0; x < fullWidth; x++) {
        final c = countMap[y][x];
        if (c == 0) continue;
        final idx = x * 3;
        final r = _clamp((weightMap[y][idx] / c) * 255.0);
        final g = _clamp((weightMap[y][idx + 1] / c) * 255.0);
        final b = _clamp((weightMap[y][idx + 2] / c) * 255.0);
        result.setPixelRgb(x, y, r, g, b);
      }
    }
    return result;
  }

  Float32List _toFloat32(img.Image image) {
    final data = Float32List(image.height * image.width * 3);
    int idx = 0;
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final px = image.getPixel(x, y);
        data[idx++] = px.r / 255.0;
        data[idx++] = px.g / 255.0;
        data[idx++] = px.b / 255.0;
      }
    }
    return data;
  }

  int _clamp(double v) => v < 0 ? 0 : (v > 255 ? 255 : v.round());
}
