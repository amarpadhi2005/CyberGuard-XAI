import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../domain/entities/call_scan_result.dart';

class CallHistoryTile extends StatelessWidget {
  final CallScanResult scan;
  final VoidCallback onTap;

  const CallHistoryTile({
    super.key,
    required this.scan,
    required this.onTap,
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

  @override
  Widget build(BuildContext context) {
    final color = _getVerdictColor(scan.verdict);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: CyberColors.surfaceCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: CyberColors.borderSubtle, width: 1.0),
            boxShadow: const [CyberColors.cardShadow],
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.12),
                ),
                child: Icon(
                  scan.verdict == CallVerdict.safe
                      ? Icons.verified_rounded
                      : Icons.phone_locked_rounded,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            scan.callerName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: CyberColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            scan.verdict.label,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      scan.formattedNumber,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: CyberColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${scan.carrier} • ${scan.location}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: CyberColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${scan.riskScore}/100',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
