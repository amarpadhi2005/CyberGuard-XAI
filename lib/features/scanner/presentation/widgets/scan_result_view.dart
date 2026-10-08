import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../../../core/widgets/cyber_button.dart';
import '../../domain/entities/url_scan_result.dart';
import '../../../xai_result/domain/entities/xai_result_model.dart';

class ScanResultView extends StatelessWidget {
  final UrlScanResult result;
  final VoidCallback onScanAnother;

  const ScanResultView({
    super.key,
    required this.result,
    required this.onScanAnother,
  });

  Color _getThreatColor(ThreatLevel level) {
    switch (level) {
      case ThreatLevel.critical:
      case ThreatLevel.high:
        return CyberColors.danger;
      case ThreatLevel.medium:
      case ThreatLevel.low:
        return CyberColors.warning;
      case ThreatLevel.safe:
        return CyberColors.success;
    }
  }

  Color _getSeverityColor(IndicatorSeverity severity) {
    switch (severity) {
      case IndicatorSeverity.critical:
      case IndicatorSeverity.high:
        return CyberColors.danger;
      case IndicatorSeverity.medium:
      case IndicatorSeverity.low:
        return CyberColors.warning;
      case IndicatorSeverity.info:
        return CyberColors.primary;
    }
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$label copied to clipboard',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: CyberColors.textPrimary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  XaiResultModel _convertToXaiModel(UrlScanResult result) {
    XaiSeverity severity;
    switch (result.threatLevel) {
      case ThreatLevel.critical:
        severity = XaiSeverity.critical;
        break;
      case ThreatLevel.high:
        severity = XaiSeverity.high;
        break;
      case ThreatLevel.medium:
        severity = XaiSeverity.medium;
        break;
      case ThreatLevel.low:
      case ThreatLevel.safe:
        severity = XaiSeverity.safe;
        break;
    }

    final evidenceItems = result.indicators.map((ind) {
      IconData icon;
      switch (ind.severity) {
        case IndicatorSeverity.critical:
        case IndicatorSeverity.high:
          icon = Icons.warning_amber_rounded;
          break;
        case IndicatorSeverity.medium:
          icon = Icons.info_outline_rounded;
          break;
        case IndicatorSeverity.low:
          icon = Icons.shield_outlined;
          break;
        case IndicatorSeverity.info:
          icon = Icons.lock_outline_rounded;
          break;
      }

      double weight = 0.5;
      if (ind.severity == IndicatorSeverity.critical) weight = 0.95;
      if (ind.severity == IndicatorSeverity.high) weight = 0.85;
      if (ind.severity == IndicatorSeverity.medium) weight = 0.65;
      if (ind.severity == IndicatorSeverity.low) weight = 0.35;
      if (ind.severity == IndicatorSeverity.info) weight = 0.15;

      return XaiEvidenceItem(
        title: ind.name,
        description: '${ind.evidence}. ${ind.explanation}',
        severityWeight: weight,
        icon: icon,
        isFlagged: ind.severity != IndicatorSeverity.info,
      );
    }).toList();

    final factorMetrics = [
      XaiFactorMetric(
        name: 'Domain Identity',
        score: result.riskScore >= 40 ? 0.9 : 0.15,
        summary: result.indicators.any((i) => i.name.contains('Brand') || i.name.contains('Typosquat'))
            ? 'Anomalous domain impersonation signatures identified'
            : 'Domain structure verified against registration norms',
        color: result.riskScore >= 40 ? CyberColors.danger : CyberColors.success,
      ),
      XaiFactorMetric(
        name: 'URI Path Semantics',
        score: result.indicators.any((i) => i.name.contains('Credential') || i.name.contains('Keyword'))
            ? 0.85
            : 0.1,
        summary: result.indicators.any((i) => i.name.contains('Credential'))
            ? 'Harvesting tokens detected in URI parameters'
            : 'Standard resource identifier semantics observed',
        color: result.indicators.any((i) => i.name.contains('Credential'))
            ? CyberColors.danger
            : CyberColors.success,
      ),
      XaiFactorMetric(
        name: 'Transport Encryption',
        score: result.isHttps ? 0.2 : 0.85,
        summary: result.httpsMeaning,
        color: result.isHttps ? CyberColors.primary : CyberColors.warning,
      ),
    ];

    return XaiResultModel(
      id: 'XAI-URL-${result.scannedAt.millisecondsSinceEpoch}',
      target: result.originalUrl,
      category: 'Website Forensic',
      threatType: '${result.threatLevel.label} (${result.domain})',
      riskScore: result.riskScore,
      confidence: result.confidence / 100.0,
      severity: severity,
      plainEnglishSummary: result.summary,
      howItWorks: result.riskScore >= 50
          ? 'This URL was analyzed for deceptive syntax, brand spoofing, and credential harvesting patterns. When clicked, deceptive links route traffic to unauthorized servers to intercept credentials.'
          : 'This URL was verified against lexical patterns, standard naming conventions, and transport layer security. No deceptive masquerading patterns were detected.',
      realWorldAnalogy: result.riskScore >= 50
          ? 'Think of this like a counterfeit store sign made to look like a well-known bank, positioned to trick visitors into handing over their physical keys.'
          : 'Think of this like a storefront with proper signage, registered licensing, and a clear physical address matching public records.',
      evidenceList: evidenceItems.isEmpty
          ? const [
              XaiEvidenceItem(
                title: 'Standard Lexical Structure',
                description: 'URL conforms to standard naming and URI syntax conventions.',
                severityWeight: 0.1,
                icon: Icons.check_circle_outline,
                isFlagged: false,
              )
            ]
          : evidenceItems,
      factorMetrics: factorMetrics,
      recommendedActions: [
        result.recommendedAction,
        if (result.riskScore >= 50) 'Do not enter passwords, one-time codes, or credit card details.',
        'URL has been defanged for safe display: ${result.defangedUrl}',
      ],
      timestamp: result.scannedAt,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isThreat = result.riskScore >= 40;
    final threatColor = _getThreatColor(result.threatLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ----------------------------------------------------
        // 1. TARGET URL (Single Source of Truth)
        // ----------------------------------------------------
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CyberColors.cardBorder, width: 1.0),
            boxShadow: CyberColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SUBMITTED TARGET URL',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: CyberColors.textSecondary,
                    ),
                  ),
                  if (result.isQuickTest)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: CyberColors.softBlueBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: CyberColors.softBlueBorder, width: 1.0),
                      ),
                      child: Text(
                        'QUICK TEST SIGNATURE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: CyberColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: CyberColors.cardBgSecondary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: CyberColors.cardBorder, width: 1.0),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link_rounded, size: 18, color: CyberColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SelectableText(
                        result.originalUrl,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: CyberColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ----------------------------------------------------
        // 2. RISK SCORE SECTION (Enterprise White Card Dashboard)
        // Structure:
        // [ CRITICAL THREAT ]                    [ HTTPS ENCRYPTED ]
        //                     80 / 100
        //                  COMPUTED RISK SCORE
        // URL
        // ----------------------------------------------------
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CyberColors.cardBorder, width: 1.0),
            boxShadow: CyberColors.cardShadow,
          ),
          child: Column(
            children: [
              // Header Row: [ CRITICAL THREAT ] ... [ HTTPS ENCRYPTED ]
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Threat Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isThreat ? CyberColors.softDangerBg : CyberColors.softSuccessBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isThreat ? CyberColors.softDangerBorder : CyberColors.softSuccessBorder,
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isThreat ? Icons.warning_rounded : Icons.verified_user_rounded,
                          size: 15,
                          color: isThreat ? CyberColors.danger : CyberColors.success,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          result.threatLevel.label.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: isThreat ? CyberColors.danger : CyberColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Encryption Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: result.isHttps ? CyberColors.softBlueBg : CyberColors.softWarningBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: result.isHttps ? CyberColors.softBlueBorder : CyberColors.softWarningBorder,
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          result.isHttps ? Icons.lock_rounded : Icons.lock_open_rounded,
                          size: 13,
                          color: result.isHttps ? CyberColors.primary : CyberColors.warning,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          result.isHttps ? 'HTTPS ENCRYPTED' : 'HTTP INSECURE',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: result.isHttps ? CyberColors.primary : CyberColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Prominent Score Display in Soft Tint Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: isThreat ? CyberColors.softDangerBg : CyberColors.softSuccessBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isThreat ? CyberColors.softDangerBorder : CyberColors.softSuccessBorder,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${result.riskScore}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 50,
                        fontWeight: FontWeight.w900,
                        color: isThreat ? CyberColors.danger : CyberColors.success,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      ' / 100',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: CyberColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'COMPUTED RISK SCORE',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: CyberColors.textSecondary,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                result.originalUrl,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: CyberColors.textSecondary,
                ),
              ),

              const SizedBox(height: 12),

              // Confidence Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: CyberColors.cardBgSecondary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'CONFIDENCE INDEX: ${result.confidence}%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: CyberColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ----------------------------------------------------
        // 3. DEFANGED URL (Safe for Display & Copying)
        // ----------------------------------------------------
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CyberColors.cardBorder, width: 1.0),
            boxShadow: CyberColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DEFANGED URL (SAFE DISPLAY)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: CyberColors.textSecondary,
                    ),
                  ),
                  InkWell(
                    onTap: () => _copyToClipboard(context, result.defangedUrl, 'Defanged URL'),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: CyberColors.softBlueBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: CyberColors.softBlueBorder, width: 1.0),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.copy_rounded, size: 12, color: CyberColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'COPY',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: CyberColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: CyberColors.cardBgSecondary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CyberColors.cardBorder, width: 1.0),
                ),
                child: SelectableText(
                  result.defangedUrl,
                  style: GoogleFonts.robotoMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CyberColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'URL defanged for safe display (brackets disarm protocol & dots to prevent browser routing).',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: CyberColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ----------------------------------------------------
        // 4. THREAT CATEGORY BREAKDOWN (SECURITY INDICATORS)
        // Clean white cards with red badges
        // ----------------------------------------------------
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'THREAT CATEGORY BREAKDOWN',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: CyberColors.textPrimary,
              ),
            ),
            Text(
              '${result.indicators.length} AUDITED',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: CyberColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (result.indicators.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CyberColors.cardBorder, width: 1.0),
              boxShadow: CyberColors.cardShadow,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CyberColors.softSuccessBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_outline_rounded, color: CyberColors.success, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No anomalous or threat indicators identified in URL structure.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: CyberColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...result.indicators.map((indicator) {
            final sevColor = _getSeverityColor(indicator.severity);
            final isIndicatorThreat = indicator.severity != IndicatorSeverity.info;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isIndicatorThreat ? CyberColors.softDangerBorder : CyberColors.cardBorder,
                    width: 1.0,
                  ),
                  boxShadow: CyberColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: isIndicatorThreat ? CyberColors.softDangerBg : CyberColors.softBlueBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isIndicatorThreat ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                                size: 16,
                                color: isIndicatorThreat ? CyberColors.danger : CyberColors.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              indicator.name.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: CyberColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: isIndicatorThreat ? CyberColors.softDangerBg : CyberColors.softBlueBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isIndicatorThreat ? CyberColors.softDangerBorder : CyberColors.softBlueBorder,
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            isIndicatorThreat ? 'THREAT DETECTED' : indicator.severity.label.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: isIndicatorThreat ? CyberColors.danger : CyberColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: CyberColors.cardBgSecondary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: CyberColors.cardBorder, width: 0.8),
                      ),
                      child: Text(
                        'Evidence: ${indicator.evidence}',
                        style: GoogleFonts.robotoMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: sevColor,
                        ),
                      ),
                    ),
                    if (indicator.explanation.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        indicator.explanation,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: CyberColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),

        const SizedBox(height: 16),

        // ----------------------------------------------------
        // 5. GEMINI FORENSIC REASONING
        // White card, Blue section heading, Dark navy body text
        // ----------------------------------------------------
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CyberColors.cardBorder, width: 1.0),
            boxShadow: CyberColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: CyberColors.softBlueBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, size: 18, color: CyberColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'GEMINI FORENSIC REASONING',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: CyberColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                result.summary,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                  color: CyberColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: CyberColors.cardBgSecondary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CyberColors.cardBorder, width: 0.8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 15, color: CyberColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Webpage content was disarmed. Evaluated strictly from URL lexical and domain telemetry.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: CyberColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ----------------------------------------------------
        // 6. HTTPS STATUS (Transport Layer Disclosure)
        // ----------------------------------------------------
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CyberColors.cardBorder, width: 1.0),
            boxShadow: CyberColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    result.isHttps ? Icons.lock_rounded : Icons.lock_open_rounded,
                    size: 18,
                    color: result.isHttps ? CyberColors.primary : CyberColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    result.isHttps ? 'HTTPS: CONNECTION ENCRYPTED' : 'HTTP: INSECURE PLAINTEXT',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: result.isHttps ? CyberColors.primary : CyberColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                result.httpsMeaning,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: CyberColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: CyberColors.softWarningBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CyberColors.softWarningBorder, width: 0.8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 16, color: CyberColors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Important: HTTPS only confirms transport encryption and does NOT guarantee website legitimacy.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: CyberColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ----------------------------------------------------
        // 7. RECOMMENDED ACTION
        // Light red/pink background, Thin red border, Red warning/shield icon, Dark navy text
        // ----------------------------------------------------
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: CyberColors.softDangerBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CyberColors.softDangerBorder, width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_rounded, size: 18, color: CyberColors.danger),
                  const SizedBox(width: 8),
                  Text(
                    'RECOMMENDED FORENSIC ACTION',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: CyberColors.danger,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                result.recommendedAction,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                  color: CyberColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Endpoint neutralized. Do not provide authentication credentials or session tokens.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: CyberColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ----------------------------------------------------
        // 8. TECHNICAL DETAILS (Telemetry Data)
        // ----------------------------------------------------
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CyberColors.cardBorder, width: 1.0),
            boxShadow: CyberColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TECHNICAL TELEMETRY DETAILS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: CyberColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              _buildTechRow('Domain:', result.domain),
              _buildTechRow('Protocol:', result.protocol.toUpperCase()),
              _buildTechRow('Port:', result.port != null ? '${result.port}' : (result.protocol == 'https' ? '443 (Default)' : '80 (Default)')),
              _buildTechRow('Path:', result.path.isNotEmpty ? result.path : '/'),
              if (result.query.isNotEmpty) _buildTechRow('Query:', result.query),
              if (result.redirects.isNotEmpty) _buildTechRow('Redirects:', result.redirects.join(' -> ')),
              _buildTechRow('Webpage Inspected:', result.webpageInspected ? 'Yes' : 'No (Disarmed)'),
              _buildTechRow('Reputation Status:', result.reputationStatus),
              _buildTechRow('Analysis Timestamp:', result.scannedAt.toLocal().toString().split('.')[0]),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ----------------------------------------------------
        // 9. ACTION BUTTONS
        // ----------------------------------------------------
        CyberButton(
          text: 'EXPLAIN WITH XAI (PLAIN ENGLISH)',
          icon: Icons.psychology_alt_rounded,
          variant: CyberButtonVariant.primary,
          onPressed: () {
            final xaiModel = _convertToXaiModel(result);
            Navigator.pushNamed(context, '/xai-result', arguments: xaiModel);
          },
        ),

        const SizedBox(height: 10),

        // Scan Another Target
        CyberButton(
          text: 'SCAN ANOTHER TARGET',
          icon: Icons.refresh_rounded,
          variant: CyberButtonVariant.secondary,
          onPressed: onScanAnother,
        ),
      ],
    );
  }

  Widget _buildTechRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: CyberColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.robotoMono(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: CyberColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
