import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';

class ThreatScreenshotPicker extends StatelessWidget {
  final bool hasScreenshot;
  final String screenshotName;
  final VoidCallback onToggle;

  const ThreatScreenshotPicker({
    super.key,
    required this.hasScreenshot,
    required this.screenshotName,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CyberColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CyberColors.borderSubtle, width: 1),
        boxShadow: CyberColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: hasScreenshot
                          ? CyberColors.riskCriticalBg
                          : CyberColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: hasScreenshot
                          ? CyberColors.riskCritical
                          : CyberColors.textSecondary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'THREAT SCREENSHOT EVIDENCE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: CyberColors.textPrimary,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: hasScreenshot
                        ? CyberColors.riskCriticalBg
                        : CyberColors.primarySoftBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: hasScreenshot
                          ? CyberColors.riskCritical.withOpacity(0.3)
                          : CyberColors.primaryBlue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    hasScreenshot ? 'DETACH' : 'ATTACH EVIDENCE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: hasScreenshot
                          ? CyberColors.riskCritical
                          : CyberColors.primaryBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Evidence Preview Box
          if (hasScreenshot)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CyberColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: CyberColors.borderSubtle,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: CyberColors.riskCriticalBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: CyberColors.riskCritical.withOpacity(0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.image_outlined,
                      color: CyberColors.riskCritical,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          screenshotName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: CyberColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(
                              Icons.verified_outlined,
                              size: 12,
                              color: CyberColors.riskSafe,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'SHA-256 DIGITAL WATERMARK SEALED',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: CyberColors.riskSafe,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              'Attach a screenshot of deceptive SMS, phishing website, or wire instructions to corroborate the incident report.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: CyberColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
