import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../domain/entities/threat_history_item.dart';
import 'threat_detail_dialog.dart';

class ThreatHistoryCard extends StatelessWidget {
  final ThreatHistoryItem item;
  final VoidCallback onDelete;

  const ThreatHistoryCard({
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

  String _formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM dd').format(dt);
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: CyberColors.borderSubtle, width: 1),
        ),
        title: Text(
          'PURGE AUDIT RECORD?',
          style: GoogleFonts.plusJakartaSans(
            color: CyberColors.criticalDanger,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        content: Text(
          'Permanently delete this scan item from Cloud Firestore threat history?',
          style: GoogleFonts.plusJakartaSans(
            color: CyberColors.textSecondary,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'CANCEL',
              style: GoogleFonts.plusJakartaSans(
                color: CyberColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: CyberColors.criticalDanger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              onDelete();
            },
            child: Text(
              'PURGE',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _getSeverityColor(item.severity);
    final relativeTime = _formatRelativeTime(item.timestamp);
    final fullDate = DateFormat('MMM dd, yyyy • HH:mm').format(item.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => ThreatDetailDialog(
              item: item,
              onDelete: onDelete,
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: CyberColors.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CyberColors.borderSubtle, width: 1.0),
            boxShadow: const [CyberColors.cardShadow],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Category Pill + Threat Type + Risk Score + Delete Icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Category Icon Avatar
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(0.12),
                    ),
                    child: Icon(
                      item.category.icon,
                      color: color,
                      size: 18,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Category & Threat Type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: CyberColors.surfaceSecondary,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: CyberColors.borderSubtle, width: 0.8),
                              ),
                              child: Text(
                                item.category.label.toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: CyberColors.primaryBlue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              relativeTime,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: CyberColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.threatType,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: CyberColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Risk Score Gauge Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withOpacity(0.4), width: 1),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${item.riskScore}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                        Text(
                          item.severity.label,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 4),

                  // Delete Scan Button
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 18, color: CyberColors.textSecondary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Delete scan',
                    onPressed: () => _showDeleteConfirmation(context),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Title / Target
              Text(
                item.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: CyberColors.primaryBlue,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 6),

              // Reason Snippet
              Text(
                item.reason,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: CyberColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 10),

              // Bottom Date & Action Hint
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    fullDate,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: CyberColors.textSecondary,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'AUDIT DETAILS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: CyberColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 10, color: CyberColors.primaryBlue),
                    ],
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
