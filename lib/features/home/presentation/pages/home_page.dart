import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../widgets/restoration_type_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 40),
                    _buildSectionTitle(context, 'Pilih Jenis Restorasi'),
                    const SizedBox(height: 16),
                    _buildRestorationCards(context),
                    const SizedBox(height: 40),
                    _buildInfoSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_fix_high_rounded,
                color: AppColors.onSecondary,
                size: 22,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.settings_outlined,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          AppConstants.appName,
          style: GoogleFonts.manrope(
            fontSize: 32,
            fontWeight: FontWeight.w300,
            color: AppColors.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Kembalikan keindahan foto Anda\ndengan kecerdasan buatan.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurfaceVariant,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildRestorationCards(BuildContext context) {
    return Column(
      children: [
        RestorationTypeCard(
          title: 'Peningkatan Cahaya',
          subtitle: 'Cerahkan foto gelap atau low-light',
          icon: Icons.wb_sunny_rounded,
          iconColor: const Color(0xFFE6A817),
          onTap: () {
            // TODO: Navigate to upload with low-light model
          },
        ),
        const SizedBox(height: 12),
        RestorationTypeCard(
          title: 'Penghilangan Blur',
          subtitle: 'Pertajam foto yang buram atau goyang',
          icon: Icons.center_focus_strong_rounded,
          iconColor: AppColors.secondary,
          onTap: () {
            // TODO: Navigate to upload with deblurring model
          },
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withAlpha(77),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.shield_outlined,
            color: AppColors.secondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Semua proses berjalan di perangkat Anda. Foto tidak dikirim ke server manapun.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSecondaryContainer,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
