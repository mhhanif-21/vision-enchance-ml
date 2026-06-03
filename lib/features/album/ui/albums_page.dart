// Halaman Albums — menampilkan grid bento dari koleksi album pengguna.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../bloc/album_bloc.dart';
import '../models/album_entity.dart';

class AlbumsPage extends StatelessWidget {
  const AlbumsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<AlbumBloc, AlbumState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              _buildAppBar(context),
              if (state is AlbumLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
                )
              else if (state is AlbumError)
                SliverFillRemaining(child: Center(child: Text(state.message)))
              else if (state is AlbumLoaded) ...[
                if (state.albums.isEmpty)
                  const SliverFillRemaining(child: _EmptyState())
                else
                  _buildAlbumGrid(context, state.albums),
              ] else
                const SliverToBoxAdapter(child: SizedBox.shrink()),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateAlbumDialog(context),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add_a_photo_outlined),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: const Color(0xFFFDFCF8),
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: AppColors.accent.withValues(alpha: 0.05),
      surfaceTintColor: Colors.transparent,
      expandedHeight: 140,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Albums', style: AppTypography.headlineLg.copyWith(color: AppColors.onBackground)),
            Text(
              'Kenangan Anda yang terkurasi.',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumGrid(BuildContext context, List<AlbumEntity> albums) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.78,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == albums.length) return _buildAddNewCard(context);
            return _AlbumCard(album: albums[index]);
          },
          childCount: albums.length + 1,
        ),
      ),
    );
  }

  // Kartu untuk buat album baru.
  Widget _buildAddNewCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCreateAlbumDialog(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.outlineVariant, width: 2, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Text(
              'Album Baru',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateAlbumDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Buat Album Baru'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nama album...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
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
      ),
    );
  }
}

// Kartu album individual dengan cover photo dan info.
class _AlbumCard extends StatefulWidget {
  final AlbumEntity album;
  const _AlbumCard({required this.album});

  @override
  State<_AlbumCard> createState() => _AlbumCardState();
}

class _AlbumCardState extends State<_AlbumCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.push('/album-detail', extra: widget.album),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _hovered ? -6 : 0, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: AppColors.surfaceContainerLow,
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: _hovered ? 0.12 : 0.05),
                blurRadius: _hovered ? 30 : 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: _buildCoverImage(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.album.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.headlineMd.copyWith(fontSize: 16),
                          ),
                        ),
                        Icon(
                          Icons.folder_shared_outlined,
                          size: 18,
                          color: _hovered ? AppColors.accent : AppColors.outline,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.album.restorationIds.length} foto',
                      style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage() {
    final cover = widget.album.coverImagePath;
    if (cover != null && cover.isNotEmpty) {
      return Image.file(
        File(cover),
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholderCover(),
      );
    }
    return _placeholderCover();
  }

  Widget _placeholderCover() {
    return Container(
      color: AppColors.secondaryContainer.withValues(alpha: 0.3),
      child: const Icon(Icons.photo_library_outlined, size: 40, color: AppColors.accent),
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
          const Icon(Icons.photo_album_outlined, size: 80, color: AppColors.outlineVariant),
          const SizedBox(height: 16),
          Text(
            'Belum ada album',
            style: AppTypography.headlineMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            'Buat album untuk mengorganisir foto Anda.',
            style: AppTypography.bodySm.copyWith(color: AppColors.outline),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
