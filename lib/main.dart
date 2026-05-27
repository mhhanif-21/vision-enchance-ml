/// Entry point aplikasi Lumina Restore.
/// Menginisialisasi service, repository, dan BLoC Provider sebelum UI dijalankan.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/storage/hive_setup.dart';
import 'core/di/injection.dart';
import 'features/history/presentation/bloc/history_bloc.dart';
import 'features/restore/presentation/bloc/restore_bloc.dart';
import 'app/app.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Menginisialisasi penyimpanan lokal (Hive)
  await HiveSetup.init();
  
  // Menginisialisasi dependencies via GetIt
  await initDependencies();

  // Menjalankan aplikasi dengan MultiBlocProvider agar state dapat diakses secara global
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<HistoryBloc>()..add(LoadHistory()),
        ),
        BlocProvider(
          create: (_) => sl<RestoreBloc>(),
        ),
      ],
      child: const LuminaRestoreApp(),
    ),
  );
}
