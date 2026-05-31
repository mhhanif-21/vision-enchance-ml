// Halaman Hasil Restorasi.
// Menampilkan before/after slider dan aksi simpan/bagikan.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
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

  // Menyimpan hasil ke file dan database melalui SaveRestorationUseCase.
  Future<RestorationEntity?> _saveResult() async {
    if (_isSaving) return null;
    setState(() => _isSaving = true);

    try {
      final entity = await sl<SaveRestorationUseCase>().execute(widget.result);
      if (mounted) {
        context.read<HistoryBloc>().add(SaveHistory(entity));
      }
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

  // Menyimpan kemudian menampilkan bottom sheet pilihan album.
  void _onSaveToAlbum() async {
    final entity = await _saveResult();
    if (entity == null || !mounted) return;
    _showAlbumSheet(entity);
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

  void _showSaveOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Simpan ke...', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Riwayat Saja'),
              onTap: () { Navigator.pop(context); _onSaveToHistory(); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_album_outlined),
              title: const Text('Pilih Album'),
              onTap: () { Navigator.pop(context); _onSaveToAlbum(); },
            ),
          ],
        ),
      ),
    );
  }

  void _showAlbumSheet(RestorationEntity entity) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => BlocBuilder<AlbumBloc, AlbumState>(
        builder: (context, state) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pilih Album', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              if (state is AlbumLoading)
                const Center(child: CircularProgressIndicator())
              else if (state is AlbumLoaded) ...[
                if (state.albums.isEmpty)
                  Text('Belum ada album.', style: Theme.of(context).textTheme.bodyMedium),
                ...state.albums.map((album) => ListTile(
                      leading: const Icon(Icons.photo_album),
                      title: Text(album.name),
                      subtitle: Text('${album.restorationIds.length} foto'),
                      onTap: () {
                        context.read<AlbumBloc>().add(AddRestorationToAlbum(
                              albumId: album.id,
                              restorationId: entity.id,
                              thumbnailPath: entity.thumbnailPath,
                            ));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Ditambahkan ke album "${album.name}"')),
                        );
                        context.go('/');
                      },
                    )),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () { Navigator.pop(ctx); _showCreateAlbumDialog(entity); },
                  icon: const Icon(Icons.add),
                  label: const Text('Buat Album Baru'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateAlbumDialog(RestorationEntity entity) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Buat Album Baru'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nama Album'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                context.read<AlbumBloc>().add(CreateAlbum(name));
                Navigator.pop(ctx);
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted) _showAlbumSheet(entity);
                });
              }
            },
            child: const Text('Buat'),
          ),
        ],
      ),
    );
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
                  beforeImage: Image.memory(widget.result.originalBytes, fit: BoxFit.cover),
                  afterImage: Image.memory(widget.result.restoredBytes, fit: BoxFit.cover),
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
            Text(
              'Waktu proses: ${widget.result.processingTimeMs} ms  ·  ${widget.result.modelType.displayName}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            // Tombol simpan utama.
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _showSaveOptions,
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
          ],
        ),
      ),
    );
  }
}
