import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../domain/entities/threat_history_item.dart';

class ThreatDetailDialog extends StatelessWidget {
  final ThreatHistoryItem item;
  final VoidCallback onDelete;

  const ThreatDetailDialog({
    super.key,
    required this.item,
    required this.onDelete,
  });

  Color _getSeverityColor(ThreatSeverity severity) {
    switch (severity) {
      case ThreatSeverity.critical:
        return CyberColors.riskCritical;
      case ThreatSeverity.high:
        return CyberColors.riskWarning;
      case ThreatSeverity.medium:
        return const Color(0xFFFFB800);
      case ThreatSeverity.low:
        return CyberColors.neonCyan;
      case ThreatSeverity.safe:
        return CyberColors.riskSafe;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getSeverityColor(item.severity);
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm:ss');
    final formattedDate = dateFormat.format(item.timestamp);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: CyberColors.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: CyberColors.borderSubtle, width: 1.0),
          boxShadow: const [CyberColors.cardShadow],
        ),
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Category Icon & Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.category.icon, color: color, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.category.label.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: CyberColors.primaryBlue,
                            ),
                          ),
                          Text(
                            item.id,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: CyberColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: CyberColors.textSecondary, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Threat Type & Risk Score
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.threatType,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: CyberColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          item.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: CyberColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withOpacity(0.4), width: 1.0),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${item.riskScore}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                        Text(
                          item.severity.label,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Date & Intelligence Source
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: CyberColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: CyberColors.borderSubtle, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded,
                            size: 14, color: CyberColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          formattedDate,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: CyberColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.hub_outlined,
                            size: 14, color: CyberColors.primaryBlue),
                        const SizedBox(width: 6),
                        Text(
                          item.source,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: CyberColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Reason Section
              Text(
                'DETECTION REASON & AI INDICATORS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: CyberColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CyberColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: CyberColors.borderSubtle, width: 1),
                ),
                child: Text(
                  item.reason,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: CyberColors.textPrimary,
                    height: 1.45,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Recommended Action Box
              Text(
                'RECOMMENDED DEFENSE ACTION',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: color,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CyberColors.dangerSoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: CyberColors.dangerBorder, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_rounded, size: 16, color: color),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.recommendedAction,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: CyberColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (item.metadata.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'INCIDENT METADATA & TELEMETRY',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: CyberColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: item.metadata.entries.map((entry) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: CyberColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: CyberColors.borderSubtle, width: 0.8),
                      ),
                      child: Text(
                        '${entry.key}: ${entry.value}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: CyberColors.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 18),

              // Explainable AI Deep Dive Action
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/xai-result');
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: CyberColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: CyberColors.primaryBorder,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.psychology_alt_rounded,
                          color: CyberColors.primaryBlue, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'OPEN EXPLAINABLE AI (XAI) BREAKDOWN',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: CyberColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Bottom Actions: Delete from Firestore vs Close
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: CyberColors.criticalDanger,
                        side: const BorderSide(color: CyberColors.dangerBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        onDelete();
                      },
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: Text(
                        'DELETE SCAN',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CyberColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'CLOSE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
