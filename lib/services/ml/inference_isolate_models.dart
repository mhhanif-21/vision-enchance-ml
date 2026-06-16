import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../../core/constants/model_config.dart';

class InferenceIsolateInput {
  final Float32List tensorData;
  final int width;
  final int height;
  final ModelType modelType;
  final String assetPath;
  final RootIsolateToken rootIsolateToken;

  InferenceIsolateInput({
    required this.tensorData,
    required this.width,
    required this.height,
    required this.modelType,
    required this.assetPath,
    required this.rootIsolateToken,
  });
}

// Hasil mentah dari inferensi yang dikembalikan dari background isolate.
class InferenceIsolateOutput {
  final Float32List outputData;
  final int width;
  final int height;

  InferenceIsolateOutput({
    required this.outputData,
    required this.width,
    required this.height,
  });
}
