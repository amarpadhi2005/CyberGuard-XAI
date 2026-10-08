import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../../../core/widgets/cyber_pressable.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../cyber_health/presentation/controllers/cyber_health_controller.dart';
import '../../../threat_history/domain/entities/threat_history_item.dart';
import '../../../threat_history/presentation/controllers/threat_history_controller.dart';
import '../../../xai_result/presentation/views/xai_result_screen.dart';
import '../../domain/entities/demo_simulation_scenario.dart';
import '../controllers/demo_mode_controller.dart';
import '../widgets/demo_scenario_card.dart';
import '../widgets/demo_simulation_runner_dialog.dart';

class DemoModeScreen extends StatefulWidget {
  const DemoModeScreen({super.key});

  @override
  State<DemoModeScreen> createState() => _DemoModeScreenState();
}

class _DemoModeScreenState extends State<DemoModeScreen> {
  ThreatCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      final userId = auth.currentUser?.uid ?? 'DEMO_USER_001';
      context.read<CyberHealthController>().loadScore(userId);
      context.read<ThreatHistoryController>().loadHistory(userId);
    });
  }

  void _triggerScenario(
    BuildContext context,
    DemoSimulationScenario scenario,
    String userId,
  ) async {
    final controller = context.read<DemoModeController>();

    // 1. Show the live simulation runner dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return Consumer<DemoModeController>(
          builder: (_, c, __) {
            return DemoSimulationRunnerDialog(
              scenario: scenario,
              currentStepIndex: c.currentStepIndex,
              statusMessage: c.statusMessage,
            );
          },
        );
      },
    );

    // 2. Execute simulation workflow (records ThreatHistory item + updates Health Score)
    final xaiModel = await controller.executeSimulation(
      context: context,
      scenario: scenario,
      userId: userId,
    );

    // 3. Dismiss runner dialog
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    // 4. Open Explainable AI Result Screen
    if (context.mounted && xaiModel != null) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => XaiResultScreen(initialResult: xaiModel),
        ),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: CyberColors.riskSafe, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Simulation finished: Threat History updated & Cyber Health Score adjusted.',
                    style: GoogleFonts.inter(fontSize: 12),
                  ),
                ),
              ],
            ),
            backgroundColor: CyberColors.darkBlueSurface,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final healthController = context.watch<CyberHealthController>();
    final historyController = context.watch<ThreatHistoryController>();
    final demoController = context.watch<DemoModeController>();

    final userId = auth.currentUser?.uid ?? 'DEMO_USER_001';
    final scenarios = demoController.scenarios.where((s) {
      if (_selectedCategory == null) return true;
      return s.category == _selectedCategory;
    }).toList();

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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.science_rounded,
                color: CyberColors.primaryBlue, size: 20),
            const SizedBox(width: 8),
            Text(
              'THREAT SIMULATION LAB',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: CyberColors.textPrimary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded,
                color: CyberColors.primaryBlue, size: 22),
            tooltip: 'Reset Cyber Health & History Baseline',
            onPressed: () async {
              await healthController.resetToBaseline(userId: userId);
              await historyController.reseedDemo(userId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Baseline restored: Health Score reset to 880 & default seeds restored.',
                    ),
                    backgroundColor: CyberColors.textPrimary,
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Hackathon Evaluation Hero Banner
              _buildHeroBanner(),

              const SizedBox(height: 16),

              // 2. Real-Time System Telemetry KPI Bar
              _buildLiveKpiHud(healthController, historyController),

              const SizedBox(height: 18),

              // 3. Category Filter Chips
              _buildCategoryFilterRow(demoController.scenarios),

              const SizedBox(height: 16),

              // 4. Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ATTACK VECTOR SIMULATION MATRIX',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: CyberColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: CyberColors.primarySoftBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: CyberColors.primaryBlue.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${scenarios.length} SCENARIOS',
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

              // 5. Scenarios List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: scenarios.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final scenario = scenarios[index];
                  return DemoScenarioCard(
                    scenario: scenario,
                    isBusy: demoController.isSimulating,
                    onTrigger: () =>
                        _triggerScenario(context, scenario, userId),
                  );
                },
              ),

              const SizedBox(height: 24),

              // 6. Transparent Sandbox Assurance Footer
              _buildSandboxFooter(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CyberColors.primarySoftBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CyberColors.primaryBlue.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: CyberColors.primaryBlue.withOpacity(0.3),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  'INTERACTIVE TEST HARNESS',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: CyberColors.primaryBlue,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: CyberColors.riskWarningBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'SANDBOX MODE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: CyberColors.riskWarning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Interactive Zero-Trust Attack Simulator',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: CyberColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Trigger realistic attack simulations across Phone, Email, QR, Web, Notification, and Deepfake vectors to observe how CyberGuard correlates telemetry in real time.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: CyberColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveKpiHud(
    CyberHealthController healthController,
    ThreatHistoryController historyController,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CyberColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CyberColors.borderSubtle, width: 1.0),
        boxShadow: CyberColors.cardShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Cyber Health Score
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_rounded,
                      size: 15, color: CyberColors.primaryBlue),
                  const SizedBox(width: 4),
                  Text(
                    '${healthController.score}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: CyberColors.primaryBlue,
                    ),
                  ),
                  Text(
                    ' / 1000',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      color: CyberColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                'CYBER HEALTH',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: CyberColors.textSecondary,
                ),
              ),
            ],
          ),

          Container(width: 1, height: 32, color: CyberColors.borderSubtle),

          // Total Scans in History
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.history_rounded,
                      size: 15, color: CyberColors.riskCritical),
                  const SizedBox(width: 4),
                  Text(
                    '${historyController.totalScans}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: CyberColors.riskCritical,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                'SCANS LOGGED',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: CyberColors.textSecondary,
                ),
              ),
            ],
          ),

          Container(width: 1, height: 32, color: CyberColors.borderSubtle),

          // Engine Status
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: CyberColors.riskSafe,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'GEMINI 2.5',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: CyberColors.riskSafe,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                'XAI REASONING',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: CyberColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilterRow(List<DemoSimulationScenario> allScenarios) {
    final categories = [
      null, // ALL
      ThreatCategory.phone,
      ThreatCategory.email,
      ThreatCategory.qr,
      ThreatCategory.website,
      ThreatCategory.notification,
      ThreatCategory.deepfake,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          final label = cat == null ? 'ALL VECTORS' : cat.label.toUpperCase();
          final icon = cat == null ? Icons.apps_rounded : cat.icon;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CyberPressable(
              onTap: () {
                setState(() {
                  _selectedCategory = cat;
                });
              },
              semanticLabel: 'Filter by $label',
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? CyberColors.primarySoftBg
                      : CyberColors.surfaceCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? CyberColors.primaryBlue
                        : CyberColors.borderSubtle,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 13,
                      color: isSelected
                          ? CyberColors.primaryBlue
                          : CyberColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected
                            ? CyberColors.primaryBlue
                            : CyberColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSandboxFooter() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CyberColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CyberColors.borderSubtle),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_outlined,
              size: 20, color: CyberColors.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Zero-Risk Quarantine Sandbox: Injected simulations run entirely in ephemeral memory with zero device exposure.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: CyberColors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
