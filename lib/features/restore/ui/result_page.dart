// Halaman Hasil Restorasi.
// Menampilkan before/after slider dan aksi simpan/bagikan.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import '../../settings/bloc/settings_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/before_after_slider.dart';
import '../../history/bloc/history_bloc.dart';
import '../../album/bloc/album_bloc.dart';
import '../models/restoration_result.dart';
import '../repositories/save_restoration_usecase.dart';
import '../../history/models/restoration_entity.dart';

class ResultPage extends StatefulWidget {
  final RestorationResult result;

  const ResultPage({super.key, required this.result});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _isSaving = false;
  bool _hasSaved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsState = context.read<SettingsBloc>().state;
      if (settingsState.settings.isAutoSave) {
        _saveResult().then((_) {
          if (mounted && _hasSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tersimpan otomatis.')),
            );
          }
        });
      }
    });
  }

  // Menyimpan hasil ke file dan database melalui SaveRestorationUseCase.
  Future<RestorationEntity?> _saveResult() async {
    if (_isSaving || _hasSaved) return null;
    setState(() => _isSaving = true);

    try {
      final entity = await sl<SaveRestorationUseCase>().execute(widget.result);
      if (mounted) {
        context.read<HistoryBloc>().add(SaveHistory(entity));
      }
      _hasSaved = true;
      return entity;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: AppColors.error),
        );
      }
      return null;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Menyimpan gambar ke galeri HP pengguna.
  Future<void> _onDownload() async {
    try {
      final hasAccess = await Gal.requestAccess();
      if (hasAccess) {
        await Gal.putImageBytes(widget.result.restoredBytes, album: 'Lumina');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berhasil disimpan ke Galeri HP')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin akses galeri ditolak.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan ke galeri: $e')),
        );
      }
    }
  }

  // Menyimpan lalu langsung kembali ke beranda.
  void _onSaveToHistory() async {
    await _saveResult();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gambar berhasil disimpan ke riwayat!')),
      );
      context.go('/');
    }
  }

  // Berbagi gambar hasil menggunakan share sheet OS.
  Future<void> _onShare() async {
    try {
      await Share.shareXFiles(
        [XFile.fromData(widget.result.restoredBytes, mimeType: 'image/jpeg', name: 'restored.jpg')],
        subject: 'Hasil Restorasi — Lumina Restore',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal berbagi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hasil Restorasi', style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.go('/')),
        actions: [
          // Tombol berbagi foto hasil.
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: _onShare),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // Area slider before/after.
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: BeforeAfterSlider(
                  beforeImage: Image.memory(widget.result.originalBytes, fit: BoxFit.contain),
                  afterImage: Image.memory(widget.result.restoredBytes, fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Label instruksi slider.
            Text(
              'Geser untuk membandingkan',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.secondary,
                    letterSpacing: 1.5,
                  ),
            ),
            const SizedBox(height: 4),
            // Informasi waktu proses.
            // Informasi waktu proses dan dimensi
            Text(
              'Waktu proses: ${widget.result.processingTimeMs} ms  ·  ${widget.result.modelType.displayName}\nInput: ${widget.result.inputWidth}x${widget.result.inputHeight}  ->  Output: ${widget.result.outputWidth}x${widget.result.outputHeight}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            // Tombol simpan utama.
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _onSaveToHistory,
              icon: _isSaving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save_alt),
              label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Hasil'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.onSecondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            // Tombol download ke galeri.
            OutlinedButton.icon(
              onPressed: _onDownload,
              icon: const Icon(Icons.download),
              label: const Text('Simpan ke Galeri (Download)'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
