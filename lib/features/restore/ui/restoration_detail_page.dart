// Placeholder halaman Restoration Details. Akan diimplementasi penuh di Fase 2.
import 'package:flutter/material.dart';
import '../../history/models/restoration_entity.dart';

class RestorationDetailPage extends StatelessWidget {
  final RestorationEntity entity;

  const RestorationDetailPage({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Restorasi')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
