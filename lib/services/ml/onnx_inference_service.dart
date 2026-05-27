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
import '../../features/restore/domain/entities/restoration_result.dart';
import '../../features/restore/domain/repositories/i_restore_repository.dart';

class OnnxInferenceService implements IRestoreRepository {
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

  @override
  Future<RestorationResult> restoreImage(
    Uint8List imageBytes, 
    ModelType modelType,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      final preprocessed = _preprocessor.preprocess(imageBytes, modelType);
      final session = await _modelManager.getSession(modelType);

      // Menonaktifkan Tiling sesuai permintaan agar proses deblurring selesai di bawah 30 detik.
      // Gambar akan di-resize langsung ke "sweet spot" resolution (misal: 512x512).
      const bool useTiling = false;

      late final Uint8List restoredBytes;
      late final int outWidth;
      late final int outHeight;
      late final InferenceStrategy strategy;

      if (useTiling) {
        final tiledResult = await _runTiledInference(
          session: session,
          preprocessed: preprocessed,
          modelType: modelType,
        );
        restoredBytes = tiledResult.imageBytes;
        outWidth = tiledResult.width;
        outHeight = tiledResult.height;
        strategy = InferenceStrategy.tiled;
      } else {
        final directResult = await _runDirectInference(
          session: session,
          preprocessed: preprocessed,
          modelType: modelType,
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

  Future<PostprocessResult> _runTiledInference({
    required OrtSession session,
    required PreprocessResult preprocessed,
    required ModelType modelType,
  }) async {
    final inputName = session.inputNames.first;
    final tileSize = ModelConfig.tileSize;
    final overlap = ModelConfig.tileOverlap;

    // Use preprocessed image directly instead of reconstructing from tensor
    final image = preprocessed.image;

    // Split into tiles
    final tiles = _tileProcessor.splitToTiles(
      image: image,
      tileSize: tileSize,
      overlap: overlap,
      modelType: modelType,
    );

    // Run inference on each tile sequentially
    final tileOutputs = <Float32List>[];

    for (final tile in tiles) {
      final shape = modelType == ModelType.deblurring
          ? [1, 3, tileSize, tileSize]
          : [1, tileSize, tileSize, 3];

      final inputTensor = await OrtValue.fromList(
        tile.tensorData,
        shape,
      );

      final outputs = await session.run({inputName: inputTensor});
      final outputData = await outputs.values.first.asFlattenedList();
      tileOutputs.add(Float32List.fromList(outputData.cast<double>()));

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
      modelType: modelType,
    );

    img.Image finalStitched = stitched;
    if (modelType == ModelType.deblurring && (preprocessed.originalWidth != preprocessed.width || preprocessed.originalHeight != preprocessed.height)) {
      finalStitched = img.copyResize(
        stitched,
        width: preprocessed.originalWidth,
        height: preprocessed.originalHeight,
        interpolation: img.Interpolation.linear,
      );
    }

    // Encode stitched image to JPEG
    final encoded = img.encodeJpg(finalStitched, quality: 95);

    return PostprocessResult(
      imageBytes: Uint8List.fromList(encoded),
      width: finalStitched.width,
      height: finalStitched.height,
    );
  }

  Future<void> dispose() async {
    await _modelManager.dispose();
  }
}
