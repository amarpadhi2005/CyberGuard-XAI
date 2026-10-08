import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';

class StatisticsGrid extends StatelessWidget {
  final int urlsInspected;
  final double interceptionRate;
  final int aiLatencyMs;

  const StatisticsGrid({
    super.key,
    required this.urlsInspected,
    required this.interceptionRate,
    required this.aiLatencyMs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.analytics_outlined,
                  color: CyberColors.neonCyan,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'DEFENSE TELEMETRY & STATS',
                  style: GoogleFonts.rajdhani(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                    color: CyberColors.textPrimary,
                  ),
                ),
              ],
            ),
            Text(
              'LIVE CLOUD FEED',
              style: GoogleFonts.rajdhani(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: CyberColors.textMuted,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // 2x2 Grid of Stat Cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'URLS INSPECTED',
                value: '${(urlsInspected / 1000).toStringAsFixed(1)}K',
                subtext: '99.8% Defanged',
                icon: Icons.link_rounded,
                accentColor: CyberColors.neonCyan,
                progress: 0.85,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'INTERCEPTION RATE',
                value: '$interceptionRate%',
                subtext: 'Zero Escape Rate',
                icon: Icons.shield_rounded,
                accentColor: CyberColors.riskSafe,
                progress: 0.999,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'AI INFERENCE',
                value: '${aiLatencyMs}ms',
                subtext: 'Gemini 2.5 Flash',
                icon: Icons.bolt_rounded,
                accentColor: CyberColors.neonPink,
                progress: 0.92,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'THREAT DNA CAMPAIGNS',
                value: '2 CLUSTERS',
                subtext: 'Neutralized (30d)',
                icon: Icons.hub_rounded,
                accentColor: CyberColors.cyberPurple,
                progress: 0.70,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color accentColor,
    required double progress,
  }) {
    return GlassmorphicContainer(
      borderRadius: 14,
      padding: const EdgeInsets.all(14),
      backgroundColor: CyberColors.darkBlueSurface.withOpacity(0.7),
      border: Border.all(
        color: CyberColors.darkBlueBorder,
        width: 1.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.rajdhani(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: CyberColors.textMuted,
                ),
              ),
              Icon(icon, size: 16, color: accentColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.rajdhani(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              color: CyberColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: CyberColors.cardBorder,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              minHeight: 3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtext,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
