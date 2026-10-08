import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../../../core/widgets/cyber_button.dart';
import '../../domain/entities/call_scan_result.dart';

class TruecallerCard extends StatelessWidget {
  final CallScanResult result;
  final VoidCallback onBlock;
  final VoidCallback onDismiss;

  const TruecallerCard({
    super.key,
    required this.result,
    required this.onBlock,
    required this.onDismiss,
  });

  Color _getVerdictColor(CallVerdict verdict) {
    switch (verdict) {
      case CallVerdict.fraud:
        return CyberColors.criticalDanger;
      case CallVerdict.spam:
        return CyberColors.warning;
      case CallVerdict.safe:
        return CyberColors.success;
      case CallVerdict.unknown:
        return CyberColors.textSecondary;
    }
  }

  IconData _getVerdictIcon(CallVerdict verdict) {
    switch (verdict) {
      case CallVerdict.fraud:
        return Icons.gpp_bad_rounded;
      case CallVerdict.spam:
        return Icons.warning_amber_rounded;
      case CallVerdict.safe:
        return Icons.verified_rounded;
      case CallVerdict.unknown:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final verdictColor = _getVerdictColor(result.verdict);
    final isSafe = result.verdict == CallVerdict.safe;

    return Container(
      decoration: BoxDecoration(
        color: CyberColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CyberColors.borderSubtle, width: 1.0),
        boxShadow: const [CyberColors.cardShadow],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prototype Tag & Dismiss
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: CyberColors.primarySoft,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: CyberColors.primaryBorder,
                    width: 1,
                  ),
                ),
                child: Text(
                  'TELECOM FORENSIC AUDIT',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: CyberColors.primaryBlue,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: CyberColors.textSecondary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onDismiss,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Caller ID Main Header
          Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: verdictColor.withOpacity(0.12),
                  border: Border.all(color: verdictColor.withOpacity(0.4), width: 1.5),
                ),
                child: Icon(
                  _getVerdictIcon(result.verdict),
                  color: verdictColor,
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              // Caller Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            result.callerName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: CyberColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSafe)
                          const Padding(
                            padding: EdgeInsets.only(left: 4.0),
                            child: Icon(
                              Icons.verified,
                              size: 16,
                              color: CyberColors.success,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      result.formattedNumber,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: CyberColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${result.carrier} • ${result.location}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: CyberColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Verdict & Risk Score Badges
          Row(
            children: [
              // Verdict Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: verdictColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: verdictColor.withOpacity(0.4), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: verdictColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      result.verdict.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: verdictColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Category Pill
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: CyberColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CyberColors.borderSubtle, width: 1),
                  ),
                  child: Text(
                    result.callerCategory.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: CyberColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Risk Score Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: CyberColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CyberColors.borderSubtle, width: 1),
                ),
                child: Text(
                  '${result.riskScore}/100',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: verdictColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Community Reports Banner
          if (result.reportsCount > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: CyberColors.dangerSoft,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CyberColors.dangerBorder, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people_alt_outlined, size: 15, color: CyberColors.criticalDanger),
                  const SizedBox(width: 8),
                  Text(
                    'Reported by ${result.reportsCount} community members as ${result.verdict.label}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: CyberColors.criticalDanger,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Recommended Action Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSafe ? const Color(0xFFF0FDF4) : CyberColors.dangerSoft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSafe ? const Color(0xFFBBF7D0) : CyberColors.dangerBorder,
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isSafe ? Icons.check_circle_outline : Icons.shield_outlined,
                  size: 16,
                  color: verdictColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RECOMMENDED DEFENSE ACTION',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: verdictColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        result.recommendedAction,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: CyberColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Gemini Reasoning Explanation
          Text(
            'GEMINI & TELECOM INTELLIGENCE EXPLANATION',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: CyberColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            result.explanation,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: CyberColors.textPrimary,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 18),

          // Explain with XAI Action
          CyberButton(
            text: 'EXPLAIN WITH XAI (PLAIN ENGLISH)',
            icon: Icons.psychology_alt_rounded,
            variant: CyberButtonVariant.secondary,
            height: 40,
            onPressed: () {
              Navigator.pushNamed(context, '/xai-result');
            },
          ),

          const SizedBox(height: 10),

          // Action Buttons
          Row(
            children: [
              if (!isSafe) ...[
                Expanded(
                  child: CyberButton(
                    text: result.isBlocked ? 'BLOCKED' : 'BLOCK NUMBER',
                    icon: Icons.block,
                    variant: CyberButtonVariant.danger,
                    height: 42,
                    onPressed: result.isBlocked ? null : onBlock,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: CyberButton(
                  text: 'COPY NUMBER',
                  icon: Icons.copy,
                  variant: CyberButtonVariant.outline,
                  height: 42,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: result.phoneNumber));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Phone number copied to clipboard'),
                        backgroundColor: CyberColors.textPrimary,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
