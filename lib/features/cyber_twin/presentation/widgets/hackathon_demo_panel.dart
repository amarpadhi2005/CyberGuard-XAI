import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';

class HackathonDemoPanel extends StatelessWidget {
  final int currentStage;
  final bool isAutoSimulating;
  final ValueChanged<int> onSelectStage;
  final VoidCallback onStartLiveDemo;
  final int timeWindowHours;
  final ValueChanged<int> onSelectTimeWindow;

  const HackathonDemoPanel({
    super.key,
    required this.currentStage,
    required this.isAutoSimulating,
    required this.onSelectStage,
    required this.onStartLiveDemo,
    required this.timeWindowHours,
    required this.onSelectTimeWindow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CyberColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CyberColors.borderSubtle, width: 1),
        boxShadow: CyberColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: CyberColors.primarySoftBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.science_outlined,
                      color: CyberColors.primaryBlue,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SIMULATION CONTROLS',
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
                  color: isAutoSimulating
                      ? CyberColors.riskCriticalBg
                      : CyberColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isAutoSimulating
                        ? CyberColors.riskCritical.withOpacity(0.3)
                        : CyberColors.borderSubtle,
                    width: 1,
                  ),
                ),
                child: Text(
                  isAutoSimulating ? 'SIMULATING...' : 'LIVE AUDIT MODE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: isAutoSimulating
                        ? CyberColors.riskCritical
                        : CyberColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Automated Live Demo Play Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: isAutoSimulating ? null : onStartLiveDemo,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAutoSimulating
                    ? CyberColors.borderSubtle
                    : CyberColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isAutoSimulating
                        ? Icons.sync_rounded
                        : Icons.play_arrow_rounded,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isAutoSimulating
                        ? 'Running Multi-Vector Simulation...'
                        : 'Run Multi-Vector Simulation (1 → 2 → 3)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Stage Selector Buttons
          Row(
            children: [
              _buildStageButton(
                stageNum: 1,
                title: '1. Notification',
                sub: 'SMS Received',
                isActive: currentStage == 1,
              ),
              const SizedBox(width: 8),
              _buildStageButton(
                stageNum: 2,
                title: '2. Phishing URL',
                sub: 'Link Scanned',
                isActive: currentStage == 2,
              ),
              const SizedBox(width: 8),
              _buildStageButton(
                stageNum: 3,
                title: '3. Scam Call',
                sub: 'Coordinated!',
                isActive: currentStage == 3,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Time Sliding Window Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Correlation Window:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: CyberColors.textSecondary,
                ),
              ),
              Row(
                children: [6, 12, 24, 72].map((hours) {
                  final isSelected = timeWindowHours == hours;
                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: InkWell(
                      onTap: () => onSelectTimeWindow(hours),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? CyberColors.primarySoftBg
                              : CyberColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected
                                ? CyberColors.primaryBlue
                                : CyberColors.borderSubtle,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${hours}h',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? CyberColors.primaryBlue
                                : CyberColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStageButton({
    required int stageNum,
    required String title,
    required String sub,
    required bool isActive,
  }) {
    final activeBg = stageNum == 3 ? CyberColors.riskCriticalBg : CyberColors.primarySoftBg;
    final activeBorder = stageNum == 3 ? CyberColors.riskCritical : CyberColors.primaryBlue;
    final activeColor = stageNum == 3 ? CyberColors.riskCritical : CyberColors.primaryBlue;

    return Expanded(
      child: InkWell(
        onTap: () => onSelectStage(stageNum),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: isActive ? activeBg : CyberColors.surfaceSecondary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? activeBorder : CyberColors.borderSubtle,
              width: isActive ? 1.4 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isActive ? activeColor : CyberColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  color: isActive ? activeColor : CyberColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
