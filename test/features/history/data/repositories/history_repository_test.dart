// Unit test untuk operasi baca/tulis riwayat restorasi ke database Hive.
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vision_enchance_ml/features/history/models/restoration_entity.dart';
import 'package:vision_enchance_ml/features/history/models/restoration_model.dart';
import 'package:vision_enchance_ml/features/history/repositories/history_repository_impl.dart';

void main() {
  late HistoryRepositoryImpl repository;

  setUpAll(() async {
    final tempDir = Directory.systemTemp.createTempSync('hive_testing');
    Hive.init(tempDir.path);
    Hive.registerAdapter(RestorationModelAdapter());
    await Hive.openBox<RestorationModel>(HistoryRepositoryImpl.boxName);
  });

  setUp(() async {
    repository = HistoryRepositoryImpl();
    await repository.clearAllHistory();
  });

  tearDownAll(() async {
    await Hive.close();
  });

  group('HistoryRepositoryImpl Tests', () {
    test('Berhasil menyimpan dan mengambil history restorasi', () async {
      final entity = _buildTestEntity('test_123', 'lowLight');

      await repository.saveRestoration(entity);
      final history = await repository.getAllHistory();

      expect(history.length, equals(1));
      expect(history.first.id, equals('test_123'));
      expect(history.first.modelType, equals('lowLight'));
    });

    test('Berhasil menghapus history berdasarkan ID', () async {
      final entity = _buildTestEntity('test_delete', 'deblurring');

      await repository.saveRestoration(entity);
      await repository.deleteHistory('test_delete');

      final history = await repository.getAllHistory();
      expect(history.isEmpty, isTrue);
    });
  });
}

// Helper untuk membuat entitas test tanpa duplikasi kode.
RestorationEntity _buildTestEntity(String id, String modelType) {
  // Buat via RestorationModel karena entity tidak punya factory fromMap.
  return RestorationModel(
    id: id,
    originalImagePath: '/path/ori.jpg',
    restoredImagePath: '/path/res.jpg',
    modelType: modelType,
    createdAt: DateTime.now(),
  ).toEntity();
}
