import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../domain/entities/protected_notification.dart';

class NotificationHistoryTile extends StatelessWidget {
  final ProtectedNotification notification;
  final VoidCallback? onTap;

  const NotificationHistoryTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  Color _getActionColor(NotificationUserAction action) {
    switch (action) {
      case NotificationUserAction.markedSafe:
        return CyberColors.success;
      case NotificationUserAction.reportedScam:
        return CyberColors.criticalDanger;
      case NotificationUserAction.pending:
        return CyberColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionColor = _getActionColor(notification.userAction);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: CyberColors.surfaceCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: CyberColors.borderSubtle,
              width: 1.0,
            ),
            boxShadow: const [CyberColors.cardShadow],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        notification.isMalicious
                            ? Icons.security_update_warning_rounded
                            : Icons.verified_user_rounded,
                        size: 15,
                        color: actionColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        notification.threatCategory.label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: actionColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: actionColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      notification.userAction.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: actionColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                notification.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: CyberColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                notification.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: CyberColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SRC: ${notification.appSource}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: CyberColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${notification.timestamp.hour.toString().padLeft(2, '0')}:${notification.timestamp.minute.toString().padLeft(2, '0')}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: CyberColors.textSecondary,
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
