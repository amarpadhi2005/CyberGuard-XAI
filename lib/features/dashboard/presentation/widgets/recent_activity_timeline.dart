import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../controllers/dashboard_controller.dart';

class RecentActivityTimeline extends StatelessWidget {
  const RecentActivityTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();
    final activities = controller.activities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.history_toggle_off_rounded,
                  color: CyberColors.neonCyan,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'RECENT SECURITY AUDIT TRAIL',
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
              'CONTINUOUS LOG',
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

        GlassmorphicContainer(
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          backgroundColor: CyberColors.darkBlueSurface.withOpacity(0.7),
          border: Border.all(
            color: CyberColors.darkBlueBorder,
            width: 1.0,
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(left: 17.0),
              child: Container(
                width: 2,
                height: 14,
                color: CyberColors.darkBlueBorder,
              ),
            ),
            itemBuilder: (context, index) {
              final act = activities[index];

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline Node Circle
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CyberColors.cardBg,
                          border: Border.all(
                            color: CyberColors.neonCyan,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: CyberColors.neonCyan.withOpacity(0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 14),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                act.title,
                                style: GoogleFonts.rajdhani(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: CyberColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: CyberColors.neonCyan.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                act.category,
                                style: GoogleFonts.rajdhani(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: CyberColors.neonCyan,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          act.details,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: CyberColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 11,
                              color: CyberColors.textDark,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              act.timestamp,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: CyberColors.textDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.check_circle_outline,
                              size: 11,
                              color: CyberColors.riskSafe,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'VERIFIED SECURE',
                              style: GoogleFonts.rajdhani(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: CyberColors.riskSafe,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
