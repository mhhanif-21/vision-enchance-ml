/// Halaman Upload. Memungkinkan user memilih foto dari Galeri atau Kamera.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/model_config.dart';
import '../../../../core/constants/app_constants.dart';
import 'package:image/image.dart' as img;

class UploadPage extends StatefulWidget {
  final ModelType modelType;

  const UploadPage({super.key, required this.modelType});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Memilih gambar menggunakan library ImagePicker (mendukung galeri dan kamera).
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        final file = File(image.path);
        
        // --- Mulai Validasi ---
        // 1. Validasi Ekstensi
        final ext = image.name.split('.').last.toLowerCase();
        if (!AppConstants.supportedFormats.contains(ext)) {
          _showError('Format gambar tidak didukung. Gunakan JPG, PNG, atau WEBP.');
          return;
        }

        // 2. Validasi Ukuran File (Maksimal 20MB)
        final sizeBytes = await file.length();
        if (sizeBytes > AppConstants.maxFileSizeBytes) {
          _showError('Ukuran gambar terlalu besar. Maksimal 20 MB.');
          return;
        }

        // 3. Validasi Resolusi Gambar (Maksimal 4096px)
        final bytes = await file.readAsBytes();
        final decodedImage = img.decodeImage(bytes);
        if (decodedImage == null) {
          _showError('Gagal membaca gambar. File mungkin rusak.');
          return;
        }
        if (decodedImage.width > AppConstants.maxImageDimension || decodedImage.height > AppConstants.maxImageDimension) {
          _showError('Resolusi gambar melebihi batas maksimal 4096px.');
          return;
        }
        // --- Selesai Validasi ---

        setState(() {
          _selectedImage = file;
        });
      }
    } catch (e) {
      _showError('Gagal memilih gambar: $e');
    }
  }

  // Fungsi utilitas untuk menampilkan pesan error dengan SnackBar
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  // Melanjutkan proses dengan melempar path gambar dan tipe model ke ProcessingPage.
  void _proceedToProcess() {
    if (_selectedImage != null) {
      context.push('/processing', extra: {
        'imagePath': _selectedImage!.path,
        'modelType': widget.modelType,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.modelType.displayName),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    )
                  : _buildPlaceholder(),
            ),
            const SizedBox(height: 32),
            if (_selectedImage == null) ...[
              // Tombol untuk galeri
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Pilih dari Galeri'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
              const SizedBox(height: 16),
              // Tombol untuk kamera
              OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Ambil Foto Baru'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  foregroundColor: AppColors.secondary,
                  side: const BorderSide(color: AppColors.secondary),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  // Tombol batal
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _selectedImage = null),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 56),
                        foregroundColor: AppColors.secondary,
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Tombol proses
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _proceedToProcess,
                      style: ElevatedButton.styleFrom(minimumSize: const Size(0, 56)),
                      child: const Text('Restorasi Sekarang'),
                    ),
                  ),
                ],
              )
            ],
          ],
        ),
      ),
    );
  }

  // Membuat widget placeholder saat user belum memilih gambar apapun.
  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.outline, width: 1, style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate, size: 80, color: AppColors.secondary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'Belum ada foto terpilih',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
