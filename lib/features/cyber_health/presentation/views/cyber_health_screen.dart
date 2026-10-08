import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../../../core/widgets/cyber_pressable.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/cyber_health_controller.dart';
import '../widgets/circular_health_gauge.dart';
import '../widgets/health_suggestions_card.dart';
import '../widgets/score_factors_timeline.dart';

class CyberHealthScreen extends StatefulWidget {
  const CyberHealthScreen({super.key});

  @override
  State<CyberHealthScreen> createState() => _CyberHealthScreenState();
}

class _CyberHealthScreenState extends State<CyberHealthScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      final userId = auth.currentUser?.uid ?? 'DEMO_USER_001';
      context.read<CyberHealthController>().loadScore(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final controller = context.watch<CyberHealthController>();
    final userId = auth.currentUser?.uid ?? 'DEMO_USER_001';
    final tier = controller.tier;
    final color = tier.color;

    return Scaffold(
      backgroundColor: CyberColors.background,
      appBar: AppBar(
        backgroundColor: CyberColors.darkBlueSurface.withOpacity(0.5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: CyberColors.neonCyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.speed_rounded,
                color: CyberColors.neonCyan, size: 20),
            const SizedBox(width: 8),
            Text(
              'CYBER HEALTH SCORE',
              style: GoogleFonts.rajdhani(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.8,
                color: CyberColors.textPrimary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: CyberColors.neonCyan, size: 22),
            tooltip: 'Reset Baseline (880 / 1000)',
            onPressed: () => controller.resetToBaseline(userId: userId),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Primary Health Score Gauge Card
              GlassmorphicContainer(
                borderRadius: 22,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                backgroundColor: CyberColors.darkBlueSurface.withOpacity(0.85),
                border: Border.all(color: color.withOpacity(0.5), width: 1.5),
                child: Column(
                  children: [
                    // Circular Progress Indicator
                    CircularHealthGauge(
                      score: controller.score,
                      maxScore: controller.maxScore,
                      tier: tier,
                      size: 210,
                    ),

                    const SizedBox(height: 16),

                    // Tier Subtitle
                    Text(
                      tier.subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: CyberColors.textMuted,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Shield Status Toggle Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: CyberColors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: CyberColors.darkBlueBorder, width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                controller.isShieldActive
                                    ? Icons.security_rounded
                                    : Icons.gpp_maybe_rounded,
                                color: controller.isShieldActive
                                    ? const Color(0xFF00FF9D)
                                    : CyberColors.riskCritical,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                controller.isShieldActive
                                    ? 'ACTIVE PERIMETER DEFENSE'
                                    : 'DEFENSE SHIELD DISABLED (-150 PTS)',
                                style: GoogleFonts.rajdhani(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: controller.isShieldActive
                                      ? const Color(0xFF00FF9D)
                                      : CyberColors.riskCritical,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: controller.isShieldActive,
                            activeColor: const Color(0xFF00FF9D),
                            activeTrackColor:
                                const Color(0xFF00FF9D).withOpacity(0.3),
                            inactiveThumbColor: CyberColors.riskCritical,
                            inactiveTrackColor:
                                CyberColors.riskCritical.withOpacity(0.3),
                            onChanged: (_) =>
                                controller.toggleShield(userId: userId),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Interactive Score Simulation HUD
              Text(
                'LIVE SCORE ENGINE CONTROLS',
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: CyberColors.neonCyan,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Simulate security events to test live circular gauge score increases and decreases:',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: CyberColors.textDark,
                ),
              ),
              const SizedBox(height: 10),

              // Increase Score Actions (Website, Scam, Protection)
              GlassmorphicContainer(
                borderRadius: 16,
                padding: const EdgeInsets.all(14),
                backgroundColor: CyberColors.darkBlueSurface.withOpacity(0.65),
                border: Border.all(
                  color: const Color(0xFF00FF9D).withOpacity(0.3),
                  width: 1,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.arrow_upward_rounded,
                            color: Color(0xFF00FF9D), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'INCREASE SCORE (POSITIVE HYGIENE)',
                          style: GoogleFonts.rajdhani(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: const Color(0xFF00FF9D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionChip(
                            label: 'SCAN WEBSITE',
                            delta: '+35',
                            isPositive: true,
                            icon: Icons.link_rounded,
                            onTap: () => controller.onScanWebsite(
                              url: 'https://paypal-auth.com',
                              userId: userId,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildActionChip(
                            label: 'REPORT SCAM',
                            delta: '+30',
                            isPositive: true,
                            icon: Icons.flag_rounded,
                            onTap: () => controller.onReportScam(
                              incident: 'IRS Robocall Spoof (+1 800 492-9182)',
                              userId: userId,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildActionChip(
                            label: 'ENABLE SHIELD',
                            delta: '+75',
                            isPositive: true,
                            icon: Icons.shield_rounded,
                            onTap: () =>
                                controller.onEnableProtection(userId: userId),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Decrease Score Actions (High-risk link, Protection disabled, Suspicious activity)
              GlassmorphicContainer(
                borderRadius: 16,
                padding: const EdgeInsets.all(14),
                backgroundColor: CyberColors.darkBlueSurface.withOpacity(0.65),
                border: Border.all(
                  color: CyberColors.riskCritical.withOpacity(0.3),
                  width: 1,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.arrow_downward_rounded,
                            color: CyberColors.riskCritical, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'DECREASE SCORE (RISK PENALTIES)',
                          style: GoogleFonts.rajdhani(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: CyberColors.riskCritical,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionChip(
                            label: 'HIGH-RISK LINK',
                            delta: '-100',
                            isPositive: false,
                            icon: Icons.warning_amber_rounded,
                            onTap: () => controller.onOpenHighRiskLink(
                              url: 'http://malware-drop-apk.ru',
                              userId: userId,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildActionChip(
                            label: 'DISABLE SHIELD',
                            delta: '-150',
                            isPositive: false,
                            icon: Icons.shield_outlined,
                            onTap: () =>
                                controller.onDisableProtection(userId: userId),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildActionChip(
                            label: 'SUSPICIOUS IOC',
                            delta: '-60',
                            isPositive: false,
                            icon: Icons.crisis_alert_rounded,
                            onTap: () => controller.onSuspiciousActivityDetected(
                              details: 'Anomalous SMS Wangiri call burst',
                              userId: userId,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. Suggestions Section
              HealthSuggestionsCard(
                suggestions: controller.suggestions,
                onActionPressed: (route) => Navigator.pushNamed(context, route),
              ),

              const SizedBox(height: 24),

              // 4. Audit Log Timeline
              ScoreFactorsTimeline(
                events: controller.history,
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required String label,
    required String delta,
    required bool isPositive,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final color = isPositive ? const Color(0xFF00FF9D) : CyberColors.riskCritical;

    return CyberPressable(
      onTap: onTap,
      semanticLabel: '$label: $delta points',
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.4), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.rajdhani(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: CyberColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '$delta PTS',
              style: GoogleFonts.rajdhani(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
