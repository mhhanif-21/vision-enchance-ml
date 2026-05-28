// File ini mendefinisikan antarmuka (interface) untuk proses restorasi gambar.
// Implementasinya akan berada di ML Service layer.
import 'dart:typed_data';
import '../../../../core/constants/model_config.dart';
import '../entities/restoration_result.dart';

abstract class IRestoreRepository {
  // Menjalankan proses restorasi AI dan mengembalikan hasil lengkap beserta metadata
  Future<RestorationResult> restoreImage(Uint8List imageBytes, ModelType modelType);
}
