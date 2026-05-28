/// Halaman beranda (Dashboard) dari Lumina Restore.
/// Menampilkan pilihan tipe restorasi dan tombol untuk melihat riwayat (History).
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/model_config.dart';
import '../../../../core/widgets/custom_card.dart';

import '../../history/ui/history_page.dart';
import '../../album/ui/albums_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomeContent(),
    const AlbumsPage(),
    const HistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        indicatorColor: AppColors.secondaryContainer,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.onSecondaryContainer),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_album_outlined),
            selectedIcon: Icon(Icons.photo_album, color: AppColors.onSecondaryContainer),
            label: 'Album',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: AppColors.onSecondaryContainer),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lumina Restore',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.secondary),
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0), // Ample whitespace
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Jenis\nRestorasi',
                style: theme.textTheme.displayLarge,
              ),
              const SizedBox(height: 64), // Section Gap
              // Kartu opsi Low-Light
              _buildTypeCard(
                context,
                title: 'Peningkatan Cahaya',
                subtitle: 'Terangkan foto yang gelap atau kurang pencahayaan.',
                icon: Icons.brightness_6,
                modelType: ModelType.lowLight,
              ),
              const SizedBox(height: 32),
              // Kartu opsi Deblurring
              _buildTypeCard(
                context,
                title: 'Penghilangan Blur',
                subtitle: 'Pertajam foto yang buram atau kabur dengan cepat.',
                icon: Icons.blur_off,
                modelType: ModelType.deblurring,
              ),
              const SizedBox(height: 64),
            ],
          ),
        ),
      ),
    );
  }

  // Membuat komponen kartu opsi restorasi yang dapat ditekan.
  Widget _buildTypeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required ModelType modelType,
  }) {
    return CustomCard(
      onTap: () {
        // Navigasi ke layar upload dengan melempar parameter tipe model
        context.push('/upload', extra: modelType);
      },
      padding: const EdgeInsets.all(28.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Lingkaran aksen untuk icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.secondary, size: 28),
          ),
          const SizedBox(width: 24),
          // Teks penjelasan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMd?.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.arrow_forward_ios, color: AppColors.outlineVariant, size: 16),
        ],
      ),
    );
  }
}

