/// Halaman beranda (Dashboard) dari Lumina Restore.
/// Menampilkan pilihan tipe restorasi dan tombol untuk melihat riwayat (History).
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/model_config.dart';

import '../../../history/ui/history_page.dart';
import '../../../album/ui/albums_page.dart';

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
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_album_outlined),
            selectedIcon: Icon(Icons.photo_album),
            label: 'Album',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lumina Restore',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.secondary),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0), // Spasi yang luas sesuai desain Stitch
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Jenis\nRestorasi',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 32),
            // Kartu opsi Low-Light
            _buildTypeCard(
              context,
              title: 'Peningkatan Cahaya',
              subtitle: 'Terangkan foto yang gelap atau kurang pencahayaan.',
              icon: Icons.brightness_6,
              modelType: ModelType.lowLight,
            ),
            const SizedBox(height: 16),
            // Kartu opsi Deblurring
            _buildTypeCard(
              context,
              title: 'Penghilangan Blur',
              subtitle: 'Pertajam foto yang buram atau kabur dengan cepat.',
              icon: Icons.blur_off,
              modelType: ModelType.deblurring,
            ),
          ],
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
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () {
          // Navigasi ke layar upload dengan melempar parameter tipe model
          context.push('/upload', extra: modelType);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // Lingkaran aksen untuk icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.secondary, size: 32),
              ),
              const SizedBox(width: 16),
              // Teks penjelasan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: AppColors.outline, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
