import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../../../core/widgets/cyber_button.dart';
import '../../../../core/widgets/cyber_loading_indicator.dart';
import '../../../../core/widgets/cyber_pressable.dart';
import '../controllers/url_scanner_controller.dart';
import '../widgets/scan_result_view.dart';

class UrlScannerScreen extends StatefulWidget {
  const UrlScannerScreen({super.key});

  @override
  State<UrlScannerScreen> createState() => _UrlScannerScreenState();
}

class _UrlScannerScreenState extends State<UrlScannerScreen> {
  final TextEditingController _urlController = TextEditingController();

  final List<({String label, String url, bool isSimulated})> _quickTestSignatures = [
    (
      label: 'Google (Legitimate)',
      url: 'https://google.com',
      isSimulated: false,
    ),
    (
      label: 'PayPal Spoof (Homograph)',
      url: 'http://paypa1-security-verification.com/login',
      isSimulated: true,
    ),
    (
      label: 'Bank Lure (Credential Harvester)',
      url: 'http://secure-chase-update.net/auth/otp',
      isSimulated: true,
    ),
  ];

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      setState(() {
        _urlController.text = data.text!.trim();
      });
    }
  }

  void _triggerScan({bool isQuickTest = false}) {
    FocusScope.of(context).unfocus();
    final controller = context.read<UrlScannerController>();
    controller.scanUrl(_urlController.text, isQuickTest: isQuickTest);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: CyberColors.cardBorder,
            height: 1,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: CyberColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: CyberColors.softBlueBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.radar_rounded, color: CyberColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'AI URL Forensic Scanner',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: CyberColors.textPrimary,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<UrlScannerController>(
          builder: (context, controller, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Input Card (Always present or interactive)
                  _buildInputCard(context, controller),

                  const SizedBox(height: 20),

                  // Error Message
                  if (controller.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: CyberColors.softDangerBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: CyberColors.softDangerBorder,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: CyberColors.danger, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              controller.errorMessage!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: CyberColors.danger,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            color: CyberColors.danger,
                            onPressed: controller.clearError,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Scanning Live Animation
                  if (controller.isScanning) ...[
                    _buildScanningState(controller),
                  ] else if (controller.currentResult != null) ...[
                    // Full Result View
                    ScanResultView(
                      result: controller.currentResult!,
                      onScanAnother: () {
                        controller.clearResult();
                        _urlController.clear();
                      },
                    ),
                  ] else ...[
                    // Recent Scans History Section
                    _buildRecentScansHistory(controller),
                  ],

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputCard(BuildContext context, UrlScannerController controller) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TARGET ENDPOINT / URL',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: CyberColors.textSecondary,
                ),
              ),
              InkWell(
                onTap: _pasteFromClipboard,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: CyberColors.softBlueBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CyberColors.softBlueBorder, width: 1.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.content_paste_rounded, size: 13, color: CyberColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'PASTE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: CyberColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // URL Input Field
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: CyberColors.cardBorder,
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 14.0, right: 10.0),
                  child: Icon(Icons.link_rounded, color: CyberColors.primary, size: 20),
                ),
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    enabled: !controller.isScanning,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: CyberColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'https://example-domain.com/path',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: CyberColors.textMuted,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onSubmitted: (_) => _triggerScan(isQuickTest: false),
                  ),
                ),
                if (_urlController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.cancel_rounded, size: 18, color: CyberColors.textSecondary),
                    onPressed: () {
                      setState(() => _urlController.clear());
                    },
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Explicitly Labeled Quick Test Signatures
          Row(
            children: [
              const Icon(Icons.science_outlined, size: 14, color: CyberColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'QUICK TEST SIGNATURES (SAMPLE BENCHMARKS):',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: CyberColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickTestSignatures.map((sig) {
              return CyberPressable(
                onTap: () {
                  setState(() => _urlController.text = sig.url);
                  _triggerScan(isQuickTest: true);
                },
                semanticLabel: 'Load and test ${sig.label}',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: sig.isSimulated
                        ? CyberColors.softDangerBg
                        : CyberColors.softBlueBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: sig.isSimulated
                          ? CyberColors.softDangerBorder
                          : CyberColors.softBlueBorder,
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    sig.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: sig.isSimulated ? CyberColors.danger : CyberColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Action Scan Button
          CyberButton(
            text: 'ANALYZE WITH GEMINI AI',
            icon: Icons.auto_awesome_rounded,
            isLoading: controller.isScanning,
            onPressed: () => _triggerScan(isQuickTest: false),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningState(UrlScannerController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CyberColors.cardBorder,
          width: 1.0,
        ),
        boxShadow: CyberColors.cardShadow,
      ),
      child: Center(
        child: Column(
          children: [
            const CyberLoadingIndicator(
              size: 72,
              color: CyberColors.primary,
              statusText: '',
            ),
            const SizedBox(height: 24),
            Text(
              'FORENSIC REASONING ENGINE ACTIVE',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: CyberColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.scanPhase,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: CyberColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentScansHistory(UrlScannerController controller) {
    final history = controller.history;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENT INSPECTION AUDITS',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: CyberColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: CyberColors.softBlueBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${history.length} AUDITS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: CyberColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (history.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CyberColors.cardBorder, width: 1.0),
              boxShadow: CyberColors.cardShadow,
            ),
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CyberColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.history_rounded, color: CyberColors.textSecondary, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No URLs inspected in current session',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: CyberColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...history.map((item) {
            final isThreat = item.riskScore >= 40;
            final color = isThreat ? CyberColors.danger : CyberColors.success;
            final softBg = isThreat ? CyberColors.softDangerBg : CyberColors.softSuccessBg;
            final softBorder = isThreat ? CyberColors.softDangerBorder : CyberColors.softSuccessBorder;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: InkWell(
                onTap: () {
                  setState(() => _urlController.text = item.originalUrl);
                  controller.scanUrl(item.originalUrl, isQuickTest: item.isQuickTest);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                          color: softBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: softBorder, width: 1.0),
                        ),
                        child: Icon(Icons.link_rounded, size: 18, color: color),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.domain,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: CyberColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.threatLevel.label,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: softBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: softBorder, width: 1.0),
                        ),
                        child: Text(
                          '${item.riskScore} / 100',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
