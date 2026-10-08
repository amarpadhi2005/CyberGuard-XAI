import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../../../core/widgets/cyber_button.dart';
import '../../../../core/widgets/cyber_pressable.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/scam_call_controller.dart';
import '../widgets/call_history_tile.dart';
import '../widgets/incoming_call_overlay.dart';
import '../widgets/truecaller_card.dart';

class ScamCallScreen extends StatefulWidget {
  const ScamCallScreen({super.key});

  @override
  State<ScamCallScreen> createState() => _ScamCallScreenState();
}

class _ScamCallScreenState extends State<ScamCallScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      final userId = auth.currentUser?.uid ?? 'DEMO_USER_001';
      context.read<ScamCallController>().loadHistory(userId);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _triggerScan() {
    final auth = context.read<AuthController>();
    final controller = context.read<ScamCallController>();
    final userId = auth.currentUser?.uid ?? 'DEMO_USER_001';

    controller.analyzeNumber(_phoneController.text, userId);
  }

  void _simulateCall([String? number]) {
    final auth = context.read<AuthController>();
    final controller = context.read<ScamCallController>();
    final userId = auth.currentUser?.uid ?? 'DEMO_USER_001';
    final target = number ?? _phoneController.text;

    if (target.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter or select a phone number to simulate call.'),
          backgroundColor: CyberColors.riskWarning,
        ),
      );
      return;
    }

    controller.simulateIncomingCall(target, userId);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final controller = context.watch<ScamCallController>();
    final userId = auth.currentUser?.uid ?? 'DEMO_USER_001';

    // If incoming call simulation is active, show the full-screen overlay
    if (controller.isIncomingCallActive && controller.currentScan != null) {
      return IncomingCallOverlay(
        scanResult: controller.currentScan!,
        onDismiss: controller.dismissIncomingCall,
      );
    }

    return Scaffold(
      backgroundColor: CyberColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: CyberColors.borderSubtle, height: 1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: CyberColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.phone_in_talk_rounded, color: CyberColors.primaryBlue, size: 20),
            const SizedBox(width: 8),
            Text(
              'SCAM CALL INTELLIGENCE',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: CyberColors.textPrimary,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Prototype Disclaimer Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: CyberColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CyberColors.primaryBorder,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: CyberColors.primaryBlue, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PROTOTYPE TELEPHONY DEFENSE (DEMO / SIMULATION)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: CyberColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Demonstration model for call interception and reputation lookup. Real-time automatic call screening requires native Android CallScreeningService integration.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: CyberColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Truecaller-Style Search Bar & Input Box (NUMBER LOOKUP)
              Container(
                decoration: BoxDecoration(
                  color: CyberColors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: CyberColors.borderSubtle,
                    width: 1.0,
                  ),
                  boxShadow: const [CyberColors.cardShadow],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NUMBER LOOKUP & FORENSIC AUDIT',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: CyberColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: CyberColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: CyberColors.borderSubtle, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 14.0, right: 10.0),
                            child: Icon(Icons.search_rounded,
                                color: CyberColors.primaryBlue, size: 20),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: CyberColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter phone number (+1 800...)',
                                hintStyle: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: CyberColors.textSecondary,
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onSubmitted: (_) => _triggerScan(),
                            ),
                          ),
                          if (_phoneController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear,
                                  size: 18, color: CyberColors.textSecondary),
                              onPressed: () {
                                setState(() => _phoneController.clear());
                              },
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Quick Demo Preset Numbers
                    Text(
                      'DEMO / SIMULATION TEST SIGNATURES (4 PRESETS):',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: CyberColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: controller.demoPresets.map((preset) {
                        final v = preset['verdict']!;
                        final Color color = v == 'FRAUD'
                            ? CyberColors.criticalDanger
                            : (v == 'SPAM'
                                ? CyberColors.warning
                                : (v == 'SAFE'
                                    ? CyberColors.success
                                    : CyberColors.textSecondary));

                        return CyberPressable(
                          onTap: () {
                            setState(() => _phoneController.text = preset['number']!);
                            _triggerScan();
                          },
                          semanticLabel: 'Scan phone number ${preset['label']}',
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: color.withOpacity(0.35), width: 1.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  preset['label']!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.4,
                                    color: color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // Action Buttons (Scan vs Simulate Call)
                    Row(
                      children: [
                        Expanded(
                          child: CyberButton(
                            text: 'LOOKUP NUMBER',
                            icon: Icons.search_rounded,
                            isLoading: controller.isAnalyzing,
                            onPressed: _triggerScan,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CyberButton(
                            text: 'SIMULATE CALL',
                            icon: Icons.phone_callback_rounded,
                            variant: CyberButtonVariant.outline,
                            onPressed: () => _simulateCall(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. Real-Time Call Protection Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CyberColors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: CyberColors.borderSubtle, width: 1.0),
                  boxShadow: const [CyberColors.cardShadow],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.security_update_warning_rounded,
                                color: CyberColors.warning, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'REAL-TIME CALL PROTECTION STATUS',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: CyberColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: CyberColors.surfaceSecondary,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: CyberColors.borderSubtle),
                          ),
                          child: Text(
                            'PASSIVE MODE',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: CyberColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Real-time automatic interception of incoming calls requires Android CallScreeningService system permission. In this build, use manual Number Lookup above.',
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

              // Error Banner
              if (controller.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CyberColors.dangerSoft,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: CyberColors.dangerBorder,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: CyberColors.criticalDanger, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          controller.errorMessage!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: CyberColors.criticalDanger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 3. Active Scan Result Card (Truecaller Style)
              if (controller.currentScan != null) ...[
                TruecallerCard(
                  result: controller.currentScan!,
                  onBlock: () => controller.blockNumber(
                    controller.currentScan!.phoneNumber,
                    userId,
                  ),
                  onDismiss: controller.clearCurrentScan,
                ),
                const SizedBox(height: 20),
              ],

              // 4. Firestore Call Scan History
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.history_rounded, size: 16, color: CyberColors.primaryBlue),
                      const SizedBox(width: 6),
                      Text(
                        'FIRESTORE CALL SCAN AUDITS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: CyberColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: CyberColors.primarySoft,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: CyberColors.primaryBorder),
                    ),
                    child: Text(
                      '${controller.history.length} SCANS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: CyberColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (controller.history.isEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: CyberColors.surfaceCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: CyberColors.borderSubtle, width: 1.0),
                    boxShadow: const [CyberColors.cardShadow],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.phone_disabled_outlined,
                            color: CyberColors.textSecondary, size: 36),
                        const SizedBox(height: 10),
                        Text(
                          'No phone scans recorded yet. Enter a number above to start.',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: CyberColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...controller.history.map((scan) {
                  return CallHistoryTile(
                    scan: scan,
                    onTap: () {
                      setState(() {
                        _phoneController.text = scan.phoneNumber;
                      });
                      controller.analyzeNumber(scan.phoneNumber, userId);
                    },
                  );
                }),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
