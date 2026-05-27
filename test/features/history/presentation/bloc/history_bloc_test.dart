/// Unit testing untuk menguji logika state management HistoryBloc.
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vision_enchance_ml/features/history/data/repositories/history_repository_impl.dart';
import 'package:vision_enchance_ml/features/history/data/models/restoration_model.dart';
import 'package:vision_enchance_ml/features/history/presentation/bloc/history_bloc.dart';

// Membuat tiruan (mock) dari HistoryRepositoryImpl agar tidak perlu mengakses Hive sungguhan.
class MockHistoryRepository extends Mock implements HistoryRepositoryImpl {}

void main() {
  late HistoryBloc historyBloc;
  late MockHistoryRepository mockRepository;

  setUp(() {
    mockRepository = MockHistoryRepository();
    historyBloc = HistoryBloc(repository: mockRepository);
  });

  tearDown(() {
    historyBloc.close();
  });

  group('HistoryBloc Tests', () {
    final tRestorationModel = RestorationModel(
      id: '1',
      originalImagePath: '/ori.jpg',
      restoredImagePath: '/res.jpg',
      modelType: 'lowLight',
      createdAt: DateTime(2025, 1, 1),
    );
    final tHistoryList = [tRestorationModel];

    test('State pertama harus berupa HistoryLoading', () {
      expect(historyBloc.state, equals(HistoryLoading()));
    });

    test('LoadHistory menghasilkan state [HistoryLoading, HistoryLoaded] saat sukses', () async {
      // Mengatur mock untuk mengembalikan tHistoryList ketika dipanggil
      when(() => mockRepository.getAllHistory())
          .thenAnswer((_) async => tHistoryList);

      // Urutan state yang diekspektasikan
      final expectedStates = [
        HistoryLoading(),
        HistoryLoaded(tHistoryList),
      ];

      // Memeriksa stream BLoC
      expectLater(historyBloc.stream, emitsInOrder(expectedStates));

      // Memicu event
      historyBloc.add(LoadHistory());
    });

    test('DeleteHistory memicu proses hapus lalu load ulang (LoadHistory)', () async {
      when(() => mockRepository.deleteHistory(any())).thenAnswer((_) async => {});
      when(() => mockRepository.getAllHistory()).thenAnswer((_) async => []);

      historyBloc.add(const DeleteHistory('1'));

      // Memberi jeda kecil agar proses asynchronous selesai
      await Future.delayed(const Duration(milliseconds: 100));

      // Memverifikasi bahwa metode di repository benar-benar dipanggil
      verify(() => mockRepository.deleteHistory('1')).called(1);
      verify(() => mockRepository.getAllHistory()).called(1);
    });
  });
}
