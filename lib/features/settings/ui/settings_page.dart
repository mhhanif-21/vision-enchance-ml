// Halaman Settings — pengaturan tampilan, perilaku aplikasi, dan manajemen data.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../bloc/settings_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
          final isDark = state.settings.isDarkMode;

          return CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Page header
                    Text('Settings', style: AppTypography.headlineLg.copyWith(color: AppColors.onSurface)),
                    const SizedBox(height: 6),
                    Text(
                      'Konfigurasi preferensi aplikasi dan manajemen data.',
                      style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 32),
                    // Grid 2 section: Display + App Behavior
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _DisplaySection(isDark: isDark)),
                        const SizedBox(width: 16),
                        Expanded(child: _AppBehaviorSection(isDark: isDark)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Data Management (full width)
                    _DataManagementSection(),
                    const SizedBox(height: 24),
                    // Version info
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

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFFFDFCF8),
      pinned: true,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0.5,
      shadowColor: AppColors.accent.withValues(alpha: 0.06),
      title: Text(
        'Settings',
        style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onBackground),
      ),
    );
  }
}

// Section tampilan: dark theme toggle dan language.
class _DisplaySection extends StatelessWidget {
  final bool isDark;
  const _DisplaySection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'DISPLAY',
      children: [
        // Dark mode toggle
        _SettingRow(
          icon: Icons.dark_mode_outlined,
          title: 'Dark Theme',
          subtitle: 'Sesuaikan tampilan aplikasi',
          trailing: _CustomSwitch(
            value: isDark,
            onChanged: (v) => context.read<SettingsBloc>().add(ToggleTheme(v)),
          ),
        ),
        const SizedBox(height: 4),
        // Language (non-functional info only)
        _SettingRow(
          icon: Icons.language_outlined,
          title: 'Bahasa',
          subtitle: 'Indonesia',
          trailing: const Icon(Icons.chevron_right, color: AppColors.outlineVariant),
          onTap: () {},
        ),
      ],
    );
  }
}

// Section perilaku aplikasi: auto-save toggle.
class _AppBehaviorSection extends StatelessWidget {
  final bool isDark;
  const _AppBehaviorSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'APP BEHAVIOR',
      children: [
        _SettingRow(
          icon: Icons.save_outlined,
          title: 'Auto-save',
          subtitle: 'Simpan perubahan otomatis',
          trailing: _CustomSwitch(value: true, onChanged: (_) {}),
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
        _DataActionRow(
          icon: Icons.settings_backup_restore_outlined,
          title: 'Backup / Restore',
          subtitle: 'Ekspor atau impor data aplikasi',
          trailing: const Icon(Icons.file_download_outlined, color: AppColors.outlineVariant),
          onTap: () {},
        ),
        const SizedBox(height: 8),
        _DataActionRow(
          icon: Icons.folder_open_outlined,
          title: 'Lokasi Penyimpanan',
          subtitle: '/Documents/LuminaRestore',
          trailing: const Icon(Icons.edit_outlined, color: AppColors.outlineVariant),
          onTap: () {},
        ),
        const SizedBox(height: 8),
        // Clear history
        _DataActionRow(
          icon: Icons.history_outlined,
          title: 'Hapus Riwayat',
          subtitle: 'Menghapus semua riwayat restorasi',
          trailing: const Icon(Icons.delete_sweep_outlined, color: AppColors.outline),
          onTap: () => _showClearDialog(
            context,
            title: 'Hapus Riwayat?',
            onConfirm: () => context.read<SettingsBloc>().add(ClearHistoryCache()),
          ),
        ),
        const SizedBox(height: 8),
        // Clear albums
        _DataActionRow(
          icon: Icons.photo_album_outlined,
          title: 'Hapus Album',
          subtitle: 'Menghapus semua album yang dibuat',
          trailing: const Icon(Icons.delete_sweep_outlined, color: AppColors.outline),
          onTap: () => _showClearDialog(
            context,
            title: 'Hapus Album?',
            onConfirm: () => context.read<SettingsBloc>().add(ClearAlbumsCache()),
          ),
        ),
        const SizedBox(height: 8),
        // Delete all data (danger zone)
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
            onTap: () => _showClearDialog(
              context,
              title: 'Hapus Semua Data?',
              onConfirm: () {
                context.read<SettingsBloc>().add(ClearHistoryCache());
                context.read<SettingsBloc>().add(ClearAlbumsCache());
              },
              isDanger: true,
            ),
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.04), blurRadius: 32, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 2)),
          Divider(height: 24, color: AppColors.surfaceVariant),
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
  final VoidCallback? onTap;

  const _SettingRow({required this.icon, required this.title, required this.subtitle, required this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: AppColors.surfaceContainer, shape: BoxShape.circle),
              child: Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface)),
                  Text(subtitle, style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
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
                color: iconColor == AppColors.error ? AppColors.errorContainer.withValues(alpha: 0.2) : AppColors.surfaceContainer,
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
                  Text(subtitle, style: AppTypography.bodySm.copyWith(color: titleColor == AppColors.error ? AppColors.error.withValues(alpha: 0.7) : AppColors.onSurfaceVariant)),
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
