import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../controllers/dashboard_controller.dart';

class RecentAlertsSection extends StatelessWidget {
  const RecentAlertsSection({super.key});

  void _showAlertDetails(BuildContext context, SecurityAlert alert) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        final color = _getSeverityColor(alert.severity);

        return AlertDialog(
          backgroundColor: CyberColors.darkBlueSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: color.withOpacity(0.6), width: 1.2),
          ),
          title: Row(
            children: [
              Icon(Icons.shield_outlined, color: color, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'INCIDENT IOC // ${alert.id}',
                  style: GoogleFonts.rajdhani(
                    color: CyberColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alert.title,
                style: GoogleFonts.rajdhani(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                alert.description,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: CyberColors.textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('DETECTION VECTOR', alert.vector),
              const SizedBox(height: 6),
              _buildDetailRow('ACTION TAKEN', alert.actionTaken),
              const SizedBox(height: 6),
              _buildDetailRow('DETECTED AT', alert.timestamp),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<DashboardController>().acknowledgeAlert(alert.id);
                Navigator.pop(dialogCtx);
              },
              child: Text(
                'ACKNOWLEDGE & ARCHIVE',
                style: GoogleFonts.rajdhani(
                  color: CyberColors.neonCyan,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.rajdhani(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: CyberColors.textDark,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: CyberColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor(ThreatSeverity severity) {
    switch (severity) {
      case ThreatSeverity.critical:
        return CyberColors.neonPink;
      case ThreatSeverity.high:
        return CyberColors.riskWarning;
      case ThreatSeverity.medium:
        return const Color(0xFFFFB703);
      case ThreatSeverity.safe:
        return CyberColors.neonCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();
    final alerts = controller.alerts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.crisis_alert_rounded,
                  color: CyberColors.neonPink,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'RECENT SECURITY ALERTS',
                  style: GoogleFonts.rajdhani(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                    color: CyberColors.textPrimary,
                  ),
                ),
              ],
            ),
            Text(
              '${alerts.length} ACTIVE',
              style: GoogleFonts.rajdhani(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: CyberColors.neonPink,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (alerts.isEmpty)
          GlassmorphicContainer(
            borderRadius: 14,
            padding: const EdgeInsets.all(20),
            backgroundColor: CyberColors.darkBlueSurface.withOpacity(0.6),
            child: Center(
              child: Text(
                'NO PENDING THREAT ALERTS // PERIMETER CLEAR',
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: CyberColors.riskSafe,
                ),
              ),
            ),
          )
        else
          ...alerts.map((alert) {
            final color = _getSeverityColor(alert.severity);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: InkWell(
                onTap: () => _showAlertDetails(context, alert),
                borderRadius: BorderRadius.circular(14),
                child: GlassmorphicContainer(
                  borderRadius: 14,
                  padding: const EdgeInsets.all(14),
                  backgroundColor: CyberColors.darkBlueSurface.withOpacity(0.7),
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 1.0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.security_update_warning_rounded,
                          size: 18,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    alert.title,
                                    style: GoogleFonts.rajdhani(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: CyberColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    alert.severity.name.toUpperCase(),
                                    style: GoogleFonts.rajdhani(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.0,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              alert.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: CyberColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.shield, size: 11, color: color),
                                    const SizedBox(width: 4),
                                    Text(
                                      alert.actionTaken,
                                      style: GoogleFonts.rajdhani(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: color,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  alert.timestamp,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: CyberColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => Navigator.pushNamed(context, '/threat-history'),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: CyberColors.cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: CyberColors.neonCyan.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history_edu_rounded,
                    color: CyberColors.neonCyan, size: 16),
                const SizedBox(width: 8),
                Text(
                  'VIEW UNIFIED THREAT TIMELINE (5 VECTORS)',
                  style: GoogleFonts.rajdhani(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: CyberColors.neonCyan,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: CyberColors.neonCyan, size: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
