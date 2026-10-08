import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../domain/entities/threat_dna_campaign.dart';

class RiskTrendChart extends StatelessWidget {
  final List<RiskTrendPoint> trendPoints;
  final int currentRiskScore;
  final int escalationBoost;

  const RiskTrendChart({
    super.key,
    required this.trendPoints,
    required this.currentRiskScore,
    required this.escalationBoost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CyberColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CyberColors.borderSubtle, width: 1),
        boxShadow: CyberColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: CyberColors.primarySoftBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.show_chart_rounded,
                      color: CyberColors.primaryBlue,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'OVERALL RISK TREND',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: CyberColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: CyberColors.riskCriticalBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: CyberColors.riskCritical.withOpacity(0.3),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  'CRITICAL SURGE (+$escalationBoost PTS)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: CyberColors.riskCritical,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            'Dynamic threat amplification calculated as multi-vector correlation confidence rises.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: CyberColors.textSecondary,
            ),
          ),

          const SizedBox(height: 18),

          // Custom Painted Chart
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CustomPaint(
              painter: _RiskTrendPainter(points: trendPoints),
            ),
          ),

          const SizedBox(height: 14),

          // Stage Value Indicators at the bottom
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: trendPoints.map((point) {
              final isLatest = point == trendPoints.last;
              final color = isLatest
                  ? CyberColors.riskCritical
                  : (point.riskScore >= 80 ? CyberColors.riskCritical : CyberColors.riskWarning);

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  decoration: BoxDecoration(
                    color: CyberColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isLatest ? color.withOpacity(0.4) : CyberColors.borderSubtle,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        point.label.split(':')[0],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: CyberColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${point.riskScore}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                      Text(
                        point.timestampStr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          color: CyberColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _RiskTrendPainter extends CustomPainter {
  final List<RiskTrendPoint> points;

  _RiskTrendPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const double paddingLeft = 32.0;
    const double paddingRight = 24.0;
    const double paddingTop = 16.0;
    const double paddingBottom = 24.0;

    final drawWidth = size.width - paddingLeft - paddingRight;
    final drawHeight = size.height - paddingTop - paddingBottom;

    // Draw horizontal threshold grid lines (40 = Safe, 75 = Warning, 100 = Critical)
    final gridPaint = Paint()
      ..color = CyberColors.borderSubtle
      ..strokeWidth = 0.8;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final thresholds = [40, 75, 100];
    for (final th in thresholds) {
      final y = paddingTop + drawHeight * (1.0 - (th / 100.0));
      canvas.drawLine(
        Offset(paddingLeft, y),
        Offset(size.width - paddingRight, y),
        gridPaint,
      );

      textPainter.text = TextSpan(
        text: '$th',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 8.5,
          fontWeight: FontWeight.w600,
          color: CyberColors.textSecondary,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(8, y - 6));
    }

    // Compute coordinate points
    final List<Offset> offsets = [];
    final count = points.length;

    for (int i = 0; i < count; i++) {
      final x = count == 1
          ? paddingLeft + drawWidth / 2
          : paddingLeft + (i / (count - 1)) * drawWidth;
      final y = paddingTop + drawHeight * (1.0 - (points[i].riskScore / 100.0));
      offsets.add(Offset(x, y));
    }

    // Build Curve Path
    final path = Path();
    path.moveTo(offsets[0].dx, offsets[0].dy);

    for (int i = 0; i < offsets.length - 1; i++) {
      final p0 = offsets[i];
      final p1 = offsets[i + 1];
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
    }

    // Draw Gradient Filled Area (Soft red tint)
    final fillPath = Path.from(path);
    fillPath.lineTo(offsets.last.dx, paddingTop + drawHeight);
    fillPath.lineTo(offsets.first.dx, paddingTop + drawHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, paddingTop),
        Offset(0, paddingTop + drawHeight),
        [
          CyberColors.riskCritical.withOpacity(0.15),
          CyberColors.riskCritical.withOpacity(0.02),
        ],
        [0.0, 1.0],
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw Crisp Line Stroke
    final strokePaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(offsets.first.dx, 0),
        Offset(offsets.last.dx, 0),
        [
          CyberColors.riskWarning,
          CyberColors.riskCritical,
        ],
      )
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, strokePaint);

    // Draw Clean Data Points
    for (int i = 0; i < offsets.length; i++) {
      final pt = offsets[i];
      final isLatest = i == offsets.length - 1;
      final nodeColor = isLatest
          ? CyberColors.riskCritical
          : (points[i].riskScore >= 80 ? CyberColors.riskCritical : CyberColors.riskWarning);

      // Clean circle with white center and colored outline
      canvas.drawCircle(
        pt,
        isLatest ? 5.0 : 4.0,
        Paint()..color = nodeColor,
      );

      canvas.drawCircle(
        pt,
        isLatest ? 2.5 : 2.0,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RiskTrendPainter oldDelegate) => true;
}
