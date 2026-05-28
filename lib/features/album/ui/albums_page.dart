// File ini menampilkan halaman utama daftar Album.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../bloc/album_bloc.dart';
import '../../models/album_entity.dart';

class AlbumsPage extends StatelessWidget {
  const AlbumsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Album Anda'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined),
            onPressed: () => _showCreateAlbumDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<AlbumBloc, AlbumState>(
        builder: (context, state) {
          if (state is AlbumLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          } else if (state is AlbumError) {
            return Center(child: Text(state.message));
          } else if (state is AlbumLoaded) {
            if (state.albums.isEmpty) {
              return _buildEmptyState(context);
            }
            return GridView.builder(
              padding: const EdgeInsets.all(24.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: state.albums.length,
              itemBuilder: (context, index) {
                final album = state.albums[index];
                return _buildAlbumCard(context, album);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // UI saat belum ada album
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.photo_album_outlined, size: 80, color: AppColors.outline),
          const SizedBox(height: 16),
          Text(
            'Belum ada album',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  // UI untuk kartu album
  Widget _buildAlbumCard(BuildContext context, AlbumEntity album) {
    return GestureDetector(
      onTap: () {
        context.push('/album-detail', extra: album);
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.tertiary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Icon(
                  Icons.folder_copy_outlined,
                  size: 48,
                  color: AppColors.secondary.withOpacity(0.5),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${album.restorationIds.length} Foto',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog untuk membuat album baru
  void _showCreateAlbumDialog(BuildContext context) {
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
                }
              },
              child: const Text('Buat'),
            ),
          ],
        );
      },
    );
  }
}
