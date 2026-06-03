// Halaman Upload — memilih foto dari galeri atau kamera dengan validasi.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/model_config.dart';

class UploadPage extends StatefulWidget {
  final ModelType modelType;
  const UploadPage({super.key, required this.modelType});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _selectedImage;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source);
      if (picked == null) return;
      final file = File(picked.path);
      // Validate extension
      final ext = picked.name.split('.').last.toLowerCase();
      if (!AppConstants.supportedFormats.contains(ext)) {
        _showError('Format tidak didukung. Gunakan JPG, PNG, atau WEBP.');
        return;
      }
      // Validate file size
      if (await file.length() > AppConstants.maxFileSizeBytes) {
        _showError('Ukuran gambar terlalu besar. Maks 20 MB.');
        return;
      }
      // Validate resolution
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) { _showError('File gambar rusak.'); return; }
      if (decoded.width > AppConstants.maxImageDimension || decoded.height > AppConstants.maxImageDimension) {
        _showError('Resolusi melebihi batas 4096px.');
        return;
      }
      setState(() => _selectedImage = file);
    } catch (e) {
      _showError('Gagal memilih gambar: $e');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  void _proceed() {
    if (_selectedImage != null) {
      context.push('/processing', extra: {'imagePath': _selectedImage!.path, 'modelType': widget.modelType});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFCF8),
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.secondary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.modelType.displayName, style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onBackground)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: Column(
          children: [
            // Page header
            Text('Upload Foto Anda', style: AppTypography.headlineXl.copyWith(color: AppColors.onSurface), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              'Seret dan lepas gambar di bawah, atau ketuk untuk memilih file. Format yang didukung: JPG, PNG, WEBP.',
              style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Upload area
            GestureDetector(
              onTap: () => _selectedImage == null ? _pickImage(ImageSource.gallery) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.outlineVariant,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.06), blurRadius: 30, offset: const Offset(0, 8))],
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.cloud_upload_outlined, size: 40, color: AppColors.secondary),
                          ),
                          const SizedBox(height: 16),
                          Text('Drag & Drop', style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface)),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              text: 'atau ',
                              style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                              children: [
                                TextSpan(text: 'pilih file', style: AppTypography.bodyMd.copyWith(color: AppColors.secondary, decoration: TextDecoration.underline)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(color: AppColors.tertiaryFixed, borderRadius: BorderRadius.circular(99)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.info_outline, size: 14, color: AppColors.onSurfaceVariant),
                                const SizedBox(width: 6),
                                Text('Resolusi tinggi menghasilkan kualitas terbaik', style: AppTypography.bodySm.copyWith(fontSize: 11, color: AppColors.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            // Action buttons
            if (_selectedImage == null) ...[
              _ActionButton(
                label: 'Pilih dari Galeri',
                icon: Icons.photo_library_outlined,
                onTap: () => _pickImage(ImageSource.gallery),
                filled: true,
              ),
              const SizedBox(height: 12),
              _ActionButton(
                label: 'Ambil Foto Baru',
                icon: Icons.camera_alt_outlined,
                onTap: () => _pickImage(ImageSource.camera),
                filled: false,
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(label: 'Ganti Foto', icon: Icons.swap_horiz_rounded, onTap: () => setState(() => _selectedImage = null), filled: false),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(label: 'Restorasi Sekarang', icon: Icons.auto_fix_high_rounded, onTap: _proceed, filled: true),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 40),
            // Info cards
            Row(
              children: [
                Expanded(child: _InfoCard(icon: Icons.photo_size_select_actual_outlined, title: 'Batas Ukuran File', body: 'Maksimal 20MB. Pastikan gambar tidak terkompresi berlebihan.')),
                const SizedBox(width: 16),
                Expanded(child: _InfoCard(icon: Icons.security_outlined, title: 'Privasi Terjamin', body: 'Foto Anda diproses secara lokal dan tidak pernah dibagikan.')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  const _ActionButton({required this.label, required this.icon, required this.onTap, required this.filled});

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTypography.labelMd,
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.secondary,
        side: const BorderSide(color: AppColors.secondary),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTypography.labelMd,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _InfoCard({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.04), blurRadius: 20)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelMd.copyWith(color: AppColors.onSurface)),
                const SizedBox(height: 4),
                Text(body, style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
