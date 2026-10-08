import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../../../core/widgets/cyber_button.dart';
import '../controllers/dashboard_controller.dart';

class QuickScanCard extends StatelessWidget {
  const QuickScanCard({super.key});

  void _openQuickScanModal(BuildContext context) {
    final controller = context.read<DashboardController>();
    controller.startQuickScan();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _QuickScanModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(18),
      backgroundColor: CyberColors.darkBlueSurface.withOpacity(0.8),
      border: Border.all(
        color: CyberColors.neonCyan.withOpacity(0.4),
        width: 1.2,
      ),
      child: Row(
        children: [
          // Radar Icon with subtle glow
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CyberColors.cardBg,
              border: Border.all(
                color: CyberColors.neonCyan,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: CyberColors.neonCyan.withOpacity(0.3),
                  blurRadius: 16,
                ),
              ],
            ),
            child: const Icon(
              Icons.radar_rounded,
              color: CyberColors.neonCyan,
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          // Scan Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AUTONOMOUS QUICK SCAN',
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: CyberColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Inspect memory, endpoints & deepfake streams',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: CyberColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Action Button
          CyberButton(
            text: 'SCAN',
            icon: Icons.play_arrow_rounded,
            height: 38,
            width: 95,
            onPressed: () => _openQuickScanModal(context),
          ),
        ],
      ),
    );
  }
}

class _QuickScanModal extends StatefulWidget {
  const _QuickScanModal();

  @override
  State<_QuickScanModal> createState() => _QuickScanModalState();
}

class _QuickScanModalState extends State<_QuickScanModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();
    final isDone = controller.scanProgress >= 1.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: CyberColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: CyberColors.neonCyan.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: CyberColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 20),

            // Header
            Text(
              isDone ? 'DEFENSE AUDIT COMPLETED' : 'NEURAL SHIELD SCANNING',
              style: GoogleFonts.rajdhani(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: isDone ? CyberColors.riskSafe : CyberColors.neonCyan,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Zero-Trust Heuristic & Memory Inspection',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: CyberColors.textMuted,
              ),
            ),

            const SizedBox(height: 28),

            // Animated Radar Display
            SizedBox(
              width: 160,
              height: 160,
              child: AnimatedBuilder(
                animation: _radarController,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(160, 160),
                    painter: _RadarScanPainter(
                      angle: _radarController.value * 2 * pi,
                      isDone: isDone,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 28),

            // Live Target Text
            Text(
              controller.scanStatusText,
              textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: isDone ? CyberColors.riskSafe : CyberColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: controller.scanProgress,
                backgroundColor: CyberColors.cardBorder,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDone ? CyberColors.riskSafe : CyberColors.neonCyan,
                ),
                minHeight: 6,
              ),
            ),

            const SizedBox(height: 12),

            // Stats Sub-row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(controller.scanProgress * 100).toInt()}% COMPLETED',
                  style: GoogleFonts.rajdhani(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: CyberColors.neonCyan,
                  ),
                ),
                Text(
                  '${controller.scannedItemsCount} OBJECTS SCANNED',
                  style: GoogleFonts.rajdhani(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: CyberColors.textMuted,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Dismiss or Close Button
            CyberButton(
              text: isDone ? 'CLOSE PROTOCOL' : 'ABORT SCAN',
              variant: isDone ? CyberButtonVariant.primary : CyberButtonVariant.outline,
              onPressed: () {
                if (!isDone) {
                  controller.cancelScan();
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RadarScanPainter extends CustomPainter {
  final double angle;
  final bool isDone;

  _RadarScanPainter({required this.angle, required this.isDone});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final color = isDone ? CyberColors.riskSafe : CyberColors.neonCyan;

    // Rings
    final ringPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius, ringPaint);
    canvas.drawCircle(center, radius * 0.66, ringPaint);
    canvas.drawCircle(center, radius * 0.33, ringPaint);

    // Crosshairs
    final linePaint = Paint()
      ..color = color.withOpacity(0.15)
      ..strokeWidth = 0.8;
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), linePaint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), linePaint);

    if (isDone) {
      // Draw Checkmark
      final checkPaint = Paint()
        ..color = CyberColors.riskSafe
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;

      final path = Path()
        ..moveTo(center.dx - 20, center.dy)
        ..lineTo(center.dx - 5, center.dy + 15)
        ..lineTo(center.dx + 25, center.dy - 15);

      canvas.drawPath(path, checkPaint);
      return;
    }

    // Rotating Sweep Arc
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          color.withOpacity(0.35),
        ],
        stops: const [0.8, 1.0],
        transform: GradientRotation(angle),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, sweepPaint);

    // Sweep Leading Needle
    final needlePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0;

    final needleEnd = Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );
    canvas.drawLine(center, needleEnd, needlePaint);
  }

  @override
  bool shouldRepaint(_RadarScanPainter oldDelegate) {
    return oldDelegate.angle != angle || oldDelegate.isDone != isDone;
  }
}
