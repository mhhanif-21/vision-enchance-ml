// Halaman Processing — menampilkan animasi ambient saat ML sedang memproses gambar.
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/restore_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/model_config.dart';

class ProcessingPage extends StatefulWidget {
  final String imagePath;
  final ModelType modelType;

  const ProcessingPage({super.key, required this.imagePath, required this.modelType});

  @override
  State<ProcessingPage> createState() => _ProcessingPageState();
}

class _ProcessingPageState extends State<ProcessingPage> with TickerProviderStateMixin {
  late final AnimationController _blob1Controller;
  late final AnimationController _blob2Controller;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _blob1Controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat(reverse: true);
    _blob2Controller = AnimationController(vsync: this, duration: const Duration(seconds: 25))..repeat(reverse: true);
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _startRestoration();
  }

  @override
  void dispose() {
    _blob1Controller.dispose();
    _blob2Controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startRestoration() async {
    final bytes = await File(widget.imagePath).readAsBytes();
    if (mounted) {
      context.read<RestoreBloc>().add(StartRestoration(imageBytes: bytes, modelType: widget.modelType));
    }
  }

  String _stepLabel(RestorationStep? step) {
    switch (step) {
      case RestorationStep.preprocessing: return 'Mempersiapkan gambar...';
      case RestorationStep.inferencing: return 'Model AI sedang bekerja...';
      case RestorationStep.postprocessing: return 'Memfinalisasi hasil...';
      default: return 'Menginisialisasi...';
    }
  }

  double _stepProgress(RestorationStep? step) {
    switch (step) {
      case RestorationStep.preprocessing: return 0.33;
      case RestorationStep.inferencing: return 0.66;
      case RestorationStep.postprocessing: return 0.95;
      default: return 0.05;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<RestoreBloc, RestoreState>(
        listener: (context, state) {
          if (state is RestoreSuccess) {
            context.pushReplacement('/result', extra: state.result);
          } else if (state is RestoreFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage), backgroundColor: AppColors.error),
            );
            context.pop();
          } else if (state is RestoreCancelled) {
            context.pop();
          }
        },
        builder: (context, state) {
          final step = state is RestoreProcessing ? state.step : null;
          final progress = _stepProgress(step);

          return Stack(
            children: [
              _buildAmbientBackground(),
              SafeArea(
                child: Column(
                  children: [
                    // Cancel button
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => context.read<RestoreBloc>().add(CancelRestoration()),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: const StadiumBorder(),
                            backgroundColor: AppColors.surfaceContainerLow.withValues(alpha: 0.8),
                          ),
                          icon: const Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.primary),
                          label: Text('Batal', style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant)),
                        ),
                      ),
                    ),
                    // Main content
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildPreviewCard(),
                              const SizedBox(height: 40),
                              _buildProgressBar(progress),
                              const SizedBox(height: 16),
                              Text('Merestorasi Detail', style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface), textAlign: TextAlign.center),
                              const SizedBox(height: 8),
                              Text(_stepLabel(step), style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Branding footer
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Opacity(
                        opacity: 0.4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.verified_user_outlined, size: 14, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Text('Secured by Lumina AI', style: AppTypography.bodySm.copyWith(fontSize: 12, color: AppColors.onSurfaceVariant)),
                          ],
                        ),
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

  Widget _buildAmbientBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Blob 1 — secondary container
          AnimatedBuilder(
            animation: _blob1Controller,
            builder: (_, _) => Positioned(
              left: -80 + (_blob1Controller.value * 50),
              top: 80 + (_blob1Controller.value * -40),
              child: _GlowBlob(color: AppColors.secondaryContainer.withValues(alpha: 0.3), size: 400),
            ),
          ),
          // Blob 2 — tertiary fixed
          AnimatedBuilder(
            animation: _blob2Controller,
            builder: (_, _) => Positioned(
              right: -80 + (_blob2Controller.value * -30),
              bottom: 100 + (_blob2Controller.value * 30),
              child: _GlowBlob(color: AppColors.tertiaryFixed.withValues(alpha: 0.4), size: 350),
            ),
          ),
          // Center glow
          Center(
            child: _GlowBlob(color: AppColors.primaryContainer.withValues(alpha: 0.2), size: 600),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      width: double.infinity,
      height: 260,
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.18), blurRadius: 50, offset: const Offset(0, 20))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Blurred original image preview
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(color: AppColors.surfaceContainer),
              ),
            ),
            // Glassmorphism overlay
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: AppColors.surfaceContainerLowest.withValues(alpha: 0.55)),
            ),
            // Progress ring + icon
            Center(
              child: SizedBox(
                width: 110,
                height: 110,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.secondary,
                      backgroundColor: AppColors.surfaceContainerHighest,
                      strokeWidth: 3,
                    ),
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, _) => Opacity(
                        opacity: 0.6 + (_pulseController.value * 0.4),
                        child: const Icon(Icons.auto_fix_high_rounded, size: 36, color: AppColors.secondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  Container(color: AppColors.surfaceContainerHighest.withValues(alpha: 0.5)),
                  AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 600),
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        boxShadow: [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.4), blurRadius: 8)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.secondary, letterSpacing: 1),
              ),
              const SizedBox(width: 6),
              Text('Selesai', style: AppTypography.bodySm.copyWith(fontSize: 12, color: AppColors.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget lingkaran cahaya ambient untuk efek background.
class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
        child: const SizedBox.expand(),
      ),
    );
  }
}
