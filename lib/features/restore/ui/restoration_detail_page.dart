import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../history/bloc/history_bloc.dart';
import '../../history/models/restoration_entity.dart';
import '../../../../core/widgets/before_after_slider.dart';

class RestorationDetailPage extends StatelessWidget {
  final RestorationEntity entity;
  const RestorationDetailPage({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumb
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  Text('Riwayat', style: AppTypography.bodySm.copyWith(color: AppColors.outline)),
                  const Icon(Icons.chevron_right, size: 16, color: AppColors.outline),
                  Text(
                    entity.modelType,
                    style: AppTypography.bodySm.copyWith(color: AppColors.accent),
                  ),
                ],
              ),
            ),
            // Title + badges
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entity.modelType == 'deblurring' ? 'Perbaikan Blur' : 'Peningkatan Low-Light',
                    style: AppTypography.headlineXl.copyWith(color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _BadgeChip(label: entity.modelType, color: AppColors.surfaceContainerHigh),
                      _BadgeChip(label: 'Lumina AI', color: AppColors.secondaryContainer),
                    ],
                  ),
                ],
              ),
            ),
            // Action buttons row
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Share.shareXFiles([XFile(entity.restoredImagePath)]),
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: const Text('Bagikan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: const BorderSide(color: AppColors.secondary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: const Text('Simpan Foto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.onSecondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                      shadowColor: AppColors.secondary.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
            // Before/After slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: BeforeAfterSlider(
                    beforeImage: Image.file(File(entity.originalImagePath), fit: BoxFit.cover, width: double.infinity),
                    afterImage: Image.file(File(entity.restoredImagePath), fit: BoxFit.cover, width: double.infinity),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Metadata card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _MetadataCard(entity: entity),
            ),
            const SizedBox(height: 32),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFFDFCF8),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.primary),
        onPressed: () => context.pop(),
      ),
      title: Text('Restore Detail', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onBackground)),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
          onPressed: () => _confirmDelete(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Restorasi?'),
        content: const Text('Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              context.read<HistoryBloc>().add(DeleteHistory(entity.id));
              Navigator.pop(ctx);
              context.pop();
            },
            child: Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// Chip badge untuk model type dan engine.
class _BadgeChip extends StatelessWidget {
  final String label;
  final Color color;
  const _BadgeChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(99)),
      child: Text(label.toUpperCase(), style: AppTypography.labelMd.copyWith(fontSize: 11, letterSpacing: 1)),
    );
  }
}

// Kartu metadata teknikal proses restorasi.
class _MetadataCard extends StatelessWidget {
  final RestorationEntity entity;
  const _MetadataCard({required this.entity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DETAIL TEKNIKAL', style: AppTypography.labelMd.copyWith(color: AppColors.accent, letterSpacing: 2)),
          const SizedBox(height: 6),
          Text('Pipeline Pemrosesan', style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface)),
          const SizedBox(height: 20),
          _MetaRow(label: 'Tanggal Restorasi', value: _formatDate(entity.createdAt)),
          _MetaRow(label: 'Tipe Model', value: entity.modelType),
          _MetaRow(label: 'Waktu Proses', value: '${entity.processingTimeMs}ms'),
          _MetaRow(
            label: 'Resolusi Output',
            value: '${entity.outputWidth} × ${entity.outputHeight}',
            isLast: true,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _MetaRow({required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
              Text(value, style: AppTypography.labelMd.copyWith(color: AppColors.onSurface)),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: AppColors.outline.withValues(alpha: 0.1)),
      ],
    );
  }
}
