// File ini menampilkan isi dari satu album (detail foto di dalamnya).
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../models/album_entity.dart';
import '../bloc/album_bloc.dart';
import '../../history/bloc/history_bloc.dart';

class AlbumDetailPage extends StatelessWidget {
  final AlbumEntity album;

  const AlbumDetailPage({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(album.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () {
              // Menghapus album
              context.read<AlbumBloc>().add(DeleteAlbum(album.id));
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoaded) {
            // Memfilter history berdasarkan ID yang ada di dalam album
            final photosInAlbum = state.historyList
                .where((item) => album.restorationIds.contains(item.id))
                .toList();

            if (photosInAlbum.isEmpty) {
              return Center(
                child: Text(
                  'Album ini masih kosong',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(24.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: photosInAlbum.length,
              itemBuilder: (context, index) {
                final photo = photosInAlbum[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    File(photo.restoredImagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.outline,
                      child: const Icon(Icons.broken_image, color: Colors.white),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
