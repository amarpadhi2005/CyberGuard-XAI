import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../../../core/widgets/cyber_button.dart';
import '../../../../core/widgets/cyber_pressable.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/notification_protection_controller.dart';
import '../widgets/notification_history_tile.dart';
import '../widgets/notification_warning_dialog.dart';

class NotificationProtectionScreen extends StatefulWidget {
  const NotificationProtectionScreen({super.key});

  @override
  State<NotificationProtectionScreen> createState() =>
      _NotificationProtectionScreenState();
}

class _NotificationProtectionScreenState
    extends State<NotificationProtectionScreen> {
  final TextEditingController _customTitleController = TextEditingController();
  final TextEditingController _customBodyController = TextEditingController();
  final String _customSource = 'SMS / Messages';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      final userId = auth.currentUser?.uid ?? 'DEMO_USER_001';
      context.read<NotificationProtectionController>().loadHistory(userId);
    });
  }

  @override
  void dispose() {
    _customTitleController.dispose();
    _customBodyController.dispose();
    super.dispose();
  }

  void _triggerSimulation(Map<String, String> scenario) async {
    final auth = context.read<AuthController>();
    final controller = context.read<NotificationProtectionController>();
    final userId = auth.currentUser?.uid ?? 'DEMO_USER_001';

    try {
      final result = await controller.simulateIncomingNotification(
        title: scenario['title']!,
        body: scenario['body']!,
        appSource: scenario['appSource']!,
        userId: userId,
      );

      if (result.isMalicious && mounted) {
        _showWarningPopup(context, result);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification analyzed: VERIFIED SAFE (${result.title})'),
            backgroundColor: CyberColors.riskSafe,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification analysis error: $e'),
            backgroundColor: CyberColors.riskCritical,
          ),
        );
      }
    }
  }

  void _triggerCustomSimulation() async {
    final title = _customTitleController.text.trim();
    final body = _customBodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both title and body for notification simulation.'),
          backgroundColor: CyberColors.riskWarning,
        ),
      );
      return;
    }

    final auth = context.read<AuthController>();
    final controller = context.read<NotificationProtectionController>();
    final userId = auth.currentUser?.uid ?? 'DEMO_USER_001';

    try {
      final result = await controller.simulateIncomingNotification(
        title: title,
        body: body,
        appSource: _customSource,
        userId: userId,
      );

      if (result.isMalicious && mounted) {
        _showWarningPopup(context, result);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification verified clean: ${result.title}'),
            backgroundColor: CyberColors.riskSafe,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Custom notification analysis error: $e'),
            backgroundColor: CyberColors.riskCritical,
          ),
        );
      }
    }
  }

  void _showWarningPopup(BuildContext context, dynamic notification) {
    final auth = context.read<AuthController>();
    final controller = context.read<NotificationProtectionController>();
    final userId = auth.currentUser?.uid ?? 'DEMO_USER_001';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => NotificationWarningDialog(
        notification: notification,
        onMarkSafe: () {
          controller.markAsSafe(notification: notification, userId: userId);
          Navigator.pop(dialogCtx);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification marked as SAFE and synchronized to Firestore.'),
              backgroundColor: CyberColors.riskSafe,
            ),
          );
        },
        onReportScam: () {
          controller.reportScam(notification: notification, userId: userId);
          Navigator.pop(dialogCtx);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Threat blocked & reported to Firestore telemetry cloud.'),
              backgroundColor: CyberColors.riskCritical,
            ),
          );
        },
        onDismiss: () {
          controller.dismissActiveWarning();
          Navigator.pop(dialogCtx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NotificationProtectionController>();

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
            const Icon(Icons.notifications_active_outlined, color: CyberColors.primaryBlue, size: 20),
            const SizedBox(width: 8),
            Text(
              'NOTIFICATION DEFENSE SENTINEL',
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
              // 1. Master Protection Toggle Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: CyberColors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: controller.protectionEnabled
                        ? const Color(0xFFBBF7D0)
                        : CyberColors.borderSubtle,
                    width: 1.0,
                  ),
                  boxShadow: const [CyberColors.cardShadow],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: controller.protectionEnabled
                            ? const Color(0xFFF0FDF4)
                            : CyberColors.surfaceSecondary,
                      ),
                      child: Icon(
                        controller.protectionEnabled
                            ? Icons.notifications_active
                            : Icons.notifications_off,
                        color: controller.protectionEnabled
                            ? CyberColors.success
                            : CyberColors.textSecondary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.protectionEnabled
                                ? 'NOTIFICATION SHIELD ARMED'
                                : 'INSPECTION TELEMETRY PAUSED',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: CyberColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            controller.protectionEnabled
                                ? 'Detecting Bank Scams, KYC, OTP theft & CEO fraud'
                                : 'Push notifications are not being evaluated by Gemini',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: CyberColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: controller.protectionEnabled,
                      activeColor: CyberColors.primaryBlue,
                      onChanged: controller.toggleProtection,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Prototype Push Simulator Section
              Text(
                'LIVE NOTIFICATION SIMULATOR',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: CyberColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Simulate incoming push notifications to test Gemini threat detection',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: CyberColors.textSecondary,
                ),
              ),

              const SizedBox(height: 12),

              // Preset Scenario Badges
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.simulationScenarios.map((scenario) {
                  final isClean = scenario['category'] == 'CLEAN';
                  final color = isClean ? CyberColors.success : CyberColors.criticalDanger;

                  return CyberPressable(
                    onTap: controller.isAnalyzing ? null : () => _triggerSimulation(scenario),
                    semanticLabel: 'Simulate notification: ${scenario['name']}',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color.withOpacity(0.35), width: 1.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isClean ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                            size: 14,
                            color: color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            scenario['name']!,
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

              const SizedBox(height: 20),

              // Custom Push Injection Box
              Container(
                decoration: BoxDecoration(
                  color: CyberColors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: CyberColors.borderSubtle, width: 1.0),
                  boxShadow: const [CyberColors.cardShadow],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CUSTOM NOTIFICATION INJECTION',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: CyberColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _customTitleController,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: CyberColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Notification Title (e.g. Bank Debit Alert)',
                        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: CyberColors.textSecondary),
                        filled: true,
                        fillColor: CyberColors.surfaceSecondary,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: CyberColors.borderSubtle),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: CyberColors.borderSubtle),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: CyberColors.primaryBlue),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _customBodyController,
                      maxLines: 2,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: CyberColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Notification Message Payload (e.g. Your KYC expired...)',
                        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: CyberColors.textSecondary),
                        filled: true,
                        fillColor: CyberColors.surfaceSecondary,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: CyberColors.borderSubtle),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: CyberColors.borderSubtle),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: CyberColors.primaryBlue),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 14),
                    CyberButton(
                      text: 'SIMULATE INCOMING PUSH',
                      icon: Icons.send_to_mobile_rounded,
                      isLoading: controller.isAnalyzing,
                      onPressed: _triggerCustomSimulation,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3. Android Native Integration Callout
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: CyberColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CyberColors.primaryBorder, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.android, color: CyberColors.primaryBlue, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ANDROID NATIVE INTEGRATION HOOK',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: CyberColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'In physical production environments, native Android notifications are listened to via CyberNotificationListener.kt and forwarded to this Gemini pipeline via EventChannel.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: CyberColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 4. Firestore Audited Notifications History
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.history_edu_rounded, size: 16, color: CyberColors.primaryBlue),
                      const SizedBox(width: 6),
                      Text(
                        'FIRESTORE INSPECTION AUDIT LOG',
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
                      '${controller.history.length} SYNCED',
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
                        const Icon(Icons.notifications_none, color: CyberColors.textSecondary, size: 36),
                        const SizedBox(height: 10),
                        Text(
                          'No notifications simulated or recorded yet.',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: CyberColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...controller.history.map((notif) {
                  return NotificationHistoryTile(
                    notification: notif,
                    onTap: notif.isMalicious ? () => _showWarningPopup(context, notif) : null,
                  );
                }),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
