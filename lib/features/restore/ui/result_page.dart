/// Halaman Result. Menampilkan perbandingan gambar sebelum dan sesudah direstorasi.
/// Memungkinkan pengguna untuk melihat secara detail dan menyimpannya.
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../services/ml/onnx_inference_service.dart';
import '../../../../services/storage/file_storage_service.dart';
import '../../../../core/di/injection.dart';
import '../../../history/bloc/history_bloc.dart';
import '../../../history/models/restoration_entity.dart';
import '../../../album/bloc/album_bloc.dart';
import '../../models/restoration_result.dart';

class ResultPage extends StatefulWidget {
  final RestorationResult result;

  const ResultPage({super.key, required this.result});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _showOriginal = false;
  bool _isSaving = false;

  Future<void> _saveResult({String? albumId}) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final storage = sl<FileStorageService>();
      final uuid = const Uuid().v4();
      
      // Menyimpan file menggunakan FileStorageService
      final originalPath = await storage.saveOriginal(uuid, widget.result.originalBytes);
      final restoredPath = await storage.saveRestored(uuid, widget.result.restoredBytes);

      // Membuat model data untuk disimpan ke Hive
      final entity = RestorationEntity(
        id: uuid,
        originalImagePath: originalPath,
        restoredImagePath: restoredPath,
        modelType: widget.result.modelType.name,
        createdAt: DateTime.now(),
      );

      // Menyimpan ke database melalui BLoC
      if (mounted) {
        context.read<HistoryBloc>().add(SaveHistory(entity));
        
        // Jika user memilih album, tambahkan ke album tersebut
        if (albumId != null) {
          context.read<AlbumBloc>().add(AddRestorationToAlbum(
                albumId: albumId,
                restorationId: uuid,
              ));
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gambar berhasil disimpan!')),
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

  // Menampilkan BottomSheet untuk memilih album
  void _showSaveOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return BlocBuilder<AlbumBloc, AlbumState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Simpan ke...',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Riwayat Saja'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _saveResult();
                    },
                  ),
                  const Divider(),
                  if (state is AlbumLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (state is AlbumLoaded && state.albums.isNotEmpty)
                    ...state.albums.map((album) => ListTile(
                          leading: const Icon(Icons.photo_album),
                          title: Text(album.name),
                          onTap: () {
                            Navigator.pop(ctx);
                            _saveResult(albumId: album.id);
                          },
                        )),
                  if (state is AlbumLoaded && state.albums.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Belum ada album.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showCreateAlbumDialog();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Buat Album Baru'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Menampilkan dialog untuk membuat album baru sebelum menyimpan
  void _showCreateAlbumDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Buat Album Baru'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Nama Album',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  context.read<AlbumBloc>().add(CreateAlbum(name));
                  Navigator.pop(ctx);
                  // Setelah buat album, tampilkan opsi save lagi
                  _showSaveOptions();
                }
              },
              child: const Text('Buat'),
            ),
          ],
        );
      },
    );
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
              onPressed: _isSaving ? null : _showSaveOptions,
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
