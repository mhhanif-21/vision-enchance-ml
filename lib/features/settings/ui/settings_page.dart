// Halaman Settings — pengaturan tampilan, perilaku aplikasi, dan manajemen data.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../bloc/settings_bloc.dart';
import '../../history/bloc/history_bloc.dart';
import '../../album/bloc/album_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!), backgroundColor: AppColors.error),
            );
          } else if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!), backgroundColor: AppColors.secondary),
            );
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text('Settings', style: AppTypography.headlineLg.copyWith(color: colorScheme.onSurface)),
                    const SizedBox(height: 6),
                    Text(
                      'Konfigurasi preferensi aplikasi dan manajemen data.',
                      style: AppTypography.bodyLg.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 32),
                    // Section Display
                    _DisplaySection(isDark: state.settings.isDarkMode),
                    const SizedBox(height: 16),
                    // Section App Behavior
                    _AppBehaviorSection(isAutoSave: state.settings.isAutoSave),
                    const SizedBox(height: 16),
                    // Data Management
                    _DataManagementSection(),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'Lumina Restore v1.0.0 (Offline Edition)',
                        style: AppTypography.bodySm.copyWith(color: AppColors.outlineVariant),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SliverAppBar(
      backgroundColor: colorScheme.surface,
      pinned: true,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0.5,
      shadowColor: colorScheme.secondary.withValues(alpha: 0.06),
      automaticallyImplyLeading: false,
      title: Text(
        'Settings',
        style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: colorScheme.onSurface),
      ),
    );
  }
}

// Section tampilan: dark theme toggle dan bahasa.
class _DisplaySection extends StatelessWidget {
  final bool isDark;
  const _DisplaySection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'DISPLAY',
      children: [
        _SettingRow(
          icon: Icons.dark_mode_outlined,
          title: 'Dark Theme',
          subtitle: isDark ? 'Mode gelap aktif' : 'Mode terang aktif',
          trailing: _CustomSwitch(
            value: isDark,
            onChanged: (v) => context.read<SettingsBloc>().add(ToggleTheme(v)),
          ),
        ),
      ],
    );
  }
}

// Section perilaku aplikasi: auto-save toggle.
class _AppBehaviorSection extends StatelessWidget {
  final bool isAutoSave;
  const _AppBehaviorSection({required this.isAutoSave});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'APP BEHAVIOR',
      children: [
        _SettingRow(
          icon: Icons.save_outlined,
          title: 'Auto-save',
          subtitle: isAutoSave ? 'Simpan otomatis aktif' : 'Simpan otomatis nonaktif',
          trailing: _CustomSwitch(
            value: isAutoSave,
            onChanged: (v) => context.read<SettingsBloc>().add(ToggleAutoSave(v)),
          ),
        ),
      ],
    );
  }
}

// Section manajemen data: hapus riwayat, album, semua data.
class _DataManagementSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'DATA MANAGEMENT',
      children: [
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.errorContainer.withValues(alpha: 0.5)),
          ),
          child: _DataActionRow(
            icon: Icons.delete_forever_outlined,
            title: 'Hapus Semua Data',
            subtitle: 'Hapus semua foto dan riwayat permanen',
            iconColor: AppColors.error,
            titleColor: AppColors.error,
            trailing: const Icon(Icons.warning_amber_rounded, color: AppColors.errorContainer),
            onTap: () {
              final historyBloc = context.read<HistoryBloc>();
              final albumBloc = context.read<AlbumBloc>();
              _showClearDialog(
                context,
                title: 'Hapus Semua Data?',
                onConfirm: () {
                  context.read<SettingsBloc>().add(ClearHistoryCache());
                  context.read<SettingsBloc>().add(ClearAlbumsCache());
                  Future.delayed(const Duration(milliseconds: 300), () {
                    historyBloc.add(LoadHistory());
                    albumBloc.add(LoadAlbums());
                  });
                },
                isDanger: true,
              );
            },
          ),
        ),
      ],
    );
  }

  void _showClearDialog(BuildContext context, {required String title, required VoidCallback onConfirm, bool isDanger = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: const Text('Tindakan ini tidak dapat dibatalkan. Lanjutkan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: isDanger ? AppColors.error : AppColors.secondary),
            onPressed: () { onConfirm(); Navigator.pop(ctx); },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// Card container untuk setiap section settings.
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: theme.colorScheme.secondary.withValues(alpha: 0.04), blurRadius: 32, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.labelMd.copyWith(color: theme.colorScheme.onSurfaceVariant, letterSpacing: 2)),
          Divider(height: 24, color: theme.colorScheme.surfaceContainerHigh),
          ...children,
        ],
      ),
    );
  }
}

// Baris setting dengan icon, teks, dan trailing widget.
class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingRow({required this.icon, required this.title, required this.subtitle, required this.trailing});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: colorScheme.surfaceContainerHigh, shape: BoxShape.circle),
              child: Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyMd.copyWith(color: colorScheme.onSurface)),
                  Text(subtitle, style: AppTypography.bodySm.copyWith(color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

// Baris untuk aksi data management.
class _DataActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;
  final Color iconColor;
  final Color titleColor;

  const _DataActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
    this.iconColor = AppColors.onSurfaceVariant,
    this.titleColor = AppColors.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor == AppColors.error ? colorScheme.errorContainer.withValues(alpha: 0.2) : colorScheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyMd.copyWith(color: titleColor, fontWeight: titleColor == AppColors.error ? FontWeight.w500 : FontWeight.w400)),
                  Text(subtitle, style: AppTypography.bodySm.copyWith(color: titleColor == AppColors.error ? colorScheme.error.withValues(alpha: 0.7) : colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

// Custom toggle switch sesuai desain Stitch.
class _CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _CustomSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 26,
        decoration: BoxDecoration(
          color: value ? AppColors.secondary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: value ? Colors.transparent : AppColors.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
