import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../domain/entities/xai_result_model.dart';

class XaiActionPlanCard extends StatelessWidget {
  final List<String> actions;
  final XaiSeverity severity;

  const XaiActionPlanCard({
    super.key,
    required this.actions,
    required this.severity,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSafe ? const Color(0xFFF0FDF4) : CyberColors.dangerSoft;
    final borderColor = isSafe ? const Color(0xFFBBF7D0) : CyberColors.dangerBorder;
    final headerColor = isSafe ? CyberColors.success : CyberColors.criticalDanger;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: const [CyberColors.cardShadow],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSafe ? Icons.check_circle_outline_rounded : Icons.shield_rounded,
                color: headerColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'RECOMMENDED ACTION PLAN',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: headerColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ...actions.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final actionText = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: headerColor.withOpacity(0.5), width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$idx',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: headerColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      actionText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: CyberColors.textPrimary,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
