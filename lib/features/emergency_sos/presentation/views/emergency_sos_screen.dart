import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../../../core/widgets/cyber_loading_indicator.dart';
import '../../../../core/widgets/cyber_pressable.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/emergency_sos_controller.dart';
import '../widgets/emergency_sos_button.dart';
import '../widgets/trusted_contacts_card.dart';
import '../widgets/location_sharing_tile.dart';
import '../widgets/threat_screenshot_picker.dart';
import '../widgets/report_scam_card.dart';
import '../widgets/incident_report_dialog.dart';

class EmergencySosScreen extends StatefulWidget {
  const EmergencySosScreen({super.key});

  @override
  State<EmergencySosScreen> createState() => _EmergencySosScreenState();
}

class _EmergencySosScreenState extends State<EmergencySosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      final userId = auth.currentUser?.uid ?? 'DEMO_USER_001';
      context.read<EmergencySosController>().loadData(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final controller = context.watch<EmergencySosController>();
    final userId = auth.currentUser?.uid ?? 'DEMO_USER_001';
    final state = controller.state;
    final isActive = controller.isSosActive;

    return Scaffold(
      backgroundColor: CyberColors.background,
      appBar: AppBar(
        backgroundColor: CyberColors.surfaceCard,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: const Border(
          bottom: BorderSide(color: CyberColors.borderSubtle, width: 1),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: CyberColors.textPrimary,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.emergency_rounded,
                  color: CyberColors.riskCritical,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'EMERGENCY S.O.S.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: CyberColors.textPrimary,
                  ),
                ),
              ],
            ),
            Text(
              'HIGH-PRIORITY INCIDENT ESCALATION',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: CyberColors.riskCritical,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          if (isActive)
            TextButton(
              onPressed: () => controller.resetSosActiveState(),
              child: Text(
                'STAND DOWN',
                style: GoogleFonts.plusJakartaSans(
                  color: CyberColors.riskCritical,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: controller.isLoading && state.trustedContacts.isEmpty
          ? const Center(
              child: CyberLoadingIndicator(
                size: 72,
                message: 'ESTABLISHING SECURE EMERGENCY RELAY...',
              ),
            )
          : RefreshIndicator(
              color: CyberColors.emergencyRed,
              backgroundColor: CyberColors.darkBlueSurface,
              onRefresh: () => controller.loadData(userId),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Status Telemetry Banner
                    _buildStatusBanner(context, controller),

                    const SizedBox(height: 20),

                    // 2. High-Impact Pulsating Emergency SOS Button
                    EmergencySosButton(
                      isSosActive: controller.isSosActive,
                      isTriggering: controller.isTriggering,
                      countdownSeconds: controller.countdownSeconds,
                      onTrigger: () => controller.startEmergencyCountdown(userId),
                      onCancel: () => controller.cancelEmergencySos(),
                    ),

                    const SizedBox(height: 24),

                    // 3. Share Location Toggle Tile
                    LocationSharingTile(
                      isLocationShared: controller.isLocationShared,
                      coordinates: state.currentLocationCoordinates,
                      address: state.currentLocationAddress,
                      onToggle: () => controller.toggleLocationSharing(),
                    ),

                    const SizedBox(height: 14),

                    // 4. Share Threat Screenshot Evidence Picker
                    ThreatScreenshotPicker(
                      hasScreenshot: controller.hasThreatScreenshot,
                      screenshotName: state.threatScreenshotName,
                      onToggle: () => controller.toggleThreatScreenshot(),
                    ),

                    const SizedBox(height: 14),

                    // 5. Trusted Contacts Relay Card
                    TrustedContactsCard(
                      contacts: controller.trustedContacts,
                      onAddContact: (contact) =>
                          controller.addTrustedContact(userId, contact),
                      onRemoveContact: (contactId) =>
                          controller.removeTrustedContact(userId, contactId),
                    ),

                    const SizedBox(height: 14),

                    // 6. Report Scam & Instant Incident Generation Form
                    ReportScamCard(
                      onGenerateReport: ({
                        required String scamType,
                        required String scammerContact,
                        required String description,
                      }) async {
                        final report = await controller.dispatchImmediateSos(
                          userId,
                          scamType: scamType,
                          scammerContact: scammerContact,
                          description: description,
                        );
                        if (context.mounted) {
                          IncidentReportDialog.show(context, report);
                        }
                      },
                    ),

                    const SizedBox(height: 14),

                    // 7. Recent Incident Reports Log (Stored in Firestore)
                    if (controller.recentReports.isNotEmpty)
                      _buildRecentReportsList(context, controller),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatusBanner(
    BuildContext context,
    EmergencySosController controller,
  ) {
    final isActive = controller.isSosActive;
    final isTriggering = controller.isTriggering;

    Color borderColor;
    Color bgColor;
    Color iconColor;
    if (isActive) {
      borderColor = CyberColors.riskCritical.withOpacity(0.3);
      bgColor = CyberColors.riskCriticalBg;
      iconColor = CyberColors.riskCritical;
    } else if (isTriggering) {
      borderColor = CyberColors.riskWarning.withOpacity(0.4);
      bgColor = CyberColors.riskWarningBg;
      iconColor = CyberColors.riskWarning;
    } else {
      borderColor = CyberColors.borderSubtle;
      bgColor = CyberColors.surfaceCard;
      iconColor = CyberColors.riskSafe;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: CyberColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white
                  : (isTriggering ? Colors.white : CyberColors.riskSafeBg),
              shape: BoxShape.circle,
              border: Border.all(color: iconColor.withOpacity(0.3), width: 1),
            ),
            child: Icon(
              isActive ? Icons.crisis_alert_rounded : Icons.shield_rounded,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isActive ? 'EMERGENCY BEACON ACTIVE' : 'PERIMETER STATUS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: isActive
                            ? CyberColors.riskCritical
                            : CyberColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.white
                            : CyberColors.riskSafeBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isActive
                              ? CyberColors.riskCritical.withOpacity(0.3)
                              : CyberColors.riskSafe.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        isActive ? 'BEACON TRANSMITTING' : 'DEFENSE STANDBY',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? CyberColors.riskCritical
                              : CyberColors.riskSafe,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  controller.statusMessage,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: CyberColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReportsList(
    BuildContext context,
    EmergencySosController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CyberColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CyberColors.borderSubtle, width: 1),
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
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: CyberColors.riskCriticalBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.history_edu_rounded,
                      color: CyberColors.riskCritical,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'FIRESTORE INCIDENT LOG',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: CyberColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: CyberColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: CyberColors.borderSubtle),
                ),
                child: Text(
                  '${controller.recentReports.length} REPORTS LOGGED',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: CyberColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.recentReports.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final report = controller.recentReports[index];
              return CyberPressable(
                onTap: () => IncidentReportDialog.show(context, report),
                semanticLabel: 'View incident report ${report.incidentId}',
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CyberColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: CyberColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: CyberColors.riskCriticalBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: CyberColors.riskCritical,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  report.incidentId,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: CyberColors.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: CyberColors.riskCriticalBg,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: CyberColors.riskCritical.withOpacity(0.3),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    report.severity,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      color: CyberColors.riskCritical,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              report.scamType,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: CyberColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: CyberColors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
