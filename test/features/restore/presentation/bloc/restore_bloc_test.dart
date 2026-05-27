/// Unit testing untuk menguji logika proses restorasi gambar di RestoreBloc.
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vision_enchance_ml/services/ml/onnx_inference_service.dart';
import 'package:vision_enchance_ml/core/constants/model_config.dart';
import 'package:vision_enchance_ml/features/restore/presentation/bloc/restore_bloc.dart';

class MockInferenceService extends Mock implements OnnxInferenceService {}

class FakeRestorationResult extends Fake implements RestorationResult {}

void main() {
  late RestoreBloc restoreBloc;
  late MockInferenceService mockInferenceService;

  setUpAll(() {
    // Registrasi nilai default untuk keperluan Mocktail (any)
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(ModelType.lowLight);
  });

  setUp(() {
    mockInferenceService = MockInferenceService();
    restoreBloc = RestoreBloc(inferenceService: mockInferenceService);
  });

  tearDown(() {
    restoreBloc.close();
  });

  group('RestoreBloc Tests', () {
    final dummyBytes = Uint8List.fromList([1, 2, 3]);
    final fakeResult = FakeRestorationResult();

    test('State pertama harus berupa RestoreInitial', () {
      expect(restoreBloc.state, equals(RestoreInitial()));
    });

    test('StartRestoration menghasilkan [RestoreProcessing, RestoreSuccess] jika berhasil', () async {
      // Mock agar inferenceService berhasil mengembalikan data simulasi
      when(() => mockInferenceService.restore(
            imageBytes: any(named: 'imageBytes'),
            modelType: any(named: 'modelType'),
          )).thenAnswer((_) async => fakeResult);

      final expectedStates = [
        RestoreProcessing(),
        RestoreSuccess(fakeResult),
      ];

      expectLater(restoreBloc.stream, emitsInOrder(expectedStates));

      restoreBloc.add(StartRestoration(
        imageBytes: dummyBytes,
        modelType: ModelType.lowLight,
      ));
    });

    test('StartRestoration menghasilkan [RestoreProcessing, RestoreFailure] jika terjadi error', () async {
      // Mock agar inferenceService melemparkan error
      when(() => mockInferenceService.restore(
            imageBytes: any(named: 'imageBytes'),
            modelType: any(named: 'modelType'),
          )).thenThrow(Exception('Simulasi Error OOM'));

      final expectedStates = [
        RestoreProcessing(),
        const RestoreFailure('Proses restorasi gagal: Exception: Simulasi Error OOM'),
      ];

      expectLater(restoreBloc.stream, emitsInOrder(expectedStates));

      restoreBloc.add(StartRestoration(
        imageBytes: dummyBytes,
        modelType: ModelType.lowLight,
      ));
    });

    test('ResetRestoration mengembalikan state ke RestoreInitial', () {
      final expectedStates = [RestoreInitial()];

      expectLater(restoreBloc.stream, emitsInOrder(expectedStates));

      restoreBloc.add(ResetRestoration());
    });
  });
}
