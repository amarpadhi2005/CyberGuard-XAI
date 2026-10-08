import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';

class QuickActionsBar extends StatelessWidget {
  final VoidCallback onScanUrl;
  final VoidCallback onScanQr;
  final VoidCallback onScanFile;
  final VoidCallback onCheckPhone;
  final VoidCallback onSecurityReport;

  const QuickActionsBar({
    super.key,
    required this.onScanUrl,
    required this.onScanQr,
    required this.onScanFile,
    required this.onCheckPhone,
    required this.onSecurityReport,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem(
        label: 'Scan URL',
        icon: Icons.link_rounded,
        color: const Color(0xFF0284C7),
        onTap: onScanUrl,
      ),
      _ActionItem(
        label: 'Scan QR',
        icon: Icons.qr_code_scanner_rounded,
        color: const Color(0xFF8B5CF6),
        onTap: onScanQr,
      ),
      _ActionItem(
        label: 'Scan File',
        icon: Icons.insert_drive_file_rounded,
        color: const Color(0xFF10B981),
        onTap: onScanFile,
      ),
      _ActionItem(
        label: 'Check Phone',
        icon: Icons.security_rounded,
        color: CyberColors.primary,
        onTap: onCheckPhone,
      ),
      _ActionItem(
        label: 'Security Report',
        icon: Icons.analytics_rounded,
        color: const Color(0xFFF59E0B),
        onTap: onSecurityReport,
      ),
    ];

    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final action = actions[index];
          return InkWell(
            onTap: action.onTap,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: action.color.withOpacity(0.25),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: action.color.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: action.color.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      action.icon,
                      size: 14,
                      color: action.color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    action.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: CyberColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActionItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _ActionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
