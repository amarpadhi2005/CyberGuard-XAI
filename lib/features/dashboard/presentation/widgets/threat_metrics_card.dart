import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';

class ThreatMetricsCard extends StatelessWidget {
  final int threatsBlockedToday;
  final int activeBreaches;

  const ThreatMetricsCard({
    super.key,
    required this.threatsBlockedToday,
    required this.activeBreaches,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(18),
      backgroundColor: CyberColors.darkBlueSurface.withOpacity(0.75),
      border: Border.all(
        color: CyberColors.neonPink.withOpacity(0.35),
        width: 1.2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: CyberColors.neonPink,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "TODAY'S THREAT TELEMETRY",
                    style: GoogleFonts.rajdhani(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                      color: CyberColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: CyberColors.neonPink.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'REAL-TIME MITIGATION',
                  style: GoogleFonts.rajdhani(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: CyberColors.neonPink,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Two Main Metric Pillars
          Row(
            children: [
              // Blocked Counter
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: CyberColors.cardBg.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CyberColors.darkBlueBorder,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$threatsBlockedToday',
                        style: GoogleFonts.rajdhani(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: CyberColors.neonPink,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'NEUTRALIZED',
                        style: GoogleFonts.rajdhani(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: CyberColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Zero-payload breaches',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: CyberColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Active Breaches Counter
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: CyberColors.cardBg.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CyberColors.darkBlueBorder,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$activeBreaches',
                        style: GoogleFonts.rajdhani(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: CyberColors.riskSafe,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ACTIVE COMPROMISES',
                        style: GoogleFonts.rajdhani(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: CyberColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Perimeter fully secured',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: CyberColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Threat Vectors breakdown row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildVectorBadge('Phishing URLs', '9', CyberColors.neonCyan),
              _buildVectorBadge('Malicious QR', '4', CyberColors.neonPink),
              _buildVectorBadge('VoIP Spoof', '3', CyberColors.riskWarning),
              _buildVectorBadge('Deepfake', '2', CyberColors.cyberPurple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVectorBadge(String name, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: CyberColors.textMuted,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            count,
            style: GoogleFonts.rajdhani(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
