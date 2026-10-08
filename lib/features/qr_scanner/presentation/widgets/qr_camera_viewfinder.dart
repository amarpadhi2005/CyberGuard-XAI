import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';

class QrCameraViewfinder extends StatefulWidget {
  final bool isScanning;
  final double scanWindowSize;

  const QrCameraViewfinder({
    super.key,
    this.isScanning = true,
    this.scanWindowSize = 260.0,
  });

  @override
  State<QrCameraViewfinder> createState() => _QrCameraViewfinderState();
}

class _QrCameraViewfinderState extends State<QrCameraViewfinder>
    with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  late Animation<double> _laserPosition;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _laserPosition = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.scanWindowSize;

    return Stack(
      children: [
        // Hardware-accelerated transparent cutout overlay over live camera feed
        CustomPaint(
          size: Size.infinite,
          painter: _QrCutoutOverlayPainter(
            scanWindowSize: size,
            borderRadius: 24.0,
            overlayColor: Colors.black.withOpacity(0.60),
          ),
        ),

        // Corner brackets and scan target box
        Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                // Soft boundary border
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: CyberColors.primary.withOpacity(0.35),
                      width: 1.5,
                    ),
                  ),
                ),

                // Corner Reticle Indicators
                const Positioned(
                  top: 0,
                  left: 0,
                  child: _CornerBracket(isTop: true, isLeft: true),
                ),
                const Positioned(
                  top: 0,
                  right: 0,
                  child: _CornerBracket(isTop: true, isLeft: false),
                ),
                const Positioned(
                  bottom: 0,
                  left: 0,
                  child: _CornerBracket(isTop: false, isLeft: true),
                ),
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: _CornerBracket(isTop: false, isLeft: false),
                ),

                // Animated Laser Line
                if (widget.isScanning)
                  AnimatedBuilder(
                    animation: _laserPosition,
                    builder: (context, child) {
                      return Positioned(
                        top: size * _laserPosition.value,
                        left: 16,
                        right: 16,
                        child: Container(
                          height: 2.5,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                CyberColors.primary,
                                Color(0xFF60A5FA),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: CyberColors.primary.withOpacity(0.8),
                                blurRadius: 10,
                                spreadRadius: 1.5,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),

        // Scanning Guidance Label
        Positioned(
          left: 20,
          right: 20,
          top: (MediaQuery.of(context).size.height / 2) + (size / 2) + 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Position the QR code inside the frame',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Instant on-device detection & forensic inspection',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),

        // Strict Privacy Notice Badge (Requirement 21)
        Positioned(
          left: 24,
          right: 24,
          bottom: 30,
          child: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF334155),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    color: Color(0xFF60A5FA),
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your camera is used only to detect QR codes. Camera frames are not stored or uploaded.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFE2E8F0),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CornerBracket extends StatelessWidget {
  final bool isTop;
  final bool isLeft;

  const _CornerBracket({required this.isTop, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    const double length = 26.0;
    const double thickness = 3.5;
    const color = CyberColors.primary;

    return Container(
      width: length,
      height: length,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? const BorderSide(color: color, width: thickness)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(color: color, width: thickness)
              : BorderSide.none,
          left: isLeft
              ? const BorderSide(color: color, width: thickness)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(color: color, width: thickness)
              : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: isTop && isLeft ? const Radius.circular(14) : Radius.zero,
          topRight: isTop && !isLeft ? const Radius.circular(14) : Radius.zero,
          bottomLeft: !isTop && isLeft ? const Radius.circular(14) : Radius.zero,
          bottomRight: !isTop && !isLeft ? const Radius.circular(14) : Radius.zero,
        ),
      ),
    );
  }
}

class _QrCutoutOverlayPainter extends CustomPainter {
  final double scanWindowSize;
  final double borderRadius;
  final Color overlayColor;

  _QrCutoutOverlayPainter({
    required this.scanWindowSize,
    required this.borderRadius,
    required this.overlayColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanWindowSize,
      height: scanWindowSize,
    );

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(cutoutRect, Radius.circular(borderRadius)),
      );

    // Punch out the viewfinder window cleanly from the dark backdrop
    final finalPath = Path.combine(PathOperation.difference, backgroundPath, cutoutPath);

    final paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(finalPath, paint);
  }

  @override
  bool shouldRepaint(covariant _QrCutoutOverlayPainter oldDelegate) {
    return oldDelegate.scanWindowSize != scanWindowSize ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.overlayColor != overlayColor;
  }
}
