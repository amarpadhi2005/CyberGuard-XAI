import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';

class EmergencySosButton extends StatefulWidget {
  final bool isSosActive;
  final bool isTriggering;
  final int countdownSeconds;
  final VoidCallback onTrigger;
  final VoidCallback onCancel;

  const EmergencySosButton({
    super.key,
    required this.isSosActive,
    required this.isTriggering,
    required this.countdownSeconds,
    required this.onTrigger,
    required this.onCancel,
  });

  @override
  State<EmergencySosButton> createState() => _EmergencySosButtonState();
}

class _EmergencySosButtonState extends State<EmergencySosButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.4, end: 0.95).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTriggering = widget.isTriggering;
    final isActive = widget.isSosActive;

    return Column(
      children: [
        Center(
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = (isTriggering || isActive) ? _scaleAnimation.value : 1.0;

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 184,
                  height: 184,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: CyberColors.riskCritical.withOpacity((isTriggering || isActive) ? 0.35 : 0.2),
                        blurRadius: (isTriggering || isActive) ? 30 : 20,
                        spreadRadius: (isTriggering || isActive) ? 6 : 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer Subtle Ring
                      Container(
                        width: 184,
                        height: 184,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: CyberColors.riskCritical.withOpacity(0.25),
                            width: 2.5,
                          ),
                        ),
                      ),

                      // Secondary Inner Ring
                      Container(
                        width: 164,
                        height: 164,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                      ),

                      // Solid Pressable Button Core
                      Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          splashColor: Colors.white.withOpacity(0.2),
                          onTap: isTriggering
                              ? null
                              : () {
                                  if (isActive) {
                                    widget.onCancel();
                                  } else {
                                    widget.onTrigger();
                                  }
                                },
                          child: Ink(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFEF4444),
                                  Color(0xFFDC2626),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isActive
                                      ? Icons.warning_rounded
                                      : (isTriggering
                                          ? Icons.hourglass_top_rounded
                                          : Icons.emergency_rounded),
                                  color: Colors.white,
                                  size: 38,
                                ),
                                const SizedBox(height: 4),
                                if (isTriggering) ...[
                                  Text(
                                    '${widget.countdownSeconds}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1.0,
                                    ),
                                  ),
                                  Text(
                                    'DISPATCHING...',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white.withOpacity(0.9),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ] else if (isActive) ...[
                                  Text(
                                    'SOS ACTIVE',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  Text(
                                    'TAP TO STAND-DOWN',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white.withOpacity(0.9),
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ] else ...[
                                  Text(
                                    'EMERGENCY',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white.withOpacity(0.85),
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  Text(
                                    'S.O.S.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 1.5,
                                      height: 1.1,
                                    ),
                                  ),
                                  Text(
                                    'TAP TO TRIGGER',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white.withOpacity(0.8),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 18),

        // Cancel Trigger Button if countdown is active
        if (isTriggering)
          OutlinedButton.icon(
            onPressed: widget.onCancel,
            icon: const Icon(Icons.close_rounded, color: CyberColors.riskCritical, size: 18),
            label: Text(
              'CANCEL EMERGENCY DISPATCH',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: CyberColors.riskCritical,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: CyberColors.riskCritical, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          )
        else
          Text(
            isActive
                ? 'Emergency beacon broadcast transmitted to trusted circle & Firestore'
                : 'Locks telemetry • Prepares incident dossier • Alerts trusted contacts',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              color: isActive ? CyberColors.riskCritical : CyberColors.textSecondary,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
