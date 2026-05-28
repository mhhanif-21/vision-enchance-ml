// File ini mendefinisikan entitas RestorationResult.
// Berfungsi untuk menyimpan hasil dari proses inferensi ML.

import 'dart:typed_data';
import '../../../../core/constants/model_config.dart';

class RestorationResult {
  final ModelType modelType;
  final Uint8List originalBytes;
  final Uint8List restoredBytes;
  final int inputWidth;
  final int inputHeight;
  final int outputWidth;
  final int outputHeight;
  final int processingTimeMs;

  const RestorationResult({
    required this.modelType,
    required this.originalBytes,
    required this.restoredBytes,
    required this.inputWidth,
    required this.inputHeight,
    required this.outputWidth,
    required this.outputHeight,
    required this.processingTimeMs,
  });
}
