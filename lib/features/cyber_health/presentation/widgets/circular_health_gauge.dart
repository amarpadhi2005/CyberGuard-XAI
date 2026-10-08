import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../domain/entities/cyber_health_score.dart';

class CircularHealthGauge extends StatefulWidget {
  final int score;
  final int maxScore;
  final HealthTier tier;
  final double size;

  const CircularHealthGauge({
    super.key,
    required this.score,
    this.maxScore = CyberHealthScore.maxScore,
    required this.tier,
    this.size = 220,
  });

  @override
  State<CircularHealthGauge> createState() => _CircularHealthGaugeState();
}

class _CircularHealthGaugeState extends State<CircularHealthGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scoreAnimation =
        Tween<double>(begin: 0, end: widget.score.toDouble()).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();
  }

  @override
  void didUpdateWidget(CircularHealthGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _scoreAnimation = Tween<double>(
        begin: _scoreAnimation.value,
        end: widget.score.toDouble(),
      ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
      );
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.tier.color;

    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        final currentVal = _scoreAnimation.value.toInt();
        final progress = (_scoreAnimation.value / widget.maxScore).clamp(0.0, 1.0);

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Radial Painter with crisp track & sweep arc
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CircularGaugePainter(
                  progress: progress,
                  themeColor: color,
                ),
              ),

              // Central Score & Readouts
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$currentVal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: widget.size * 0.22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.0,
                      color: CyberColors.textPrimary,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'OF ${widget.maxScore} PTS',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: widget.size * 0.055,
                      fontWeight: FontWeight.w600,
                      color: CyberColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.3), width: 1),
                    ),
                    child: Text(
                      widget.tier.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: widget.size * 0.046,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CircularGaugePainter extends CustomPainter {
  final double progress;
  final Color themeColor;

  _CircularGaugePainter({
    required this.progress,
    required this.themeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;
    const startAngle = -pi / 2; // Start at 12 o'clock
    final sweepAngle = 2 * pi * progress;

    // 1. Ambient Background Track Ring
    final trackPaint = Paint()
      ..color = CyberColors.borderSubtle
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // 2. Main Active Progress Sweep Arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = themeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10.0
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );

      // 3. Crisp Head Cap Dot
      final headAngle = startAngle + sweepAngle;
      final headX = center.dx + radius * cos(headAngle);
      final headY = center.dy + radius * sin(headAngle);

      final dotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      final dotBorder = Paint()
        ..color = themeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      canvas.drawCircle(Offset(headX, headY), 5.0, dotPaint);
      canvas.drawCircle(Offset(headX, headY), 5.0, dotBorder);
    }

    // 4. Outer Subtle Tick Marks
    final tickPaint = Paint()
      ..color = CyberColors.borderSubtle
      ..strokeWidth = 1.0;

    const totalTicks = 36;
    for (int i = 0; i < totalTicks; i++) {
      final tickAngle = (2 * pi / totalTicks) * i;
      final isMajor = i % 9 == 0;
      final outerR = size.width / 2 - 2;
      final innerR = isMajor ? size.width / 2 - 7 : size.width / 2 - 4;

      final p1 = Offset(
        center.dx + innerR * cos(tickAngle),
        center.dy + innerR * sin(tickAngle),
      );
      final p2 = Offset(
        center.dx + outerR * cos(tickAngle),
        center.dy + outerR * sin(tickAngle),
      );

      tickPaint.color = isMajor
          ? themeColor.withOpacity(0.5)
          : CyberColors.borderSubtle;
      canvas.drawLine(p1, p2, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CircularGaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.themeColor != themeColor;
  }
}
