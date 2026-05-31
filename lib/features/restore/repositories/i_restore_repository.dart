// Kontrak antarmuka untuk operasi restorasi gambar.
// Mendukung callback progress agar UI dapat memperbarui tahap secara real-time.
import 'dart:typed_data';
import '../../../../core/constants/model_config.dart';
import '../models/restoration_result.dart';
import '../../restore/bloc/restore_bloc.dart';

abstract class IRestoreRepository {
  // Menjalankan restorasi AI dan melaporkan tahap melalui callback opsional.
  Future<RestorationResult> restoreImage(
    Uint8List imageBytes,
    ModelType modelType, {
    void Function(RestorationStep step)? onStepChanged,
  });
}
