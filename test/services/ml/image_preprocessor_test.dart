// Unit testing untuk proses preprocessing gambar (ImagePreprocessor).
// Memastikan pengubahan resolusi dan normalisasi pixel (NCHW vs NHWC) berjalan benar.
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:vision_enchance_ml/services/ml/image_preprocessor.dart';
import 'package:vision_enchance_ml/core/constants/model_config.dart';

void main() {
  late ImagePreprocessor preprocessor;
  late Uint8List dummyImageBytes;

  setUp(() {
    preprocessor = ImagePreprocessor();
    // Membuat gambar dummy warna merah berukuran 100x100
    final image = img.Image(width: 100, height: 100);
    img.fill(image, color: img.ColorRgb8(255, 0, 0)); // Merah solid
    dummyImageBytes = Uint8List.fromList(img.encodeJpg(image));
  });

  group('ImagePreprocessor Tests', () {
    test('Low Light model menggunakan format NHWC dan kelipatan 32', () {
      final result = preprocessor.preprocess(dummyImageBytes, ModelType.lowLight);

      // Gambar 100x100 akan dibulatkan ke bawah ke kelipatan 32 terdekat yaitu 96x96
      expect(result.width, equals(96));
      expect(result.height, equals(96));
      
      // Ukuran tensor harus (1 * 96 * 96 * 3)
      expect(result.tensorData.length, equals(1 * 96 * 96 * 3));
      
      // Karena format NHWC, indeks pertama adalah R, kedua G, ketiga B.
      // Warna merah (255, 0, 0) dinormalisasi menjadi (1.0, 0.0, 0.0)
      expect(result.tensorData[0], closeTo(1.0, 0.1)); // R
      expect(result.tensorData[1], closeTo(0.0, 0.1)); // G
      expect(result.tensorData[2], closeTo(0.0, 0.1)); // B
    });

    test('Deblurring model menggunakan format NCHW dan kelipatan 32', () {
      final result = preprocessor.preprocess(dummyImageBytes, ModelType.deblurring);


      expect(result.width, equals(96));
      expect(result.height, equals(96));

      // NCHW menumpuk semua R, lalu semua G, lalu semua B.
      // Jadi tensor indeks 0 sampai (96*96 - 1) adalah R (1.0)
      // Tensor indeks (96*96) sampai selesai adalah G/B (0.0)
      final pixelsCount = 96 * 96;
      expect(result.tensorData[0], closeTo(1.0, 0.1)); // R pixel pertama
      expect(result.tensorData[pixelsCount - 1], closeTo(1.0, 0.1)); // R pixel terakhir
      expect(result.tensorData[pixelsCount], closeTo(0.0, 0.1)); // G pixel pertama
    });
  });
}
