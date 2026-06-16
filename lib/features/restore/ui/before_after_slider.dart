import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class BeforeAfterSlider extends StatefulWidget {
  final Uint8List beforeImage;
  final Uint8List afterImage;

  const BeforeAfterSlider({
    super.key,
    required this.beforeImage,
    required this.afterImage,
  });

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _sliderPosition = 0.5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              _sliderPosition = (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
            });
          },
          onTapDown: (details) {
            setState(() {
              _sliderPosition = (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
            });
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // After (full background)
                SizedBox(
                  width: constraints.maxWidth,
                  child: Image.memory(widget.afterImage, fit: BoxFit.contain),
                ),
                // Before (clipped)
                ClipRect(
                  clipper: _SliderClipper(_sliderPosition),
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: Image.memory(widget.beforeImage, fit: BoxFit.contain),
                  ),
                ),
                // Divider line
                Positioned(
                  left: constraints.maxWidth * _sliderPosition - 1.5,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 3,
                    color: Colors.white,
                    child: const SizedBox(),
                  ),
                ),
                // Handle
                Positioned(
                  left: constraints.maxWidth * _sliderPosition - 18,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: const Icon(Icons.drag_handle_rounded, size: 18, color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ),
                // Labels
                Positioned(
                  left: 12, top: 12,
                  child: _buildLabel('Sebelum'),
                ),
                Positioned(
                  right: 12, top: 12,
                  child: _buildLabel('Sesudah'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(128),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _SliderClipper extends CustomClipper<Rect> {
  final double position;
  _SliderClipper(this.position);

  @override
  Rect getClip(Size size) => Rect.fromLTRB(0, 0, size.width * position, size.height);

  @override
  bool shouldReclip(_SliderClipper old) => old.position != position;
}
