import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/widgets/cyber_loading_indicator.dart';
import '../../domain/entities/demo_simulation_scenario.dart';

class DemoSimulationRunnerDialog extends StatelessWidget {
  final DemoSimulationScenario scenario;
  final int currentStepIndex;
  final String statusMessage;

  const DemoSimulationRunnerDialog({
    super.key,
    required this.scenario,
    required this.currentStepIndex,
    required this.statusMessage,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        (currentStepIndex + 1) / scenario.simulationSteps.length.clamp(1, 10);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: CyberColors.surfaceCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: CyberColors.borderSubtle),
          boxShadow: CyberColors.cardShadow,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Telemetry Header
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: CyberColors.primarySoftBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: CyberColors.primaryBlue.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.science_outlined,
                          size: 13, color: CyberColors.primaryBlue),
                      const SizedBox(width: 5),
                      Text(
                        'LIVE FORENSIC SIMULATION',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: CyberColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '${((progress * 100).toInt())}%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: CyberColors.primaryBlue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Loading Core
            Center(
              child: CyberLoadingIndicator(
                size: 64,
                color: scenario.accentColor,
                statusText: '',
              ),
            ),

            const SizedBox(height: 16),

            // Scenario Title
            Text(
              scenario.title.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: CyberColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              scenario.threatType,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: CyberColors.textSecondary,
              ),
            ),

            const SizedBox(height: 16),

            // Simulated Target Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: CyberColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: CyberColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Icon(scenario.icon, size: 16, color: scenario.accentColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      scenario.simulatedTarget,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: CyberColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: CyberColors.surfaceSecondary,
                valueColor: AlwaysStoppedAnimation<Color>(scenario.accentColor),
              ),
            ),

            const SizedBox(height: 16),

            // Active Telemetry Status Message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CyberColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: CyberColors.borderSubtle,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: CyberColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      statusMessage,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: CyberColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Security disclaimer
            Text(
              'SANDBOX HARNESS: Simulating multi-vector ingress. Updating Cloud Firestore threat records & adjusting Cyber Health Score.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: CyberColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
