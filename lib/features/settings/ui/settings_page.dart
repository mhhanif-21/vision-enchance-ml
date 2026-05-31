// File ini menampilkan halaman Pengaturan (Settings).
// Menyediakan kontrol untuk tema aplikasi dan penghapusan cache.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/custom_card.dart';
import '../bloc/settings_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w400)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
            );
          } else if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final isDark = state.settings.isDarkMode;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            children: [
              // Bagian Tampilan
              Text(
                'Tampilan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.secondary,
                    ),
              ),
              const SizedBox(height: 16),
              CustomCard(
                padding: EdgeInsets.zero,
                child: SwitchListTile(
                  title: const Text('Mode Gelap'),
                  subtitle: const Text('Gunakan tema gelap untuk aplikasi'),
                  value: isDark,
                  activeThumbColor: AppColors.primary,
                  onChanged: (value) {
                    context.read<SettingsBloc>().add(ToggleTheme(value));
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Bagian Penyimpanan
              Text(
                'Penyimpanan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.secondary,
                    ),
              ),
              const SizedBox(height: 16),
              CustomCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.history, color: AppColors.error),
                      title: const Text('Hapus Riwayat'),
                      subtitle: const Text('Menghapus semua riwayat restorasi.'),
                      onTap: () => _showClearDialog(
                        context,
                        title: 'Hapus Riwayat?',
                        onConfirm: () => context.read<SettingsBloc>().add(ClearHistoryCache()),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.photo_album, color: AppColors.error),
                      title: const Text('Hapus Album'),
                      subtitle: const Text('Menghapus semua album yang telah dibuat.'),
                      onTap: () => _showClearDialog(
                        context,
                        title: 'Hapus Album?',
                        onConfirm: () => context.read<SettingsBloc>().add(ClearAlbumsCache()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Dialog konfirmasi generik untuk menghindari penghapusan data secara tidak sengaja.
  void _showClearDialog(
    BuildContext context, {
    required String title,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: const Text('Tindakan ini tidak dapat dibatalkan. Lanjutkan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              onConfirm();
              Navigator.pop(ctx);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
