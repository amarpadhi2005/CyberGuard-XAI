import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';

class ProtectionStatusBanner extends StatefulWidget {
  final bool isShieldActive;
  final VoidCallback onToggle;

  const ProtectionStatusBanner({
    super.key,
    required this.isShieldActive,
    required this.onToggle,
  });

  @override
  State<ProtectionStatusBanner> createState() => _ProtectionStatusBannerState();
}

class _ProtectionStatusBannerState extends State<ProtectionStatusBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
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
    final activeColor = widget.isShieldActive ? CyberColors.riskSafe : CyberColors.riskCritical;

    return GlassmorphicContainer(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      backgroundColor: CyberColors.darkBlueSurface.withOpacity(0.7),
      border: Border.all(
        color: activeColor.withOpacity(0.4),
        width: 1.0,
      ),
      child: Row(
        children: [
          // Animated Pulsing Status Dot
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeColor.withOpacity(0.12),
                  boxShadow: widget.isShieldActive
                      ? [
                          BoxShadow(
                            color: activeColor.withOpacity(0.35 * _glowAnimation.value),
                            blurRadius: 16 * _glowAnimation.value,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
                child: child,
              );
            },
            child: Icon(
              widget.isShieldActive ? Icons.verified_user : Icons.gpp_bad,
              color: activeColor,
              size: 24,
            ),
          ),

          const SizedBox(width: 14),

          // Status Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isShieldActive
                      ? 'AI SHIELD ACTIVE'
                      : 'PROTECTION COMPROMISED',
                  style: GoogleFonts.rajdhani(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: widget.isShieldActive
                        ? CyberColors.textPrimary
                        : CyberColors.riskCritical,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.isShieldActive
                      ? '4/4 Neural defense layers armed'
                      : 'Real-time telemetry & firewall offline',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: CyberColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Cyber Switch Toggle
          GestureDetector(
            onTap: widget.onToggle,
            child: Container(
              width: 50,
              height: 28,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: widget.isShieldActive
                    ? CyberColors.neonCyan.withOpacity(0.2)
                    : CyberColors.cardBorder,
                border: Border.all(
                  color: widget.isShieldActive
                      ? CyberColors.neonCyan
                      : CyberColors.textDark,
                  width: 1.2,
                ),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: widget.isShieldActive
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isShieldActive
                        ? CyberColors.neonCyan
                        : CyberColors.textMuted,
                    boxShadow: widget.isShieldActive
                        ? [
                            BoxShadow(
                              color: CyberColors.neonCyan.withOpacity(0.6),
                              blurRadius: 8,
                            ),
                          ]
                        : [],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
