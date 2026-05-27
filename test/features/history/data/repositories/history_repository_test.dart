/// Unit test untuk memastikan operasi baca/tulis ke database Hive berfungsi dengan baik.
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vision_enchance_ml/features/history/data/models/restoration_model.dart';
import 'package:vision_enchance_ml/features/history/data/repositories/history_repository_impl.dart';

void main() {
  late HistoryRepositoryImpl repository;

  setUpAll(() async {
    // Inisialisasi Hive di folder temporary khusus untuk keperluan testing
    final tempDir = Directory.systemTemp.createTempSync('hive_testing');
    Hive.init(tempDir.path);
    Hive.registerAdapter(RestorationModelAdapter());
    await Hive.openBox<RestorationModel>(HistoryRepositoryImpl.boxName);
  });

  setUp(() async {
    repository = HistoryRepositoryImpl();
    await repository.clearAllHistory(); // Kosongkan database sebelum setiap test
  });

  tearDownAll(() async {
    await Hive.close();
  });

  group('HistoryRepositoryImpl Tests', () {
    test('Berhasil menyimpan dan mengambil history restorasi', () async {
      final model = RestorationModel(
        id: 'test_123',
        originalImagePath: '/path/ori.jpg',
        restoredImagePath: '/path/res.jpg',
        modelType: 'lowLight',
        createdAt: DateTime.now(),
      );

      await repository.saveRestoration(model);
      final history = await repository.getAllHistory();

      expect(history.length, equals(1));
      expect(history.first.id, equals('test_123'));
      expect(history.first.modelType, equals('lowLight'));
    });

    test('Berhasil menghapus history berdasarkan ID', () async {
      final model = RestorationModel(
        id: 'test_delete',
        originalImagePath: '/path/ori.jpg',
        restoredImagePath: '/path/res.jpg',
        modelType: 'deblurring',
        createdAt: DateTime.now(),
      );

      await repository.saveRestoration(model);
      await repository.deleteHistory('test_delete');
      
      final history = await repository.getAllHistory();
      expect(history.isEmpty, isTrue);
    });
  });
}
