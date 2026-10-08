import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../../../core/widgets/cyber_pressable.dart';
import '../../domain/entities/demo_simulation_scenario.dart';

class DemoScenarioCard extends StatelessWidget {
  final DemoSimulationScenario scenario;
  final VoidCallback onTrigger;
  final bool isBusy;

  const DemoScenarioCard({
    super.key,
    required this.scenario,
    required this.onTrigger,
    this.isBusy = false,
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
          // 1. Top Badges Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Badge
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CyberColors.primarySoftBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CyberColors.primaryBlue.withOpacity(0.3),
                  ),
                ),
                child: Icon(scenario.icon, color: CyberColors.primaryBlue, size: 22),
              ),

              const SizedBox(width: 12),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: CyberColors.primarySoftBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            scenario.category.label.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: CyberColors.primaryBlue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: CyberColors.riskCriticalBg,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: CyberColors.riskCritical.withOpacity(0.3),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            'RISK ${scenario.riskScore}/100',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: CyberColors.riskCritical,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scenario.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: CyberColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Subtitle / Vector info
          Text(
            scenario.subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: CyberColors.primaryBlue,
            ),
          ),

          const SizedBox(height: 6),

          // Description
          Text(
            scenario.description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              color: CyberColors.textSecondary,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 12),

          // Simulated Target Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: CyberColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: CyberColors.borderSubtle),
            ),
            child: Row(
              children: [
                const Icon(Icons.gps_fixed_rounded,
                    size: 13, color: CyberColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'TARGET: ${scenario.simulatedTarget}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: CyberColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Action Button & Impact Telemetry
          Row(
            children: [
              // Health Score impact chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: CyberColors.riskCriticalBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: CyberColors.riskCritical.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.health_and_safety_outlined,
                        size: 14, color: CyberColors.riskCritical),
                    const SizedBox(width: 4),
                    Text(
                      '${scenario.healthScorePenalty} PTS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: CyberColors.riskCritical,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Trigger Simulation Button
              Expanded(
                child: CyberPressable(
                  onTap: isBusy ? null : onTrigger,
                  semanticLabel: 'Simulate ${scenario.title}',
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: CyberColors.primaryBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow_rounded,
                            size: 18, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'SIMULATE & RUN XAI',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
