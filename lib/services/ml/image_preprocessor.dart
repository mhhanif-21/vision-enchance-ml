import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../../core/constants/model_config.dart';
import '../../core/errors/exceptions.dart';

class PreprocessResult {
  final Float32List tensorData;
  final int width;
  final int height;
  final int originalWidth;
  final int originalHeight;

  const PreprocessResult({
    required this.tensorData,
    required this.width,
    required this.height,
    required this.originalWidth,
    required this.originalHeight,
  });
}

class ImagePreprocessor {
  PreprocessResult preprocess(Uint8List imageBytes, ModelType modelType) {
    try {
      final decoded = img.decodeImage(imageBytes);
      if (decoded == null) {
        throw const ImageProcessingException('Failed to decode image');
      }

      final originalWidth = decoded.width;
      final originalHeight = decoded.height;

      final maxRes = ModelConfig.maxResolution[modelType]!;
      final resized = _fitToMaxResolution(
        decoded,
        maxRes.width.toInt(),
        maxRes.height.toInt(),
      );

      final tensorData = _normalizeToFloat32(resized);

      return PreprocessResult(
        tensorData: tensorData,
        width: resized.width,
        height: resized.height,
        originalWidth: originalWidth,
        originalHeight: originalHeight,
      );
    } catch (e) {
      if (e is ImageProcessingException) rethrow;
      throw ImageProcessingException('Preprocessing failed: $e');
    }
  }

  img.Image _fitToMaxResolution(img.Image image, int maxW, int maxH) {
    if (image.width <= maxW && image.height <= maxH) {
      return image;
    }

    final scaleW = maxW / image.width;
    final scaleH = maxH / image.height;
    final scale = scaleW < scaleH ? scaleW : scaleH;

    final newWidth = (image.width * scale).round();
    final newHeight = (image.height * scale).round();

    return img.copyResize(
      image,
      width: newWidth,
      height: newHeight,
      interpolation: img.Interpolation.linear,
    );
  }

  Float32List _normalizeToFloat32(img.Image image) {
    final pixels = image.width * image.height;
    final tensor = Float32List(1 * image.height * image.width * 3);

    int idx = 0;
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        tensor[idx++] = pixel.r / 255.0;
        tensor[idx++] = pixel.g / 255.0;
        tensor[idx++] = pixel.b / 255.0;
      }
    }

    return tensor;
  }
}
