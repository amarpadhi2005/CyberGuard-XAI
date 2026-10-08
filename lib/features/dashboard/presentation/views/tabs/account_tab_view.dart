import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/cyber_colors.dart';
import '../../../../auth/presentation/controllers/auth_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../../../../core/widgets/cyber_button.dart';

class AccountTabView extends StatefulWidget {
  const AccountTabView({super.key});

  @override
  State<AccountTabView> createState() => _AccountTabViewState();
}

class _AccountTabViewState extends State<AccountTabView> {
  bool _pushNotifications = true;
  bool _sirenAlerts = true;
  bool _biometricVault = true;

  Future<void> _handleLogout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Terminate Active Session?',
          style: GoogleFonts.plusJakartaSans(
            color: CyberColors.danger,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        content: Text(
          'Disconnecting will pause local foreground AI defense telemetry until re-authentication.',
          style: GoogleFonts.plusJakartaSans(
            color: CyberColors.textSecondary,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                color: CyberColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: CyberColors.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(
              'Log Out',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final auth = context.read<AuthController>();
      await auth.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  void _showSubscriptionModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) => Container(
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
                  'CyberGuard Pro Enterprise',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: CyberColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: CyberColors.success.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'ACTIVE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: CyberColors.success,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Your subscription includes full Gemini 2.5 Flash threat reasoning, multi-device protection, and zero-day live threat intelligence.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: CyberColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            _buildBenefitRow(Icons.all_inclusive_rounded, 'Unlimited Multi-Vector Scans'),
            _buildBenefitRow(Icons.devices_rounded, 'Up to 5 Protected Endpoints'),
            _buildBenefitRow(Icons.bolt_rounded, 'Sub-40ms Neural Latency'),
            _buildBenefitRow(Icons.support_agent_rounded, '24/7 SecOps Priority Response'),
            const SizedBox(height: 20),
            CyberButton(
              text: 'Manage Billing on Supabase',
              onPressed: () => Navigator.pop(modalCtx),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: CyberColors.primary),
          const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: CyberColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final dashboard = context.watch<DashboardController>();
    final user = auth.currentUser;
    final displayName = user?.displayName ?? 'Alex Vance';
    final email = user?.email ?? 'alex.vance@enterprise-sec.io';
    const phone = '+1 (555) 382-9012';

    return Scaffold(
      backgroundColor: CyberColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'Account & Settings',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: CyberColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          children: [
            // Profile Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                  Stack(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: CyberColors.primaryGradient,
                        ),
                        child: const Center(
                          child: Icon(Icons.person_rounded, size: 36, color: Colors.white),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: CyberColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, size: 10, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              displayName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: CyberColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.verified_rounded, size: 16, color: CyberColors.primary),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: CyberColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          phone,
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

            // Subscription Card
            InkWell(
              onTap: _showSubscriptionModal,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2563EB),
                      Color(0xFF1D4ED8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CyberGuard Pro Enterprise',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Active Tier • Zero-Trust Heuristics',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Security Score Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: CyberColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.speed_rounded, color: CyberColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Device Security Score',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: CyberColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Hardened • Optimal Protection',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: CyberColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    '${(dashboard.cyberScore / 10).round()}/100',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: CyberColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Connected Devices
            Text(
              'Connected Devices',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: CyberColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.phone_android_rounded, color: CyberColors.primary, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Realme 12 Pro+ 5G',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: CyberColors.textPrimary,
                              ),
                            ),
                            Text(
                              'This Device • Armed & Telemetry Active',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: CyberColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: CyberColors.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'PRIMARY',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: CyberColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.laptop_mac_rounded, color: CyberColors.textSecondary, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MacBook Pro M3 Max',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: CyberColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Secondary Endpoint • Protected',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: CyberColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle_rounded, color: CyberColors.success, size: 16),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Settings & Preferences
            Text(
              'Preferences & Security',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: CyberColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      'Push Threat Notifications',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Instant alert when malicious URL or call is intercepted',
                      style: GoogleFonts.plusJakartaSans(fontSize: 10, color: CyberColors.textSecondary),
                    ),
                    value: _pushNotifications,
                    activeColor: CyberColors.primary,
                    onChanged: (val) => setState(() => _pushNotifications = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(
                      'Zero-Day Threat Siren',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Audible tone for critical ransomware and exploit threats',
                      style: GoogleFonts.plusJakartaSans(fontSize: 10, color: CyberColors.textSecondary),
                    ),
                    value: _sirenAlerts,
                    activeColor: CyberColors.primary,
                    onChanged: (val) => setState(() => _sirenAlerts = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(
                      'Biometric Security Vault',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Require fingerprint or face ID to view forensic logs',
                      style: GoogleFonts.plusJakartaSans(fontSize: 10, color: CyberColors.textSecondary),
                    ),
                    value: _biometricVault,
                    activeColor: CyberColors.primary,
                    onChanged: (val) => setState(() => _biometricVault = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Log Out Button
            CyberButton(
              text: 'Log Out of Active Session',
              variant: CyberButtonVariant.danger,
              icon: Icons.logout_rounded,
              onPressed: _handleLogout,
            ),

            const SizedBox(height: 12),

            Center(
              child: Text(
                'CyberGuard XAI • Enterprise Edition v2.5.0\nProtected by Supabase & Gemini 2.5',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: CyberColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
