// Layanan inferensi utama yang mengimplementasikan IRestoreRepository.
// Memisahkan pipeline menjadi 3 tahap dan menjalankan inferensi berat di isolate.
import 'dart:typed_data';
import '../../core/constants/model_config.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/memory_utils.dart';
import '../../features/restore/repositories/i_restore_repository.dart';
import '../../features/restore/models/restoration_result.dart';
import '../../features/restore/bloc/restore_bloc.dart';
import 'image_preprocessor.dart';
import 'image_postprocessor.dart';
import 'inference_isolate_models.dart';
import 'inference_runner.dart';

class OnnxInferenceService implements IRestoreRepository {
  final ImagePreprocessor _preprocessor;
  final ImagePostprocessor _postprocessor;

  OnnxInferenceService({
    required ImagePreprocessor preprocessor,
    required ImagePostprocessor postprocessor,
  })  : _preprocessor = preprocessor,
        _postprocessor = postprocessor;

  @override
  Future<RestorationResult> restoreImage(
    Uint8List imageBytes,
    ModelType modelType, {
    void Function(RestorationStep step)? onStepChanged,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Validasi ketersediaan RAM sebelum memulai proses berat.
      final availableRam = await MemoryUtils.getAvailableRAM();
      final requiredRam = ModelConfig.minRamRequiredMB[modelType] ?? 100;
      if (availableRam < requiredRam) {
        throw InsufficientMemoryException(
          'RAM tidak cukup. Tersedia: ${availableRam}MB, Butuh: ${requiredRam}MB',
        );
      }

      // Tahap 1: pra-proses gambar di main thread (cepat, ~50ms).
      onStepChanged?.call(RestorationStep.preprocessing);
      final preprocessed = _preprocessor.preprocess(imageBytes, modelType);

      // Tahap 2: inferensi AI di background isolate (berat, 5-30 detik).
      onStepChanged?.call(RestorationStep.inferencing);
      final inferenceOutput = await runInIsolate(InferenceIsolateInput(
        tensorData: preprocessed.tensorData,
        width: preprocessed.width,
        height: preprocessed.height,
        isNchw: modelType == ModelType.deblurring,
        assetPath: modelType.assetPath,
      ));

      // Tahap 3: pasca-proses hasil di main thread (cepat, ~100ms).
      onStepChanged?.call(RestorationStep.postprocessing);
      final postprocessed = _postprocessor.postprocess(
        outputData: inferenceOutput.outputData,
        width: inferenceOutput.width,
        height: inferenceOutput.height,
        modelType: modelType,
        targetWidth: modelType == ModelType.deblurring ? preprocessed.originalWidth : null,
        targetHeight: modelType == ModelType.deblurring ? preprocessed.originalHeight : null,
      );

      stopwatch.stop();

      return RestorationResult(
        modelType: modelType,
        originalBytes: imageBytes,
        restoredBytes: postprocessed.imageBytes,
        inputWidth: preprocessed.originalWidth,
        inputHeight: preprocessed.originalHeight,
        outputWidth: postprocessed.width,
        outputHeight: postprocessed.height,
        processingTimeMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      stopwatch.stop();
      if (e is ModelLoadException) rethrow;
      if (e is ImageProcessingException) rethrow;
      if (e is InsufficientMemoryException) rethrow;
      throw InferenceException('Restorasi gagal: $e');
    }
  }
}
