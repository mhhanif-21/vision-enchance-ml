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
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
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
                  activeColor: AppColors.primary,
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
                child: ListTile(
                  leading: const Icon(Icons.delete_sweep, color: AppColors.error),
                  title: const Text('Hapus Data Cache'),
                  subtitle: const Text('Menghapus semua Riwayat dan Album yang telah dibuat.'),
                  onTap: () => _showClearCacheDialog(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Dialog konfirmasi untuk menghindari penghapusan data secara tidak sengaja
  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Hapus Data Cache?'),
          content: const Text(
            'Tindakan ini akan menghapus permanen seluruh riwayat restorasi dan daftar album Anda. Lanjutkan?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () {
                context.read<SettingsBloc>().add(ClearAppCache());
                Navigator.pop(ctx);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
