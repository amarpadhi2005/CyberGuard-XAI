import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';

class QuickPromptsRow extends StatelessWidget {
  final List<String> prompts;
  final ValueChanged<String> onSelectPrompt;

  const QuickPromptsRow({
    super.key,
    required this.prompts,
    required this.onSelectPrompt,
  });

  IconData _getPromptIcon(String prompt) {
    final lower = prompt.toLowerCase();
    if (lower.contains('website') || lower.contains('url') || lower.contains('link')) {
      return Icons.link_rounded;
    }
    if (lower.contains('email') || lower.contains('message') || lower.contains('sms')) {
      return Icons.mark_email_read_rounded;
    }
    if (lower.contains('phishing') || lower.contains('scam')) {
      return Icons.gpp_maybe_rounded;
    }
    if (lower.contains('call') || lower.contains('voice')) {
      return Icons.phone_callback_rounded;
    }
    if (lower.contains('qr') || lower.contains('quishing')) {
      return Icons.qr_code_scanner_rounded;
    }
    return Icons.help_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: prompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final prompt = prompts[index];
          final icon = _getPromptIcon(prompt);

          return InkWell(
            onTap: () => onSelectPrompt(prompt),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: CyberColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    prompt,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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
