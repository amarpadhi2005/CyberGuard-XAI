import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../domain/entities/call_scan_result.dart';

class IncomingCallOverlay extends StatefulWidget {
  final CallScanResult scanResult;
  final VoidCallback onDismiss;

  const IncomingCallOverlay({
    super.key,
    required this.scanResult,
    required this.onDismiss,
  });

  @override
  State<IncomingCallOverlay> createState() => _IncomingCallOverlayState();
}

class _IncomingCallOverlayState extends State<IncomingCallOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getVerdictColor(CallVerdict verdict) {
    switch (verdict) {
      case CallVerdict.fraud:
        return CyberColors.riskCritical;
      case CallVerdict.spam:
        return CyberColors.riskWarning;
      case CallVerdict.safe:
        return CyberColors.riskSafe;
      case CallVerdict.unknown:
        return CyberColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scan = widget.scanResult;
    final verdictColor = _getVerdictColor(scan.verdict);

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: SafeArea(
        child: Stack(
          children: [
            // Top Floating Truecaller Caller-ID Banner HUD
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: GlassmorphicContainer(
                borderRadius: 20,
                padding: const EdgeInsets.all(16),
                backgroundColor: CyberColors.darkBlueSurface.withOpacity(0.95),
                border: Border.all(color: verdictColor, width: 1.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.amber.withOpacity(0.5), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline, size: 12, color: Colors.amber),
                          const SizedBox(width: 6),
                          Text(
                            'SIMULATED CALL — No real call was placed.',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: verdictColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                scan.verdict.label,
                                style: GoogleFonts.rajdhani(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              scan.callerCategory.toUpperCase(),
                              style: GoogleFonts.rajdhani(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: CyberColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${scan.riskScore}/100 RISK',
                          style: GoogleFonts.rajdhani(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: verdictColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      scan.recommendedAction,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: verdictColor,
                      ),
                    ),
                    if (scan.reportsCount > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Truecaller Community: ${scan.reportsCount} users flagged as ${scan.verdict.label}',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: CyberColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Center Call Avatar & Number
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  // Pulsing Avatar Ring
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: verdictColor.withOpacity(0.15),
                            border: Border.all(color: verdictColor, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: verdictColor.withOpacity(0.35),
                                blurRadius: 24,
                              ),
                            ],
                          ),
                          child: Icon(
                            scan.verdict == CallVerdict.safe
                                ? Icons.call
                                : Icons.phone_locked_rounded,
                            size: 48,
                            color: verdictColor,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 36),

                  Text(
                    'INCOMING CALL...',
                    style: GoogleFonts.rajdhani(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                      color: CyberColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    scan.callerName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rajdhani(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      color: CyberColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    scan.formattedNumber,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: CyberColors.neonCyan,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '${scan.carrier} • ${scan.location}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: CyberColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Call Controls (Decline / Accept)
            Positioned(
              bottom: 40,
              left: 40,
              right: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Decline Button
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: widget.onDismiss,
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: CyberColors.riskCritical,
                            boxShadow: [
                              BoxShadow(
                                color: CyberColors.riskCritical.withOpacity(0.4),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.call_end_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'DECLINE',
                        style: GoogleFonts.rajdhani(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: CyberColors.textMuted,
                        ),
                      ),
                    ],
                  ),

                  // Accept Button
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          widget.onDismiss();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Call session simulation concluded.'),
                              backgroundColor: CyberColors.cardBg,
                            ),
                          );
                        },
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: CyberColors.riskSafe,
                            boxShadow: [
                              BoxShadow(
                                color: CyberColors.riskSafe.withOpacity(0.4),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.call_rounded,
                            color: Colors.black,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ACCEPT',
                        style: GoogleFonts.rajdhani(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: CyberColors.textMuted,
                        ),
                      ),
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
}
