/// Halaman History. Menampilkan daftar foto yang pernah direstorasi oleh pengguna.
/// Diambil dari Hive local database menggunakan HistoryBloc.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../bloc/history_bloc.dart';
import '../data/models/restoration_model.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Restorasi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            // Tampilan loading saat memuat data dari database
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          } else if (state is HistoryError) {
            // Tampilan jika terjadi error membaca database
            return Center(child: Text(state.message));
          } else if (state is HistoryLoaded) {
            final historyList = state.historyList;

            // Jika daftar riwayat kosong
            if (historyList.isEmpty) {
              return _buildEmptyState(context);
            }

            // Menampilkan list data dengan ListView
            return ListView.separated(
              padding: const EdgeInsets.all(24.0),
              itemCount: historyList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = historyList[index];
                return _buildHistoryCard(context, item);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // Menampilkan UI ketika riwayat restorasi kosong.
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_toggle_off, size: 80, color: AppColors.outline),
          const SizedBox(height: 16),
          Text(
            'Belum ada riwayat',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  // Membuat kartu UI untuk masing-masing riwayat foto.
  Widget _buildHistoryCard(BuildContext context, RestorationModel item) {
    // Memformat penulisan tanggal
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final formattedDate = dateFormat.format(item.createdAt);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Thumbnail gambar hasil restorasi
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.file(
                File(item.restoredImagePath),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                // Mengantisipasi jika file asli terhapus dari memori HP
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: AppColors.outline,
                  child: const Icon(Icons.broken_image, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.modelType.toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.secondary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            // Tombol hapus history
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () {
                // Menghapus data dari database saat tombol ditekan
                context.read<HistoryBloc>().add(DeleteHistory(item.id));
              },
            )
          ],
        ),
      ),
    );
  }
}
