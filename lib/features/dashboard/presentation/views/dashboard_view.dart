import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/widgets/cyber_error_boundary.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/cyber_bottom_nav_bar.dart';
import 'tabs/home_tab_view.dart';
import 'tabs/protection_tab_view.dart';
import 'tabs/history_tab_view.dart';
import 'tabs/account_tab_view.dart';
import '../../../assistant/presentation/views/assistant_screen.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _currentTabIndex = 0;

  void _triggerQuickScanModal() {
    final controller = context.read<DashboardController>();
    controller.startQuickScan();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _QuickScanModal(),
    );
  }

  void _launchDeepScan() {
    Navigator.pushNamed(context, '/device_scan');
  }

  void _showSecurityTipsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CyberGuard Security Tips',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: CyberColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTipItem(
              Icons.password_rounded,
              'Enable Passkeys & 2FA',
              'Use hardware or authenticator-based 2FA rather than SMS codes to avoid SIM swaps.',
            ),
            const SizedBox(height: 10),
            _buildTipItem(
              Icons.qr_code_scanner_rounded,
              'Inspect Dynamic QR Codes',
              'Never authorize banking transfers from public parking or street QR stickers.',
            ),
            const SizedBox(height: 10),
            _buildTipItem(
              Icons.phone_locked_rounded,
              'Hang Up on Urgent Authority Calls',
              'Scammers use AI voice synthesis and caller ID spoofing to create panic.',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: CyberColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: CyberColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: CyberColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: CyberColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.background,
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          FeatureErrorBoundary(
            featureName: 'Home',
            child: HomeTabView(
              onQuickScan: _triggerQuickScanModal,
              onDeepScan: _launchDeepScan,
              onOpenTips: _showSecurityTipsModal,
            ),
          ),
          FeatureErrorBoundary(
            featureName: 'Protection',
            child: ProtectionTabView(
              onDeepScan: _launchDeepScan,
            ),
          ),
          const FeatureErrorBoundary(
            featureName: 'Assistant',
            child: AssistantScreen(
              isEmbeddedInTab: true,
            ),
          ),
          const FeatureErrorBoundary(
            featureName: 'History',
            child: HistoryTabView(),
          ),
          const FeatureErrorBoundary(
            featureName: 'Account',
            child: AccountTabView(),
          ),
        ],
      ),
      bottomNavigationBar: CyberBottomNavBar(
        currentIndex: _currentTabIndex,
        onTabSelected: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        onScanPressed: _triggerQuickScanModal,
      ),
    );
  }
}

class _QuickScanModal extends StatelessWidget {
  const _QuickScanModal();

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardController>(
      builder: (context, dashboard, child) {
        final isScanning = dashboard.isScanning;
        final progress = dashboard.scanProgress;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isScanning
                      ? CyberColors.primary.withOpacity(0.1)
                      : CyberColors.success.withOpacity(0.1),
                ),
                child: Center(
                  child: Icon(
                    isScanning ? Icons.bolt_rounded : Icons.check_circle_rounded,
                    size: 36,
                    color: isScanning ? CyberColors.primary : CyberColors.success,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isScanning ? 'Running AI Quick Scan...' : 'Quick Scan Complete',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: CyberColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isScanning
                    ? dashboard.scanStatusText
                    : 'All running apps and system permissions are secure.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: CyberColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              if (isScanning) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: const AlwaysStoppedAnimation<Color>(CyberColors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${(progress * 100).toInt()}% Analyzed',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: CyberColors.primary,
                  ),
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatPill('0 Threats Detected', CyberColors.success),
                    const SizedBox(width: 8),
                    _buildStatPill('128 Apps Checked', CyberColors.primary),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CyberColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
