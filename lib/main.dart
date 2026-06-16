// Entry point aplikasi Lumina Restore.
// Menginisialisasi service, repository, dan BLoC Provider sebelum UI dijalankan.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/storage/hive_setup.dart';
import 'core/di/injection.dart';
import 'features/history/bloc/history_bloc.dart';
import 'features/restore/bloc/restore_bloc.dart';
import 'features/album/bloc/album_bloc.dart';
import 'features/settings/bloc/settings_bloc.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Menginisialisasi locale Indonesia untuk DateFormat
  await initializeDateFormatting('id', null);
  
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
        BlocProvider(
          create: (_) => sl<AlbumBloc>()..add(LoadAlbums()),
        ),
        BlocProvider(
          create: (_) => sl<SettingsBloc>()..add(LoadSettings()),
        ),
      ],
      child: const LuminaRestoreApp(),
    ),
  );
}
