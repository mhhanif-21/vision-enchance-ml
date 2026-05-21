import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../bloc/restore_bloc.dart';
import '../bloc/restore_event.dart';
import '../bloc/restore_state.dart';
import 'result_page.dart';

class ProcessingPage extends StatelessWidget {
  const ProcessingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: BlocListener<RestoreBloc, RestoreState>(
        listener: (context, state) {
          if (state is RestoreSuccess) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<RestoreBloc>(),
                  child: const ResultPage(),
                ),
              ),
            );
          } else if (state is RestoreFailure) {
            Navigator.of(context).pop();
            _showErrorDialog(context, state);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: BlocBuilder<RestoreBloc, RestoreState>(
              builder: (context, state) {
                final phase = state is RestoreProcessing ? state : null;
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildProgressCircle(),
                        const SizedBox(height: 40),
                        Text(
                          phase?.message ?? 'Mempersiapkan...',
                          style: GoogleFonts.manrope(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Proses ini memakan waktu beberapa detik',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 48),
                        _buildPhaseIndicator(phase?.phase),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCircle() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withAlpha(77),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.secondary,
            backgroundColor: AppColors.outlineVariant.withAlpha(60),
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseIndicator(RestorePhase? current) {
    final phases = [
      (RestorePhase.preprocessing, 'Pra-proses', Icons.tune_rounded),
      (RestorePhase.inference, 'Inferensi AI', Icons.auto_fix_high_rounded),
      (RestorePhase.postprocessing, 'Pasca-proses', Icons.save_alt_rounded),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: phases.map((p) {
        final isActive = current == p.$1;
        final isDone = current != null && p.$1.index < current.index;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDone
                      ? AppColors.secondary
                      : (isActive
                          ? AppColors.secondaryContainer
                          : AppColors.surfaceContainer),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDone ? Icons.check_rounded : p.$3,
                  size: 18,
                  color: isDone
                      ? AppColors.onSecondary
                      : (isActive
                          ? AppColors.secondary
                          : AppColors.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                p.$2,
                style: TextStyle(
                  fontSize: 11,
                  color: isActive
                      ? AppColors.secondary
                      : AppColors.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showErrorDialog(BuildContext context, RestoreFailure state) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: AppColors.error, size: 24),
            const SizedBox(width: 8),
            const Text('Restorasi Gagal'),
          ],
        ),
        content: Text(state.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          if (state.actionLabel != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<RestoreBloc>().add(const RestoreStarted());
              },
              child: Text(state.actionLabel!),
            ),
        ],
      ),
    );
  }
}
