import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../domain/entities/xai_result_model.dart';

class XaiGaugesSection extends StatelessWidget {
  final XaiResultModel result;

  const XaiGaugesSection({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final isThreat = result.riskScore >= 40;
    final severityColor = isThreat ? CyberColors.danger : CyberColors.success;
    final confidencePct = (result.confidence * 100).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CyberColors.cardBorder, width: 1.0),
        boxShadow: CyberColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Category Pill & Target
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isThreat ? CyberColors.softDangerBg : CyberColors.softSuccessBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isThreat ? CyberColors.softDangerBorder : CyberColors.softSuccessBorder, width: 1.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: severityColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${result.category.toUpperCase()} THREAT AUDIT',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: severityColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: CyberColors.cardBgSecondary,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: CyberColors.cardBorder, width: 0.8),
                ),
                child: Text(
                  result.id,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: CyberColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Threat Type Title
          Text(
            result.threatType,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: CyberColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            result.target,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: CyberColors.primary,
            ),
          ),

          const SizedBox(height: 20),

          // Side-by-Side Dual Meters: Risk Score & AI Confidence
          Row(
            children: [
              // 1. Risk Score Radial Meter
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isThreat ? CyberColors.softDangerBg : CyberColors.softSuccessBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isThreat ? CyberColors.softDangerBorder : CyberColors.softSuccessBorder,
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 88,
                        height: 88,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(88, 88),
                              painter: _MiniGaugePainter(
                                progress: result.riskPercentage,
                                color: severityColor,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${result.riskScore}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: severityColor,
                                    height: 1.0,
                                  ),
                                ),
                                Text(
                                  '/ 100',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: CyberColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'RISK SCORE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: CyberColors.textSecondary,
                        ),
                      ),
                      Text(
                        result.severity.label.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: severityColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 2. AI Confidence Meter
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CyberColors.softBlueBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: CyberColors.softBlueBorder,
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 88,
                        height: 88,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(88, 88),
                              painter: _MiniGaugePainter(
                                progress: result.confidencePercentage,
                                color: CyberColors.primary,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$confidencePct%',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: CyberColors.primary,
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Icon(
                                  Icons.psychology_rounded,
                                  size: 14,
                                  color: CyberColors.primary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'AI CONFIDENCE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: CyberColors.textSecondary,
                        ),
                      ),
                      Text(
                        'CERTAINTY LEVEL',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: CyberColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniGaugePainter extends CustomPainter {
  final double progress;
  final Color color;

  _MiniGaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    final trackPaint = Paint()
      ..color = CyberColors.cardBorder.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final activePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MiniGaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
