import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/widgets/cyber_button.dart';
import '../../../../core/widgets/cyber_pressable.dart';
import '../../domain/entities/xai_result_model.dart';
import '../controllers/xai_result_controller.dart';
import '../widgets/xai_action_plan_card.dart';
import '../widgets/xai_breakdown_chart.dart';
import '../widgets/xai_evidence_list.dart';
import '../widgets/xai_gauges_section.dart';
import '../widgets/xai_plain_english_card.dart';

class XaiResultScreen extends StatefulWidget {
  final XaiResultModel? initialResult;

  const XaiResultScreen({super.key, this.initialResult});

  @override
  State<XaiResultScreen> createState() => _XaiResultScreenState();
}

class _XaiResultScreenState extends State<XaiResultScreen> {
  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context)?.settings.arguments as XaiResultModel?;
    final activeResult = widget.initialResult ?? routeArgs;

    return ChangeNotifierProvider<XaiResultController>(
      create: (_) => XaiResultController(initialResult: activeResult),
      child: const _XaiResultView(),
    );
  }
}

class _XaiResultView extends StatelessWidget {
  const _XaiResultView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<XaiResultController>();
    final result = controller.result;

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
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: CyberColors.textPrimary, size: 18),
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
              child: const Icon(Icons.auto_awesome_rounded, color: CyberColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'Explainable AI Forensics',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: CyberColors.textPrimary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded,
                color: CyberColors.primary, size: 18),
            tooltip: 'Copy Plain Summary',
            onPressed: () {
              Clipboard.setData(ClipboardData(
                text: 'CyberGuard XAI Report\n'
                    'Threat: ${result.threatType}\n'
                    'Risk: ${result.riskScore}/100 (${result.severity.label})\n'
                    'Target: ${result.target}\n'
                    'Explanation: ${result.plainEnglishSummary}',
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'XAI Report copied to clipboard',
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
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Audit Context & Presets (Horizontal Scroll)
              Text(
                controller.hasCustomResult
                    ? 'AUDIT CONTEXT / SIMULATION BENCHMARKS:'
                    : 'DEMO AUDIT SCENARIOS:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: CyberColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    if (controller.hasCustomResult)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CyberPressable(
                          onTap: controller.selectCustomResult,
                          semanticLabel: 'View custom analyzed URL target',
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: controller.selectedPresetIndex == -1
                                  ? CyberColors.softBlueBg
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: controller.selectedPresetIndex == -1
                                    ? CyberColors.primary
                                    : CyberColors.cardBorder,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_user_rounded,
                                    size: 14, color: controller.selectedPresetIndex == -1 ? CyberColors.primary : CyberColors.textSecondary),
                                const SizedBox(width: 6),
                                Text(
                                  'MY ANALYZED TARGET',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    color: controller.selectedPresetIndex == -1
                                        ? CyberColors.primary
                                        : CyberColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ...controller.presets.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final preset = entry.value;
                      final isSelected = controller.selectedPresetIndex == idx;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CyberPressable(
                          onTap: () => controller.selectPreset(idx),
                          semanticLabel:
                              'Select benchmark preset ${preset.category} ${preset.threatType}',
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? CyberColors.softBlueBg
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? CyberColors.primary
                                    : CyberColors.cardBorder,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${preset.category}: ',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: CyberColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  preset.threatType,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected
                                        ? CyberColors.primary
                                        : CyberColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Audience Mode Toggle (Non-Technical vs Technical)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: CyberColors.cardBgSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CyberColors.cardBorder,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildToggleTab(
                        label: 'PLAIN ENGLISH (ALL USERS)',
                        icon: Icons.people_outline_rounded,
                        isSelected: controller.isSimplifiedMode,
                        onTap: () => controller.setSimplifiedMode(true),
                      ),
                    ),
                    Expanded(
                      child: _buildToggleTab(
                        label: 'TECHNICAL TELEMETRY',
                        icon: Icons.terminal_rounded,
                        isSelected: !controller.isSimplifiedMode,
                        onTap: () => controller.setSimplifiedMode(false),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 3. Dual Radial Meters (Threat Type, Risk Score & Confidence)
              XaiGaugesSection(result: result),

              const SizedBox(height: 18),

              // 4. Plain English Explanations
              XaiPlainEnglishCard(result: result),

              const SizedBox(height: 18),

              // 5. Charts & Progress Bars: Factor Breakdown Weights
              XaiBreakdownChart(metrics: result.factorMetrics),

              const SizedBox(height: 18),

              // 6. Concrete Observed Evidence
              XaiEvidenceList(evidence: result.evidenceList),

              const SizedBox(height: 18),

              // 7. Recommended Action Plan
              XaiActionPlanCard(
                actions: result.recommendedActions,
                severity: result.severity,
              ),

              const SizedBox(height: 24),

              // 8. Bottom Action Buttons
              Row(
                children: [
                  Expanded(
                    child: CyberButton(
                      text: 'ASK AI ASSISTANT',
                      icon: Icons.auto_awesome_rounded,
                      variant: CyberButtonVariant.secondary,
                      onPressed: () {
                        Navigator.pushNamed(context, '/assistant');
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CyberButton(
                      text: 'DONE & DISMISS',
                      icon: Icons.check_circle_outline_rounded,
                      variant: CyberButtonVariant.primary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return CyberPressable(
      onTap: onTap,
      semanticLabel: 'Switch to $label mode',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: Color(0x0C0F172A),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
          border: isSelected
              ? Border.all(color: CyberColors.cardBorder, width: 1.0)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? CyberColors.primary : CyberColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 0.5,
                color: isSelected ? CyberColors.primary : CyberColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
