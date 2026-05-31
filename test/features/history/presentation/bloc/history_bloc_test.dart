// Unit test untuk HistoryBloc — menguji state transition saat load dan delete riwayat.
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vision_enchance_ml/features/history/repositories/i_history_repository.dart';
import 'package:vision_enchance_ml/features/history/repositories/manage_history_usecase.dart';
import 'package:vision_enchance_ml/features/history/bloc/history_bloc.dart';
import 'package:vision_enchance_ml/features/history/models/restoration_entity.dart';

// Mock implements interface agar tidak bergantung pada implementasi Hive.
class MockHistoryRepository extends Mock implements IHistoryRepository {}

void main() {
  late HistoryBloc historyBloc;
  late MockHistoryRepository mockRepository;

  setUp(() {
    mockRepository = MockHistoryRepository();
    historyBloc = HistoryBloc(
      useCase: ManageHistoryUseCase(mockRepository),
    );
  });

  tearDown(() {
    historyBloc.close();
  });

  group('HistoryBloc Tests', () {
    final tEntity = RestorationEntity(
      id: '1',
      originalImagePath: '/ori.jpg',
      restoredImagePath: '/res.jpg',
      thumbnailPath: '/thumb.jpg',
      modelType: 'lowLight',
      createdAt: DateTime(2025, 1, 1),
      processingTimeMs: 1000,
      outputWidth: 512,
      outputHeight: 512,
    );
    final tList = [tEntity];

    test('State pertama harus berupa HistoryLoading', () {
      expect(historyBloc.state, equals(HistoryLoading()));
    });

    test('LoadHistory menghasilkan HistoryLoaded saat sukses', () async {
      when(() => mockRepository.getAllHistory()).thenAnswer((_) async => tList);

      expectLater(
        historyBloc.stream,
        emitsInOrder([
          HistoryLoading(),
          isA<HistoryLoaded>().having((s) => s.allItems.length, 'length', 1),
        ]),
      );

      historyBloc.add(LoadHistory());
    });

    test('DeleteHistory memanggil repository lalu reload', () async {
      when(() => mockRepository.deleteHistory(any())).thenAnswer((_) async {});
      when(() => mockRepository.getAllHistory()).thenAnswer((_) async => []);

      historyBloc.add(const DeleteHistory('1'));
      await Future.delayed(const Duration(milliseconds: 200));

      verify(() => mockRepository.deleteHistory('1')).called(1);
      verify(() => mockRepository.getAllHistory()).called(greaterThan(0));
    });
  });
}
