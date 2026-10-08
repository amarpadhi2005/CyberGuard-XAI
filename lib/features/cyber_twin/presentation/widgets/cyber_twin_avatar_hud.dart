import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../domain/entities/cyber_twin_state.dart';

class CyberTwinAvatarHud extends StatefulWidget {
  final CyberTwinState state;

  const CyberTwinAvatarHud({
    super.key,
    required this.state,
  });

  @override
  State<CyberTwinAvatarHud> createState() => _CyberTwinAvatarHudState();
}

class _CyberTwinAvatarHudState extends State<CyberTwinAvatarHud>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAlert = widget.state.isCoordinatedScamDetected;
    final primaryColor = isAlert ? CyberColors.riskCritical : CyberColors.primaryBlue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: CyberColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAlert ? CyberColors.riskCritical.withOpacity(0.3) : CyberColors.borderSubtle,
          width: 1,
        ),
        boxShadow: CyberColors.cardShadow,
      ),
      child: Row(
        children: [
          // Enterprise Rotating Sentinel Ring & Core
          SizedBox(
            width: 68,
            height: 68,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Subtle Rotating Ring
                RotationTransition(
                  turns: _rotationController,
                  child: CustomPaint(
                    size: const Size(68, 68),
                    painter: _AvatarRingPainter(color: primaryColor),
                  ),
                ),

                // Center Icon Core
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isAlert ? CyberColors.riskCriticalBg : CyberColors.primarySoftBg,
                    border: Border.all(
                      color: primaryColor.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    isAlert
                        ? Icons.shield_outlined
                        : Icons.smart_toy_outlined,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Cyber Twin Intelligence Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.state.guardianName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: CyberColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isAlert ? CyberColors.riskCriticalBg : CyberColors.primarySoftBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        isAlert ? 'CORRELATION ALERT' : 'SENTINEL ACTIVE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isAlert
                      ? 'Neural engine correlating 3 convergent threat events.'
                      : 'Zero-trust runtime perimeter continuously shielded.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: CyberColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.sync_alt_rounded,
                        size: 13, color: CyberColors.primaryBlue),
                    const SizedBox(width: 5),
                    Text(
                      'NEURAL SYNC: ${(widget.state.neuralSyncLevel * 100).toStringAsFixed(1)}% • 24H WINDOW',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: CyberColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarRingPainter extends CustomPainter {
  final Color color;

  _AvatarRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final paint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Segmented dashed arcs
    for (int i = 0; i < 4; i++) {
      final startAngle = i * (pi / 2) + 0.15;
      const sweepAngle = (pi / 2) - 0.3;
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
  bool shouldRepaint(covariant _AvatarRingPainter oldDelegate) =>
      oldDelegate.color != color;
}
