// Use case untuk menyimpan hasil restorasi ke file dan database Hive.
// Menggabungkan FileStorageService + HistoryRepository dalam satu operasi atomik.
import 'package:uuid/uuid.dart';
import '../models/restoration_result.dart';
import '../../history/models/restoration_entity.dart';
import '../../history/repositories/i_history_repository.dart';
import '../../../services/storage/file_storage_service.dart';

class SaveRestorationUseCase {
  final FileStorageService storageService;
  final IHistoryRepository historyRepository;

  SaveRestorationUseCase({
    required this.storageService,
    required this.historyRepository,
  });

  // Menyimpan file ke disk dan metadata ke Hive, mengembalikan entitas yang disimpan.
  Future<RestorationEntity> execute(RestorationResult result) async {
    final id = const Uuid().v4();

    final originalPath = await storageService.saveOriginal(id, result.originalBytes);
    final restoredPath = await storageService.saveRestored(id, result.restoredBytes);
    final thumbnailPath = await storageService.saveThumbnail(id, result.restoredBytes);

    final entity = RestorationEntity(
      id: id,
      originalImagePath: originalPath,
      restoredImagePath: restoredPath,
      thumbnailPath: thumbnailPath,
      modelType: result.modelType.name,
      createdAt: DateTime.now(),
      processingTimeMs: result.processingTimeMs,
      outputWidth: result.outputWidth,
      outputHeight: result.outputHeight,
    );

    await historyRepository.saveRestoration(entity);
    return entity;
  }
}
