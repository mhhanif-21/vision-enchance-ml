import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../../core/constants/app_constants.dart';
import '../../core/constants/model_config.dart';

class PostprocessResult {
  final Uint8List imageBytes;
  final int width;
  final int height;

  const PostprocessResult({
    required this.imageBytes,
    required this.width,
    required this.height,
  });
}

class ImagePostprocessor {
  PostprocessResult postprocess({
    required Float32List outputData,
    required int width,
    required int height,
    required ModelType modelType,
    int? targetWidth,
    int? targetHeight,
  }) {
    final image = img.Image(width: width, height: height);

    // Decode NHWC: [1, H, W, 3]
    int idx = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final r = _clampToByte(outputData[idx++] * 255.0);
        final g = _clampToByte(outputData[idx++] * 255.0);
        final b = _clampToByte(outputData[idx++] * 255.0);
        image.setPixelRgb(x, y, r, g, b);
      }
    }

    img.Image finalImage = image;
    if (targetWidth != null && targetHeight != null) {
      if (targetWidth != width || targetHeight != height) {
        finalImage = img.copyResize(
          image,
          width: targetWidth,
          height: targetHeight,
          interpolation: img.Interpolation.linear,
        );
      }
    }

    final encoded = img.encodeJpg(finalImage, quality: AppConstants.jpegQuality);
    return PostprocessResult(
      imageBytes: Uint8List.fromList(encoded),
      width: finalImage.width,
      height: finalImage.height,
    );
  }

  int _clampToByte(double value) {
    if (value.isNaN) return 0;
    if (value.isInfinite) return value < 0 ? 0 : 255;
    if (value < 0) return 0;
    if (value > 255) return 255;
    return value.round();
  }
}
