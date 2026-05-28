import 'package:flutter/material.dart';

class BeforeAfterSlider extends StatefulWidget {
  final Widget beforeImage;
  final Widget afterImage;
  final double initialPosition;

  const BeforeAfterSlider({
    Key? key,
    required this.beforeImage,
    required this.afterImage,
    this.initialPosition = 0.5,
  }) : super(key: key);

  @override
  _BeforeAfterSliderState createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  late double _position;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _position = (_position + details.delta.dx / width).clamp(0.0, 1.0);
              });
            },
            child: Stack(
              children: [
                // After Image (Base)
                SizedBox(
                  width: width,
                  height: height,
                  child: widget.afterImage,
                ),
                
                // Before Image (Clipped)
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: _position,
                    child: SizedBox(
                      width: width,
                      height: height,
                      child: widget.beforeImage,
                    ),
                  ),
                ),
                
                // Slider Handle and Line
                Positioned(
                  left: width * _position - 20, // Center the handle (40 width)
                  top: 0,
                  bottom: 0,
                  child: _buildHandle(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Thin vertical line
          Container(
            width: 2,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          // Elegant circle handle
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.code, // Typically '< >' icon
              size: 16,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
