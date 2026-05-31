// Smoke test dasar — memverifikasi LuminaRestoreApp dapat dimuat tanpa crash.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vision_enchance_ml/features/settings/repositories/i_settings_repository.dart';
import 'package:vision_enchance_ml/features/settings/repositories/manage_settings_usecase.dart';
import 'package:vision_enchance_ml/features/settings/bloc/settings_bloc.dart';
import 'package:vision_enchance_ml/features/settings/models/settings_entity.dart';
import 'package:vision_enchance_ml/app/app.dart';

// Mock interface agar SettingsBloc dapat diinstansiasi tanpa Hive sungguhan.
class MockSettingsRepository extends Mock implements ISettingsRepository {}

void main() {
  testWidgets('LuminaRestoreApp dapat dimuat tanpa crash', (WidgetTester tester) async {
    final mockRepo = MockSettingsRepository();
    when(() => mockRepo.getSettings()).thenAnswer((_) async => SettingsEntity.initial());

    await tester.pumpWidget(
      BlocProvider<SettingsBloc>(
        create: (_) => SettingsBloc(useCase: ManageSettingsUseCase(mockRepo)),
        child: const LuminaRestoreApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
