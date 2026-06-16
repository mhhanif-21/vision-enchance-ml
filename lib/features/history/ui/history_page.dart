// Halaman History Gallery — menampilkan grid foto hasil restorasi dengan filter chip.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gal/gal.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../bloc/history_bloc.dart';
import '../models/restoration_entity.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          final items = state is HistoryLoaded ? state.filteredItems : <RestorationEntity>[];
          final activeFilter = state is HistoryLoaded ? state.activeFilter : null;

          return CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(child: _FilterChips(activeFilter: activeFilter)),
              if (state is HistoryLoading)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.accent)))
              else if (items.isEmpty)
                const SliverFillRemaining(child: _EmptyState())
              else
                _buildGrid(context, items),
            ],
          );
        },
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      pinned: true,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gallery', style: AppTypography.headlineLg.copyWith(color: AppColors.onSurface, fontSize: 28)),
            Text('Arsip kenangan Anda yang terestorasi.', style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<RestorationEntity> items) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 4 / 6,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _HistoryCard(entity: items[index]),
          childCount: items.length,
        ),
      ),
    );
  }
}

// Filter chip horizontal scrollable.
class _FilterChips extends StatelessWidget {
  final String? activeFilter;
  const _FilterChips({this.activeFilter});

  @override
  Widget build(BuildContext context) {
    final filters = [
      (null, 'Semua'),
      ('deblurring', 'Blur'),
      ('lowLight', 'Low Light'),
    ];

    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final (filter, label) = filters[index];
          final isActive = activeFilter == filter;
          return GestureDetector(
              onTap: () => context.read<HistoryBloc>().add(FilterHistory(filter)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.secondaryContainer : AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                label,
                style: AppTypography.labelMd.copyWith(
                  color: isActive ? AppColors.onSecondaryContainer : AppColors.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Kartu item gallery dengan hover animation.
class _HistoryCard extends StatefulWidget {
  final RestorationEntity entity;
  const _HistoryCard({required this.entity});

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) {
        setState(() => _hovered = false);
        context.push('/restoration-detail', extra: widget.entity);
      },
      onTapCancel: () => setState(() => _hovered = false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              transform: Matrix4.translationValues(0, _hovered ? -8 : 0, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: _hovered ? 0.12 : 0.05),
                    blurRadius: _hovered ? 30 : 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Restored image
                    Image.file(
                      File(widget.entity.restoredImagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: AppColors.surfaceContainerLow,
                        child: const Icon(Icons.broken_image_outlined, color: AppColors.outline, size: 40),
                      ),
                    ),
                    // Badge "Restored" glassmorphism
                    Positioned(
                      top: 12,
                      right: 12,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          color: Colors.white.withValues(alpha: 0.75),
                          child: Text(
                            'Restored',
                            style: AppTypography.bodySm.copyWith(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Title dan date
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.entity.modelType == 'deblurring' ? 'Perbaikan Blur' : 'Peningkatan Low-Light',
                        style: AppTypography.headlineMd.copyWith(fontSize: 15, color: AppColors.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Direstorasi ${DateFormat('d MMM yyyy', 'id').format(widget.entity.createdAt)}',
                        style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.download_outlined, color: AppColors.secondary),
                  onPressed: () async {
                    try {
                      final hasAccess = await Gal.requestAccess();
                      if (hasAccess) {
                        final bytes = await File(widget.entity.restoredImagePath).readAsBytes();
                        await Gal.putImageBytes(bytes, album: 'Lumina');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Berhasil disimpan ke Galeri HP')),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Izin galeri ditolak.')),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal menyimpan: $e')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_toggle_off_outlined, size: 72, color: AppColors.outlineVariant),
          const SizedBox(height: 16),
          Text('Belum ada riwayat', style: AppTypography.headlineMd.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text('Foto yang Anda restorasi akan muncul di sini.', style: AppTypography.bodySm.copyWith(color: AppColors.outline), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
