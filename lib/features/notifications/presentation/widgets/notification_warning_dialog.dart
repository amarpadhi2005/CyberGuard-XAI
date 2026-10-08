import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../../../core/widgets/cyber_button.dart';
import '../../domain/entities/protected_notification.dart';

class NotificationWarningDialog extends StatelessWidget {
  final ProtectedNotification notification;
  final VoidCallback onMarkSafe;
  final VoidCallback onReportScam;
  final VoidCallback onDismiss;

  const NotificationWarningDialog({
    super.key,
    required this.notification,
    required this.onMarkSafe,
    required this.onReportScam,
    required this.onDismiss,
  });

  Color _getCategoryColor(NotificationThreatCategory category) {
    switch (category) {
      case NotificationThreatCategory.otpTheft:
      case NotificationThreatCategory.fakeKyc:
        return CyberColors.riskCritical;
      case NotificationThreatCategory.bankScam:
      case NotificationThreatCategory.urgentPayment:
        return CyberColors.neonPink;
      case NotificationThreatCategory.lottery:
        return CyberColors.riskWarning;
      case NotificationThreatCategory.clean:
        return CyberColors.riskSafe;
    }
  }

  IconData _getCategoryIcon(NotificationThreatCategory category) {
    switch (category) {
      case NotificationThreatCategory.bankScam:
        return Icons.account_balance_rounded;
      case NotificationThreatCategory.lottery:
        return Icons.emoji_events_rounded;
      case NotificationThreatCategory.fakeKyc:
        return Icons.badge_rounded;
      case NotificationThreatCategory.otpTheft:
        return Icons.password_rounded;
      case NotificationThreatCategory.urgentPayment:
        return Icons.warning_rounded;
      case NotificationThreatCategory.clean:
        return Icons.verified_user_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final alertColor = _getCategoryColor(notification.threatCategory);

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Warning Row
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: alertColor.withOpacity(0.12),
                      border: Border.all(color: alertColor.withOpacity(0.4), width: 1.5),
                    ),
                    child: Icon(
                      _getCategoryIcon(notification.threatCategory),
                      color: alertColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SECURITY THREAT INTERCEPTED',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: alertColor,
                          ),
                        ),
                        Text(
                          'AI Notification Defense Active',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: CyberColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: CyberColors.textSecondary),
                    onPressed: onDismiss,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Threat Category Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: alertColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: alertColor.withOpacity(0.4), width: 1),
                ),
                child: Text(
                  notification.threatCategory.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: alertColor,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Intercepted Notification Content Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CyberColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CyberColors.borderSubtle, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          notification.appSource.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: CyberColors.primaryBlue,
                          ),
                        ),
                        Text(
                          'JUST NOW',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: CyberColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: CyberColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: CyberColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Gemini Forensic Analysis Reason
              Text(
                'GEMINI FORENSIC EVALUATION',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: CyberColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                notification.explanation,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  height: 1.45,
                  color: CyberColors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              // Recommended Action
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CyberColors.dangerSoft,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CyberColors.dangerBorder, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_outlined, size: 16, color: alertColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        notification.recommendedAction,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: CyberColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons: Mark Safe vs Report Scam
              Row(
                children: [
                  Expanded(
                    child: CyberButton(
                      text: 'MARK AS SAFE',
                      icon: Icons.check,
                      height: 44,
                      variant: CyberButtonVariant.outline,
                      onPressed: onMarkSafe,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CyberButton(
                      text: 'REPORT SCAM',
                      icon: Icons.report_problem,
                      height: 44,
                      variant: CyberButtonVariant.danger,
                      onPressed: onReportScam,
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
