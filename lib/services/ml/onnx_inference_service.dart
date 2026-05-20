import 'dart:typed_data';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import '../../core/constants/model_config.dart';
import '../../core/errors/exceptions.dart';
import 'model_manager.dart';
import 'image_preprocessor.dart';
import 'image_postprocessor.dart';

class RestorationResult {
  final Uint8List originalBytes;
  final Uint8List restoredBytes;
  final int inputWidth;
  final int inputHeight;
  final int outputWidth;
  final int outputHeight;
  final int processingTimeMs;
  final InferenceStrategy strategy;

  const RestorationResult({
    required this.originalBytes,
    required this.restoredBytes,
    required this.inputWidth,
    required this.inputHeight,
    required this.outputWidth,
    required this.outputHeight,
    required this.processingTimeMs,
    required this.strategy,
  });
}

class OnnxInferenceService {
  final ModelManager _modelManager;
  final ImagePreprocessor _preprocessor;
  final ImagePostprocessor _postprocessor;

  OnnxInferenceService({
    required ModelManager modelManager,
    required ImagePreprocessor preprocessor,
    required ImagePostprocessor postprocessor,
  })  : _modelManager = modelManager,
        _preprocessor = preprocessor,
        _postprocessor = postprocessor;

  Future<RestorationResult> restore({
    required Uint8List imageBytes,
    required ModelType modelType,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Preprocess
      final preprocessed = _preprocessor.preprocess(imageBytes, modelType);

      // Get model session
      final session = await _modelManager.getSession(modelType);

      // Get input/output info
      final inputInfo = await session.getInputNames();
      final inputName = inputInfo.first;

      // Create input tensor
      final inputTensor = OnnxRuntimeTensor.fromList(
        preprocessed.tensorData,
        [1, preprocessed.height, preprocessed.width, 3],
      );

      // Run inference
      final outputs = await session.run({inputName: inputTensor});

      // Extract output
      final outputTensor = outputs.values.first;
      final outputData = outputTensor.value as List<double>;

      // Postprocess
      final postprocessed = _postprocessor.postprocess(
        outputData: outputData,
        width: preprocessed.width,
        height: preprocessed.height,
      );

      // Cleanup tensors
      inputTensor.dispose();
      for (final tensor in outputs.values) {
        tensor.dispose();
      }

      stopwatch.stop();

      return RestorationResult(
        originalBytes: imageBytes,
        restoredBytes: postprocessed.imageBytes,
        inputWidth: preprocessed.originalWidth,
        inputHeight: preprocessed.originalHeight,
        outputWidth: postprocessed.width,
        outputHeight: postprocessed.height,
        processingTimeMs: stopwatch.elapsedMilliseconds,
        strategy: InferenceStrategy.direct,
      );
    } catch (e) {
      stopwatch.stop();
      if (e is ModelLoadException) rethrow;
      if (e is ImageProcessingException) rethrow;
      throw InferenceException('Restoration failed: $e');
    }
  }

  Future<void> dispose() async {
    await _modelManager.dispose();
  }
}
