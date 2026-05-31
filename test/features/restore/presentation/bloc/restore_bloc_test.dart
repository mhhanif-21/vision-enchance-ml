// Unit test untuk RestoreBloc — menguji state transition saat restorasi berhasil dan gagal.
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vision_enchance_ml/features/restore/repositories/i_restore_repository.dart';
import 'package:vision_enchance_ml/features/restore/repositories/restore_image_usecase.dart';
import 'package:vision_enchance_ml/features/restore/bloc/restore_bloc.dart';
import 'package:vision_enchance_ml/features/restore/models/restoration_result.dart';
import 'package:vision_enchance_ml/core/constants/model_config.dart';

// Mock implements interface agar tidak bergantung pada OnnxRuntime sungguhan.
class MockRestoreRepository extends Mock implements IRestoreRepository {}

void main() {
  late RestoreBloc restoreBloc;
  late MockRestoreRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(ModelType.lowLight);
  });

  setUp(() {
    mockRepository = MockRestoreRepository();
    restoreBloc = RestoreBloc(
      useCase: RestoreImageUseCase(mockRepository),
    );
  });

  tearDown(() {
    restoreBloc.close();
  });

  group('RestoreBloc Tests', () {
    final dummyBytes = Uint8List.fromList([1, 2, 3]);

    final fakeResult = RestorationResult(
      modelType: ModelType.lowLight,
      originalBytes: Uint8List(0),
      restoredBytes: Uint8List(0),
      inputWidth: 100,
      inputHeight: 100,
      outputWidth: 96,
      outputHeight: 96,
      processingTimeMs: 500,
    );

    test('State pertama harus berupa RestoreInitial', () {
      expect(restoreBloc.state, equals(RestoreInitial()));
    });

    test('StartRestoration menghasilkan [RestoreProcessing, RestoreSuccess] jika berhasil', () async {
      when(() => mockRepository.restoreImage(
            any(),
            any(),
            onStepChanged: any(named: 'onStepChanged'),
          )).thenAnswer((_) async => fakeResult);

      expectLater(
        restoreBloc.stream,
        emitsInOrder([
          isA<RestoreProcessing>(),
          isA<RestoreProcessing>(),
          isA<RestoreProcessing>(),
          isA<RestoreSuccess>(),
        ]),
      );

      restoreBloc.add(StartRestoration(
        imageBytes: dummyBytes,
        modelType: ModelType.lowLight,
      ));
    });

    test('StartRestoration menghasilkan RestoreFailure jika terjadi error', () async {
      when(() => mockRepository.restoreImage(
            any(),
            any(),
            onStepChanged: any(named: 'onStepChanged'),
          )).thenThrow(Exception('Simulasi Error OOM'));

      expectLater(
        restoreBloc.stream,
        emitsInOrder([
          isA<RestoreProcessing>(),
          isA<RestoreFailure>(),
        ]),
      );

      restoreBloc.add(StartRestoration(
        imageBytes: dummyBytes,
        modelType: ModelType.lowLight,
      ));
    });

    test('ResetRestoration mengembalikan state ke RestoreInitial', () {
      expectLater(restoreBloc.stream, emitsInOrder([RestoreInitial()]));
      restoreBloc.add(ResetRestoration());
    });
  });
}
