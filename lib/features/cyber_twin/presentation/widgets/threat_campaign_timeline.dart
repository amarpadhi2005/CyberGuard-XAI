import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../domain/entities/threat_dna_campaign.dart';

class ThreatCampaignTimeline extends StatefulWidget {
  final List<ThreatDnaTimelineStep> timeline;

  const ThreatCampaignTimeline({
    super.key,
    required this.timeline,
  });

  @override
  State<ThreatCampaignTimeline> createState() => _ThreatCampaignTimelineState();
}

class _ThreatCampaignTimelineState extends State<ThreatCampaignTimeline> {
  int? _expandedStepIndex;

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
          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: CyberColors.primarySoftBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.timeline_rounded,
                      color: CyberColors.primaryBlue,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'MULTI-STAGE THREAT TIMELINE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
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
                    width: 0.8,
                  ),
                ),
                child: Text(
                  '${widget.timeline.length} CONVERGENT EVENTS',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: CyberColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Chronological Steps
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.timeline.length,
            itemBuilder: (context, index) {
              final step = widget.timeline[index];
              final isLast = index == widget.timeline.length - 1;
              final isExpanded = _expandedStepIndex == index;

              return _buildTimelineRow(
                step: step,
                isLast: isLast,
                isExpanded: isExpanded,
                onTap: () {
                  setState(() {
                    _expandedStepIndex = isExpanded ? null : index;
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineRow({
    required ThreatDnaTimelineStep step,
    required bool isLast,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    Color stepColor;
    if (step.riskScore >= 90) {
      stepColor = CyberColors.riskCritical;
    } else if (step.riskScore >= 80) {
      stepColor = CyberColors.riskCritical;
    } else {
      stepColor = CyberColors.riskWarning;
    }

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Node & Vertical Connector Column
            Column(
              children: [
                // Step Indicator Node
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: stepColor, width: 2),
                  ),
                  child: Center(
                    child: Icon(
                      step.icon,
                      size: 15,
                      color: stepColor,
                    ),
                  ),
                ),

                // Vertical Connector Line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: CyberColors.borderSubtle,
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            // Step Content Card
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CyberColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isExpanded ? stepColor : CyberColors.borderSubtle,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Elapsed Time + Step Number + Risk Pill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: CyberColors.borderSubtle,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  step.elapsedStr,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: CyberColors.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'STAGE ${step.stepNumber}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: CyberColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: stepColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: stepColor.withOpacity(0.4),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              'RISK: ${step.riskScore}/100',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: stepColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Step Title
                      Text(
                        step.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: CyberColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 2),

                      // Source / Artifact
                      Text(
                        'Target Artifact: ${step.source}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: CyberColors.primaryBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),

                      // Description
                      Text(
                        step.description,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: CyberColors.textSecondary,
                          height: 1.35,
                        ),
                        maxLines: isExpanded ? null : 2,
                        overflow: isExpanded ? null : TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Tap hint
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          isExpanded ? 'Tap to collapse' : 'Tap for forensics',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: CyberColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
