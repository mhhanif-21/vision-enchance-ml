/// Halaman Processing. Menampilkan animasi saat Machine Learning (ONNX) sedang memproses gambar.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/restore_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/model_config.dart';

class ProcessingPage extends StatefulWidget {
  final String imagePath;
  final ModelType modelType;

  const ProcessingPage({
    super.key,
    required this.imagePath,
    required this.modelType,
  });

  @override
  State<ProcessingPage> createState() => _ProcessingPageState();
}

class _ProcessingPageState extends State<ProcessingPage> {
  @override
  void initState() {
    super.initState();
    // Memulai pemrosesan secara otomatis saat layar ini dibuka.
    _startRestoration();
  }

  // Fungsi untuk membaca file gambar menjadi bytes dan mengirimkannya ke BLoC.
  Future<void> _startRestoration() async {
    final imageBytes = await File(widget.imagePath).readAsBytes();
    if (mounted) {
      context.read<RestoreBloc>().add(
            StartRestoration(
              imageBytes: imageBytes,
              modelType: widget.modelType,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<RestoreBloc, RestoreState>(
        listener: (context, state) {
          if (state is RestoreSuccess) {
            // Jika sukses, lempar hasil pemrosesan ke halaman Result dan tutup layar ini.
            context.pushReplacement('/result', extra: state.result);
          } else if (state is RestoreFailure) {
            // Jika gagal, tampilkan notifikasi error dan kembali ke layar Upload.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
            context.pop();
          }
        },
        builder: (context, state) {
          // Menampilkan animasi loading selama proses berlangsung.
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 200,
                    height: 4,
                    child: LinearProgressIndicator(
                      backgroundColor: AppColors.surfaceContainerHigh,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Sedang Merestorasi Foto...',
                    style: Theme.of(context).textTheme.headlineMd,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Mohon tunggu sebentar. AI kami sedang bekerja untuk meningkatkan kualitas foto Anda.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
