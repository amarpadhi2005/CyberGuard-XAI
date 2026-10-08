import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../domain/entities/threat_dna_campaign.dart';

class ThreatDnaCard extends StatelessWidget {
  final ThreatDnaCampaign campaign;

  const ThreatDnaCard({
    super.key,
    required this.campaign,
  });

  @override
  Widget build(BuildContext context) {
    final isCritical = campaign.escalatedRiskScore >= 80;
    final accentColor = isCritical ? CyberColors.riskCritical : CyberColors.primaryBlue;

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
          // Header with Chip Icon + Campaign ID + Confidence Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isCritical ? CyberColors.riskCriticalBg : CyberColors.primarySoftBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: accentColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.fingerprint_rounded,
                  color: accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'THREAT DNA PROFILE',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: accentColor,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: CyberColors.surfaceSecondary,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: CyberColors.borderSubtle,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            campaign.campaignId,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: CyberColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      campaign.targetBrand,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: CyberColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // DNA Fingerprint Bar with One-Tap Copy
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                Icon(
                  Icons.hub_outlined,
                  size: 15,
                  color: CyberColors.primaryBlue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    campaign.dnaFingerprint,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: CyberColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: campaign.dnaFingerprint));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Threat DNA Fingerprint copied to clipboard',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12),
                        ),
                        duration: const Duration(seconds: 2),
                        backgroundColor: CyberColors.textPrimary,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.copy_rounded,
                      size: 14,
                      color: CyberColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Key Metrics Grid (Escalated Risk, Vectors, Time Span)
          Row(
            children: [
              _buildMetricTile(
                title: 'ESCALATED RISK',
                value: '${campaign.escalatedRiskScore}',
                unit: '/100',
                color: campaign.severityColor,
                subtext: '+${campaign.escalationBoost} boost',
              ),
              const SizedBox(width: 8),
              _buildMetricTile(
                title: 'CONVERGENCE',
                value: '${campaign.timeSpanMinutes}',
                unit: 'min',
                color: CyberColors.primaryBlue,
                subtext: '${campaign.eventCount} channels',
              ),
              const SizedBox(width: 8),
              _buildMetricTile(
                title: 'INFERENCE',
                value: '${(campaign.confidence * 100).toInt()}%',
                unit: '',
                color: isCritical ? CyberColors.riskCritical : CyberColors.primaryBlue,
                subtext: 'Correlation',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Section Divider
          Divider(
            color: CyberColors.borderSubtle,
            thickness: 1,
            height: 1,
          ),

          const SizedBox(height: 14),

          // Correlation Evidence Header
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 15,
                color: CyberColors.primaryBlue,
              ),
              const SizedBox(width: 6),
              Text(
                'CORRELATION EVIDENCE (HEURISTIC INFERENCE)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: CyberColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Evidence Bullet Points
          ...campaign.correlationEvidence.map((evidence) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CyberColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      evidence,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: CyberColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),

          // Disclaimer Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: CyberColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: CyberColors.borderSubtle,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 13,
                  color: CyberColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Correlations represent possible rather than confirmed multi-vector coordination.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      color: CyberColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String unit,
    required Color color,
    required String subtext,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: CyberColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: CyberColors.borderSubtle,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: CyberColors.textSecondary,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 2),
                  Text(
                    unit,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      color: CyberColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(
              subtext,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9.5,
                color: CyberColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
