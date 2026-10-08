import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/widgets/cyber_button.dart';

class PermissionItem {
  final String id;
  final String title;
  final String category;
  final String explanation;
  final IconData icon;
  final Color iconColor;
  bool isGranted;

  PermissionItem({
    required this.id,
    required this.title,
    required this.category,
    required this.explanation,
    required this.icon,
    required this.iconColor,
    this.isGranted = false,
  });
}

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final List<PermissionItem> _permissions = [
    PermissionItem(
      id: 'notification',
      title: 'Notification Sentinel',
      category: 'Real-time Alerts',
      explanation:
          'Intercepts and audits incoming SMS and push alerts in milliseconds to block phishing links and fraudulent OTP requests.',
      icon: Icons.notifications_active_rounded,
      iconColor: const Color(0xFF3B82F6),
      isGranted: true,
    ),
    PermissionItem(
      id: 'accessibility',
      title: 'Accessibility Sentinel',
      category: 'Zero-Day Shield',
      explanation:
          'Inspects active UI surfaces to prevent clickjacking, malicious app overlays, and unauthorized screen recording.',
      icon: Icons.accessibility_new_rounded,
      iconColor: const Color(0xFF6366F1),
      isGranted: true,
    ),
    PermissionItem(
      id: 'overlay',
      title: 'System Overlay Defense',
      category: 'Immediate Interception',
      explanation:
          'Projects instant defensive warning banners directly over fraudulent calls, malicious URLs, and compromised apps.',
      icon: Icons.layers_rounded,
      iconColor: const Color(0xFF0EA5E9),
      isGranted: true,
    ),
    PermissionItem(
      id: 'background',
      title: 'Background Protection',
      category: 'Persistent Engine',
      explanation:
          'Keeps the AI threat engine armed and scanning device telemetry continuously even when the screen is locked.',
      icon: Icons.security_rounded,
      iconColor: const Color(0xFF10B981),
      isGranted: true,
    ),
    PermissionItem(
      id: 'usage',
      title: 'Usage Access Telemetry',
      category: 'Anomaly Detection',
      explanation:
          'Detects hidden background app launches, battery drain spikes, and spyware beacons running without user consent.',
      icon: Icons.query_stats_rounded,
      iconColor: const Color(0xFFF59E0B),
      isGranted: false,
    ),
    PermissionItem(
      id: 'battery',
      title: 'Battery Optimization Exemption',
      category: 'Unbroken Defense',
      explanation:
          'Prevents Android OS aggressive sleep management from killing the active security daemon during standby.',
      icon: Icons.battery_charging_full_rounded,
      iconColor: const Color(0xFFEC4899),
      isGranted: false,
    ),
  ];

  int get _grantedCount => _permissions.where((p) => p.isGranted).length;

  void _proceedToDeviceScan() {
    Navigator.pushReplacementNamed(context, '/device_scan');
  }

  void _grantAll() {
    setState(() {
      for (final p in _permissions) {
        p.isGranted = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Security Permissions',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: CyberColors.textPrimary,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF4F8FC),
              Color(0xFFEFF6FF),
              Color(0xFFF8FAFC),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Header Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: CyberColors.cardBorder,
                          width: 1.2,
                        ),
                        boxShadow: CyberColors.cardShadow,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: CyberColors.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: CyberColors.primary.withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.admin_panel_settings_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Zero-Trust Permissions',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: CyberColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$_grantedCount of ${_permissions.length} core layers configured',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: CyberColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'REQUIRED SECURITY ACCESS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: CyberColors.textMuted,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Permission Cards
                    ..._permissions.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: item.isGranted
                                ? CyberColors.primary.withOpacity(0.3)
                                : CyberColors.cardBorder,
                            width: item.isGranted ? 1.4 : 1.0,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x050F172A),
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: item.iconColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      item.icon,
                                      color: item.iconColor,
                                      size: 22,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: CyberColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        item.category,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: item.iconColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch.adaptive(
                                  value: item.isGranted,
                                  activeColor: CyberColors.primary,
                                  onChanged: (val) {
                                    setState(() {
                                      item.isGranted = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.explanation,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                height: 1.4,
                                fontWeight: FontWeight.w400,
                                color: CyberColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Bottom Floating Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A0F172A),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
                border: Border(
                  top: BorderSide(
                    color: CyberColors.cardBorder,
                    width: 1.0,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    if (_grantedCount < _permissions.length) ...[
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: _grantAll,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'Grant All',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: CyberColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 2,
                      child: CyberButton(
                        text: 'Continue to Device Scan',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: _proceedToDeviceScan,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
