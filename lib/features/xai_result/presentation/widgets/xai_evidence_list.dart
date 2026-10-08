import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../domain/entities/xai_result_model.dart';

class XaiEvidenceList extends StatelessWidget {
  final List<XaiEvidenceItem> evidence;

  const XaiEvidenceList({
    super.key,
    required this.evidence,
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
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: CyberColors.softBlueBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.fingerprint_rounded,
                      color: CyberColors.primary, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  'OBSERVED FORENSIC EVIDENCE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: CyberColors.textPrimary,
                  ),
                ),
              ],
            ),
            Text(
              '${evidence.length} INDICATORS',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: CyberColors.primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        ...evidence.map((item) {
          final impactPct = (item.severityWeight * 100).toInt();
          final Color color = !item.isFlagged
              ? CyberColors.success
              : (item.severityWeight >= 0.85
                  ? CyberColors.danger
                  : (item.severityWeight >= 0.5
                      ? CyberColors.warning
                      : CyberColors.primary));

          final softBg = !item.isFlagged
              ? CyberColors.softSuccessBg
              : (item.severityWeight >= 0.85
                  ? CyberColors.softDangerBg
                  : (item.severityWeight >= 0.5
                      ? CyberColors.softWarningBg
                      : CyberColors.softBlueBg));

          final softBorder = !item.isFlagged
              ? CyberColors.softSuccessBorder
              : (item.severityWeight >= 0.85
                  ? CyberColors.softDangerBorder
                  : (item.severityWeight >= 0.5
                      ? CyberColors.softWarningBorder
                      : CyberColors.softBlueBorder));

          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: item.isFlagged && item.severityWeight >= 0.85
                      ? CyberColors.softDangerBorder
                      : CyberColors.cardBorder,
                  width: 1.0,
                ),
                boxShadow: CyberColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: softBg,
                          border: Border.all(color: softBorder, width: 1.0),
                        ),
                        child: Icon(item.icon, size: 16, color: color),
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
                                    item.title,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: CyberColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: softBg,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: softBorder, width: 1.0),
                                  ),
                                  child: Text(
                                    item.isFlagged
                                        ? '$impactPct% IMPACT'
                                        : 'VERIFIED',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.description,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: CyberColors.textSecondary,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Mini Impact Weight Progress Bar
                  if (item.isFlagged) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'THREAT WEIGHT',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: CyberColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: item.severityWeight,
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                              minHeight: 5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
