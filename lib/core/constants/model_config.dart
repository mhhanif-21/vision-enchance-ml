import 'dart:ui';

enum ModelType {
  lowLight,
  deblurring;

  String get displayName {
    switch (this) {
      case ModelType.lowLight:
        return 'Peningkatan Cahaya';
      case ModelType.deblurring:
        return 'Penghilangan Blur';
    }
  }

  String get assetPath {
    switch (this) {
      case ModelType.lowLight:
        return 'models/low_light_enhancement_fp16.onnx';
      case ModelType.deblurring:
        return 'models/deblurring_nafnet_2025may_fp16.onnx';
    }
  }
}

enum InferenceStrategy { direct, tiled }

enum DeviceTier { low, mid, high }

class ModelConfig {
  ModelConfig._();

  static const Map<ModelType, Size> maxResolution = {
    ModelType.lowLight: Size(1920, 1080),
    ModelType.deblurring: Size(1280, 720),
  };

  static const Map<ModelType, int> minRamRequiredMB = {
    ModelType.lowLight: 100,
    ModelType.deblurring: 500,
  };

  static const int tileSize = 512;
  static const int tileOverlap = 32;
}
