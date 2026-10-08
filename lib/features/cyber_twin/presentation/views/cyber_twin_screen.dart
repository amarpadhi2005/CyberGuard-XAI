import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../../../core/widgets/cyber_loading_indicator.dart';
import '../../../../core/widgets/cyber_pressable.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/cyber_twin_controller.dart';
import '../../domain/entities/threat_dna_campaign.dart';
import '../widgets/cyber_twin_avatar_hud.dart';
import '../widgets/coordinated_scam_alert_banner.dart';
import '../widgets/hackathon_demo_panel.dart';
import '../widgets/threat_dna_card.dart';
import '../widgets/threat_campaign_timeline.dart';
import '../widgets/risk_trend_chart.dart';

class CyberTwinScreen extends StatefulWidget {
  const CyberTwinScreen({super.key});

  @override
  State<CyberTwinScreen> createState() => _CyberTwinScreenState();
}

class _CyberTwinScreenState extends State<CyberTwinScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      final userId = auth.currentUser?.uid ?? 'DEMO_USER_001';
      context.read<CyberTwinController>().loadCorrelation(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final controller = context.watch<CyberTwinController>();
    final userId = auth.currentUser?.uid ?? 'DEMO_USER_001';
    final state = controller.state;
    final campaign = controller.campaign;

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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: CyberColors.textPrimary,
            size: 20,
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
                  Icons.psychology_outlined,
                  color: CyberColors.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'CYBER TWIN // AI GUARDIAN',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: CyberColors.textPrimary,
                  ),
                ),
              ],
            ),
            Text(
              'CROSS-VECTOR THREAT CORRELATION',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: CyberColors.textSecondary,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: controller.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: CyberColors.primaryBlue,
                    ),
                  )
                : const Icon(
                    Icons.refresh_rounded,
                    color: CyberColors.primaryBlue,
                    size: 22,
                  ),
            tooltip: 'Re-correlate Events',
            onPressed: controller.isLoading
                ? null
                : () => controller.loadCorrelation(userId),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: controller.isLoading && state == null
          ? const Center(
              child: CyberLoadingIndicator(
                size: 72,
                message: 'CORRELATING MULTI-VECTOR THREAT ARTIFACTS...',
              ),
            )
          : RefreshIndicator(
              color: CyberColors.primaryBlue,
              backgroundColor: Colors.white,
              onRefresh: () => controller.loadCorrelation(userId),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Rotating Guardian Avatar HUD
                    if (state != null)
                      CyberTwinAvatarHud(state: state),

                    const SizedBox(height: 14),

                    // 2. Hackathon Demo Control Panel (Interactive for Judges)
                    HackathonDemoPanel(
                      currentStage: controller.simulationStage,
                      isAutoSimulating: controller.isAutoSimulating,
                      onSelectStage: (stage) =>
                          controller.setSimulationStage(stage, userId),
                      onStartLiveDemo: () =>
                          controller.startHackathonLiveDemo(userId),
                      timeWindowHours: state?.timeWindowHours ?? 24,
                      onSelectTimeWindow: (hours) =>
                          controller.setTimeWindow(hours, userId),
                    ),

                    const SizedBox(height: 14),

                    // 3. Coordinated Scam Alert Banner
                    if (campaign != null)
                      CoordinatedScamAlertBanner(
                        campaign: campaign,
                        isDetected: controller.isCoordinatedScamDetected,
                      ),

                    const SizedBox(height: 14),

                    // 4. Threat DNA Card
                    if (campaign != null)
                      ThreatDnaCard(campaign: campaign),

                    const SizedBox(height: 14),

                    // 5. Threat Timeline
                    if (campaign != null && campaign.timeline.isNotEmpty)
                      ThreatCampaignTimeline(timeline: campaign.timeline),

                    const SizedBox(height: 14),

                    // 6. Overall Risk Trend Chart
                    if (campaign != null && campaign.riskTrend.isNotEmpty)
                      RiskTrendChart(
                        trendPoints: campaign.riskTrend,
                        currentRiskScore: campaign.escalatedRiskScore,
                        escalationBoost: campaign.escalationBoost,
                      ),

                    const SizedBox(height: 14),

                    // 7. Recommended Playbook & Threat Neutralization Actions
                    if (campaign != null)
                      _buildPlaybookCard(context, campaign, controller, userId),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPlaybookCard(
    BuildContext context,
    ThreatDnaCampaign campaign,
    CyberTwinController controller,
    String userId,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: CyberColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CyberColors.borderSubtle,
          width: 1.0,
        ),
        boxShadow: const [CyberColors.cardShadow],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.security_rounded,
                  color: CyberColors.success,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'AI GUARDIAN DEFENSE PLAYBOOK',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: CyberColors.success,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            campaign.recommendedPlaybook,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: CyberColors.textPrimary,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),

          CyberPressable(
            onTap: () async {
              await controller.acknowledgeCampaign(userId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.verified_user_rounded,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Threat campaign acknowledged & neutralized.',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12),
                        ),
                      ],
                    ),
                    backgroundColor: CyberColors.textPrimary,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            semanticLabel: 'Neutralize and acknowledge threat campaign',
            child: Container(
              width: double.infinity,
              height: 46,
              decoration: BoxDecoration(
                color: CyberColors.primaryBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield_outlined, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'NEUTRALIZE & ACKNOWLEDGE THREAT',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
