// Payload serializable yang dikirim ke background isolate untuk proses inferensi.
// Seluruh field harus dapat ditransfer antar isolate (primitif atau Uint8List).
import 'dart:typed_data';

class InferenceIsolateInput {
  final Float32List tensorData;
  final int width;
  final int height;
  final bool isNchw;
  final String assetPath;

  InferenceIsolateInput({
    required this.tensorData,
    required this.width,
    required this.height,
    required this.isNchw,
    required this.assetPath,
  });
}

// Hasil mentah dari inferensi yang dikembalikan dari background isolate.
class InferenceIsolateOutput {
  final List<double> outputData;
  final int width;
  final int height;

  InferenceIsolateOutput({
    required this.outputData,
    required this.width,
    required this.height,
  });
}
