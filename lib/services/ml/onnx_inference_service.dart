import 'dart:typed_data';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:image/image.dart' as img;
import '../../core/constants/model_config.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/memory_utils.dart';
import 'model_manager.dart';
import 'image_preprocessor.dart';
import 'image_postprocessor.dart';
import '../../features/restore/domain/entities/restoration_result.dart';
import '../../features/restore/domain/repositories/i_restore_repository.dart';

class OnnxInferenceService implements IRestoreRepository {
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

  @override
  Future<RestorationResult> restoreImage(
    Uint8List imageBytes, 
    ModelType modelType,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      // --- Pengecekan Keamanan Memori (RAM Check) ---
      final availableRam = await MemoryUtils.getAvailableRAM();
      final requiredRam = ModelConfig.minRamRequiredMB[modelType] ?? 100;
      if (availableRam < requiredRam) {
        throw InsufficientMemoryException('RAM tidak cukup. Tersedia: ${availableRam}MB, Butuh: ${requiredRam}MB');
      }

      final preprocessed = _preprocessor.preprocess(imageBytes, modelType);
      final session = await _modelManager.getSession(modelType);

      final directResult = await _runDirectInference(
        session: session,
        preprocessed: preprocessed,
        modelType: modelType,
      );
      
      final restoredBytes = directResult.imageBytes;
      final outWidth = directResult.width;
      final outHeight = directResult.height;
      const strategy = InferenceStrategy.direct;

      stopwatch.stop();

      return RestorationResult(
        modelType: modelType,
        originalBytes: imageBytes,
        restoredBytes: restoredBytes,
        inputWidth: preprocessed.originalWidth,
        inputHeight: preprocessed.originalHeight,
        outputWidth: outWidth,
        outputHeight: outHeight,
        processingTimeMs: stopwatch.elapsedMilliseconds,
        strategy: strategy,
      );
    } catch (e, stackTrace) {
      print('DEBUG ONNX EXCEPTION: $e\n$stackTrace');
      stopwatch.stop();
      if (e is ModelLoadException) rethrow;
      if (e is ImageProcessingException) rethrow;
      throw InferenceException('Restoration failed: $e');
    }
  }

  Future<PostprocessResult> _runDirectInference({
    required OrtSession session,
    required PreprocessResult preprocessed,
    required ModelType modelType,
  }) async {
    final inputName = session.inputNames.first;

    final shape = modelType == ModelType.deblurring
        ? [1, 3, preprocessed.height, preprocessed.width]
        : [1, preprocessed.height, preprocessed.width, 3];

    final inputTensor = await OrtValue.fromList(
      preprocessed.tensorData,
      shape,
    );

    final outputs = await session.run({inputName: inputTensor});
    final outputList = await outputs.values.first.asFlattenedList();
    final outputData = outputList.cast<double>();

    final result = _postprocessor.postprocess(
      outputData: outputData,
      width: preprocessed.width,
      height: preprocessed.height,
      modelType: modelType,
      targetWidth: modelType == ModelType.deblurring ? preprocessed.originalWidth : null,
      targetHeight: modelType == ModelType.deblurring ? preprocessed.originalHeight : null,
    );

    inputTensor.dispose();
    for (final t in outputs.values) {
      t.dispose();
    }

    return result;
  }

  Future<void> dispose() async {
    await _modelManager.dispose();
  }
}
