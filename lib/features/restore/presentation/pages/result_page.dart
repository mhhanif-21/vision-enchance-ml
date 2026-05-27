/// Halaman Result. Menampilkan perbandingan gambar sebelum dan sesudah direstorasi.
/// Memungkinkan pengguna untuk melihat secara detail dan menyimpannya.
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../services/ml/onnx_inference_service.dart';
import '../../../history/presentation/bloc/history_bloc.dart';
import '../../../history/data/models/restoration_model.dart';

class ResultPage extends StatefulWidget {
  final RestorationResult result;

  const ResultPage({super.key, required this.result});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _showOriginal = false;
  bool _isSaving = false;

  // Fungsi untuk menyimpan gambar hasil restorasi ke direktori lokal (memori internal).
  // Kemudian mencatat path-nya ke dalam database Hive melalui HistoryBloc.
  Future<void> _saveResult() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      // Mendapatkan direktori internal aplikasi
      final appDir = await getApplicationDocumentsDirectory();
      final uuid = const Uuid().v4();
      
      // Menyimpan file gambar asli
      final originalFile = File('${appDir.path}/ori_$uuid.jpg');
      await originalFile.writeAsBytes(widget.result.originalBytes);
      
      // Menyimpan file gambar hasil restorasi
      final restoredFile = File('${appDir.path}/res_$uuid.jpg');
      await restoredFile.writeAsBytes(widget.result.restoredBytes);

      // Membuat model data untuk disimpan ke Hive
      final model = RestorationModel(
        id: uuid,
        originalImagePath: originalFile.path,
        restoredImagePath: restoredFile.path,
        modelType: widget.result.strategy.name,
        createdAt: DateTime.now(),
      );

      // Menyimpan ke database melalui BLoC
      if (mounted) {
        context.read<HistoryBloc>().add(SaveHistory(model));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gambar berhasil disimpan ke History!')),
        );
        // Kembali ke halaman utama setelah sukses
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan gambar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menentukan gambar mana yang sedang ditampilkan (Asli vs Restorasi)
    final Uint8List displayBytes = _showOriginal
        ? widget.result.originalBytes
        : widget.result.restoredBytes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Restorasi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                // Jika user menahan gambar, tampilkan gambar aslinya (Before)
                onTapDown: (_) => setState(() => _showOriginal = true),
                onTapUp: (_) => setState(() => _showOriginal = false),
                onTapCancel: () => setState(() => _showOriginal = false),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.memory(
                      displayBytes,
                      fit: BoxFit.contain,
                      gaplessPlayback: true, // Mencegah flicker saat toggle
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _showOriginal ? 'SEBELUM (Tahan untuk melihat)' : 'SESUDAH',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.secondary,
                    letterSpacing: 2.0,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Waktu Proses: ${widget.result.processingTimeMs} ms',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveResult,
              icon: _isSaving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save_alt),
              label: Text(_isSaving ? 'Menyimpan...' : 'Simpan & Selesai'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
