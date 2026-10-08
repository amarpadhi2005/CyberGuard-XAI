import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/cyber_colors.dart';
import '../../../../auth/presentation/controllers/auth_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../../../../core/widgets/cyber_pressable.dart';

class HomeTabView extends StatelessWidget {
  final VoidCallback onQuickScan;
  final VoidCallback onDeepScan;
  final VoidCallback onOpenTips;

  const HomeTabView({
    super.key,
    required this.onQuickScan,
    required this.onDeepScan,
    required this.onOpenTips,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final dashboard = context.watch<DashboardController>();
    final user = auth.currentUser;
    final displayName = user?.displayName ?? 'Alex Vance';

    return Scaffold(
      backgroundColor: CyberColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 600));
          },
          color: CyberColors.primary,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Top Header Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: CyberColors.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: CyberColors.primary.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.shield_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getGreeting(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: CyberColors.textSecondary,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    displayName,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: CyberColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.verified_rounded,
                                    size: 16,
                                    color: CyberColors.primary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      // SOS Quick Emergency Button
                      CyberPressable(
                        onTap: () => Navigator.pushNamed(context, '/emergency-sos'),
                        semanticLabel: 'Emergency SOS Crisis Relay',
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: CyberColors.danger.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.emergency_rounded,
                                size: 16,
                                color: CyberColors.danger,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'SOS',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: CyberColors.danger,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Main Dashboard Body
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 1. Security Score Card (Commercial Look)
                    _buildSecurityScoreCard(context, dashboard),

                    const SizedBox(height: 16),

                    // 2. AI Protection Status Bar
                    _buildProtectionStatusBar(dashboard),

                    const SizedBox(height: 16),

                    // 3. Today's Threat Telemetry
                    _buildTodayThreatsSummary(dashboard),

                    const SizedBox(height: 20),

                    // 4. Feature Hub Heading
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Security Services & Tools',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: CyberColors.textPrimary,
                          ),
                        ),
                        Text(
                          '12 Modules Armed',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: CyberColors.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 5. Grid of Cybersecurity Services
                    _buildServicesGrid(context),

                    const SizedBox(height: 24),

                    // 6. Recent Activity Feed
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Threat Activity',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: CyberColors.textPrimary,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pushNamed(context, '/threat-history'),
                          child: Text(
                            'View All',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: CyberColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    _buildRecentActivityList(dashboard),

                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityScoreCard(BuildContext context, DashboardController dashboard) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF2563EB),
            Color(0xFF3B82F6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'ENTERPRISE POSTURE',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF4ADE80),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'LOW RISK',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Score Radial
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 74,
                    height: 74,
                    child: CircularProgressIndicator(
                      value: dashboard.cyberScore / 1000,
                      strokeWidth: 7,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(dashboard.cyberScore / 10).round()}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '/100',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Device is Protected',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Real-time neural heuristics blocking phishing, rogue apps & telephony attacks.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        height: 1.4,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Sub metrics breakdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSubScoreItem('Identity', '98%'),
                Container(width: 1, height: 20, color: Colors.white.withOpacity(0.2)),
                _buildSubScoreItem('Network', '91%'),
                Container(width: 1, height: 20, color: Colors.white.withOpacity(0.2)),
                _buildSubScoreItem('Device', '94%'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Action Buttons: Quick Scan & Deep Scan
          Row(
            children: [
              Expanded(
                child: CyberPressable(
                  onTap: onQuickScan,
                  semanticLabel: 'Quick Scan',
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bolt_rounded, size: 18, color: Color(0xFF1E3A8A)),
                        const SizedBox(width: 6),
                        Text(
                          'Quick Scan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E3A8A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CyberPressable(
                  onTap: onDeepScan,
                  semanticLabel: 'Deep Scan',
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.radar_rounded, size: 18, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'Deep Scan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubScoreItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildProtectionStatusBar(DashboardController dashboard) {
    final active = dashboard.isShieldActive;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? CyberColors.success.withOpacity(0.12)
                  : CyberColors.danger.withOpacity(0.12),
            ),
            child: Icon(
              active ? Icons.shield_rounded : Icons.gpp_maybe_rounded,
              color: active ? CyberColors.success : CyberColors.danger,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  active ? 'Zero-Trust Shield Active' : 'Shield Disengaged',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: CyberColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  active ? 'Real-time telemetry & background protection on' : 'Device at risk',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: CyberColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: active,
            onChanged: (_) => dashboard.toggleProtectionShield(),
            activeColor: CyberColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayThreatsSummary(DashboardController dashboard) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: "Today's Threats",
            value: '${dashboard.threatsBlockedToday}',
            subtitle: 'Blocked & defanged',
            color: CyberColors.primary,
            icon: Icons.security_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            title: 'Active Breaches',
            value: '${dashboard.activeBreaches}',
            subtitle: 'Zero compromises',
            color: CyberColors.success,
            icon: Icons.check_circle_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: CyberColors.textSecondary,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: CyberColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    final services = [
      _ServiceItem(
        title: 'Link Scanner',
        subtitle: 'Detect phishing & typosquats',
        icon: Icons.link_rounded,
        color: const Color(0xFF2563EB),
        route: '/url-scanner',
      ),
      _ServiceItem(
        title: 'QR Sentinel',
        subtitle: 'Quishing & redirect defense',
        icon: Icons.qr_code_scanner_rounded,
        color: const Color(0xFF7C3AED),
        route: '/qr-scanner',
      ),
      _ServiceItem(
        title: 'Scam Call Defense',
        subtitle: 'Voice clone & spoof blocker',
        icon: Icons.phone_callback_rounded,
        color: const Color(0xFF0D9488),
        route: '/scam-call',
      ),
      _ServiceItem(
        title: 'Notification Guard',
        subtitle: 'Inspect rogue SMS & push',
        icon: Icons.notifications_active_rounded,
        color: const Color(0xFFD97706),
        route: '/notifications',
      ),
      _ServiceItem(
        title: 'Cyber Health',
        subtitle: 'Password hygiene & leaks',
        icon: Icons.health_and_safety_rounded,
        color: const Color(0xFF059669),
        route: '/cyber-health',
      ),
      _ServiceItem(
        title: 'Cyber Twin AI',
        subtitle: 'Multi-vector threat DNA',
        icon: Icons.hub_rounded,
        color: const Color(0xFFE11D48),
        route: '/cyber-twin',
      ),
      _ServiceItem(
        title: 'App Permissions',
        subtitle: 'Audit camera & mic access',
        icon: Icons.admin_panel_settings_rounded,
        color: const Color(0xFF4F46E5),
        onTap: () => Navigator.pushNamed(context, '/permissions'),
      ),
      _ServiceItem(
        title: 'Demo Attack Lab',
        subtitle: 'Simulate 6 attack vectors',
        icon: Icons.science_rounded,
        color: const Color(0xFF9333EA),
        route: '/demo-mode',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final item = services[index];
        return InkWell(
          onTap: item.onTap ?? () => Navigator.pushNamed(context, item.route!),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: item.color, size: 20),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: CyberColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: CyberColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivityList(DashboardController dashboard) {
    final alerts = dashboard.alerts.take(3).toList();

    return Column(
      children: alerts.map((alert) {
        Color severityColor;
        switch (alert.severity) {
          case ThreatSeverity.critical:
            severityColor = CyberColors.danger;
            break;
          case ThreatSeverity.high:
            severityColor = const Color(0xFFF97316);
            break;
          case ThreatSeverity.medium:
            severityColor = CyberColors.warning;
            break;
          case ThreatSeverity.safe:
            severityColor = CyberColors.success;
            break;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: severityColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            alert.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: CyberColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          alert.timestamp,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: CyberColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${alert.vector} • ${alert.actionTaken}',
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
        );
      }).toList(),
    );
  }
}

class _ServiceItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? route;
  final VoidCallback? onTap;

  _ServiceItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.route,
    this.onTap,
  });
}
