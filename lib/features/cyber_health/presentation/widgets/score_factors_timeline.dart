import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../domain/entities/score_factor_event.dart';

class ScoreFactorsTimeline extends StatelessWidget {
  final List<ScoreFactorEvent> events;

  const ScoreFactorsTimeline({
    super.key,
    required this.events,
  });

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM dd').format(dt);
  }

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
                const Icon(Icons.receipt_long_rounded,
                    color: CyberColors.neonCyan, size: 18),
                const SizedBox(width: 8),
                Text(
                  'HEALTH SCORE AUDIT LOG',
                  style: GoogleFonts.rajdhani(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                    color: CyberColors.textPrimary,
                  ),
                ),
              ],
            ),
            Text(
              '${events.length} EVENTS',
              style: GoogleFonts.rajdhani(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: CyberColors.neonCyan,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (events.isEmpty)
          GlassmorphicContainer(
            borderRadius: 14,
            padding: const EdgeInsets.all(20),
            backgroundColor: CyberColors.darkBlueSurface.withOpacity(0.6),
            child: Center(
              child: Text(
                'NO SCORE ADJUSTMENTS LOGGED YET',
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: CyberColors.textDark,
                ),
              ),
            ),
          )
        else
          ...events.map((evt) {
            final isPositive = evt.pointsDelta > 0;
            final color = isPositive
                ? const Color(0xFF00FF9D)
                : CyberColors.riskCritical;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: GlassmorphicContainer(
                borderRadius: 12,
                padding: const EdgeInsets.all(12),
                backgroundColor: CyberColors.darkBlueSurface.withOpacity(0.6),
                border: Border.all(
                  color: color.withOpacity(0.25),
                  width: 1,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.12),
                      ),
                      child: Icon(evt.type.icon, color: color, size: 16),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  evt.title,
                                  style: GoogleFonts.rajdhani(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: CyberColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isPositive
                                      ? '+${evt.pointsDelta} PTS'
                                      : '${evt.pointsDelta} PTS',
                                  style: GoogleFonts.rajdhani(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  evt.description,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: CyberColors.textMuted,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatTime(evt.timestamp),
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: CyberColors.textDark,
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
          }),
      ],
    );
  }
}
