import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../../app/theme/app_colors.dart';
import '../../../../services/storage/file_storage_service.dart';
import '../../../../core/di/injection.dart';
import '../bloc/restore_bloc.dart';
import '../bloc/restore_event.dart';
import '../bloc/restore_state.dart';
import '../widgets/before_after_slider.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RestoreBloc, RestoreState>(
      builder: (context, state) {
        if (state is! RestoreSuccess) {
          return const Scaffold(body: Center(child: Text('No result')));
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Hasil Restorasi'),
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                context.read<RestoreBloc>().add(const RestoreReset());
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: BeforeAfterSlider(
                      beforeImage: state.originalBytes,
                      afterImage: state.restoredBytes,
                    ),
                  ),
                ),
                _buildMetadata(context, state),
                _buildActions(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetadata(BuildContext context, RestoreSuccess state) {
    final seconds = (state.processingTimeMs / 1000).toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMetaItem(context, Icons.auto_fix_high_rounded, state.modelType.displayName),
            _buildMetaItem(context, Icons.timer_outlined, '${seconds}s'),
            _buildMetaItem(context, Icons.photo_size_select_actual_outlined, '${state.inputWidth}×${state.inputHeight}'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaItem(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildActions(BuildContext context, RestoreSuccess state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _saveToGallery(context, state),
              icon: const Icon(Icons.save_alt_rounded, size: 18),
              label: Text('Simpan', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () => _shareResult(context, state),
            child: const Icon(Icons.share_rounded, size: 20),
          ),
        ],
      ),
    );
  }

  Future<void> _saveToGallery(BuildContext context, RestoreSuccess state) async {
    try {
      final storage = sl<FileStorageService>();
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      await storage.saveRestored(id, state.restoredBytes);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Foto berhasil disimpan'),
            backgroundColor: AppColors.secondary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _shareResult(BuildContext context, RestoreSuccess state) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/lumina_restored_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(state.restoredBytes);
      await Share.shareXFiles([XFile(file.path)], text: 'Restored with Lumina Restore');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membagikan: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}
