import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../domain/entities/cyber_health_score.dart';

class HealthSuggestionsCard extends StatelessWidget {
  final List<HealthSuggestion> suggestions;
  final Function(String route)? onActionPressed;

  const HealthSuggestionsCard({
    super.key,
    required this.suggestions,
    this.onActionPressed,
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
                const Icon(Icons.tips_and_updates_outlined,
                    color: CyberColors.primaryBlue, size: 18),
                const SizedBox(width: 8),
                Text(
                  'HEALTH SCORE SUGGESTIONS',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: CyberColors.textPrimary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: CyberColors.primarySoftBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: CyberColors.primaryBlue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'TARGET: 1000 PTS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: CyberColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        ...suggestions.map((sug) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: CyberColors.surfaceCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: CyberColors.borderSubtle,
                  width: 1,
                ),
                boxShadow: CyberColors.cardShadow,
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CyberColors.primarySoftBg,
                      border: Border.all(
                        color: CyberColors.primaryBlue.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(sug.icon, color: CyberColors.primaryBlue, size: 18),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                sug.title,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: CyberColors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: CyberColors.riskSafeBg,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: CyberColors.statusSuccess.withOpacity(0.3),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                '+${sug.pointsBoost} PTS',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: CyberColors.statusSuccess,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Text(
                          sug.description,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: CyberColors.textSecondary,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 8),

                        InkWell(
                          onTap: () {
                            if (onActionPressed != null) {
                              onActionPressed!(sug.actionRoute);
                            } else {
                              Navigator.pushNamed(context, sug.actionRoute);
                            }
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'TAKE ACTION',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: CyberColors.primaryBlue,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_ios_rounded,
                                  size: 10, color: CyberColors.primaryBlue),
                            ],
                          ),
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
