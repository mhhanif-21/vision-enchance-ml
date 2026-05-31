import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24.0),
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = backgroundColor ?? theme.colorScheme.surfaceContainerLowest;
    
    // Ambient soft shadow with a tint of the secondary/accent color
    final shadowColor = theme.colorScheme.secondary.withValues(alpha: 0.05);

    Widget cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24.0), // 1.5rem roundedness
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
