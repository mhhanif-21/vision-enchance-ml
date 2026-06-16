// Halaman utama (Dashboard) — menampilkan pilihan restorasi dan aktivitas terbaru.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/model_config.dart';
import '../../history/bloc/history_bloc.dart';
import '../../history/models/restoration_entity.dart';
import '../../history/ui/history_page.dart';
import '../../settings/ui/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  void _switchTab(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _DashboardContent(onSwitchTab: _switchTab),
          const HistoryPage(),
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: _switchTab,
      ),
    );
  }
}

// Widget bottom navigation sesuai desain Stitch.
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4))),
        boxShadow: [
          BoxShadow(
            color: colorScheme.secondary.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Dashboard', index: 0, currentIndex: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.history_outlined, activeIcon: Icons.history, label: 'History', index: 1, currentIndex: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Settings', index: 2, currentIndex: currentIndex, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : icon, color: isActive ? AppColors.accent : AppColors.outline, size: 24),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 0.8,
                color: isActive ? AppColors.accent : AppColors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Konten utama halaman Dashboard.
class _DashboardContent extends StatelessWidget {
  final ValueChanged<int> onSwitchTab;
  const _DashboardContent({required this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header overview
                Text('Overview', style: AppTypography.headlineXl.copyWith(color: colorScheme.onSurface)),
                const SizedBox(height: 8),
                Text(
                  'Pilihan restorasi dan aktivitas terbaru Anda.',
                  style: AppTypography.bodyMd.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 48),
                // Section restoration type
                Text('Pilih Jenis Restorasi', style: AppTypography.headlineLg.copyWith(color: colorScheme.onSurface)),
                const SizedBox(height: 24),
                _RestorationTypeCard(
                  title: 'Perbaiki Blur',
                  subtitle: 'Pertajam subjek yang tidak fokus dan pulihkan detail halus dari blur.',
                  icon: Icons.blur_on_outlined,
                  modelType: ModelType.deblurring,
                ),
                const SizedBox(height: 16),
                _RestorationTypeCard(
                  title: 'Tingkatkan Low-Light',
                  subtitle: 'Cerahkan foto gelap, kurangi noise, dan seimbangkan eksposur.',
                  icon: Icons.wb_sunny_outlined,
                  modelType: ModelType.lowLight,
                ),
                const SizedBox(height: 48),
                // Section recent activity
                _RecentActivitySection(onViewAll: () => onSwitchTab(1)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SliverAppBar(
      pinned: true,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: colorScheme.secondary.withValues(alpha: 0.08),
      title: Text(
        'RESTORATION',
        style: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w300,
          letterSpacing: 5,
          color: colorScheme.onSurface,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.surfaceContainerHigh,
            child: const Icon(Icons.person_outline, size: 18, color: AppColors.outline),
          ),
        ),
      ],
    );
  }
}

// Kartu pilihan jenis restorasi dengan hover animation.
class _RestorationTypeCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final ModelType modelType;

  const _RestorationTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.modelType,
  });

  @override
  State<_RestorationTypeCard> createState() => _RestorationTypeCardState();
}

class _RestorationTypeCardState extends State<_RestorationTypeCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        context.push('/upload', extra: widget.modelType);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
        padding: const EdgeInsets.all(28),
        constraints: const BoxConstraints(minHeight: 160),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _pressed ? colorScheme.outlineVariant : Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: colorScheme.secondary.withValues(alpha: _pressed ? 0.04 : 0.07),
              blurRadius: _pressed ? 10 : 24,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, size: 28, color: colorScheme.primary),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: AppTypography.headlineMd.copyWith(color: colorScheme.onSurface, fontSize: 20)),
                  const SizedBox(height: 6),
                  Text(widget.subtitle, style: AppTypography.bodySm.copyWith(color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: colorScheme.outlineVariant),
          ],
        ),
      ),
    );
  }
}

// Section aktivitas terbaru dari history.
class _RecentActivitySection extends StatelessWidget {
  final VoidCallback onViewAll;
  const _RecentActivitySection({required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        final items = state is HistoryLoaded ? state.filteredItems.take(2).toList() : <RestorationEntity>[];
        final total = state is HistoryLoaded ? state.filteredItems.length : 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text('Aktivitas Terbaru', style: AppTypography.headlineMd.copyWith(color: colorScheme.onSurface)),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onViewAll,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_forward, size: 14, color: colorScheme.secondary),
                      const SizedBox(width: 4),
                      Text('Lihat Semua', style: AppTypography.labelMd.copyWith(color: colorScheme.secondary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Stat card
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _StatCard(count: total),
                ),
                const SizedBox(width: 16),
                // Recent list
                if (items.isNotEmpty)
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: colorScheme.surfaceContainerHigh),
                        boxShadow: [BoxShadow(color: colorScheme.secondary.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        children: items.asMap().entries.map((e) {
                          final item = e.value;
                          final isLast = e.key == items.length - 1;
                          return Column(
                            children: [
                              _HistoryListItem(entity: item),
                              if (!isLast) ...[
                                const SizedBox(height: 8),
                                Divider(height: 1, color: colorScheme.surfaceContainerHigh),
                                const SizedBox(height: 8),
                              ],
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  )
                else
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: colorScheme.surfaceContainerHigh),
                      ),
                      child: Center(
                        child: Text('Belum ada riwayat', style: AppTypography.bodySm.copyWith(color: colorScheme.outline)),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// Kartu statistik jumlah foto terrestorasi.
class _StatCard extends StatelessWidget {
  final int count;
  const _StatCard({required this.count});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.secondaryContainer.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$count',
            style: GoogleFonts.manrope(fontSize: 48, fontWeight: FontWeight.w300, color: colorScheme.onSurface, height: 1),
          ),
          const SizedBox(height: 4),
          Text('Foto', style: AppTypography.labelMd.copyWith(color: colorScheme.onSurfaceVariant, letterSpacing: 1)),
          Text('Terrestorasi', style: AppTypography.bodySm.copyWith(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// Item list riwayat restorasi terbaru.
class _HistoryListItem extends StatelessWidget {
  final RestorationEntity entity;
  const _HistoryListItem({required this.entity});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        // Thumbnail atau icon placeholder
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(8)),
          child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(entity.thumbnailPath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.image_outlined, size: 20, color: colorScheme.outline),
                ),
              ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entity.modelType, style: AppTypography.labelMd.copyWith(color: colorScheme.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(
                _formatDate(entity.createdAt),
                style: AppTypography.bodySm.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Icon(Icons.check_circle_outline, color: colorScheme.secondary, size: 20),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Hari ini';
    if (diff.inDays == 1) return 'Kemarin';
    return '${diff.inDays} hari lalu';
  }
}
