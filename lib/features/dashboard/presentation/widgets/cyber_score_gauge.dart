import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';

class CyberScoreGauge extends StatefulWidget {
  final int score;
  final int maxScore;
  final int identityScore;
  final int networkScore;
  final int deviceScore;
  final bool isShieldActive;

  const CyberScoreGauge({
    super.key,
    required this.score,
    this.maxScore = 1000,
    required this.identityScore,
    required this.networkScore,
    required this.deviceScore,
    required this.isShieldActive,
  });

  @override
  State<CyberScoreGauge> createState() => _CyberScoreGaugeState();
}

class _CyberScoreGaugeState extends State<CyberScoreGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _scoreAnimation =
        Tween<double>(begin: 0, end: widget.score.toDouble()).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void didUpdateWidget(CyberScoreGauge oldWidget) {
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

  Color _getScoreColor(double score) {
    if (!widget.isShieldActive) return CyberColors.riskCritical;
    if (score >= 850) return const Color(0xFF00FF9D); // Emerald Neon
    if (score >= 700) return CyberColors.neonCyan;
    if (score >= 400) return CyberColors.riskWarning;
    return CyberColors.riskCritical;
  }

  String _getScoreTier(double score) {
    if (!widget.isShieldActive) return 'DEFENSE DEGRADED';
    if (score >= 850) return 'OPTIMAL POSTURE';
    if (score >= 700) return 'HARDENED';
    if (score >= 400) return 'VULNERABLE';
    return 'CRITICAL EXPOSURE';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getScoreColor(widget.score.toDouble());
    final tierLabel = _getScoreTier(widget.score.toDouble());

    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/cyber-health'),
      borderRadius: BorderRadius.circular(20),
      child: GlassmorphicContainer(
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        backgroundColor: CyberColors.darkBlueSurface.withOpacity(0.75),
        border: Border.all(
          color: statusColor.withOpacity(0.4),
          width: 1.2,
        ),
        child: Column(
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor,
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.8),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CYBER HEALTH SCORE',
                      style: GoogleFonts.rajdhani(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                        color: CyberColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: statusColor.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    tierLabel,
                    style: GoogleFonts.rajdhani(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Gauge Center Wheel (Scaled to 1000)
            AnimatedBuilder(
              animation: _scoreAnimation,
              builder: (context, child) {
                final progress =
                    (_scoreAnimation.value / widget.maxScore).clamp(0.0, 1.0);
                final dynamicColor = _getScoreColor(_scoreAnimation.value);

                return SizedBox(
                  width: 175,
                  height: 175,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(175, 175),
                        painter: _RadialScorePainter(
                          progress: progress,
                          glowColor: dynamicColor,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_scoreAnimation.value.toInt()}',
                            style: GoogleFonts.rajdhani(
                              fontSize: 46,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.0,
                              color: CyberColors.textPrimary,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            '/ ${widget.maxScore}',
                            style: GoogleFonts.rajdhani(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: CyberColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: dynamicColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'CYBER HEALTH',
                              style: GoogleFonts.rajdhani(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: dynamicColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Sub-scores Row (Identity, Network, Device)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: CyberColors.cardBg.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CyberColors.darkBlueBorder,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSubScoreItem(
                    'IDENTITY',
                    '${widget.identityScore}/1000',
                    CyberColors.neonCyan,
                    Icons.fingerprint,
                  ),
                  Container(
                      width: 1, height: 28, color: CyberColors.darkBlueBorder),
                  _buildSubScoreItem(
                    'NETWORK',
                    '${widget.networkScore}/1000',
                    CyberColors.neonPink,
                    Icons.wifi_tethering,
                  ),
                  Container(
                      width: 1, height: 28, color: CyberColors.darkBlueBorder),
                  _buildSubScoreItem(
                    'DEVICE',
                    '${widget.deviceScore}/1000',
                    const Color(0xFF00FF9D),
                    Icons.devices_other,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Suggestions & Audit Hint Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: CyberColors.neonCyan.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: CyberColors.neonCyan.withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tips_and_updates_rounded,
                          size: 14, color: CyberColors.neonCyan),
                      const SizedBox(width: 8),
                      Text(
                        'Suggestions available to reach 1000',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: CyberColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'AUDIT',
                        style: GoogleFonts.rajdhani(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: CyberColors.neonCyan,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 10, color: CyberColors.neonCyan),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubScoreItem(
      String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.rajdhani(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: CyberColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.rajdhani(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _RadialScorePainter extends CustomPainter {
  final double progress;
  final Color glowColor;

  _RadialScorePainter({required this.progress, required this.glowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    // Track circle background
    final bgPaint = Paint()
      ..color = CyberColors.cardBorder.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi,
      false,
      bgPaint,
    );

    // Glowing progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = SweepGradient(
          colors: [
            glowColor.withOpacity(0.2),
            glowColor,
            glowColor,
          ],
          stops: const [0.0, 0.7, 1.0],
          transform: const GradientRotation(-pi / 2),
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9.0
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        progressPaint,
      );
    }

    // Subtle outer tick marks
    final tickPaint = Paint()
      ..color = CyberColors.neonCyan.withOpacity(0.25)
      ..strokeWidth = 1.2;

    for (int i = 0; i < 36; i++) {
      final angle = (i * 10) * pi / 180;
      final outerX = center.dx + (radius + 8) * cos(angle);
      final outerY = center.dy + (radius + 8) * sin(angle);
      final innerX = center.dx + (radius + 4) * cos(angle);
      final innerY = center.dy + (radius + 4) * sin(angle);
      canvas.drawLine(Offset(innerX, innerY), Offset(outerX, outerY), tickPaint);
    }
  }

  @override
  bool shouldRepaint(_RadialScorePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.glowColor != glowColor;
  }
}
