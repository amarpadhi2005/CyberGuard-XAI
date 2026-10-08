import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../domain/entities/threat_dna_campaign.dart';

class CoordinatedScamAlertBanner extends StatelessWidget {
  final ThreatDnaCampaign campaign;
  final bool isDetected;

  const CoordinatedScamAlertBanner({
    super.key,
    required this.campaign,
    this.isDetected = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isDetected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: CyberColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CyberColors.borderSubtle, width: 1),
          boxShadow: CyberColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CyberColors.primarySoftBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: CyberColors.primaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SINGLE THREAT MONITORED',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: CyberColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'No coordinated multi-vector attack detected at this stage.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: CyberColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: CyberColors.riskCriticalBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CyberColors.riskCritical.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: CyberColors.cardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Emergency Alert Badge + Confidence Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: CyberColors.riskCritical.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: CyberColors.riskCritical,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'FORENSIC CORRELATION ALERT',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: CyberColors.riskCritical,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: CyberColors.riskCritical.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${(campaign.confidence * 100).toInt()}% CONFIDENCE',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: CyberColors.riskCritical,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Possible coordinated scam activity detected.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: CyberColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Multi-Vector Attack Progression Chain
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: CyberColors.borderSubtle,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                _buildVectorPill(
                  icon: Icons.notifications_active_rounded,
                  label: 'SMS Alert',
                  color: CyberColors.riskWarning,
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: CyberColors.riskCritical,
                ),
                const SizedBox(width: 6),
                _buildVectorPill(
                  icon: Icons.language_rounded,
                  label: 'Phishing URL',
                  color: CyberColors.primaryBlue,
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: CyberColors.riskCritical,
                ),
                const SizedBox(width: 6),
                _buildVectorPill(
                  icon: Icons.phone_in_talk_rounded,
                  label: 'Scam Call',
                  color: CyberColors.riskCritical,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Cautious forensic note & risk escalation badge
          Row(
            children: [
              Expanded(
                child: Text(
                  'Events share temporal & brand correlation. Inferred as possible syndicate campaign.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: CyberColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: CyberColors.riskCritical.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      size: 13,
                      color: CyberColors.riskCritical,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${campaign.escalationBoost} RISK SURGE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: CyberColors.riskCritical,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVectorPill({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: CyberColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
