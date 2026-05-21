import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/model_config.dart';
import '../bloc/restore_bloc.dart';
import '../bloc/restore_event.dart';
import '../bloc/restore_state.dart';
import 'processing_page.dart';

class UploadPage extends StatefulWidget {
  final ModelType modelType;
  const UploadPage({super.key, required this.modelType});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final _picker = ImagePicker();
  String? _selectedPath;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 100);
    if (picked != null) {
      setState(() => _selectedPath = picked.path);
      if (mounted) {
        context.read<RestoreBloc>().add(
          RestoreImageSelected(imagePath: picked.path, modelType: widget.modelType),
        );
      }
    }
  }

  void _startRestore() {
    context.read<RestoreBloc>().add(const RestoreStarted());
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<RestoreBloc>(),
          child: const ProcessingPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.modelType.displayName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _selectedPath != null ? _buildPreview() : _buildPicker(),
              ),
              const SizedBox(height: 24),
              if (_selectedPath != null) ..._buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPicker() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 48),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.outlineVariant.withAlpha(100),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 56,
                color: AppColors.onSurfaceVariant.withAlpha(150),
              ),
              const SizedBox(height: 16),
              Text(
                'Pilih Foto untuk Direstorasi',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'JPEG, PNG, atau WebP (maks. 20 MB)',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                    label: const Text('Galeri'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: const Text('Kamera'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(File(_selectedPath!), fit: BoxFit.contain),
    );
  }

  List<Widget> _buildActions() {
    return [
      ElevatedButton(
        onPressed: _startRestore,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            'Mulai Restorasi',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      const SizedBox(height: 8),
      OutlinedButton(
        onPressed: () => setState(() => _selectedPath = null),
        child: const Text('Pilih Foto Lain'),
      ),
    ];
  }
}
