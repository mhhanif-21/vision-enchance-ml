// Fungsi top-level untuk dijalankan di background isolate via Flutter compute().
// compute() secara otomatis menyiapkan BackgroundIsolateBinaryMessenger
// sehingga method channel (digunakan flutter_onnxruntime) tetap berfungsi.
import 'package:flutter/foundation.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'inference_isolate_models.dart';

// Fungsi top-level yang dipanggil oleh compute() di background isolate.
Future<InferenceIsolateOutput> runInferenceInIsolate(
  InferenceIsolateInput input,
) async {
  final runtime = OnnxRuntime();
  final session = await runtime.createSessionFromAsset(input.assetPath);

  final inputName = session.inputNames.first;
  final shape = input.isNchw
      ? [1, 3, input.height, input.width]
      : [1, input.height, input.width, 3];

  final inputTensor = await OrtValue.fromList(input.tensorData, shape);
  final outputs = await session.run({inputName: inputTensor});
  final outputList = await outputs.values.first.asFlattenedList();

  // Bersihkan resource native setelah selesai.
  inputTensor.dispose();
  for (final t in outputs.values) { t.dispose(); }
  await session.close();

  return InferenceIsolateOutput(
    outputData: outputList.cast<double>(),
    width: input.width,
    height: input.height,
  );
}

// Wrapper publik untuk memanggil inferensi di background isolate.
Future<InferenceIsolateOutput> runInIsolate(InferenceIsolateInput input) {
  return compute(runInferenceInIsolate, input);
}
