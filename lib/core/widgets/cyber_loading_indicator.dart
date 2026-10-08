import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/cyber_colors.dart';

class CyberLoadingIndicator extends StatefulWidget {
  final String statusText;
  final double size;
  final Color? color;

  const CyberLoadingIndicator({
    super.key,
    String? statusText,
    String? message,
    this.size = 54.0,
    this.color,
  }) : statusText = message ?? statusText ?? 'DEFENSE TELEMETRY COMPUTING...';

  @override
  State<CyberLoadingIndicator> createState() => _CyberLoadingIndicatorState();
}

class _CyberLoadingIndicatorState extends State<CyberLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.color ?? CyberColors.neonCyan;

    return Semantics(
      label: 'Loading indicator: ${widget.statusText}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Counter-clockwise outer dashed arc
                RotationTransition(
                  turns: Tween<double>(begin: 1.0, end: 0.0).animate(_controller),
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _DashedOrbitalRingPainter(
                      color: primaryColor.withOpacity(0.5),
                    ),
                  ),
                ),

                // Clockwise inner ring
                RotationTransition(
                  turns: _controller,
                  child: CustomPaint(
                    size: Size(widget.size * 0.75, widget.size * 0.75),
                    painter: _InnerArcPainter(
                      color: widget.color ?? CyberColors.neonPink,
                    ),
                  ),
                ),

                // Center Pulsing Core
                Container(
                  width: widget.size * 0.32,
                  height: widget.size * 0.32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withOpacity(0.2),
                    border: Border.all(color: primaryColor, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (widget.statusText.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              widget.statusText,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: CyberColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _DashedOrbitalRingPainter extends CustomPainter {
  final Color color;

  _DashedOrbitalRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    for (int i = 0; i < 4; i++) {
      final startAngle = i * (pi / 2) + 0.2;
      const sweepAngle = (pi / 2) - 0.4;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedOrbitalRingPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _InnerArcPainter extends CustomPainter {
  final Color color;

  _InnerArcPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.0,
      pi * 1.2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _InnerArcPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Shimmer Skeleton loading block for modern enterprise card placeholders
class CyberShimmer extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const CyberShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12.0,
  });

  @override
  State<CyberShimmer> createState() => _CyberShimmerState();
}

class _CyberShimmerState extends State<CyberShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + (_shimmerController.value * 2.0), -0.3),
              end: Alignment(1.0 + (_shimmerController.value * 2.0), 0.3),
              colors: [
                CyberColors.darkBlueBg,
                CyberColors.cardBorder.withOpacity(0.5),
                CyberColors.darkBlueBg,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            border: Border.all(
              color: CyberColors.darkBlueBorder.withOpacity(0.5),
              width: 0.8,
            ),
          ),
        );
      },
    );
  }
}
