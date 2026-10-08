import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/cyber_colors.dart';

class ProtectionTabView extends StatefulWidget {
  final VoidCallback onDeepScan;

  const ProtectionTabView({super.key, required this.onDeepScan});

  @override
  State<ProtectionTabView> createState() => _ProtectionTabViewState();
}

class _ProtectionTabViewState extends State<ProtectionTabView> {
  bool _webShield = true;
  bool _callShield = true;
  bool _qrShield = true;
  bool _notificationShield = true;
  bool _appAudit = true;
  bool _networkArmor = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: CyberColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'Protection Center',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: CyberColors.textPrimary,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: CyberColors.success.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CyberColors.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_rounded, size: 14, color: CyberColors.success),
                const SizedBox(width: 4),
                Text(
                  'ALL ARMED',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: CyberColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          children: [
            // Deep Scan Hero Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1E3A8A),
                    Color(0xFF2563EB),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.radar_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deep System Scan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Inspect all 16 vectors including root, mock location & unknown APKs.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: widget.onDeepScan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    child: Text(
                      'Scan',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Real-Time Defense Shields',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: CyberColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Zero-Trust heuristic analyzers running on-device with zero battery lag.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: CyberColors.textSecondary,
              ),
            ),

            const SizedBox(height: 16),

            _buildShieldTile(
              title: 'Web & Phishing Shield',
              description: 'Defangs malicious URLs, typosquatting domains & credential harvesting',
              icon: Icons.language_rounded,
              color: const Color(0xFF2563EB),
              value: _webShield,
              onChanged: (val) => setState(() => _webShield = val),
              route: '/url-scanner',
            ),
            const SizedBox(height: 12),

            _buildShieldTile(
              title: 'Scam Call & Voice Clone Sentinel',
              description: 'Detects synthetic AI voice cloning, impersonation & caller ID spoofing',
              icon: Icons.phone_callback_rounded,
              color: const Color(0xFF0D9488),
              value: _callShield,
              onChanged: (val) => setState(() => _callShield = val),
              route: '/scam-call',
            ),
            const SizedBox(height: 12),

            _buildShieldTile(
              title: 'Camera & QR Quishing Shield',
              description: 'Validates barcode intents before opening browser or payment gateways',
              icon: Icons.qr_code_scanner_rounded,
              color: const Color(0xFF7C3AED),
              value: _qrShield,
              onChanged: (val) => setState(() => _qrShield = val),
              route: '/qr-scanner',
            ),
            const SizedBox(height: 12),

            _buildShieldTile(
              title: 'SMS & Notification Sentinel',
              description: 'Interprets inbound WhatsApp and SMS messages for smishing payloads',
              icon: Icons.notifications_active_rounded,
              color: const Color(0xFFD97706),
              value: _notificationShield,
              onChanged: (val) => setState(() => _notificationShield = val),
              route: '/notifications',
            ),
            const SizedBox(height: 12),

            _buildShieldTile(
              title: 'App Permissions & Hardware Auditor',
              description: 'Prevents silent background camera, microphone and accessibility misuse',
              icon: Icons.admin_panel_settings_rounded,
              color: const Color(0xFF4F46E5),
              value: _appAudit,
              onChanged: (val) => setState(() => _appAudit = val),
              route: '/permissions',
            ),
            const SizedBox(height: 12),

            _buildShieldTile(
              title: 'Network & DNS Armor',
              description: 'Blocks insecure DNS leakages and protects against ARP poisoning',
              icon: Icons.wifi_protected_setup_rounded,
              color: const Color(0xFF059669),
              value: _networkArmor,
              onChanged: (val) => setState(() => _networkArmor = val),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildShieldTile({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? route,
  }) {
    return InkWell(
      onTap: route != null ? () => Navigator.pushNamed(context, route) : null,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: CyberColors.textPrimary,
                          ),
                        ),
                      ),
                      if (route != null)
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: Color(0xFF94A3B8),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
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
            const SizedBox(width: 8),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }
}
