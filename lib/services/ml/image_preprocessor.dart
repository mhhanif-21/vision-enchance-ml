import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../../core/constants/model_config.dart';
import '../../core/errors/exceptions.dart';

class PreprocessResult {
  final img.Image image;
  final Float32List tensorData;
  final int width;
  final int height;
  final int originalWidth;
  final int originalHeight;

  const PreprocessResult({
    required this.image,
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

      final tensorData = _normalizeToFloat32(resized, modelType);

      return PreprocessResult(
        image: resized,
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
    int newWidth = image.width;
    int newHeight = image.height;

    if (image.width > maxW || image.height > maxH) {
      final scaleW = maxW / image.width;
      final scaleH = maxH / image.height;
      final scale = scaleW < scaleH ? scaleW : scaleH;

      newWidth = (image.width * scale).round();
      newHeight = (image.height * scale).round();
    }

    // Pastikan dimensi adalah kelipatan 32 (Syarat mutlak untuk model bertingkat seperti NAFNet)
    newWidth = (newWidth ~/ 32) * 32;
    newHeight = (newHeight ~/ 32) * 32;

    if (newWidth == 0) newWidth = 32;
    if (newHeight == 0) newHeight = 32;

    if (newWidth == image.width && newHeight == image.height) {
      return image;
    }

    return img.copyResize(
      image,
      width: newWidth,
      height: newHeight,
      interpolation: img.Interpolation.linear,
    );
  }

  Float32List _normalizeToFloat32(img.Image image, ModelType modelType) {
    final pixels = image.width * image.height;
    final tensor = Float32List(1 * image.height * image.width * 3);

    if (modelType == ModelType.deblurring) {
      // NCHW format for NAFNet: [1, 3, H, W]
      int rIdx = 0;
      int gIdx = pixels;
      int bIdx = pixels * 2;

      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          tensor[rIdx++] = pixel.r / 255.0;
          tensor[gIdx++] = pixel.g / 255.0;
          tensor[bIdx++] = pixel.b / 255.0;
        }
      }
    } else {
      // NHWC format for Zero-DCE: [1, H, W, 3]
      int idx = 0;
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          tensor[idx++] = pixel.r / 255.0;
          tensor[idx++] = pixel.g / 255.0;
          tensor[idx++] = pixel.b / 255.0;
        }
      }
    }
    return tensor;
  }
}
