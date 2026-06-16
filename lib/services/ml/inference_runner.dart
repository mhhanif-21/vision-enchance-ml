// Fungsi top-level untuk dijalankan di background isolate via Flutter compute().
// compute() secara otomatis menyiapkan BackgroundIsolateBinaryMessenger
// sehingga method channel (digunakan flutter_onnxruntime) tetap berfungsi.
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:image/image.dart' as img;
import 'inference_isolate_models.dart';
import 'tile_processor.dart';
import '../../core/constants/model_config.dart';

Float32List _nhwcToNchw(Float32List nhwc, int width, int height) {
  final nchw = Float32List(nhwc.length);
  final channelSize = width * height;
  int nhwcIdx = 0;
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final spatialIdx = y * width + x;
      nchw[spatialIdx] = nhwc[nhwcIdx++];                 // R
      nchw[channelSize + spatialIdx] = nhwc[nhwcIdx++];   // G
      nchw[channelSize * 2 + spatialIdx] = nhwc[nhwcIdx++]; // B
    }
  }
  return nchw;
}

Float32List _nchwToNhwc(Float32List nchw, int width, int height) {
  final nhwc = Float32List(nchw.length);
  final channelSize = width * height;
  int nhwcIdx = 0;
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final spatialIdx = y * width + x;
      nhwc[nhwcIdx++] = nchw[spatialIdx];
      nhwc[nhwcIdx++] = nchw[channelSize + spatialIdx];
      nhwc[nhwcIdx++] = nchw[channelSize * 2 + spatialIdx];
    }
  }
  return nhwc;
}

// Fungsi top-level yang dipanggil oleh compute() di background isolate.
Future<InferenceIsolateOutput> runInferenceInIsolate(
  InferenceIsolateInput input,
) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(input.rootIsolateToken);
  final runtime = OnnxRuntime();
  final session = await runtime.createSessionFromAsset(input.assetPath);

  final inputName = session.inputNames.first;
  final isNchw = input.modelType == ModelType.deblurring;

  if (input.modelType == ModelType.deblurring && (input.width * input.height > 512 * 512)) {
    // Tiled inference
    final tileProcessor = TileProcessor();
    final tileSize = ModelConfig.tileSize;
    final overlap = ModelConfig.tileOverlap;

    // Reconstruct image from flat tensor
    final image = img.Image(width: input.width, height: input.height);
    int idx = 0;
    for (int y = 0; y < input.height; y++) {
      for (int x = 0; x < input.width; x++) {
        final r = (input.tensorData[idx++] * 255).round();
        final g = (input.tensorData[idx++] * 255).round();
        final b = (input.tensorData[idx++] * 255).round();
        image.setPixelRgb(x, y, r, g, b);
      }
    }

    final tiles = tileProcessor.splitToTiles(
      image: image,
      tileSize: tileSize,
      overlap: overlap,
    );

    final tileOutputs = <Float32List>[];

    for (final tile in tiles) {
      final tensorToPass = isNchw ? _nhwcToNchw(tile.tensorData, tileSize, tileSize) : tile.tensorData;
      final shape = isNchw ? [1, 3, tileSize, tileSize] : [1, tileSize, tileSize, 3];

      final inputTensor = await OrtValue.fromList(tensorToPass, shape);

      final outputs = await session.run({inputName: inputTensor});
      final outputData = await outputs.values.first.asFlattenedList();
      
      final outFlat = Float32List.fromList(outputData.cast<double>());
      final processedOut = isNchw ? _nchwToNhwc(outFlat, tileSize, tileSize) : outFlat;
      tileOutputs.add(processedOut);

      inputTensor.dispose();
      for (final t in outputs.values) {
        t.dispose();
      }
    }

    final stitched = tileProcessor.stitchTiles(
      tiles: tiles,
      outputs: tileOutputs,
      fullWidth: input.width,
      fullHeight: input.height,
      tileSize: tileSize,
      overlap: overlap,
    );

    // Convert back to tensor data format expected by postprocessor
    final outputData = Float32List(input.width * input.height * 3);
    idx = 0;
    for (int y = 0; y < input.height; y++) {
      for (int x = 0; x < input.width; x++) {
        final px = stitched.getPixel(x, y);
        outputData[idx++] = px.r / 255.0;
        outputData[idx++] = px.g / 255.0;
        outputData[idx++] = px.b / 255.0;
      }
    }

    await session.close();

    return InferenceIsolateOutput(
      outputData: outputData,
      width: input.width,
      height: input.height,
    );
  } else {
    // Direct inference
    final tensorToPass = isNchw ? _nhwcToNchw(input.tensorData, input.width, input.height) : input.tensorData;
    final shape = isNchw ? [1, 3, input.height, input.width] : [1, input.height, input.width, 3];

    final inputTensor = await OrtValue.fromList(tensorToPass, shape);
    final outputs = await session.run({inputName: inputTensor});
    final outputList = await outputs.values.first.asFlattenedList();
    
    // Wajib melakukan deep copy (salin ke Dart memory) sebelum memanggil dispose() 
    // pada native tensor, jika tidak datanya akan terkorupsi saat melintasi isolate!
    final copiedData = Float32List.fromList(outputList.cast<double>());
    final processedOut = isNchw ? _nchwToNhwc(copiedData, input.width, input.height) : copiedData;

    inputTensor.dispose();
    for (final t in outputs.values) { t.dispose(); }
    await session.close();

    return InferenceIsolateOutput(
      outputData: processedOut,
      width: input.width,
      height: input.height,
    );
  }
}

// Wrapper publik untuk memanggil inferensi di background isolate.
Future<InferenceIsolateOutput> runInIsolate(InferenceIsolateInput input) {
  return compute(runInferenceInIsolate, input);
}
