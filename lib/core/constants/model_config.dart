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
        return 'models/low_light_enhancement.onnx';
      case ModelType.deblurring:
        return 'models/nafnet_gopro_width32_fp16.onnx';
    }
  }
}

enum DeviceTier { low, mid, high }

class ModelConfig {
  ModelConfig._();

  static const Map<ModelType, Size> maxResolution = {
    ModelType.lowLight: Size(1920, 1080),
    ModelType.deblurring: Size(1280, 720),
  };

  // Resolusi fallback saat RAM terbatas
  static const Map<ModelType, Size> lowMemoryResolution = {
    ModelType.lowLight: Size(640, 480),
    ModelType.deblurring: Size(384, 384),
  };

  // Threshold RAM minimum (MB) sebelum fallback ke resolusi rendah
  static const Map<ModelType, int> minRamRequiredMB = {
    ModelType.lowLight: 80,
    ModelType.deblurring: 100, // Sekarang menggunakan Tiling, aman untuk RAM 100MB+
  };

  static const int tileSize = 512;
  static const int tileOverlap = 32;

  // Menentukan resolusi maksimal berdasarkan RAM tersedia
  static Size getAdaptiveMaxResolution(ModelType modelType, int availableRamMB) {
    final required = minRamRequiredMB[modelType] ?? 100;
    if (availableRamMB < required) {
      return lowMemoryResolution[modelType]!;
    }
    return maxResolution[modelType]!;
  }
}

