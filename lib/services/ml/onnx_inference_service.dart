import 'dart:typed_data';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:image/image.dart' as img;
import '../../core/constants/model_config.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/memory_utils.dart';
import 'model_manager.dart';
import 'image_preprocessor.dart';
import 'image_postprocessor.dart';
import 'tile_processor.dart';

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
  final TileProcessor _tileProcessor;

  OnnxInferenceService({
    required ModelManager modelManager,
    required ImagePreprocessor preprocessor,
    required ImagePostprocessor postprocessor,
    required TileProcessor tileProcessor,
  })  : _modelManager = modelManager,
        _preprocessor = preprocessor,
        _postprocessor = postprocessor,
        _tileProcessor = tileProcessor;

  Future<RestorationResult> restore({
    required Uint8List imageBytes,
    required ModelType modelType,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      final preprocessed = _preprocessor.preprocess(imageBytes, modelType);
      final session = await _modelManager.getSession(modelType);

      final useTiling = MemoryUtils.needsTiling(
        modelType,
        preprocessed.width,
        preprocessed.height,
        DeviceTier.mid,
      );

      late final Uint8List restoredBytes;
      late final int outWidth;
      late final int outHeight;
      late final InferenceStrategy strategy;

      if (useTiling) {
        final tiledResult = await _runTiledInference(
          session: session,
          preprocessed: preprocessed,
        );
        restoredBytes = tiledResult.imageBytes;
        outWidth = tiledResult.width;
        outHeight = tiledResult.height;
        strategy = InferenceStrategy.tiled;
      } else {
        final directResult = await _runDirectInference(
          session: session,
          preprocessed: preprocessed,
        );
        restoredBytes = directResult.imageBytes;
        outWidth = directResult.width;
        outHeight = directResult.height;
        strategy = InferenceStrategy.direct;
      }

      stopwatch.stop();

      return RestorationResult(
        originalBytes: imageBytes,
        restoredBytes: restoredBytes,
        inputWidth: preprocessed.originalWidth,
        inputHeight: preprocessed.originalHeight,
        outputWidth: outWidth,
        outputHeight: outHeight,
        processingTimeMs: stopwatch.elapsedMilliseconds,
        strategy: strategy,
      );
    } catch (e) {
      stopwatch.stop();
      if (e is ModelLoadException) rethrow;
      if (e is ImageProcessingException) rethrow;
      throw InferenceException('Restoration failed: $e');
    }
  }

  Future<PostprocessResult> _runDirectInference({
    required OnnxRuntimeSession session,
    required PreprocessResult preprocessed,
  }) async {
    final inputName = (await session.getInputNames()).first;

    final inputTensor = OnnxRuntimeTensor.fromList(
      preprocessed.tensorData,
      [1, preprocessed.height, preprocessed.width, 3],
    );

    final outputs = await session.run({inputName: inputTensor});
    final outputData = outputs.values.first.value as List<double>;

    final result = _postprocessor.postprocess(
      outputData: outputData,
      width: preprocessed.width,
      height: preprocessed.height,
    );

    inputTensor.dispose();
    for (final t in outputs.values) {
      t.dispose();
    }

    return result;
  }

  Future<PostprocessResult> _runTiledInference({
    required OnnxRuntimeSession session,
    required PreprocessResult preprocessed,
  }) async {
    final inputName = (await session.getInputNames()).first;
    final tileSize = ModelConfig.tileSize;
    final overlap = ModelConfig.tileOverlap;

    // Reconstruct image from preprocessed tensor for tiling
    final image = img.Image(
      width: preprocessed.width,
      height: preprocessed.height,
    );
    int idx = 0;
    for (int y = 0; y < preprocessed.height; y++) {
      for (int x = 0; x < preprocessed.width; x++) {
        final r = (preprocessed.tensorData[idx++] * 255).round();
        final g = (preprocessed.tensorData[idx++] * 255).round();
        final b = (preprocessed.tensorData[idx++] * 255).round();
        image.setPixelRgb(x, y, r, g, b);
      }
    }

    // Split into tiles
    final tiles = _tileProcessor.splitToTiles(
      image: image,
      tileSize: tileSize,
      overlap: overlap,
    );

    // Run inference on each tile sequentially
    final tileOutputs = <Float32List>[];

    for (final tile in tiles) {
      final inputTensor = OnnxRuntimeTensor.fromList(
        tile.tensorData,
        [1, tileSize, tileSize, 3],
      );

      final outputs = await session.run({inputName: inputTensor});
      final outputData = outputs.values.first.value as List<double>;
      tileOutputs.add(Float32List.fromList(outputData.map((e) => e.toDouble()).toList()));

      inputTensor.dispose();
      for (final t in outputs.values) {
        t.dispose();
      }
    }

    // Stitch tiles back together
    final stitched = _tileProcessor.stitchTiles(
      tiles: tiles,
      outputs: tileOutputs,
      fullWidth: preprocessed.width,
      fullHeight: preprocessed.height,
      tileSize: tileSize,
      overlap: overlap,
    );

    // Encode stitched image to JPEG
    final encoded = img.encodeJpg(stitched, quality: 95);

    return PostprocessResult(
      imageBytes: Uint8List.fromList(encoded),
      width: stitched.width,
      height: stitched.height,
    );
  }

  Future<void> dispose() async {
    await _modelManager.dispose();
  }
}
