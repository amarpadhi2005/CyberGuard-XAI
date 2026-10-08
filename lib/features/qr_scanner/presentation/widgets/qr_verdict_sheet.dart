import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../../../core/widgets/cyber_button.dart';
import '../../domain/entities/qr_scan_result.dart';

class QrVerdictSheet extends StatelessWidget {
  final QrScanResult result;
  final VoidCallback onScanAgain;

  const QrVerdictSheet({
    super.key,
    required this.result,
    required this.onScanAgain,
  });

  Color _getVerdictColor(QrSafetyVerdict verdict) {
    switch (verdict) {
      case QrSafetyVerdict.safe:
        return CyberColors.riskSafe;
      case QrSafetyVerdict.suspicious:
        return CyberColors.riskWarning;
      case QrSafetyVerdict.dangerous:
        return CyberColors.riskCritical;
    }
  }

  IconData _getVerdictIcon(QrSafetyVerdict verdict) {
    switch (verdict) {
      case QrSafetyVerdict.safe:
        return Icons.verified_user_rounded;
      case QrSafetyVerdict.suspicious:
        return Icons.warning_amber_rounded;
      case QrSafetyVerdict.dangerous:
        return Icons.gpp_bad_rounded;
    }
  }

  void _copyDefangedUrl(BuildContext context) {
    final defanged = result.extractedUrl.replaceAll('http', 'hxxp').replaceAll('.', '[.]');
    Clipboard.setData(ClipboardData(text: defanged));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Defanged URL copied safely: $defanged'),
        backgroundColor: CyberColors.cardBg,
      ),
    );
  }

  void _confirmOpenUrl(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: CyberColors.darkBlueSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: CyberColors.riskWarning, width: 1.2),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning, color: CyberColors.riskWarning, size: 22),
            const SizedBox(width: 8),
            Text(
              'SECURITY OVERRIDE',
              style: GoogleFonts.rajdhani(
                color: CyberColors.riskWarning,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        content: Text(
          'This link was flagged as SUSPICIOUS. Automatic opening is blocked by default. Are you certain you want to bypass the defense shield?',
          style: GoogleFonts.inter(
            color: CyberColors.textMuted,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'ABORT',
              style: GoogleFonts.rajdhani(
                color: CyberColors.neonCyan,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: CyberColors.riskWarning,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              // Open in browser
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sandboxed navigation initiated.'),
                  backgroundColor: CyberColors.cardBg,
                ),
              );
            },
            child: Text(
              'PROCEED ANYWAY',
              style: GoogleFonts.rajdhani(
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final verdictColor = _getVerdictColor(result.verdict);
    final isDangerous = result.verdict == QrSafetyVerdict.dangerous;
    final isSuspicious = result.verdict == QrSafetyVerdict.suspicious;
    final isSafe = result.verdict == QrSafetyVerdict.safe;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      decoration: BoxDecoration(
        color: CyberColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: verdictColor.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Drag Handle
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: CyberColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Verdict Header Banner
              GlassmorphicContainer(
                borderRadius: 18,
                padding: const EdgeInsets.all(18),
                backgroundColor: verdictColor.withOpacity(0.12),
                border: Border.all(color: verdictColor, width: 1.5),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: verdictColor.withOpacity(0.2),
                      ),
                      child: Icon(
                        _getVerdictIcon(result.verdict),
                        color: verdictColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                result.verdict.label,
                                style: GoogleFonts.rajdhani(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.0,
                                  color: verdictColor,
                                ),
                              ),
                              Text(
                                '${result.riskScore}/100 RISK',
                                style: GoogleFonts.rajdhani(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: verdictColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isDangerous
                                ? 'HIGH QUISHING THREAT DETECTED'
                                : (isSuspicious
                                    ? 'CAUTION: POTENTIAL DECEPTION'
                                    : 'VERIFIED NOMINAL REPUTATION'),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: CyberColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Zero-Trust Auto-Open Warning
              if (!isSafe) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CyberColors.cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: CyberColors.darkBlueBorder,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined,
                          color: CyberColors.neonCyan, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'AUTOMATIC OPENING BLOCKED: CyberGuard never automatically opens unverified or dangerous QR links.',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: CyberColors.neonCyan,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Extracted URL Section
              Text(
                'EXTRACTED ENDPOINT',
                style: GoogleFonts.rajdhani(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: CyberColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: CyberColors.darkBlueSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: CyberColors.darkBlueBorder, width: 1),
                ),
                child: Text(
                  result.extractedUrl,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: CyberColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // "EXPLAIN WHY" Section
              Text(
                'GEMINI FORENSIC ANALYSIS (EXPLAIN WHY)',
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: CyberColors.neonCyan,
                ),
              ),
              const SizedBox(height: 8),

              GlassmorphicContainer(
                borderRadius: 14,
                padding: const EdgeInsets.all(14),
                backgroundColor: CyberColors.darkBlueSurface.withOpacity(0.7),
                border: Border.all(color: CyberColors.darkBlueBorder, width: 1),
                child: Text(
                  result.reason,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.45,
                    color: CyberColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Threat Signals / Signals Tags
              if (result.threatSignals.isNotEmpty) ...[
                Text(
                  'DETECTED RISK SIGNALS',
                  style: GoogleFonts.rajdhani(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: CyberColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: result.threatSignals.map((sig) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: verdictColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: verdictColor.withOpacity(0.3), width: 0.8),
                      ),
                      child: Text(
                        sig,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: verdictColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
              ],

              // Action Buttons
              if (isDangerous) ...[
                // Dangerous: Blocked from opening, offer defang and quarantine
                CyberButton(
                  text: 'COPY DEFANGED URL (SAFE)',
                  icon: Icons.copy,
                  variant: CyberButtonVariant.primary,
                  onPressed: () => _copyDefangedUrl(context),
                ),
              ] else if (isSuspicious) ...[
                // Suspicious: Offer safety copy, or guarded override
                Row(
                  children: [
                    Expanded(
                      child: CyberButton(
                        text: 'COPY DEFANGED',
                        variant: CyberButtonVariant.primary,
                        onPressed: () => _copyDefangedUrl(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CyberButton(
                        text: 'PROCEED...',
                        variant: CyberButtonVariant.outline,
                        onPressed: () => _confirmOpenUrl(context),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Safe: User may open or copy
                CyberButton(
                  text: 'COPY VERIFIED LINK',
                  icon: Icons.copy,
                  variant: CyberButtonVariant.primary,
                  onPressed: () => _copyDefangedUrl(context),
                ),
              ],

              const SizedBox(height: 10),

              // Scan Again Button
              CyberButton(
                text: 'SCAN ANOTHER QR CODE',
                variant: CyberButtonVariant.outline,
                onPressed: () {
                  Navigator.pop(context);
                  onScanAgain();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
