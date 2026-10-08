import 'dart:ui';
import 'package:flutter/material.dart';
import 'cyber_colors.dart';

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blur;
  final Color? backgroundColor;
  final Border? border;
  final double? width;
  final double? height;
  final List<BoxShadow>? boxShadow;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.blur = 0.0,
    this.backgroundColor,
    this.border,
    this.width,
    this.height,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    // Resolve background: enforce pure white or soft clean tint, never dark or blurry
    Color resolvedBg = CyberColors.surface;
    if (backgroundColor != null) {
      // If the provided color is dark or nearly black, sanitize to clean white
      if (backgroundColor!.computeLuminance() < 0.35) {
        resolvedBg = CyberColors.surface;
      } else {
        // If it's a light tint (like soft danger or soft blue), keep it opaque or soft
        resolvedBg = backgroundColor!.withOpacity(1.0);
      }
    }

    // Resolve border: clean subtle 1px border (#D9E0EA)
    final resolvedBorder = border ??
        Border.all(
          color: CyberColors.cardBorder,
          width: 1.0,
        );

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: resolvedBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: resolvedBorder,
        boxShadow: boxShadow ?? CyberColors.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
